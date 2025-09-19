return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      -- Change the default chat adapter
      cmd = {
        adapter = "ollama",
      },
      chat = {
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
