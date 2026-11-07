vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.clipboard = "unnamedplus"
vim.o.numberwidth = 3
vim.o.signcolumn = "yes"
vim.g.mapleader = " "

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/vague2k/vague.nvim" } })
--vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

vim.pack.add({ { src = "https://github.com/folke/tokyonight.nvim" } })
vim.pack.add({ { src = "https://github.com/rebelot/kanagawa.nvim" } })
vim.cmd("colorscheme kanagawa")
--------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } })
require("oil").setup({
	default_file_explorer = true,
	restore_win_options = true,
	skip_confirm_for_simple_edits = true,

	float = {
		padding = 2,
		max_width = 80,
		max_height = 35,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
	},

	override = function(conf)
		conf.row = 1
		return conf
	end,

	view_options = {
		show_hidden = true,
		is_hidden_file = function(name)
			return false
		end,
		natural_order = true,
		sort = {
			{ "type", "asc" },
			{ "name", "asc" },
		},
	},

	columns = {
		"icon",
		"permissions",
		"size",
		"mtime",
	},
})
vim.keymap.set("n", "-", "<CMD>Oil --float<CR>")

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" } })
require("tiny-inline-diagnostic").setup({
	signs = {
		left = "",
		right = "",
		diag = "●",
		arrow = "    ",
		up_arrow = "    ",
		vertical = " │",
		vertical_end = " └",
	},
	blend = {
		factor = 0.22,
	},

	vim.diagnostic.config({ virtual_text = false }),
})

-------------------------------------------------------------------------------
vim.pack.add({ "https://github.com/seblyng/roslyn.nvim" }, { load = function() end })

---@module 'roslyn.config'
---@type RoslynNvimConfig
local opts = {}

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cs", "razor" },
	once = true,
	callback = function()
		vim.cmd.packadd("roslyn.nvim")
		require("roslyn").setup(opts)
	end,
})

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } })

local opts = {
	ensure_installed = {
		"vim",
		"lua",
		"vimdoc",
		"html",
		"css",
		"cpp",
		"go",
		"bash",
		"elixir",
		"heex",
		"eex",
		"java",
		"python",
		"scala",
		"c_sharp",
		"razor",
	},

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = { enable = true },
}

config = function(_, opts)
	vim.treesitter.language.register("bash", "conf")
	vim.treesitter.language.register("bash", "kitty")
	vim.treesitter.language.register("bash", "tmux")
	vim.treesitter.language.register("bash", "sh")
end

require("nvim-treesitter").setup(opts)

-------------------------------------------------------------------------------
vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
})

require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})

-- LSP configuration names managed by Mason.
local mason_servers = {
	"html",
	"cssls",
	"eslint",
	"ts_ls",
	"gopls",
	"pyright",
	"cmake",
	"bashls",
	"lua_ls",
	"jdtls",
}

require("mason-lspconfig").setup({
	ensure_installed = mason_servers,

	-- We enable the servers explicitly below.
	automatic_enable = false,
})

vim.lsp.config("lua_ls", {
	before_init = function(_, config)
		config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				runtime = {
					version = "LuaJIT",
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						vim.fn.stdpath("config"),
					},
				},
				telemetry = {
					enable = false,
				},
			},
		})
	end,
})

-- These are installed separately, not by Mason in this configuration.
vim.lsp.config("clangd", {
	cmd = {
		"/home/gordonyx/.local/bin/llvm/bin/clangd",
		"--log=verbose",
		"--pretty",
		"--enable-config",
		"--background-index",
		"--compile-commands-dir=build",
		"--query-driver=/home/gordonyx/.local/bin/llvm/bin/clang++",
	},
})

vim.lsp.config("elixirls", {
	cmd = { "/home/gordonyx/.local/bin/elixir-ls/release/language_server.sh" },
	root_markers = { "mix.exs", ".git" },
})

vim.lsp.enable(mason_servers)
vim.lsp.enable({ "clangd", "elixirls", "roslyn_ls" })

vim.diagnostic.config({
	underline = false,
	virtual_text = false,
	update_in_insert = false,
	severity_sort = true,

	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E ",
			[vim.diagnostic.severity.WARN] = "W ",
			[vim.diagnostic.severity.HINT] = "H ",
			[vim.diagnostic.severity.INFO] = "I ",
		},
	},
})

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } })

local opts = {

	formatters_by_ft = {
		lua = { "stylua" },
		css = { "prettier" },
		html = { "prettier" },
	},

	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

require("conform").setup(opts)

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/nvim-lua/plenary.nvim" } })
vim.pack.add({ {
	src = "https://github.com/ThePrimeagen/harpoon",
	version = "harpoon2",
} })

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } })
vim.pack.add({ { src = "https://github.com/nvim-telescope/telescope.nvim" } })

local opts = {
	defaults = {
		prompt_prefix = "   ",
		selection_caret = " ",
		entry_prefix = " ",
		sorting_strategy = "ascending",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
			},
			width = 0.87,
			height = 0.80,
		},
		mappings = {
			n = { ["q"] = require("telescope.actions").close },
		},
	},

	extensions_list = { "themes", "terms" },
	extensions = {},
}

require("telescope").setup(opts)

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/nvim-tree/nvim-web-devicons" } })

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/lukas-reineke/indent-blankline.nvim" } })

--------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/lewis6991/gitsigns.nvim" } })

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/hrsh7th/nvim-cmp" } })

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/L3MON4D3/LuaSnip" } })

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/windwp/nvim-autopairs" } })

-------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/saadparwaiz1/cmp_luasnip" } })
vim.pack.add({ { src = "https://github.com/hrsh7th/cmp-nvim-lua" } })
vim.pack.add({ { src = "https://github.com/hrsh7th/cmp-nvim-lsp" } })
vim.pack.add({ { src = "https://github.com/hrsh7th/cmp-buffer" } })
vim.pack.add({ { src = "https://codeberg.org/FelipeLema/cmp-async-path.git" } })
vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" } })

-------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>/", "<cmd>gcc<CR>", { desc = "toggle nvcheatsheet" })
vim.keymap.set("v", "<leader>/", "<cmd>gc<CR>", { desc = "toggle nvcheatsheet" })
vim.keymap.set("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })
vim.keymap.set("n", "<leader>x", ":bd<CR>", { desc = "delete open buffer" })
vim.keymap.set("n", "<leader>[", ":bn<CR>", { desc = "next buffer" })
vim.keymap.set("n", "<leader>]", ":bp<CR>", { desc = "previous buffer" })

vim.keymap.set("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
vim.keymap.set("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
vim.keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
vim.keymap.set(
	"n",
	"<leader>fz",
	"<cmd>Telescope current_buffer_fuzzy_find<CR>",
	{ desc = "telescope find in current buffer" }
)

vim.keymap.set("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
vim.keymap.set("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
vim.keymap.set("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
vim.keymap.set("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
vim.keymap.set(
	"n",
	"<leader>fa",
	"<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
	{ desc = "telescope find all files" }
)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_user_command("TSInstallAll", function()
	require("nvim-treesitter").install(treesitter_parsers)
end, { desc = "Install configured Treesitter parsers" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = bufnr })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
		vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = bufnr })
	end,
})

vim.api.nvim_create_user_command("NvChadExportCheatsheet", function(opts)
	local path = opts.args ~= "" and opts.args or nil
	require("export_cheatsheet").export(path)
end, { nargs = "?", complete = "file" })

--- LspWatchBuild -------------------------------------------------------------
-------------------------------------------------------------------------------
local lsp_watch_build_job = nil
local lsp_watch_reload_timer = nil

local project_root = vim.fs.normalize("/home/gordonyx/.local/src/c++/aima")

local function is_project_file(path)
	path = vim.fs.normalize(path)

	return path == project_root or vim.startswith(path, project_root .. "/")
end

local function is_cpp_file(path)
	return path:match("%.c$")
		or path:match("%.cc$")
		or path:match("%.cpp$")
		or path:match("%.cxx$")
		or path:match("%.h$")
		or path:match("%.hh$")
		or path:match("%.hpp$")
		or path:match("%.hxx$")
		or path:match("%.ixx$")
		or path:match("%.cppm$")
		or path:match("%.mpp$")
end

local function reload_project_buffers()
	local visible_buffers = {}

	-- Reload buffers currently displayed in windows.
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local bufnr = vim.api.nvim_win_get_buf(win)
		local path = vim.api.nvim_buf_get_name(bufnr)

		if
			vim.api.nvim_buf_is_valid(bufnr)
			and vim.bo[bufnr].buftype == ""
			and path ~= ""
			and is_project_file(path)
			and is_cpp_file(path)
			and not vim.bo[bufnr].modified
		then
			visible_buffers[bufnr] = true

			local view = vim.api.nvim_win_call(win, function()
				return vim.fn.winsaveview()
			end)

			vim.api.nvim_win_call(win, function()
				vim.cmd("edit!")
			end)

			vim.api.nvim_win_call(win, function()
				vim.fn.winrestview(view)
			end)
		end
	end

	-- Unload hidden project buffers. They remain listed, but their current
	-- contents and LSP attachment are discarded. They will be read again when
	-- opened.
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if
			not visible_buffers[bufnr]
			and vim.api.nvim_buf_is_valid(bufnr)
			and vim.api.nvim_buf_is_loaded(bufnr)
			and vim.bo[bufnr].buflisted
			and vim.bo[bufnr].buftype == ""
		then
			local path = vim.api.nvim_buf_get_name(bufnr)

			if path ~= "" and is_project_file(path) and is_cpp_file(path) and not vim.bo[bufnr].modified then
				vim.api.nvim_buf_delete(bufnr, { unload = true })
			end
		end
	end

	vim.notify("Reloaded project C/C++ buffers", vim.log.levels.INFO)
end

local function schedule_reload()
	if lsp_watch_reload_timer then
		lsp_watch_reload_timer:stop()
		lsp_watch_reload_timer:close()
		lsp_watch_reload_timer = nil
	end

	lsp_watch_reload_timer = vim.defer_fn(function()
		lsp_watch_reload_timer = nil
		reload_project_buffers()
	end, 300)
end

vim.api.nvim_create_user_command("LspWatchBuild", function()
	if lsp_watch_build_job then
		vim.notify("LspWatchBuild is already running", vim.log.levels.WARN)
		return
	end

	local source_dir = project_root

	if vim.fn.isdirectory(source_dir) == 0 then
		vim.notify("Project directory does not exist: " .. source_dir, vim.log.levels.ERROR)
		return
	end

	lsp_watch_build_job = vim.fn.jobstart({
		"stdbuf",
		"-oL",
		"inotifywait",
		"--monitor",
		"--recursive",
		"--event",
		"close_write",
		"--format",
		"%w%f",
		"--exclude",
		"(^|/)(\\.git|build|\\.cache)(/|$)",
		"--exclude",
		"(^|/)compile_commands\\.json$",
		source_dir,
	}, {
		stdout_buffered = false,

		on_stdout = function(_, data)
			for _, filename in ipairs(data or {}) do
				filename = vim.trim(filename)

				if filename ~= "" and is_project_file(filename) and is_cpp_file(filename) then
					schedule_reload()
				end
			end
		end,

		on_stderr = function(_, data)
			for _, line in ipairs(data or {}) do
				line = vim.trim(line)

				if line ~= "" then
					vim.schedule(function()
						vim.notify("LspWatchBuild: " .. line, vim.log.levels.WARN)
					end)
				end
			end
		end,

		on_exit = function(_, exit_code)
			vim.schedule(function()
				lsp_watch_build_job = nil

				if exit_code ~= 0 then
					vim.notify("LspWatchBuild stopped with exit code " .. exit_code, vim.log.levels.WARN)
				else
					vim.notify("LspWatchBuild stopped", vim.log.levels.INFO)
				end
			end)
		end,
	})

	if lsp_watch_build_job <= 0 then
		lsp_watch_build_job = nil
		vim.notify("Could not start inotifywait", vim.log.levels.ERROR)
		return
	end

	vim.notify("Watching project source files for changes", vim.log.levels.INFO)
end, {
	desc = "Reload project buffers after source changes",
})

vim.api.nvim_create_user_command("LspWatchBuildStop", function()
	if not lsp_watch_build_job then
		vim.notify("LspWatchBuild is not running", vim.log.levels.WARN)
		return
	end

	vim.fn.jobstop(lsp_watch_build_job)
	lsp_watch_build_job = nil

	vim.notify("LspWatchBuild stopped", vim.log.levels.INFO)
end, {
	desc = "Stop project source watcher",
})

-------------------------------------------------------------------------------
