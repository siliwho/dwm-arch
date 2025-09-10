return {
	"tiagovla/tokyodark.nvim",
	config = function()
		vim.g.tokyodark_enable_italic_comment = true
		vim.g.tokyodark_enable_italic = true
		vim.g.tokyodark_color_gamma = "1.0"
		vim.g.tokyodark_transparent_background = true
		local transparent = true -- set to true if you would like to enable transparency

		vim.cmd("colorscheme tokyodark")
	end,
}
