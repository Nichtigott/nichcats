-- Python LSP using lspconfig
require('lspconfig').pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
      },
    },
  },
}
require('lspconfig').ruff.setup {}
