""----------------------------------------------------------------------------
"" autospec.vim
""
""   Use ":Autospec" to start autospec in a new buffer. In that buffer:
""       n:   go to next filename
""       N:   go to previous filename
""       o:   open filename under cursor
""
""   Note that this requires neovim.
""----------------------------------------------------------------------------

" For non-nix, uncomment the following line
"let g:autospec_cmd = "autospec -idoctest/ghci-wrapper/src -isrc -itest test/Spec.hs"

" Configurable vars ----------------------------------------------------------
function! <SID>InitVar(var, value)
    " Initialize variable if not already set
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

call <SID>InitVar("g:autospecLocRegex", "[^ :]*:[0-9]\\+:.*(best-effort)")
call <SID>InitVar("g:ghcLocRegex", "[^ :]*:[0-9]\\+:\[0-9]*:")
call <SID>InitVar("g:allLocRegex", "\\m\\(" . g:autospecLocRegex . "\\|" . g:ghcLocRegex . "\\)")
call <SID>InitVar("g:autospec_cmd", "autospec")
call <SID>InitVar("g:autospec_default_options", "test/Spec.hs")
call <SID>InitVar("g:autospec_width", 80)
call <SID>InitVar("g:autospec_window_loc", "right")

" Internal functions ---------------------------------------------------------

function! <SID>Search()
    " Search for the appropriate regex, and update the search register
    " accordingly
    let t:oldSearch = @/
    execute "silent! normal! G?" . g:allLocRegex . "\<CR>"
    let @/ = g:allLocRegex
endfunction

function! <SID>ClearSearch()
    " Set the search register to whatever it previously was
    if exists("t:oldSearch")
        let @/ = t:oldSearch
    endif
    if exists("t:oldHlSearch")
        let &hlsearch = t:oldHlSearch
    endif
endfunction

function! <SID>OpenFile()
    " Opens the file under the cursor
    let win_width = winwidth(".")
    execute "normal! vertical wincmd F"
endfunction

" Hooks ----------------------------------------------------------------------
function! <SID>OnBufEnter()
    set filetype=autospec
    setlocal isfname-=:
    let t:oldHlSearch = &hlsearch
    set hlsearch
    nnoremap <buffer> o :vertical wincmd F<CR>
    call <SID>Search()
    execute "silent! normal! N"
endfunction

function! <SID>OnBufLeave()
    call <SID>ClearSearch()
endfunction

" Main -----------------------------------------------------------------------
function! <SID>AutoSpecSpawn()
    let splitLocation = g:autospec_window_loc ==# "left" ? "topleft " : "botright "
    silent! execute splitLocation . 'vertical ' . g:autospec_width . ' split'
    set winfixwidth
    enew | let t:autospec_term_id = termopen(g:autospec_cmd)
    let t:autospec_buf = bufnr('%')
    let autospec_pattern = 'term://*//'.string(b:terminal_job_pid).':*'
    let onbufenter = 'autocmd BufEnter ' . autospec_pattern . '* call <SID>OnBufEnter()'
    let onbufleave = 'autocmd BufLeave ' . autospec_pattern . '* call <SID>OnBufLeave()'
    augroup AutoSpec
        autocmd!
        execute onbufenter
        execute onbufleave
    augroup END
    call <SID>OnBufEnter()
endfunction

" Shortcuts ------------------------------------------------------------------
command! Autospec call <SID>AutoSpecSpawn()
