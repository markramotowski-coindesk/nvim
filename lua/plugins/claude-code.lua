return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    priority = 1000,
    opts = {
      command = "claude",
    },
    keys = {
      {
        "<leader>cc",
        "<cmd>ClaudeCode<CR>",
        desc = "Toggle Claude Code",
      },
    },
  },
}
