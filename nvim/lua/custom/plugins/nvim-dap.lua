---@diagnostic disable: missing-parameter
return {
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    config = function()
      require 'custom.config.debugger'
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'theHamsta/nvim-dap-virtual-text', 'nvim-neotest/nvim-nio' },
    keys = {
      '<leader>db',
      '<leader>ds',
      '<leader>du',
      '<F1>',
      '<F2>',
      '<F3>',
      '<F4>',
      '<F5>',
      '<F6>',
      '<F7>',
    },
    config = function()
      require('nvim-dap-virtual-text').setup() -- optional
      local ok, noice = pcall(require, 'noice')
      if ok then
        noice.setup()
      end
      require 'custom.config.dapui'
    end,
  },
  { -- python debugger
    'mfussenegger/nvim-dap-python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
    },
    keys = {
      { '<leader>db', ft = 'python' },
      { '<leader>ds', ft = 'python' },
      { '<leader>du', ft = 'python' },
    },
    config = function()
      -- Find python with debugpy:
      -- 1. Try direnv/project-provided python (via which)
      -- 2. Try nixCats python3 host
      -- 3. Fall back to Mason path (for non-Nix systems)
      local python_path

      -- Check if debugpy is available in current python
      local handle = io.popen 'python3 -c "import debugpy; print(debugpy.__file__)" 2>/dev/null'
      if handle then
        local result = handle:read '*a'
        handle:close()
        if result and result ~= '' then
          python_path = vim.fn.exepath 'python3'
        end
      end

      -- Fallback to nixCats python host if available
      if not python_path and vim.g.python3_host_prog then
        python_path = vim.g.python3_host_prog
      end

      -- Last resort: Mason path (for non-Nix systems)
      if not python_path then
        python_path = '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
      end

      require('dap-python').setup(python_path)
    end,
  },
}
