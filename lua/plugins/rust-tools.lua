return {
  {
    "simrat39/rust-tools.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "rust" },
    config = function()
      local rt = require("rust-tools")

      rt.setup({
        dap = {
          adapter = rt.dap.get_codelldb_adapter(),
        },
      })

      local dap = require("dap")
      dap.configurations.rust = {
        {
          name = "Launch Rust executable",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Prompt for executable or build target (adjust as needed)
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
    end,
  },
}
