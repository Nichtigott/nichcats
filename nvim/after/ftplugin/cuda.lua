-- CUDA LSP using lspconfig (supports direnv clangd priority)
require('lspconfig').clangd.setup {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_dir = require('lspconfig').util.root_pattern(
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac',
    '.git'
  ),
  single_file_support = true,
  capabilities = {
    textDocument = {
      completion = { editsNearCursor = true },
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
}
