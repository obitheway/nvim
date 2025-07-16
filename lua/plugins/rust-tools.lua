return {
  {
    "simrat39/rust-tools.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "rust" },
    config = function()
      local rt = require("rust-tools")

      rt.setup({
        dap = {
          adapter = require("rust-tools.dap").get_codelldb_adapter(
            -- Provide the paths to `codelldb` and `liblldb` here:
            -- Example paths; adjust as needed for your system
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so" -- .dylib for macOS, .dll for Windows
          ),
        },
      })

      -- Optional: Only set this if you need a custom configuration beyond rust-tools
      local dap = require("dap")
      dap.configurations.rust = {
        {
          name = "Launch Rust executable",
          type = "codelldb",
          request = "launch",
          program = function()
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
