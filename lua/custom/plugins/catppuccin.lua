return {
  {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        transparent_background = true,
        integrations = {
          -- Enable or disable transparency in specific plugins if needed
          -- e.g. for telescope, lualine, etc.
        },
      }
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
}
