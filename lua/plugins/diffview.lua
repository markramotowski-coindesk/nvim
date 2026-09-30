-- <leader>gd/gD/gh are already taken by the snacks git pickers and the gitsigns
-- "hunks" group, so diffview lives under its own <leader>gv prefix.
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Open (working tree)" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Close" },
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gvb", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gv", group = "diffview" },
      },
    },
  },
}
