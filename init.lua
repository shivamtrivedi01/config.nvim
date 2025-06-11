require 'custom'
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'hl when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-hl-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('remove-whitespace-line-end', { clear = true }),
  pattern = '*',
  command = [[%s/\s\+$//e]],
})
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
