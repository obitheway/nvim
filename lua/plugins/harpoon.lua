return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Example keymaps (you can customize these)
      local keymap = vim.keymap.set
      keymap("n", "<leader>a", function()
        harpoon:list():append()
      end, { desc = "Harpoon Add File" })
      keymap("n", "<leader>h", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon Quick Menu" })
      keymap("n", "<leader>1", function()
        harpoon:list():select(1)
      end, { desc = "Harpoon to File 1" })
      keymap("n", "<leader>2", function()
        harpoon:list():select(2)
      end, { desc = "Harpoon to File 2" })
      keymap("n", "<leader>3", function()
        harpoon:list():select(3)
      end, { desc = "Harpoon to File 3" })
      keymap("n", "<leader>4", function()
        harpoon:list():select(4)
      end, { desc = "Harpoon to File 4" })
    end,
  },
}
