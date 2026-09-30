-- Cross-file edit history.
--
-- Neovim's built-in changelist (g; / g,) is per-buffer, and `bdelete` destroys
-- it along with the buffer -- which the <Esc><Esc> / :q mapping does constantly.
-- This keeps one global list of edit locations instead, so g; walks backwards
-- through recent edits regardless of which file they were in.

local M = {}

local history = {} -- most recent first
local index = 0 -- 0 = "not currently walking the list"
local MAX = 100

local function record()
  if vim.bo.buftype ~= "" then
    return
  end
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local top = history[1]
  -- Collapse repeated edits on the same line into one entry.
  if top and top.file == file and top.lnum == pos[1] then
    top.col = pos[2]
  else
    table.insert(history, 1, { file = file, lnum = pos[1], col = pos[2] })
    if #history > MAX then
      table.remove(history)
    end
  end
  index = 0
end

local function goto_entry(entry)
  if vim.fn.filereadable(entry.file) == 0 then
    return false
  end
  vim.cmd("normal! m'") -- leave a jumplist entry so <C-o> comes back
  if vim.api.nvim_buf_get_name(0) ~= entry.file then
    vim.cmd("edit " .. vim.fn.fnameescape(entry.file))
  end
  local lnum = math.min(entry.lnum, vim.api.nvim_buf_line_count(0))
  vim.api.nvim_win_set_cursor(0, { lnum, entry.col })
  return true
end

-- delta > 0 walks towards older edits, < 0 towards newer ones.
local function jump(delta)
  if #history == 0 then
    vim.notify("No edit history yet", vim.log.levels.INFO)
    return
  end
  local target = math.max(1, math.min(#history, index + delta))
  -- Skip entries whose file has since been deleted.
  while history[target] and not goto_entry(history[target]) do
    table.remove(history, target)
    if target > #history then
      target = #history
    end
  end
  if #history == 0 then
    vim.notify("No edit history yet", vim.log.levels.INFO)
    return
  end
  index = target
  vim.notify(("edit %d/%d"):format(index, #history), vim.log.levels.INFO)
end

function M.list()
  if #history == 0 then
    vim.notify("No edit history yet", vim.log.levels.INFO)
    return
  end
  local items = {}
  for _, e in ipairs(history) do
    table.insert(items, { filename = e.file, lnum = e.lnum, col = e.col + 1, text = "edit" })
  end
  vim.fn.setqflist({}, " ", { title = "Edit history", items = items })
  vim.cmd("copen")
end

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("edit_history", { clear = true }),
  callback = record,
})

vim.keymap.set("n", "g;", function()
  jump(1)
end, { desc = "Previous edit (cross-file)" })
vim.keymap.set("n", "g,", function()
  jump(-1)
end, { desc = "Next edit (cross-file)" })

vim.api.nvim_create_user_command("EditHistory", M.list, { desc = "Edit history in quickfix" })

return M
