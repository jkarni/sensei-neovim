""----------------------------------------------------------------------------
"" sensei.vim
""
""   Use ":Sensei" to start sensei in a new buffer. In that buffer:
""       n:   go to next filename
""       N:   go to previous filename
""       o:   open filename under cursor
""
""   Note that this requires neovim.
""----------------------------------------------------------------------------

" For non-nix, uncomment the following line
"let g:sensei_cmd = "sensei -idoctest/ghci-wrapper/src -isrc -itest test/Spec.hs"

" Configurable vars ----------------------------------------------------------
function! <SID>InitVar(var, value)
    " Initialize variable if not already set
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

call <SID>InitVar("g:senseiLocRegex", "[^ :]*:[0-9]\\+:.*(best-effort)")
call <SID>InitVar("g:ghcLocRegex", "[^ :]*:[0-9]\\+:\[0-9]*:")
call <SID>InitVar("g:allLocRegex", "\\m\\(" . g:senseiLocRegex . "\\|" . g:ghcLocRegex . "\\)")
call <SID>InitVar("g:sensei_cmd", "sensei")
call <SID>InitVar("g:sensei_default_options", "test/Spec.hs")
call <SID>InitVar("g:sensei_width", 80)
call <SID>InitVar("g:sensei_window_loc", "right")

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
    set filetype=sensei
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
function! <SID>SenseiSpawn()
    let splitLocation = g:sensei_window_loc ==# "left" ? "topleft " : "botright "
    silent! execute splitLocation . 'vertical ' . g:sensei_width . ' split'
    set winfixwidth
    enew | let t:sensei_term_id = termopen(g:sensei_cmd)
    let t:sensei_buf = bufnr('%')
    let sensei_pattern = 'term://*//'.string(b:terminal_job_pid).':*'
    let onbufenter = 'autocmd BufEnter ' . sensei_pattern . '* call <SID>OnBufEnter()'
    let onbufleave = 'autocmd BufLeave ' . sensei_pattern . '* call <SID>OnBufLeave()'
    augroup Sensei
        autocmd!
        execute onbufenter
        execute onbufleave
    augroup END
    call <SID>OnBufEnter()
endfunction

" Shortcuts ------------------------------------------------------------------
command! Sensei call <SID>SenseiSpawn()
