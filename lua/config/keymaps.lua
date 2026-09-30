-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "Toggle Claude Code" })

-- Double escape to close window or switch to previous tab
local log_file = vim.fn.expand("~/.nvim_keybind.log")
local last_call = 0

local function log_message(msg)
  local file = io.open(log_file, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. msg .. "\n")
    file:close()
  end
end

-- opts.bang: discard unsaved changes instead of writing first
-- opts.debounce: swallow repeat calls within 500ms (for the double-Esc mapping,
-- which can fire twice; :q must never be swallowed)
local function close_or_prev_tab(opts)
  opts = opts or {}
  if opts.debounce then
    local now = vim.loop.now()
    if now - last_call < 500 then
      log_message("Debounce: ignoring call within 500ms")
      return
    end
    last_call = now
  end
  local force = opts.bang and "!" or ""

  local tab_count = vim.fn.tabpagenr("$")
  local win_count = vim.fn.winnr("$")
  local buf_count = vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 }))

  log_message("close_or_prev_tab called: tabs=" .. tab_count .. ", windows=" .. win_count .. ", buffers=" .. buf_count)

  if opts.bang then
    log_message("Bang given, discarding changes")
  elseif not vim.bo.readonly then
    log_message("Saving buffer before action")
    pcall(vim.cmd, "silent! write")
  else
    log_message("Buffer is read-only, skipping save")
  end

  if buf_count > 1 then
    -- Snacks.bufdelete is what the bufferline "x" uses: switches windows off the
    -- buffer safely (skipping viewers like netrw) so the layout never collapses.
    require("snacks.bufdelete").delete({ force = opts.bang })
    log_message("Closed buffer with snacks.bufdelete")
  elseif win_count > 1 then
    log_message("Attempting to close window")
    local success, err = pcall(vim.cmd, "close" .. force)
    if not success then
      log_message("Close failed: " .. tostring(err))
    else
      log_message("Window closed successfully")
    end
  else
    log_message("Quitting application")
    vim.cmd("quit" .. force)
  end
end

vim.keymap.set("n", "<Esc><Esc>", function()
  close_or_prev_tab({ debounce = true })
end, { desc = "Close window or go to previous tab" })
vim.keymap.set("t", "<Esc><Esc>", function()
  log_message("Double escape in terminal mode")
  vim.cmd("stopinsert")
  close_or_prev_tab({ debounce = true })
end, { desc = "Close window or go to previous tab" })

vim.keymap.set("n", "<leader>tm", "<cmd>!go mod tidy<CR>", { desc = "Go mod tidy" })

-- Run the Go test under the cursor (subtests resolved via treesitter, nlopt
-- CGO flags included when the package needs them).
vim.keymap.set("n", "<leader>gt", function()
  require("config.gotest").run()
end, { desc = "Go: run test under cursor" })

-- Route :q / :q! through close_or_prev_tab so closing the last split does not
-- exit Neovim while other buffers are still open.
vim.api.nvim_create_user_command("Q", function(cmd)
  close_or_prev_tab({ bang = cmd.bang })
end, { bang = true })

-- Only expand when ':q' is the entire command line, so ':g/q/d', ':qa' and
-- friends are left alone.
vim.cmd([[cnoreabbrev <expr> q (getcmdtype() ==# ':' && getcmdline() ==# 'q') ? 'Q' : 'q']])
