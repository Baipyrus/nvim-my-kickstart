-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Open terminal in current window
vim.keymap.set({ 'n', 'v' }, '<leader>to', '<cmd>term<cr>', { desc = '[T]erminal [O]pen' })

-- Disable arrow keys in normal mode
vim.keymap.set({ 'n', 'v' }, '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set({ 'n', 'v' }, '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ 'n', 'v' }, '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set({ 'n', 'v' }, '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Delete (currently selected) text without yanking it
vim.keymap.set({ 'n', 'v' }, '<leader>dny', '"_d', { desc = '[D]elete [N]o [Y]ank' })
-- Replace currently selected text with default register without yanking it
vim.keymap.set('v', '<leader>pny', '"_dP', { desc = '[P]aste [N]o [Y]ank' })

-- Populate CMD to prepare for change directory
vim.keymap.set('n', '<leader>cd ', ':cd ', { desc = 'Prepare CMD for [C]hange [D]irectory' })
-- Navigate to 'base' directory, the initial dir that nvim was run in
vim.keymap.set('n', '<leader>cdh', '<cmd>cd ' .. vim.g.base_dir .. '<cr>', { desc = '[C]hange [D]irectory to [H]ome' })
-- Automatically navigate to config directory
vim.keymap.set('n', '<leader>cdn', '<cmd>cd ' .. vim.fn.stdpath 'config' .. '<cr>', { desc = '[C]hange [D]irectory to [N]eovim' })

-- Delete current buffer without closing window
vim.keymap.set('n', '<leader>bd', '<cmd>bp<bar>sp<bar>bn<bar>bd<cr>', { desc = '[B]uffer [D]elete' })
-- Switch to between buffers
vim.keymap.set('n', '<leader>bp', '<cmd>bp<cr>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bn', '<cmd>bn<cr>', { desc = '[B]uffer [N]ext' })

-- Navigate quickfix list
vim.keymap.set('n', '<leader>lo', '<cmd>copen<cr>', { desc = 'Quickfix [L]ist [O]pen' })
vim.keymap.set('n', '<C-S-j>', '<cmd>cnext<cr>')
vim.keymap.set('n', '<C-S-k>', '<cmd>cprev<cr>')

-- Resizing windows
vim.keymap.set({ 'n', 'v' }, '<M-,>', '<C-W><')
vim.keymap.set({ 'n', 'v' }, '<M-.>', '<C-W>>')
vim.keymap.set({ 'n', 'v' }, '<M-=>', '<C-W>+')
vim.keymap.set({ 'n', 'v' }, '<M-->', '<C-W>-')

local function get_visual_selection()
  -- Get selection position
  local s_start = vim.fn.getpos "'<"
  local s_end = vim.fn.getpos "'>"
  -- Get line count
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  -- Read lines from buffer
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  -- Subtract unselected sections from lines
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  -- Return selected
  return lines
end

local function global_cmd_yank()
  -- Prompt user input for expression
  local inexpr = vim.fn.input 'Enter expression: '

  -- Get the (selected) lines
  local lines = nil
  local mode = vim.api.nvim_get_mode()['mode']
  if string.find(mode:lower(), '^v') then
    lines = get_visual_selection()
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  -- Apply expression on all lines
  local matches = vim.fn.matchstrlist(lines, inexpr)
  local extracted = vim.tbl_map(function(value)
    return value['text']
  end, matches)
end

vim.keymap.set({ 'n', 'v' }, '<leader>gy', global_cmd_yank, { desc = '[G]lobal command [Y]ank' })

if vim.g.neovide then
  -- System clipboard keybinds in normal and visual mode
  vim.keymap.set({ 'n', 'v' }, '<C-S-c>', '"+y', { desc = 'Yank to System clipboard' })
  vim.keymap.set({ 'n', 'v' }, '<C-S-v>', '"+p', { desc = 'Paste from System clipboard' })
  -- Clipboard for command and insert mode
  vim.keymap.set({ 'c', 'i' }, '<C-S-v>', '<C-R>+', { desc = 'Paste from System clipboard' })
end

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
