vim.cmd 'echo "Haloo🐕"'

vim.cmd 'set number'

vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Tab Bindings
vim.keymap.set({ 'n' }, '<leader>tn', ':tabnew<CR>')
vim.keymap.set({ 'n' }, '<leader>t<right>', ':tabnext +<CR>')
vim.keymap.set({ 'n' }, '<leader>t<left>', ':tabnext -<CR>')

-- Get That Desert Camo
vim.cmd 'colorscheme desert'

-- DoubleBraces Cool {}
require('mini.pairs').setup()

-- Search & Replace // Launch with :GrugFar
require('grug-far').setup {}

local function get_git_root()
  local dot_git_path = vim.fn.finddir('.git', '.;')
  return vim.fn.fnamemodify(dot_git_path, ':h')
end

-- Find in project
vim.keymap.set({ 'n' }, '<leader>gf', function()
  require('grug-far').open { prefills = { paths = get_git_root() } }
end, { desc = 'grug-far: Search within project' })

-- Find withing range
vim.keymap.set({ 'v' }, '<leader>gf', function()
  require('grug-far').open { visualSelectionUsage = 'operate-within-range' }
end, { desc = 'grug-far: Search within selection' })

-- Git Muutokset Näkyviin
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '+' },
    delete = { text = '-' },
    topdelete = { text = '-' },
    changedelete = { text = '-' },
    untracked = { text = '?' },
  },
  signs_staged = {
    add = { text = 's+' },
    change = { text = 's+' },
    delete = { text = 's-' },
    topdelete = { text = 's-' },
    changedelete = { text = 's-' },
    untracked = { text = 's?' },
  },
  signs_staged_enable = false,
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true,
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
}

-- Formatteri
require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    -- Conform will run multiple formatters sequentially
    python = { 'pylsp' },
    -- You can customize some of the format options for the filetype (:help conform.format)
    -- Conform will run the first available formatter
  },
}

vim.api.nvim_create_user_command('Format', function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ['end'] = { args.line2, end_line:len() },
    }
  end
  require('conform').format { async = true, lsp_format = 'fallback', range = range }
end, { range = true })

vim.keymap.set('n', '<leader>ff', '<cmd>Format<CR>', { noremap = true, silent = true })

-- Linter
require('lint').linters_by_ft = {
  lua = { 'luacheck' },
}

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  callback = function()
    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require('lint').try_lint()
  end,
})

-- TreeSitter for highlights. Can do folding and indents too
package.path = 'Users/401725/.config/nvim/pack/treesitter/start/treesitter/lua/?.lua;' .. package.path
require('nvim-treesitter').setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline' },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { 'javascript' },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers",
  -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- which-key
local wk = require 'which-key'

-- lualine
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}

-- animation
require('mini.animate').setup()

-- LSP
--require('lspconfig').lua_ls.setup {}
--require('lspconfig').pylsp.setup{}

-- File Tree
require('nvim-tree').setup()
vim.keymap.set('n', '<leader>ot', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Terminal
local term_buf = nil
local term_win = nil

function TermToggle(height)
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.cmd("hide")
    else
        vim.cmd("botright new")
        local new_buf = vim.api.nvim_get_current_buf()
        vim.cmd("resize " .. height)
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.cmd("buffer " .. term_buf) -- go to terminal buffer
            vim.cmd("bd " .. new_buf) -- cleanup new buffer
        else
            vim.cmd("terminal")
            term_buf = vim.api.nvim_get_current_buf()
            vim.wo.number = false
            vim.wo.relativenumber = false
            vim.wo.signcolumn = "no"
        end
    vim.cmd("startinsert!")
    term_win = vim.api.nvim_get_current_win()
    end
end

vim.keymap.set("n", "<A-t>", ":lua TermToggle(20)<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-t>", "<Esc>:lua TermToggle(20)<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<A-t>", "<C-\\><C-n>:lua TermToggle(20)<CR>", { noremap = true, silent = true })
