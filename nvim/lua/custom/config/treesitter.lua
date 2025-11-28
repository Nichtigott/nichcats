local is_nixCats = type(nixCats) == 'table'

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
  -- In nixCats, parsers are provided by Nix, no need to install
  ensure_installed = is_nixCats and {} or {
    'bash',
    'python',
    'cpp',
    'diff',
    'html',
    'xml',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'query',
    'vim',
    'vimdoc',
    'snakemake',
  },
  ignore_install = {
    'latex',
  },
  auto_install = not is_nixCats,  -- Disable auto-install for nixCats
  highlight = {
    enable = true,
    disable = { 'latex' },
    additional_vim_regex_highlighting = { 'ruby' },
  },
  disable = function(lang, bufnr)
    return lang == 'yaml' and vim.api.nvim_buf_line_count(bufnr) > 5000
  end,
  indent = { enable = true, disable = { 'ruby' } },
}
