local M = {}

M.enabled = false

--- this should disable
local function get_file_names_without_root(info)
	print(vim.inspect(info))
	local list_info_obj = {}
	list_info_obj['id'] = info.id
	list_info_obj['items'] = 1
	local items = vim.fn.getqflist(list_info_obj).items
	local l = {}
	return {}
end

local function handle_search_output(_, data)
	local cmd = string.format("cexpr %s", vim.inspect(data))
	---    call setqflist([], 'r', {'title': 'My search'})
	local data_table = {}
	print(vim.inspect(data))
	data_table['lines'] = data
	data_table['efm'] = '%f:%l:%m'
	-- data_table['quickfixtextfunc'] = get_file_names_without_root
	vim.fn.setqflist({}, 'r', data_table)
	vim.cmd('cc 1')
	vim.cmd('cope') --lopen for loclist
end

local function handle_error(_, data)
	print('search process errored!' .. vim.inspect(data))
end

local function do_grep_find(cmd_args)
	local git_root = vim.fn.system("git rev-parse --show-toplevel")
	git_root = string.gsub(git_root, "\n", "")

	vim.fn.jobstart(
		string.format("ag %s %s | head -c -1",cmd_args.args, git_root),
		{
			stdout_buffered = true,
			on_stdout = handle_search_output,
			on_stderr = handle_error
		}
	)
end

function M.setup()
	vim.api.nvim_create_user_command('Jfi', do_grep_find, { nargs = 1 })
	vim.keymap.set("n",
		"<C-down>",
		"<cmd>cnext<CR>",
		{ noremap = true, silent = true })
	vim.keymap.set("n",
		"<C-up>",
		"<cmd>cprevious<CR>",
		{ noremap = true, silent = true })
end

return M
