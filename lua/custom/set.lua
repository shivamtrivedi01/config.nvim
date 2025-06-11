vim.g.maplocalleader = ' '
vim.o.nu = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false

vim.diagnostic.config { virtual_text = true }
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.smartindent = true

vim.o.clipboard = 'unnamedplus'

vim.o.wrap = false

vim.o.colorcolumn = '80'

vim.o.breakindent = true
vim.o.undodir = os.getenv 'HOME' .. '/.vim/undodir'
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10
vim.o.swapfile = false
vim.o.autoread = true
vim.o.termguicolors = true
vim.g.have_nerd_font = true
vim.o.isfname = vim.o.isfname .. ',@-@'
