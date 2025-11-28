-- Plugin management with lazy.nvim
-- Works for both nixCats (plugins pre-installed) and standalone (download plugins)

local is_nixCats = type(nixCats) == 'table'

if not is_nixCats then
  -- Bootstrap lazy.nvim for non-Nix systems
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
      error('Error cloning lazy.nvim:\n' .. out)
    end
  end
  vim.opt.rtp:prepend(lazypath)
end

require('lazy').setup({ { import = 'custom.plugins' } }, {
  ui = { icons = {}, border = 'rounded' },
  install = { missing = not is_nixCats },  -- Don't install if nixCats (already have plugins)
  change_detection = { enabled = not is_nixCats },
  performance = {
    reset_packpath = not is_nixCats,  -- Keep Nix packpath
    rtp = {
      reset = not is_nixCats,  -- Keep Nix runtimepath
    },
  },
})
