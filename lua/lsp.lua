local lspconfig = require("lspconfig")
local cmp = require("cmp")
local luasnip = require("luasnip")

-- nvim-cmp setup
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})

-- Mason ensures servers installed
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "clangd", "pyright", "ts_ls", "lua_ls" },
})

-- Attach servers
local servers = { "clangd", "pyright", "ts_ls", "lua_ls" }
for _, server in ipairs(servers) do
	lspconfig[server].setup({
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
	})
end

-- Inlay hints (works best with clangd 15+)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})
