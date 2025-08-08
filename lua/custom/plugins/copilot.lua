return {
  {
    'zbirenbaum/copilot.lua',
    dependencies = {
      'giuxtaposition/blink-cmp-copilot', -- this is also added to blink.cmp config in the init.lua file
    },
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },
}
