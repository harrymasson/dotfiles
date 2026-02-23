-- ~/.config/nvim/lua/plugins/obsidian.lua
return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- latest release
    ft = "markdown", -- load only for markdown files
    dependencies = {
      "nvim-lua/plenary.nvim", -- required dependency
      "nvim-telescope/telescope.nvim", -- optional: for search and pickers
      "Saghen/blink.cmp", -- optional: completion
      "MeanderingProgrammer/render-markdown.nvim", -- optional: markdown rendered
      "folke/snacks.nvim",
    },
    opts = {
      legacy_commands = false, -- will be removed in the next major release
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/vault-2025-07",
        },
      },
      completion = {
        nvim_cmp = false, -- disable cmp for note/tag completion
        blink = true, -- enable blink.cmp for note/tag completion
      },
      picker = {
        name = "telescope", -- use telescope picker (LazyVim already has it)
      },
    },
    -- Keymaps: Lazy-style which-key group + useful bindings
    keys = function()
      local wk = require("which-key")
      wk.add({ { "<leader>o", group = "+obsidian" } })
      return {
        -- Navigation & search
        { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Quick Switch" },
        { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search Notes" },
        { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
        { "<leader>ot", "<cmd>Obsidian toc<cr>", desc = "Table of Contents" },
        { "<leader>oT", "<cmd>Obsidian tags<cr>", desc = "Tags Browser" },
        { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Links in Note" },

        -- Create / insert / manage
        { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Note" },
        { "<leader>oN", "<cmd>Obsidian new_from_template<cr>", desc = "New from Template" },
        { "<leader>oi", "<cmd>Obsidian paste_img<cr>", desc = "Paste Image" },
        { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename Note (+Backlinks)" },

        -- Daily notes
        { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Today" },
        { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday (workday)" },
        { "<leader>om", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow (workday)" },
        { "<leader>oD", "<cmd>Obsidian dailies -2 1<cr>", desc = "Dailies Range" },

        -- App integration
        { "<leader>oO", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian App" },

        -- Visual-mode helpers
        { "gl", ":Obsidian link<cr>", mode = "x", desc = "Link Selection" },
        { "gL", ":Obsidian link_new<cr>", mode = "x", desc = "Link → New Note" },
        { "ge", ":Obsidian extract_note<cr>", mode = "x", desc = "Extract → New Note" },
      }
    end,
  },
  -- Optional: pretty Markdown (pick one of these, or remove both)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {},
  },
}
