return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "javascript",
      "typescript",
      "vue",
      "html",
      "css",
      "json",
    },
    highlight = { enable = true },
  },
}
