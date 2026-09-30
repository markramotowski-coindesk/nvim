return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- Repos gate files behind build tags; cc-go appends `|| gopls` on
              -- ~94 of them so editors can still see them, and tags one file
              -- `nlopt`. Without these, those files get no completion or
              -- diagnostics -- gopls treats them as excluded from the build.
              buildFlags = { "-tags=gopls,nlopt" },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = false,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
              },
            },
          },
        },
      },
    },
  },
  {
    "nvim-lspconfig",
    init = function()
      -- goimports/gofumpt are handled by conform.nvim (see the Go extra), which
      -- formats the buffer. Running `goimports -w` here would only rewrite the
      -- file on disk before Vim writes the buffer over it.
      local tidying = {}
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("go_mod_tidy", { clear = true }),
        pattern = "*.go",
        callback = function(args)
          local dir = vim.fs.root(args.file, "go.mod")
          if not dir or tidying[dir] then
            return
          end
          tidying[dir] = true
          -- Async: `go mod tidy` on a large module takes seconds, and a
          -- synchronous vim.fn.system would block the editor on every save.
          vim.system({ "go", "mod", "tidy" }, { cwd = dir }, function(obj)
            tidying[dir] = nil
            if obj.code ~= 0 then
              vim.schedule(function()
                vim.notify("go mod tidy failed:\n" .. (obj.stderr or ""), vim.log.levels.WARN)
              end)
            end
          end)
        end,
      })
    end,
  },
}
