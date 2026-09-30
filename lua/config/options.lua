-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/lazy.lua
-- Add any additional options here

-- Auto-reload files changed outside vim
vim.opt.autoread = true

-- Silently skip the swap-file ATTENTION dialog (E325); it errors out when
-- triggered from snacks picker's scheduled buffer jump
vim.opt.shortmess:append("A")

-- Double indentation (2 spaces → 4 spaces)
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Reload on focus (when switching back to vim window)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  callback = function()
    vim.cmd("checktime")
  end,
})

-- Ensure files end with a newline
vim.opt.fixendofline = true
vim.opt.endofline = true

-- Trailing whitespace is stripped by conform.nvim (lua/plugins/conform.lua),
-- which skips markdown and does not clobber the search register.

-- stylua.toml for this config sets indent_width = 2, so keep Lua at 2 rather
-- than the global 4 below. Go is unaffected (tabs).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("indent_overrides", { clear = true }),
  pattern = { "lua", "yaml", "json", "jsonc" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

-- Auto-save on lost focus
vim.api.nvim_create_autocmd("FocusLost", {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function()
    vim.cmd("silent! wa")
  end,
})
