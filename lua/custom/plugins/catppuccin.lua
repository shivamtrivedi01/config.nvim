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
          gitsigns = true,
          harpoon = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { 'italic' },
              hints = { 'italic' },
              warnings = { 'italic' },
              information = { 'italic' },
              ok = { 'italic' },
            },
            underlines = {
              errors = { 'underline' },
              hints = { 'underline' },
              warnings = { 'underline' },
              information = { 'underline' },
              ok = { 'underline' },
            },
            inlay_hints = {
              background = true,
            },
          },
          telescope = {
            enabled = true,
            -- style = "nvchad"
          },
          treesitter = true,

          -- Enable or disable transparency in specific plugins if needed
          -- e.g. for telescope, lualine, etc.
        },
      }
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
}
