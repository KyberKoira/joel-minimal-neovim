vim.cmd('echo "Haloo🐕"')
vim.cmd("set clipboard=unnamedplus")

vim.cmd("iabbrev neovimisfun 'Neovim is Fun!'")

vim.cmd("set number")

vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set filetype=on")
vim.cmd("set noexpandtab")
vim.cmd("set guicursor=a:blinkon100")
-- vim.cmd("set shortmess-=F")
vim.cmd("set noswapfile")

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- utils

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- custom exit
vim.keymap.set({ "n", "o", "x" }, "<leader><esc>", ":wall|qa!<CR>")

-- tab stuff
vim.keymap.set({ "n" }, "<leader>tn", ":tabnew<CR>")
vim.keymap.set({ "n" }, "<TAB>", ":tabn<CR>")
vim.keymap.set({ "n" }, "<S-TAB>", ":tabp<CR>")
vim.keymap.set({ "n" }, "<leader>tc", ":tabclose<CR>")

-- for exiting terminal
vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-n>")

-- for cope navigation
vim.keymap.set("n",
	"<C-down>",
	"<cmd>cnext<CR>",
	{ noremap = true, silent = true })
vim.keymap.set("n",
	"<C-up>",
	"<cmd>cprevious<CR>",
	{ noremap = true, silent = true })

-- project search
function project_find(cmd_args)
	vim.cmd("cexpr system('ag " .. cmd_args.args .. " $(git rev-parse --show-toplevel) | head -c -1')")
	vim.cmd('cope')
end
vim.api.nvim_create_user_command('ProjectFind', project_find, { nargs = 1 })
vim.keymap.set({"n"},"<leader>ff",":ProjectFind ")

-- filename search
function file_find(cmd_args)
	local command_str = [[ag -g ]] .. cmd_args.args .. [[ | awk '{ print length, $0 }' | sort -n | cut -d' ' -f2- | awk '{ print $0 \":1:\"} file' | awk -v mypre=$(pwd) '{print mypre $0} file']]
	vim.cmd([[cexpr system("]] .. command_str .. [[")]])
	vim.cmd('cope')
end
vim.api.nvim_create_user_command('FileFind', file_find, { nargs = 1 })
vim.keymap.set({"n"},"<leader>fd",":FileFind ")

-- fast terminal
function term_open()
	vim.cmd("terminal")
	vim.cmd("startinsert!")
end

vim.keymap.set({ "n" }, "<leader>tt", term_open)

-- Get That Desert Camo
vim.cmd("colorscheme badwolf")

-- Formatteri takaisin
require("conform").setup({
	formatters_by_ft = {
		php = { "php" },
	},
	notify_on_error = true,
	formatters = {
		php = {
			command = "php-cs-fixer",
			args = {
				"fix",
				"$FILENAME",
				--"--config=.php",
				"--allow-risky=yes", -- if you have risky stuff in config, if not you dont need it.
			},
			stdin = false,
		}
	}
}
)

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

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
	signs_staged_enable = true,
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

-- which-key
require("which-key")

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
vim.lsp.config["lua_ls"] = {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc')) then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT'
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME
					-- Depending on the usage, you might want to add additional paths here.
					-- "${3rd}/luv/library"
					-- "${3rd}/busted/library",
				}
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
				-- and will cause issues when working on your own configuration
				-- (see https://github.com/neovim/nvim-lspconfig/issues/3189)
				-- library = vim.api.nvim_get_runtime_file("", true)
			}
		})
	end,
	settings = {
		Lua = {}
	}
}

-- Python
vim.lsp.config["pylsp"] = {}
vim.lsp.config["pyright"] = {} -- pyproject.toml
vim.lsp.config["ruff"] = {-- pyproject.toml prio
	init_options = {
		settings = {
			configurationPreference = "filesystemFirst"
		}
	}
}

require('lint').linters_by_ft = { -- to get mypy
  python = {'mypy'},
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- C/C++
vim.lsp.config["clangd"] = {}
vim.keymap.set("n", "<leader>sF", "<cmd>ClangdSwitchSourceHeader<CR>", { noremap = true, silent = true })

vim.lsp.config["cmake"] = {}

-- Where is WebDev?

-- PHP
vim.lsp.config["phpactor"] = {}

-- Docker
vim.lsp.config["dockerls"] = {
	settings = {
		docker = {
			languageserver = {
				formatter = {
					ignoreMultilineInstructions = true,
				},
			},
		}
	}
}

vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP keymaps',
	group = vim.api.nvim_create_augroup('lsp_bindings', { clear = true }),
	callback = function(args)
		local opts_cmd = { noremap = true, silent = true }
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf

		if client == nil then return end

		if client.supports_method("textDocument/rename") then
			vim.keymap.set("n", "rn", "<cmd>lua =vim.lsp.buf.rename()<CR>", opts_cmd)
		end

		if client.supports_method("textDocument/implementation") then
			vim.keymap.set("n", "gi", "<cmd>lua =vim.lsp.buf.implementation()<CR>", opts_cmd)
		end

		if client.supports_method("textDocument/declaration") then
			vim.keymap.set("n", "gD", "<cmd>lua =vim.lsp.buf.declaration()<CR>", opts_cmd)
		end

		if client.supports_method("textDocument/definition") then
			vim.keymap.set("n", "gd", "<cmd>lua =vim.lsp.buf.definition()<CR>", opts_cmd)
		end

		if client.supports_method("textDocument/references") then
			vim.keymap.set("n", "gr", "<cmd>lua =vim.lsp.buf.references()<CR>", opts_cmd)
		end

		vim.keymap.set("n", "[d", "<cmd>lua =vim.diagnostic.goto_prev()<CR>", opts_cmd)
		vim.keymap.set("n", "]d", "<cmd>lua =vim.diagnostic.goto_next()<CR>", opts_cmd)

		if client.supports_method("textDocument/formatting") then
			vim.keymap.set("n", "<leader>ff", function() vim.lsp.buf.format() end,
				{ noremap = true, silent = true, desc = "Format with LSP" })
		end

		if client.supports_method("textDocument/completion") then
			-- this is triggered by <CTRL-X><CTRL-O>
			vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
		end
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
		source = true,
		header = "Diagnostics:",
	},
})

-- file tree
local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set("n", "<C-o>", api.tree.change_root_to_node,        opts("Up"))
    vim.keymap.set("n", "?",     api.tree.toggle_help,                  opts("Help"))
  end

  require("nvim-tree").setup(
	  {on_attach = my_on_attach}
)

vim.keymap.set("n", "<leader>ot", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })

-- terminal -- bug: messes with tabs
local term_buf = nil
local term_win = nil

function TermAppend(height)
	vim.cmd("botright new")
	vim.cmd("resize " .. height)
	vim.cmd("terminal")
	vim.cmd("startinsert!")
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.signcolumn = "no"
end

vim.keymap.set("n", "<leader>lt", ":lua TermAppend(20)<CR>", { noremap = true, silent = true })
vim.cmd("highlight DiagnosticError guifg=#ff38eb")
vim.keymap.set("n", "<c-ö>", ":cprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<c-ä>", ":cnext<CR>", { noremap = true, silent = true })

