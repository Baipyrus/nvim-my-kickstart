-- Fix oil absolute path to relative path conversion
vim.api.nvim_create_augroup('OilRelPathFix', {})
vim.api.nvim_create_autocmd('BufLeave', {
  group = 'OilRelPathFix',
  pattern = 'oil:///*',
  callback = function()
    vim.cmd 'cd .'
  end,
})

return {
  'stevearc/oil.nvim',
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup({
      view_options = {
        show_hidden = true
      }
    })
    vim.keymap.set('n', '<leader>fe', require('oil').open, { desc = '[F]ile [E]xplorer' })
  end,
}
