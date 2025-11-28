-- LSP Configuration with blink.cmp integration
-- Uses lspconfig for direnv compatibility (picks up LSPs from PATH)
return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'saghen/blink.cmp',
  },
  config = function()
    require 'custom.config.lsp'
  end,
}
