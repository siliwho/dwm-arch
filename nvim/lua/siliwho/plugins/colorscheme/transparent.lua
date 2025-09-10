return {
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			extra_groups = {
				"NormalFloat",
				"NvimTreeNormal",
				"TelescopeNormal",
				"TelescopeBorder",
			},
			exclude_groups = {},
		})
		vim.cmd("TransparentEnable")
	end,
}
