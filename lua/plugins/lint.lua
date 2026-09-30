-- Lint HTML on save with markuplint (spec-aware: catches invalid nesting,
-- orphaned end tags, bad ARIA — things regex-era linters miss).
-- LazyVim's nvim-lint spec already wires the BufWritePost/BufReadPost/InsertLeave
-- autocmds; this just registers the linter for the html filetype.
--
-- Binary: npm install -g markuplint
-- Per-project rules live in .markuplintrc
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      html = { "markuplint" },
    },
  },
}
