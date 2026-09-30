return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      vim.opt.autoread = true
    end,
    keys = {
      { "<leader>oa", function() require("opencode").ask() end, desc = "Ask opencode" },
      { "<leader>ot", function() require("opencode").toggle() end, desc = "Toggle opencode" },
      { "<leader>on", function() require("opencode").command("session_new") end, desc = "New opencode session" },
      { "<leader>oy", function() require("opencode").command("messages_copy") end, desc = "Copy last opencode message" },
      { "<leader>os", function() require("opencode").select() end, mode = { "n", "v" }, desc = "Select opencode prompt" },
    },
  },
}
