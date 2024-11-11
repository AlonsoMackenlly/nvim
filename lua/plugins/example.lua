-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- disable trouble
  { "folke/trouble.nvim", enabled = false },

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    entry_filter = function(entry)
      return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind()
    end,
  },

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  --{
  --  "neovim/nvim-lspconfig",
  --  dependencies = {
  --    "jose-elias-alvarez/typescript.nvim",
  --    init = function()
  --      require("lazyvim.util").lsp.on_attach(function(_, buffer)
  --        -- stylua: ignore
  --        vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
  --        vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
  --      end)
  --    end,
  --  },
  --  ---@class PluginLspOpts
  --  opts = {
  --    ---@type lspconfig.options
  --    servers = {
  --      -- tsserver will be automatically installed with mason and loaded with lspconfig
  --      tsserver = {},
  --      eslint = {
  --        settings = {
  --          -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
  --          workingDirectories = { mode = "auto" },
  --        },
  --      },
  --    },
  --    -- you can do any additional lsp server setup here
  --    -- return true if you don't want this server to be setup with lspconfig
  --    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  --    setup = {
  --      -- example to setup with typescript.nvim
  --      tsserver = function(_, opts)
  --        require("typescript").setup({ server = opts })
  --        require("javascript").setup({ server = opts })
  --        return true
  --      end,
  --      -- Specify * to use this function as a fallback for any server
  --      -- ["*"] = function(server, opts) end,
  --      eslint = function()
  --        local function get_client(buf)
  --          return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
  --        end

  --        local formatter = LazyVim.lsp.formatter({
  --          name = "eslint: lsp",
  --          primary = false,
  --          priority = 200,
  --          filter = { "eslint", "prettier" },
  --        })

  --        -- Use EslintFixAll on Neovim < 0.10.0
  --        if not pcall(require, "vim.lsp._dynamic") then
  --          formatter.name = "eslint: EslintFixAll"
  --          formatter.sources = function(buf)
  --            local client = get_client(buf)
  --            return client and { "eslint", "prettier" } or {}
  --          end
  --          formatter.format = function(buf)
  --            local client = get_client(buf)
  --            if client then
  --              local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
  --              if #diag > 0 then
  --                vim.cmd("EslintFixAll")
  --              end
  --            end
  --          end
  --        end

  --        -- register the formatter with LazyVim
  --        LazyVim.format.register(formatter)
  --      end,
  --    },
  --  },
  --},

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "styled",
      },
    },
  },

  -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- would overwrite `ensure_installed` with the new value.
  -- If you'd rather extend the default config, use the code below instead:
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
      })
    end,
  },

  -- the opts function can also be used to change the default opts:
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          return "😄"
        end,
      })
    end,
  },

  -- or you can return new options to override all the defaults
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        --[[add your custom lualine config here]]
      }
    end,
  },

  -- use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "prettier",
      },
    },
  },

  --  {
  --    "jose-elias-alvarez/null-ls.nvim",
  --    event = "BufReadPre", -- загружаем null-ls при открытии буфера
  --    config = function()
  --      local null_ls = require("null-ls")
  --
  --      null_ls.setup({
  --        sources = {
  --          null_ls.builtins.formatting.prettier.with({
  --            command = "/usr/bin/prettier", -- Замените на путь к prettier
  --          }),
  --        },
  --        on_attach = function(client, bufnr)
  --          if client.supports_method("textDocument/formatting") then
  --            vim.api.nvim_create_autocmd("BufWritePre", {
  --              buffer = bufnr,
  --              callback = function()
  --                vim.lsp.buf.format({ bufnr = bufnr })
  --              end,
  --            })
  --          end
  --        end,
  --      })
  --    end,
  --    opts = function(_, opts)
  --      local nls = require("null-ls")
  --      opts.root_dir = opts.root_dir
  --        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
  --      opts.sources = vim.list_extend(opts.sources or {}, {
  --        nls.builtins.formatting.fish_indent,
  --        nls.builtins.diagnostics.fish,
  --        nls.builtins.formatting.stylua,
  --        nls.builtins.formatting.shfmt,
  --      })
  --    end,
  --    dependencies = { "nvim-lua/plenary.nvim" },
  --  },
}
