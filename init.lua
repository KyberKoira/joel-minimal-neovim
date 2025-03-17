vim.cmd('echo "Haloo🐕"')

vim.cmd("set clipboard=unnamedplus")

vim.cmd("set number")

vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set filetype=on")
-- vim.cmd("set shortmess-=F")

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Tab Bindings
vim.keymap.set({ "n" }, "<leader>tn", ":tabnew<CR>")
vim.keymap.set({ "n" }, "<leader>t<right>", ":tabnext +<CR>")
vim.keymap.set({ "n" }, "<leader>t<left>", ":tabnext -<CR>")

-- Get That Desert Camo
vim.cmd("colorscheme desert")


-- DoubleBraces Cool {}
require("mini.pairs").setup()

-- Search & Replace // Launch with :GrugFar
require("grug-far").setup({})

local function get_git_root()
	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

-- Find in project
vim.keymap.set({ "n" }, "<leader>gf", function()
	require("grug-far").open({ prefills = { paths = get_git_root() } })
end, { desc = "grug-far: Search within project" })

-- Find withing range
vim.keymap.set({ "v" }, "<leader>gf", function()
	require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
end, { desc = "grug-far: Search within selection" })

-- Git Muutokset Näkyviin
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "+" },
		delete = { text = "-" },
		topdelete = { text = "-" },
		changedelete = { text = "-" },
		untracked = { text = "?" },
	},
	signs_staged = {
		add = { text = "s+" },
		change = { text = "s+" },
		delete = { text = "s-" },
		topdelete = { text = "s-" },
		changedelete = { text = "s-" },
		untracked = { text = "s?" },
	},
	signs_staged_enable = false,
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false,  -- Toggle with `:Gitsigns toggle_numhl`
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
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
		virt_text_priority = 100,
		use_focus = true,
	},
	current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000, -- Disable if file is longer than this (in lines)
	preview_config = {
		-- Options passed to nvim_open_win
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
})

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		require("lint").try_lint()
	end,
})

-- which-key
local wk = require("which-key")

-- lualine
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
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
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})

-- animation
require("mini.animate").setup()

-- LSP
require("lspconfig").lua_ls.setup({}) -- TODO: load if third party installed
require("lspconfig").pylsp.setup({})
require("lspconfig").clangd.setup({})

vim.api.nvim_create_autocmd('FileType', {
	desc = 'Choose right LSP for filetype',
	callback = function(opts)
		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('lsp_bindings', { clear = true }),
			callback = function(args)
				local opts_cmd = { noremap = true, silent = true }
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client.supports_method("textDocument/rename") then
					vim.keymap.set("n", "<leader>rn", "<cmd>lua =vim.lsp.buf.rename()<CR>", opts_cmd)
				end

				if client.supports_method("textDocument/implementation") then
					vim.keymap.set("n", "<leader>gi", "<cmd>lua =vim.lsp.buf.implementation()<CR>", opts_cmd)
				end

				if client.supports_method("textDocument/definition") then
					vim.keymap.set("n", "<leader>gd", "<cmd>lua =vim.lsp.buf.definition()<CR>", opts_cmd)
				end

				if client.supports_method("textDocument/references") then
					vim.keymap.set("n", "<leader>gr", "<cmd>lua =vim.lsp.buf.references()<CR>", opts_cmd)
				end

				vim.keymap.set("n", "[d", "<cmd>lua =vim.diagnostic.goto_prev()<CR>", opts_cmd)
				vim.keymap.set("n", "]d", "<cmd>lua =vim.diagnostic.goto_next()<CR>", opts_cmd)

				if client.supports_method("textDocument/formatting") then
					vim.keymap.set("n", "<leader>ff", "<cmd>lua =vim.lsp.buf.format()<CR>", opts_cmd)
				end
			end,
		})
	end,
})

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = false,
	float = {
		focusable = false,
		style = "minimal",
		border = "single",
		source = "always",
		header = "Diagnostics:",
	},
})

-- File Tree
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>ot", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })

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
