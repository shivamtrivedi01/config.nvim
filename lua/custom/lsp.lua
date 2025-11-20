local config = {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'single',
    source = 'always',
    header = '',
    prefix = '',
    suffix = '',
  },
}
vim.diagnostic.config(config)
-- }}}

-- Improve LSPs UI {{{
local icons = {
  Class = ' ',
  Color = ' ',
  Constant = ' ',
  Constructor = ' ',
  Enum = ' ',
  EnumMember = ' ',
  Event = ' ',
  Field = ' ',
  File = ' ',
  Folder = ' ',
  Function = '󰊕 ',
  Interface = ' ',
  Keyword = ' ',
  Method = 'ƒ ',
  Module = '󰏗 ',
  Property = ' ',
  Snippet = ' ',
  Struct = ' ',
  Text = ' ',
  Unit = ' ',
  Value = ' ',
  Variable = ' ',
}

local completion_kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(completion_kinds) do
  completion_kinds[i] = icons[kind] and icons[kind] .. kind or kind
end
-- }}}

-- Lsp capabilities and on_attach {{{
-- Here we grab default Neovim capabilities and extend them with ones we want on top
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.foldingRange = {
  dynamicRegistration = true,
  lineFoldingOnly = true,
}

capabilities.textDocument.semanticTokens.multilineTokenSupport = true
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local ok, diag = pcall(require, 'rj.extras.workspace-diagnostic')
    if ok then
      diag.populate_workspace_diagnostics(client, bufnr)
    end
  end,
})
-- }}}

-- Disable the default keybinds {{{
for _, bind in ipairs { 'grn', 'gra', 'gri', 'grr', 'grt' } do
  pcall(vim.keymap.del, 'n', bind)
end
-- }}}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

    -- Find references for the word under your cursor.
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

    -- Fuzzy find all the symbols in your current workspace.
    --  Similar to document symbols, except searches over your entire project.
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Servers {{{

-- Lua {{{
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.git', vim.uv.cwd() },
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
    },
  },
}
vim.lsp.enable 'lua_ls'
-- }}}

vim.lsp.config.basedpyright = {
  name = 'basedpyright',
  filetypes = { 'python' },
  cmd = { 'basedpyright-langserver', '--stdio' },
  settings = {
    python = {
      venvPath = vim.fn.expand '~' .. '/.virtualenvs',
    },
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        autoSearchPaths = true,
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'strict',
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = false,
        },
      },
    },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    -- local ok, venv = pcall(require, "rj.extras.venv")
    -- if ok then
    --   venv.setup()
    -- end
    local root = vim.fs.root(0, {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json',
      '.git',
      vim.uv.cwd(),
    })
    local client = vim.lsp.start(vim.tbl_extend('force', vim.lsp.config.basedpyright, { root_dir = root }), { attach = false })
    if client then
      vim.lsp.buf_attach_client(0, client)
    end
  end,
})

-- Go {{{
vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gotempl', 'gowork', 'gomod' },
  root_markers = { '.git', 'go.mod', 'go.work', vim.uv.cwd() },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      ['ui.inlayhint.hints'] = {
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
vim.lsp.enable 'gopls'
-- }}}

-- C/C++ {{{
vim.lsp.config.clangd = {
  cmd = {
    'clangd',
    '-j=' .. 2,
    '--background-index',
    '--clang-tidy',
    '--inlay-hints',
    '--fallback-style=llvm',
    '--all-scopes-completion',
    '--completion-style=detailed',
    '--header-insertion=iwyu',
    '--header-insertion-decorators',
    '--pch-storage=memory',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_markers = {
    'CMakeLists.txt',
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac',
    '.git',
    vim.uv.cwd(),
  },
}
vim.lsp.enable 'clangd'
-- }}}

-- Rust {{{
vim.lsp.config.rust_analyzer = {
  filetypes = { 'rust' },
  cmd = { 'rust-analyzer' },
  workspace_required = true,
  root_dir = function(buf, cb)
    local root = vim.fs.root(buf, { 'Cargo.toml', 'rust-project.json' })
    local out = vim.system({ 'cargo', 'metadata', '--no-deps', '--format-version', '1' }, { cwd = root }):wait()
    if out.code ~= 0 then
      return cb(root)
    end

    local ok, result = pcall(vim.json.decode, out.stdout)
    if ok and result.workspace_root then
      return cb(result.workspace_root)
    end

    return cb(root)
  end,
  settings = {
    autoformat = false,
    ['rust-analyzer'] = {
      check = {
        command = 'clippy',
      },
    },
  },
}
vim.lsp.enable 'rust_analyzer'
-- }}}

-- Typst {{{
vim.lsp.config.tinymist = {
  cmd = { 'tinymist' },
  filetypes = { 'typst' },
  root_markers = { '.git', vim.uv.cwd() },
}

vim.lsp.enable 'tinymist'
-- }}}

-- Bash {{{
vim.lsp.config.bashls = {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh', 'zsh' },
  root_markers = { '.git', vim.uv.cwd() },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    },
  },
}
vim.lsp.enable 'bashls'
-- }}}

-- Web-dev {{{
-- TSServer {{{
vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },

  init_options = {
    hostInfo = 'neovim',
  },
}
-- }}}

-- CSSls {{{
vim.lsp.config.cssls = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss' },
  root_markers = { 'package.json', '.git' },
  init_options = {
    provideFormatter = true,
  },
}
-- }}}

-- TailwindCss {{{
vim.lsp.config.tailwindcssls = {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'ejs',
    'html',
    'css',
    'scss',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'tailwind.config.ts',
    'postcss.config.js',
    'postcss.config.cjs',
    'postcss.config.mjs',
    'postcss.config.ts',
    'package.json',
    'node_modules',
  },
  settings = {
    tailwindCSS = {
      classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
      includeLanguages = {
        eelixir = 'html-eex',
        eruby = 'erb',
        htmlangular = 'html',
        templ = 'html',
      },
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidConfigPath = 'error',
        invalidScreen = 'error',
        invalidTailwindDirective = 'error',
        invalidVariant = 'error',
        recommendedVariantOrder = 'warning',
      },
      validate = true,
    },
  },
}
-- }}}

-- HTML {{{
vim.lsp.config.htmlls = {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },

  init_options = {
    configurationSection = { 'html', 'css', 'javascript' },
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    provideFormatter = true,
  },
}
-- }}}

-- PHP {{{
vim.lsp.config.intelephense = {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { '.git', 'composer.json' },
}
-- }}}

vim.lsp.enable { 'ts_ls', 'cssls', 'tailwindcssls', 'htmlls', 'intelephense' }

-- }}}

-- }}}

-- Start, Stop, Restart, Log commands {{{
vim.api.nvim_create_user_command('LspStart', function()
  vim.cmd.e()
end, { desc = 'Starts LSP clients in the current buffer' })

vim.api.nvim_create_user_command('LspStop', function(opts)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if opts.args == '' or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ': stopped')
    end
  end
end, {
  desc = 'Stop all LSP clients or a specific client attached to the current buffer.',
  nargs = '?',
  complete = function(_, _, _)
    local clients = vim.lsp.get_clients { bufnr = 0 }
    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    return client_names
  end,
})

vim.api.nvim_create_user_command('LspRestart', function()
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    client:stop(true)
    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
    end
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify 'Servers are stopped but havent been restarted'
  end
  timer:start(
    100,
    50,
    vim.schedule_wrap(function()
      for name, client in pairs(detach_clients) do
        local client_id = vim.lsp.start(client[1].config, { attach = false })
        if client_id then
          for _, buf in ipairs(client[2]) do
            vim.lsp.buf_attach_client(buf, client_id)
          end
          vim.notify(name .. ': restarted')
        end
        detach_clients[name] = nil
      end
      if next(detach_clients) == nil and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end, {
  desc = 'Restart all the language client(s) attached to the current buffer',
})

vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = 'Get all the lsp logs',
})

vim.api.nvim_create_user_command('LspInfo', function()
  vim.cmd 'silent checkhealth vim.lsp'
end, {
  desc = 'Get all the information about all LSP attached',
})
-- }}}

-- vim: fdm=marker:fdl=0
--- lsp.lua ends here
