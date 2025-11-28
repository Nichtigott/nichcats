local is_nixCats = type(nixCats) == 'table'

return {
  'nvim-treesitter/nvim-treesitter',
  build = not is_nixCats and ':TSUpdate' or nil,
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require 'custom.config.treesitter'
  end,
}
