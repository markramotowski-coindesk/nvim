-- Run the Go test under the cursor, resolving CGO (nlopt) needs and subtests.
--
-- Resolves what to run with treesitter:
--   - the enclosing `func TestXxx` / `BenchmarkXxx` declaration
--   - the chain of enclosing `t.Run("sub", ...)` calls, giving
--     `-run '^TestX$/^sub1$/^sub2$'`. Every element is anchored separately;
--     see the comment in M.command for why a single wrapping ^...$ silently
--     runs sibling test functions too.
--
-- CGO: packages importing github.com/go-nlopt/nlopt (`pkg/ivsurface/*` via
-- slsqp) fail to link without libnlopt. CGO_LDFLAGS/rpath are set always —
-- they are harmless for pure-Go packages — while `-tags` gets `nlopt` added
-- only when the package (any *.go in the dir) references nlopt: an import or
-- a build constraint. gopls is always set so
-- `//go:build integration || gopls` files compile in editor-driven runs.

local M = {}

--- Extract the name literal from a `t.Run("name", ...)` call node.
--- Returns nil for any call whose first argument is not a string literal —
--- a plain function call, or `t.Run(tt.name, ...)` in a table-driven loop,
--- whose name is only known at runtime.
---@param call TSNode
---@return string?
local function run_name(call)
  -- the "arguments" field is the argument_list wrapper, not the args
  -- themselves; the first argument is its first *named* child
  local arg_list = call:field("arguments")[1]
  if not arg_list then
    return nil
  end
  local interpreted = arg_list:named_child(0)
  if not interpreted then
    return nil
  end
  -- tree-sitter-go may nest the first arg in a parenthesized_expression
  while interpreted:type() == "parenthesized_expression" do
    local child = interpreted:named_child(0)
    if not child then
      return nil
    end
    interpreted = child
  end
  if interpreted:type() ~= "interpreted_string_literal" then
    return nil
  end
  local raw = vim.treesitter.get_node_text(interpreted, 0)
  -- strip surrounding quotes and escape sequences the way go test expects
  return (raw:gsub('^"(.*)"$', "%1"))
end

--- Collect the t.Run names enclosing the cursor, outermost first, so
--- `-run` can be built as TestParent/outer/inner.
---
--- Intent: land the cursor anywhere on (or inside) a `t.Run("name", ...)` and
--- run only that subtest. Two things make that work:
---
---  1. Resolution starts at the line's first non-blank column, not the real
---     cursor column. Sitting at column 0 of `\tt.Run("x", ...)` puts the
---     cursor on the indent, where the deepest treesitter node is the
---     enclosing statement_list — an ancestor of the call, so walking up from
---     it never sees the call and the whole parent test would run instead.
---     Anchoring to the first non-blank puts us on the `t` identifier, whose
---     ancestors do include the call.
---
---  2. A call counts no matter which child we arrived from. The old code only
---     accepted the case where we came up through the first argument (i.e. the
---     cursor was literally inside the "name" string), which is why being on
---     the call itself silently fell back to the parent test.
---
--- Calls whose first argument is not a string literal (`t.Run(tt.name, ...)`)
--- yield no name and are skipped, so a table-driven case resolves to its
--- enclosing named subtest rather than an unrunnable pattern.
---@param row integer 1-based cursor line
---@return string[] names outermost first
local function enclosing_run_names(row)
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
  local first_non_blank = #(line:match("^%s*") or "")
  local node = vim.treesitter.get_node({ pos = { row - 1, first_non_blank } })

  local names = {}
  while node do
    local name = node:type() == "call_expression" and run_name(node) or nil
    if name then
      table.insert(names, 1, name) -- prepend: ancestors are innermost first
    end
    node = node:parent()
  end
  return names
end

--- Find the enclosing func declaration whose name starts with Test/Benchmark.
---@param cursor_node TSNode
---@return string? test_name
local function enclosing_test_func(cursor_node)
  local node = cursor_node
  while node do
    if node:type() == "function_declaration" then
      local name_node = node:field("name")[1]
      if name_node then
        local name = vim.treesitter.get_node_text(name_node, 0)
        if name:match("^Test") or name:match("^Benchmark") then
          return name
        end
      end
      return nil -- inside a non-test func; no need to walk further
    end
    node = node:parent()
  end
  return nil
end

--- True when any file in dir references nlopt — an import of
--- github.com/go-nlopt/nlopt or a build constraint mentioning it.
---@param dir string package directory
---@return boolean
local function needs_nlopt_tag(dir)
  for _, name in ipairs(vim.fn.glob(dir .. "/*.go", false, true)) do
    local fh = io.open(name, "r")
    if fh then
      for line in fh:lines() do
        if line:match("nlopt") then
          fh:close()
          return true
        end
      end
      fh:close()
    end
  end
  return false
end

--- Build the shell command to run the test under the cursor.
---@return string? cmd nil when cursor is not inside a test
function M.command()
  local node = vim.treesitter.get_node({ ignore_injections = false })
  if not node then
    return nil
  end

  local test_name = enclosing_test_func(node)
  if not test_name then
    return nil
  end

  local pattern = { test_name }
  for _, sub in ipairs(enclosing_run_names(vim.fn.line("."))) do
    table.insert(pattern, sub)
  end

  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(file, ":h")

  local tags = { "gopls" }
  if needs_nlopt_tag(dir) then
    table.insert(tags, "nlopt")
  end

  -- expand $HOME here: inside the single-quoted ldflags the shell would
  -- leave it literal and the rpath would point at a nonexistent "$HOME" dir
  local home = os.getenv("HOME")
  local local_lib = home .. "/.local/lib"
  local ldflags = "-extldflags=-Wl,-rpath," .. local_lib
  local cgo_ldflags = 'CGO_LDFLAGS="-L' .. local_lib .. '"'

  -- Anchor EVERY element, not the joined string. Go splits -run on "/" and
  -- matches each element against that nesting level, so a single wrapping
  -- ^...$ only anchors the first and last: `^TestFoo/sub$` leaves TestFoo
  -- unanchored at its end and therefore also selects TestFooBar, TestFooBaz
  -- — whole sibling test funcs running alongside the one subtest you asked
  -- for. Per-element `^name$` pins each level exactly.
  --
  -- Go also rewrites spaces in subtest names to underscores, and matches the
  -- rewritten form, so a name with spaces never matches unless converted.
  -- Regex metacharacters in names are escaped for the same reason.
  local anchored = {}
  for _, element in ipairs(pattern) do
    local escaped = element:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?{}|\\]", "\\%0"):gsub(" ", "_")
    table.insert(anchored, "^" .. escaped .. "$")
  end
  local run = table.concat(anchored, "/")

  -- run inside the package dir: `go test .` needs no import-path resolution
  return string.format(
    "cd '%s' && %s go test -tags='%s' -ldflags='%s' -run '%s' -v .",
    dir,
    cgo_ldflags,
    table.concat(tags, ","),
    ldflags,
    run
  )
end

--- Run the resolved test in a reusable bottom terminal pane. The pane is
--- created once and reused: each run stops the previous job, clears the
--- buffer, and termopens the new command in place — the window never closes
--- or moves. Focus stays in the calling window (the pane never snaps).
--- Output is mirrored to a fixed log file every 500ms while a job runs, so
--- other terminals can `tail -f` it.
M._buf = nil
M._win = nil
M._timer = nil
M.LOGFILE = vim.fn.stdpath("cache") .. "/gotest.log"

-- Clean state when the pane's buffer is wiped. The window may outlive the
-- buffer (rerun swaps buffers via enew, which wipes the bufhidden=wipe
-- predecessor), so only drop the window handle if it is really gone.
local function on_buf_wipe(buf)
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      if M._buf == buf then
        M._buf = nil
      end
      if M._win and not vim.api.nvim_win_is_valid(M._win) then
        M._win = nil
      end
      if M._timer then
        M._timer:stop()
        M._timer:close()
        M._timer = nil
      end
    end,
  })
end

--- Flush terminal output to the log file. Terminal buffers expose their
--- screen content as unmodifiable lines; a channel read would be racy, so
--- snapshot the visible buffer instead (includes scrollback tail).
local function flush_log()
  if not (M._buf and vim.api.nvim_buf_is_valid(M._buf)) then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(M._buf, 0, -1, false)
  local fh = io.open(M.LOGFILE, "w")
  if fh then
    fh:write(table.concat(lines, "\n"))
    fh:close()
  end
end

--- Start the 500ms log writer for the current job.
local function start_log_writer()
  if M._timer then
    M._timer:stop()
    M._timer:close()
  end
  local fh = io.open(M.LOGFILE, "w")
  if fh then
    fh:close()
  end
  M._timer = vim.uv.new_timer()
  M._timer:start(500, 500, vim.schedule_wrap(flush_log))
end

--- Kill the pane outright: stop the job and close the window. Bound as the
--- buffer-local close so <Esc><Esc>/q remove the split instead of revealing
--- the code behind it.
local function kill_pane()
  if M._buf and vim.api.nvim_buf_is_valid(M._buf) then
    local jid = vim.b[M._buf].terminal_job_id
    if jid and jid > 0 then
      pcall(vim.fn.jobstop, jid)
    end
  end
  if M._win and vim.api.nvim_win_is_valid(M._win) then
    vim.api.nvim_win_close(M._win, true)
  end
  M._buf, M._win = nil, nil
end

--- Bind pane-kill keys buffer-locally so close attempts from inside the pane
--- remove the window itself.
local function bind_pane_close(buf)
  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "q", kill_pane, opts)
  vim.keymap.set("n", "<Esc><Esc>", kill_pane, opts)
end

--- Create the pane (bottom, ~40% height) and start the job in it.
local function open_pane(cmd)
  vim.cmd("botright 12split | terminal " .. cmd)
  M._win = vim.api.nvim_get_current_win()
  M._buf = vim.api.nvim_get_current_buf()
  -- auto-wipe when hidden so dead runs never pile up in the bufferline
  vim.bo[M._buf].bufhidden = "wipe"
  bind_pane_close(M._buf)
  vim.cmd("wincmd p") -- hand focus straight back to the calling window
  on_buf_wipe(M._buf)
end

--- Re-run cmd in the existing pane: stop the old job, then swap in a fresh
--- terminal buffer in the same window (termopen requires an unmodified
--- buffer, so reuse means a new buffer — the window itself is what's kept).
local function rerun(cmd)
  local jid = vim.b[M._buf].terminal_job_id
  if jid and jid > 0 then
    pcall(vim.fn.jobstop, jid)
  end
  local win = M._win
  vim.api.nvim_win_call(win, function()
    vim.cmd("enew") -- new empty buffer for this window
    vim.cmd("terminal " .. cmd)
  end)
  M._buf = vim.api.nvim_win_get_buf(win)
  -- auto-wipe when hidden so dead runs never pile up in the bufferline
  vim.bo[M._buf].bufhidden = "wipe"
  bind_pane_close(M._buf)
  on_buf_wipe(M._buf)
end

function M.run()
  local cmd = M.command()
  if not cmd then
    vim.notify("Not inside a Go test function", vim.log.levels.WARN)
    return
  end

  -- Drop the === PAUSE / === CONT pair t.Parallel() emits per subtest: pure
  -- scheduler noise that buries the results. --line-buffered keeps output
  -- streaming rather than arriving in one block at the end.
  cmd = cmd .. " 2>&1 | grep --line-buffered -vE '^[[:space:]]*=== (PAUSE|CONT)'"

  -- a closed window invalidates the pane; rebuild from scratch
  if M._win and not vim.api.nvim_win_is_valid(M._win) then
    M._buf, M._win = nil, nil
  end

  -- Pin the caller's window+cursor: the pane ops below shuffle the current
  -- window, which can leave the caller's cursor repositioned (observed as a
  -- jump off the test), breaking the next run's resolution.
  local caller_win = vim.api.nvim_get_current_win()
  local caller_buf = vim.api.nvim_get_current_buf()
  local caller_cursor = vim.api.nvim_win_get_cursor(caller_win)

  start_log_writer()

  if M._buf and vim.api.nvim_buf_is_valid(M._buf) then
    rerun(cmd)
  else
    open_pane(cmd)
  end

  if vim.api.nvim_win_is_valid(caller_win) then
    vim.api.nvim_set_current_win(caller_win)
    -- only restore the cursor in the buffer the caller came from
    if vim.api.nvim_get_current_buf() == caller_buf then
      vim.api.nvim_win_set_cursor(caller_win, caller_cursor)
    end
  end
end

return M
