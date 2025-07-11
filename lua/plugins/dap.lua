return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
    {
      "williamboman/mason.nvim",
      opts = {
        ensure_installed = {
          "debugpy", -- Python
          "codelldb", -- Rust
          "bash-debug-adapter", -- Bash
        },
      },
    },
    "jay-babu/mason-nvim-dap.nvim",
  },
  -- add keys for laziness

  keys = {
    -- F-keys for power users
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "DAP: Continue",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "DAP: Step Over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "DAP: Step Into",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "DAP: Step Out",
    },

    -- Leader-d group for Lazy and which-key
    {
      "<Leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "DAP: Continue",
    },
    {
      "<Leader>dn",
      function()
        require("dap").step_over()
      end,
      desc = "DAP: Step Over",
    },
    {
      "<Leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "DAP: Step Into",
    },
    {
      "<Leader>do",
      function()
        require("dap").step_out()
      end,
      desc = "DAP: Step Out",
    },
    {
      "<Leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "DAP: Toggle Breakpoint",
    },
    {
      "<Leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "DAP: Toggle REPL",
    },
    {
      "<Leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "DAP: Terminate",
    },
    {
      "<Leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "DAP UI: Toggle",
    },
    {
      "<Leader>dl",
      function()
        require("dap._cmds").show_logs()
      end,
      desc = "DAP: Show Log",
    },
  },

  config = function()
    local dap = require("dap")
    local api = vim.api

    ---------------------------------------
    -- DAP UI
    ---------------------------------------
    require("dapui").setup()
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })

    ---------------------------------------
    require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")

    ---------------------------------------
    -- Rust (codelldb)
    ---------------------------------------
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
        args = { "--port", "${port}" },
      },
    }

    dap.configurations.rust = {
      {
        name = "Launch Rust",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }

    ---------------------------------------
    -- Bash
    ---------------------------------------
    dap.adapters.bashdb = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
      name = "bashdb",
    }

    dap.configurations.sh = {
      {
        type = "bashdb",
        request = "launch",
        name = "Launch Bash script",
        showDebugOutput = true,
        pathBash = "bash",
        program = "${file}",
        cwd = "${workspaceFolder}",
        terminalKind = "integrated",
      },
    }

    ---------------------------------------
    -- User Commands
    ---------------------------------------
    if not api.nvim_create_user_command then
      return
    end
    local cmd = api.nvim_create_user_command

    cmd("DapSetLogLevel", function(opts)
      dap.set_log_level(vim.trim(opts.args))
    end, {
      nargs = 1,
      complete = function()
        return vim.tbl_keys(require("dap.log").levels)
      end,
    })

    cmd("DapShowLog", function()
      require("dap._cmds").show_logs()
    end, { nargs = 0 })
    cmd("DapContinue", function()
      dap.continue()
    end, { nargs = 0 })
    cmd("DapToggleBreakpoint", function()
      dap.toggle_breakpoint()
    end, { nargs = 0 })
    cmd("DapClearBreakpoints", function()
      dap.clear_breakpoints()
    end, { nargs = 0 })
    cmd("DapToggleRepl", function()
      require("dap.repl").toggle()
    end, { nargs = 0 })
    cmd("DapStepOver", function()
      dap.step_over()
    end, { nargs = 0 })
    cmd("DapStepInto", function()
      dap.step_into()
    end, { nargs = 0 })
    cmd("DapStepOut", function()
      dap.step_out()
    end, { nargs = 0 })
    cmd("DapPause", function()
      dap.pause()
    end, { nargs = 0 })
    cmd("DapTerminate", function()
      dap.terminate()
    end, { nargs = 0 })
    cmd("DapDisconnect", function()
      dap.disconnect({ terminateDebuggee = false })
    end, { nargs = 0 })
    cmd("DapRestartFrame", function()
      dap.restart_frame()
    end, { nargs = 0 })

    cmd("DapNew", function(args)
      return require("dap._cmds").new(args)
    end, {
      nargs = "*",
      desc = "Start one or more new debug sessions",
      complete = function()
        return require("dap._cmds").new_complete()
      end,
    })

    cmd("DapEval", function(params)
      require("dap._cmds").eval(params)
    end, {
      nargs = 0,
      range = "%",
      bang = true,
      bar = true,
      desc = "Create a new window & buffer to evaluate expressions",
    })

    if api.nvim_create_autocmd then
      local launchjson_group = api.nvim_create_augroup("dap-launch.json", { clear = true })
      api.nvim_create_autocmd("BufNewFile", {
        group = launchjson_group,
        pattern = "*/.vscode/launch.json",
        callback = function(args)
          require("dap._cmds").newlaunchjson(args)
        end,
      })

      api.nvim_create_autocmd("BufReadCmd", {
        group = api.nvim_create_augroup("dap-readcmds", { clear = true }),
        pattern = "dap-eval://*",
        callback = function()
          require("dap._cmds").bufread_eval()
        end,
      })
    end
  end,
}
