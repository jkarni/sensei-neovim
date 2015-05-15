""----------------------------------------------------------------------------
"" sensei-neovim.vim
""
""   Use ":Sensei" to start sensei in a new buffer. In that buffer:
""       n:   go to next filename
""       N:   go to previous filename
""       o:   open filename under cursor
""
""   Note that this requires neovim.
""----------------------------------------------------------------------------


" Shortcuts ------------------------------------------------------------------
command! Sensei call sensei#SenseiSpawn()
