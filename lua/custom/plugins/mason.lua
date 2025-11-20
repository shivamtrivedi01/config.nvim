return {
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'mason-org/mason-lspconfig.nvim',
    },
    post_checkout = function()
      vim.cmd 'MasonToolsInstall'
    end,
    config = function()
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'mypy',
        'pylint',
        'isort',
        'black',
        'autopep8',
        'ruff',
        'prettier',
        -- language servers
        'basedpyright',
        'bashls',
        -- "clangd",
        'cssls',
        -- "gopls",
        'html-lsp',
        'lua_ls',
        -- "tailwindcss",
        'ts_ls',
        -- "tinymist",

        -- -- debug adapters
        -- "codelldb",

        -- formatters
        -- astyle missing
        -- "biome",
        -- "clang-format",
        -- "cmakelang",
        -- "goimports",
        'prettier',

        'stylua',

        -- linters
        -- "eslint_d",
        -- "luacheck",
        -- "proselint",
        -- "shellcheck",
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    end,
  },
}
