-- ~/.config/nvim/init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- 1. Core editor settings (Set early for colorscheme compatibility)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.backspace = "indent,eol,start"
-- vim.opt.smartindent = true -- Disable this as it often conflicts with Treesitter's superior indent engine
vim.opt.copyindent = true
vim.opt.preserveindent = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus" -- system clipboard
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Improve 'gf' (go to file)
vim.opt.path:append({ "**" }) -- Search recursively in subdirectories
vim.opt.suffixesadd:append({ ".lua", ".js", ".ts", ".jsx", ".tsx", ".php", ".py", ".go" })

-- Add Mason, Bun, and Rust bin to PATH
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. ":" .. vim.fn.expand("~/.bun/bin") .. ":" .. vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH

-- Fix for shell commands (like !ls) not working correctly
if vim.fn.executable("zsh") == 1 then
  vim.opt.shell = "zsh"
elseif vim.fn.executable("bash") == 1 then
  vim.opt.shell = "bash"
end

-- 2. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Plugin specification & configuration
require("lazy").setup({
  ----------------------------------------------------------------------------
  -- Color scheme (load first, high priority)
  ----------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          lualine = true,
          mini = {
            enabled = true,
            indentscope = true,
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  ----------------------------------------------------------------------------
  -- Essential UI components
  ----------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" } },
    opts = {
      view = { width = 35 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      actions = {
        remove_file = {
          close_window = false,
        },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "auto" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<C-[>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<C-]>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bd<cr>", desc = "Close buffer" },
    },
    opts = {
      options = {
        mode = "buffers",
        offsets = { { filetype = "NvimTree", text = "File Explorer" } },
      },
    },
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  ----------------------------------------------------------------------------
  -- Fuzzy finder & search
  ----------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      {
        "<C-p>",
        function()
          local function get_project_root()
            local markers = { ".git", ".stylua.toml", "init.lua", "package.json", "go.mod" }
            for _, marker in ipairs(markers) do
              local root = vim.fn.finddir(marker, ".;")
              if root == "" then
                root = vim.fn.findfile(marker, ".;")
              end
              if root ~= "" then
                return vim.fn.fnamemodify(root, ":h")
              end
            end
            return vim.fn.getcwd()
          end
          require("telescope.builtin").find_files({
            cwd = get_project_root(),
            hidden = true,
            no_ignore = false, -- respect .gitignore
          })
        end,
        desc = "Find files (Project Root)",
      },
      { "<C-l>", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "ll", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<C-m>", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>m", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace symbols" },
      {
        "<leader>fb",
        ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
        desc = "File browser",
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "%.pyc$", "node_modules/", "%.git/", "%.DS_Store" },
        },
        extensions = {
          file_browser = {
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
              ["i"] = {
                -- your custom insert mode mappings
              },
              ["n"] = {
                -- your custom normal mode mappings
                ["a"] = telescope.extensions.file_browser.actions.create,
                ["r"] = telescope.extensions.file_browser.actions.rename,
                ["m"] = telescope.extensions.file_browser.actions.move,
                ["y"] = telescope.extensions.file_browser.actions.copy,
                ["d"] = telescope.extensions.file_browser.actions.remove,
              },
            },
          },
        },
      })
      telescope.load_extension("file_browser")
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer local keymaps",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- Syntax highlighting & text objects
  ----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- Switch to main branch for Neovim 0.12+ compatibility
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end
      configs.setup({
        ensure_installed = {
          "c", "cpp", "go", "lua", "python", "rust", "tsx", "javascript", "typescript",
          "vimdoc", "vim", "bash", "json", "yaml", "html", "css", "markdown", "markdown_inline",
          "php", "blade",
        },
        auto_install = true,
        highlight = {
          enable = true,
          -- Disable slow treesitter highlight for large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = true,
        },
        indent = { enable = false }, -- Disable treesitter indent as it often causes range errors in Nightly
        incremental_selection = { enable = false },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- LSP & completion
  ----------------------------------------------------------------------------
  -- Mason: install LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- LSP
        "lua_ls", "pyright", "rust-analyzer", "gopls", "vtsls",
        "html", "cssls", "jsonls", "yamlls", "bashls", "clangd",
        "intelephense", "emmet_ls",
        -- Linters
        "eslint_d", "pylint", "golangci-lint", "phpstan",
        -- Formatters
        "stylua", "isort", "black", "prettierd", "prettier",
        "goimports", "jq", "yamlfmt", "pint",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls", "pyright", "gopls", "vtsls",
        "html", "cssls", "jsonls", "yamlls", "bashls", "clangd",
        "intelephense",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "yioneko/nvim-vtsls", -- Better TS support
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Use LspAttach autocommand instead of on_attach for better performance and 0.11+ compatibility
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local opts = { buffer = bufnr, remap = false }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", function()
            if client and client.name == "rust-analyzer" then
              vim.cmd.RustLsp({ "hover", "actions" })
            else
              vim.lsp.buf.hover()
            end
          end, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

          -- Toggle inlay hints
          if client and client.server_capabilities.inlayHintProvider then
            vim.keymap.set("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, { buffer = bufnr, desc = "Toggle Inlay Hints" })
          end
        end,
      })

      -- Setup servers using the new vim.lsp.config API (Neovim 0.11+)
      local servers = {
        "lua_ls", "pyright", "gopls", "vtsls",
        "html", "cssls", "jsonls", "yamlls", "bashls", "clangd",
        "intelephense", "emmet_ls",
      }

      -- Explicitly require vtsls to ensure its extensions are available
      local vtsls_ok, _ = pcall(require, "vtsls")

      for _, server_name in ipairs(servers) do
        local server_opts = {
          capabilities = capabilities,
        }

        if server_name == "emmet_ls" then
          server_opts.filetypes = {
            "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "blade", "php"
          }
        elseif server_name == "lua_ls" then
          server_opts.settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
              format = { enable = false },
              hint = { enable = true },
            },
          }
        elseif server_name == "pyright" then
          server_opts.settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          }
        elseif server_name == "gopls" then
          server_opts.settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = { unusedparams = true },
              staticcheck = true,
              completeUnimported = true,
              usePlaceholders = true,
            },
          }
        elseif server_name == "vtsls" then
          server_opts.settings = {
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
                autoImports = true,
              },
              inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
              preferences = {
                importModuleSpecifierEnding = "minimal",
                includePackageJsonAutoImports = "all",
              },
            },
            javascript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
                autoImports = true,
              },
              inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
            vtsls = {
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
          }
        end

        -- Register the config and enable the server
        vim.lsp.config(server_name, server_opts)
        vim.lsp.enable(server_name)
      end
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "rafamadriz/friendly-snippets",
      "lukas-reineke/cmp-under-comparator",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require("cmp-under-comparator").under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            },
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "nvim_lsp_signature_help", priority = 500 },
          { name = "path", priority = 250 },
        }, {
          { name = "buffer", priority = 100 },
        }),
      })

      -- Cmdline completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded",
      },
      floating_window = false, -- Disable automatic floating window
      hint_enable = false,     -- Disable the "bulb" hint
      always_trigger = false,  -- Only show when explicitly called
    },
  },

  ----------------------------------------------------------------------------
  -- Formatting & Linting (replaces null-ls)
  ----------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>mp",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        json = { "jq" },
        yaml = { "yamlfmt" },
        markdown = { "prettier" },
        php = { "pint" },
      },
      formatters = {
        stylua = {
          prepend_args = { "--config-path", vim.fn.stdpath("config") .. "/.stylua.toml" },
        },
      },
      format_on_save = function(bufnr)
        -- Disable format on save for files in certain directories
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "pylint" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        go = { "golangci_lint" },
        php = { "phpstan" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Git integration
  ----------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        map("n", "]c", gs.next_hunk, { desc = "Next hunk" })
        map("n", "[c", gs.prev_hunk, { desc = "Previous hunk" })
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end, { desc = "Stage selected hunk" })
        map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end, { desc = "Reset selected hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hb", function() gs.blame_line { full = true } end, { desc = "Blame line" })
        map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle blame line" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
        map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })
      end,
    },
  },

  ----------------------------------------------------------------------------
  -- Debugging (DAP)
  ----------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
    end,
  },

  ----------------------------------------------------------------------------
  -- Utilities
  ----------------------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = {},
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>Dx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>DX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references" },
    },
    opts = {},
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Rust Support
  {
    "mrcjkb/rustaceanvim",
    lazy = false, -- This plugin is already lazy
    config = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              check = {
                command = "clippy",
              },
              procMacro = {
                enable = true,
              },
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              hover = {
                actions = {
                  enable = true,
                  references = true,
                },
              },
            },
          },
        },
      }
    end,
  },

  {
    "Saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },

  -- PHP / Laravel Support
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    cmd = { "Laravel" },
    keys = {
      { "<leader>la", "<cmd>Laravel artisan<cr>", desc = "Laravel Artisan" },
      { "<leader>lr", "<cmd>Laravel routes<cr>", desc = "Laravel Routes" },
      { "<leader>lm", "<cmd>Laravel related<cr>", desc = "Laravel Related" },
    },
    ft = { "php", "blade" },
    opts = {
      lsp_server = "intelephense",
      features = {
        null_ls = {
          enable = false,
        },
      },
    },
    config = function(_, opts)
      if vim.fn.filereadable("artisan") == 1 then
        require("laravel").setup(opts)
      end
    end,
  },

  {
    "jwalton512/vim-blade",
    ft = { "blade" },
  },

  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  {
    "tpope/vim-dotenv",
    event = "VeryLazy",
  },

  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    commit = "8b62563", -- Use a stable commit
    keys = {
      { "<leader>rr", "<cmd>Rest run<cr>", desc = "Run HTTP request" },
      { "<leader>rp", "<cmd>Rest last<cr>", desc = "Run last HTTP request" },
    },
    config = function()
      require("rest-nvim").setup({})
    end,
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or 'LspAttach'
    priority = 1000, -- needs to be loaded in last
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern", -- modern, classic, minimal, powerline
        hi = {
          background = "none", -- 'none' or color like '#1e1e2e'
        },
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
          add_messages = true,
          throttle = 20,
          softwrap = 30,
        },
      })
      -- Disable default virtual text to avoid duplication
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {},
  },
}, {
  rocks = {
    enabled = false,
    hererocks = false,
  },
})

-- Additional keymaps
vim.keymap.set("n", "<C-s>", ":w<CR>", { silent = true })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<C-q>", ":q<CR>", { silent = true })
vim.keymap.set({ "n", "i" }, "<Esc>", function()
  -- If in Insert mode, exit to Normal mode
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end

  vim.cmd("nohlsearch")

  -- Save if the buffer is a normal file and has been modified
  if vim.bo.buftype == "" and vim.bo.modified and vim.fn.expand("%") ~= "" then
    vim.cmd("silent! update")
  end

  -- Close any floating windows (like LSP hover)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = "Clear highlights, save, and close floating windows" })
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Better way to run tests (supports Bun and Rust)
vim.keymap.set("n", "<leader>bt", function()
  local cmd = "bun test"
  if vim.bo.filetype == "rust" or vim.fs.find("Cargo.toml", { upward = true })[1] then
    cmd = "cargo test"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
      vim.notify("Test finished. Press 'q' to close.")
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Run tests (Bun/Cargo) in floating terminal" })

-- Better way to run projects (supports Bun and Rust)
vim.keymap.set("n", "<leader>br", function()
  local cmd = "bun run ."
  if vim.bo.filetype == "rust" or vim.fs.find("Cargo.toml", { upward = true })[1] then
    cmd = "cargo run"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
      vim.notify("Run finished. Press 'q' to close.")
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Run project (Bun/Cargo) in floating terminal" })

-- Better way to build projects (supports Bun and Rust)
vim.keymap.set("n", "<leader>bb", function()
  local cmd = "bun run build"
  if vim.bo.filetype == "rust" or vim.fs.find("Cargo.toml", { upward = true })[1] then
    cmd = "cargo build"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
      vim.notify("Build finished. Press 'q' to close.")
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Build project (Bun/Cargo) in floating terminal" })

-- Better way to check projects (supports Bun and Rust)
vim.keymap.set("n", "<leader>bc", function()
  local cmd = "bun x tsc --noEmit"
  if vim.bo.filetype == "rust" or vim.fs.find("Cargo.toml", { upward = true })[1] then
    cmd = "cargo check"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
      vim.notify("Check finished. Press 'q' to close.")
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Check project (Bun/Cargo) in floating terminal" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Normal mode move lines (Alt + j/k)
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })

-- Normal mode move lines (Shift + j/k - Note: This replaces default J/K)
-- vim.keymap.set("n", "J", "<cmd>m .+1<cr>==", { desc = "Move line down" })
-- vim.keymap.set("n", "K", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines keeping cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half‑page down + center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half‑page up + center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result + center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result + center" })

-- File/Folder creation
local function create_item(is_folder)
  local current_dir = vim.fn.expand("%:p:h")
  if current_dir == "" or current_dir == "." then
    current_dir = vim.fn.getcwd()
  end
  local path = current_dir .. "/"

  -- Using vim.fn.input for better native auto-completion support in some environments
  local input = vim.fn.input(is_folder and "Create Folder: " or "Create File: ", path, "file")

  if not input or input == "" or input == path then
    return
  end

  if is_folder then
    vim.fn.mkdir(input, "p")
    vim.notify("Created folder: " .. input)
  else
    local dir = vim.fn.fnamemodify(input, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    vim.cmd("edit " .. input)
    vim.cmd("write")
    vim.notify("Created file: " .. input)
  end
end

vim.keymap.set("n", "<C-n>", function()
  create_item(false)
end, { desc = "New file" })
vim.keymap.set("n", "<C-f>", function()
  create_item(true)
end, { desc = "New folder" })

-- Fix for colors vanishing after shell commands (like !bun test or !cargo test)
vim.api.nvim_create_autocmd("ShellCmdPost", {
  callback = function()
    vim.cmd("redraw!")
  end,
})

-- Disable LSP semantic tokens globally to prevent "flickering" or vanishing colors
-- This ensures Treesitter remains the primary source for highlighting
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

-- Ensure .blade.php files are recognized as 'blade' filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.blade.php",
  callback = function()
    vim.opt.filetype = "blade"
  end,
})

-- Keymap to go to file under cursor
vim.keymap.set("n", "gf", "gf", { desc = "Go to file under cursor" })
vim.keymap.set("n", "<leader>gf", "<C-w>f", { desc = "Go to file in new split" })

-- Close floating windows with <Esc> if they are focused
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = true, silent = true })
    end
  end,
})

-- Convenient keymap to close the current buffer
vim.keymap.set("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close current buffer" })

-- Specialized JS/TS mappings for vtsls
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and (client.name == "vtsls") then
      local vtsls = require("vtsls")
      vim.keymap.set("n", "<leader>oi", function() vtsls.commands.organize_imports(args.buf) end, { buffer = args.buf, desc = "Organize Imports" })
      vim.keymap.set("n", "<leader>rf", function() vtsls.commands.rename_file(args.buf) end, { buffer = args.buf, desc = "Rename File (with imports update)" })
      vim.keymap.set("n", "<leader>fa", function() vtsls.commands.fix_all(args.buf) end, { buffer = args.buf, desc = "Fix All (including auto-imports)" })
    end
  end,
})

-- Alias for file browser (user requested leader+bf)
vim.keymap.set("n", "<leader>bf", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File browser (current dir)" })
