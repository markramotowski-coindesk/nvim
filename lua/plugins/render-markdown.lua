-- In-buffer markdown rendering (headings, bullets, checkboxes, tables).
-- Enable the lang.markdown extra instead if you also want LSP/formatting.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
    },
  },
}
