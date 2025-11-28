return {
  'saghen/blink.cmp',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    'L3MON4D3/LuaSnip',
    'rafamadriz/friendly-snippets',
  },
  opts = {
    keymap = {
      preset = 'default',
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      menu = {
        draw = {
          columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
        },
      },
    },
    signature = {
      enabled = true,
    },
    cmdline = {
      completion = {
        menu = { auto_show = true },
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = { score_offset = 40 },
        path = { score_offset = 50 },
        snippets = { score_offset = 40 },
        buffer = { score_offset = 10 },
      },
    },
    snippets = { preset = 'luasnip' },
  },
}
