-- Create a :Cp command for competitive programming
vim.api.nvim_create_user_command("Cp", function()
	local file = vim.fn.expand("%")
	local filename = vim.fn.expand("%:t:r")
	local filetype = vim.bo.filetype

	-- Save file first
	vim.cmd("w")

	-- Kill old terminal buffer if exists
	local term_bufnr = vim.g.comp_term_bufnr
	if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
		vim.api.nvim_buf_delete(term_bufnr, { force = true })
	end

	-- Open bottom terminal split
	vim.cmd("botright split | resize 15 | terminal")

	-- Store buffer number
	vim.g.comp_term_bufnr = vim.api.nvim_get_current_buf()

	-- Compile & run depending on language
	if filetype == "cpp" then
		vim.fn.chansend(
			vim.b.terminal_job_id,
			"g++ " .. file .. " -o " .. filename .. " && ./" .. filename .. " < input.txt\n"
		)
	elseif filetype == "python" then
		vim.fn.chansend(vim.b.terminal_job_id, "python3 " .. file .. " < input.txt\n")
	elseif filetype == "c" then
		vim.fn.chansend(
			vim.b.terminal_job_id,
			"gcc " .. file .. " -o " .. filename .. " && ./" .. filename .. " < input.txt\n"
		)
	elseif filetype == "java" then
		vim.fn.chansend(vim.b.terminal_job_id, "javac " .. file .. " && java " .. filename .. " < input.txt\n")
	end
end, {})

-- Keymap: Ctrl+b to run :Cp
vim.keymap.set("n", "<C-b>", ":Cp<CR>", { noremap = true, silent = true })
