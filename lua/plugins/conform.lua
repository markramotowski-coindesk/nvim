return {
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "gq",
        function()
          require("conform").format({ lsp_fallback = true })
        end,
        mode = { "n", "x" },
        desc = "Format buffer or selection",
      },
    },
    opts = {
      formatters_by_ft = {
        -- No real HTML formatter installed; lsp fallback formats via
        -- vscode-html-language-server.
        html = { lsp_format = "fallback" },
        go = { "goimports", "gofumpt" },
        -- "*" runs in addition to any filetype-specific formatters. Markdown is
        -- excluded because trailing double-space is a hard line break there.
        ["*"] = function(bufnr)
          if vim.bo[bufnr].filetype == "markdown" then
            return {}
          end
          return { "trim_whitespace" }
        end,
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "gq", mode = { "n", "x" }, desc = "Format buffer or selection" },
      },
    },
  },
}
