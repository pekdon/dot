set nocompatible
set showmatch
set mouse=
" highlight search results
set hlsearch
" autoindent depending on file type
set autoindent
filetype plugin indent on
set number
" column at 80 characters
set cc=80
" bash-like tab completion
set wildmode=longest,list

call plug#begin()
Plug 'airblade/vim-gitgutter'
Plug 'cdelledonne/vim-cmake'
Plug 'editorconfig/editorconfig-vim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
call plug#end()

lua <<EOF
local nvim_lsp = require('lspconfig')
-- nvim_lsp.clangd.setup{}
-- nvim_lsp.ccls.setup {
--   init_options = {
--       compilationDatabaseDirectory = "build";
--   }
-- }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- local servers = { 'clangd' }
-- for _, lsp in ipairs(servers) do
--   nvim_lsp[lsp].setup {
--     on_attach = on_attach,
--     flags = {
--       debounce_text_changes = 150,
--     }
--   }
-- end

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "erlang", "lua", "python" },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
EOF
