if exists("g:buffet_loaded")
    finish
endif

let g:buffet_loaded = 1

let g:buffet_always_show_tabline = get(g:, "buffet_always_show_tabline", 0)

let g:buffet_use_devicons = get(g:,"buffet_use_devicons",0)

augroup buffet_show_tabline
    autocmd!
    autocmd VimEnter,BufAdd,TabEnter * set showtabline=2
augroup END

if has("gui")
    if !get(g:, "buffet_use_gui_tablne", 0)
        set guioptions-=e
    endif
endif

if get(g:, "buffet_powerline_separators", 0)
    let g:buffet_powerline_separators = 1
    let g:buffet_noseparator = "\ue0b0"
    let g:buffet_separator = "\ue0b1"
else
    let g:buffet_powerline_separators = 0
    let g:buffet_noseparator = get(g:, "buffet_noseparator", " ")
    let g:buffet_separator = get(g:, "buffet_separator", "|")
endif

let g:buffet_show_index = get(g:, "buffet_show_index", 1)

let g:buffet_max_plug = get(g:, "buffet_max_plug", 10)


if !exists("g:buffet_modified_icon")
    let g:buffet_modified_icon = "+"
endif

if !exists("g:buffet_left_trunc_icon")
    let g:buffet_left_trunc_icon = "\uf0a8"
endif

if !exists("g:buffet_right_trunc_icon")
    let g:buffet_right_trunc_icon = "\uf0a9"
endif

if !exists("g:buffet_new_buffer_name")
    let g:buffet_new_buffer_name = "*"
endif

if !exists("g:buffet_tab_icon")
    let g:buffet_tab_icon = "\uf00a"
endif

let g:buffet_prefix = "Buffet"
let g:buffet_has_separator = {
            \     "Tab": {
            \         "Tab": g:buffet_separator,
            \         "LeftTrunc": g:buffet_separator,
            \         "End" : g:buffet_separator,
            \     },
            \     "LeftTrunc": {
            \         "Buffer": g:buffet_separator,
            \         "CurrentBuffer": g:buffet_separator,
            \         "ActiveBuffer": g:buffet_separator,
            \         "ModBuffer": g:buffet_separator,
            \     },
            \     "RightTrunc": {
            \         "Tab": g:buffet_separator,
            \         "End": g:buffet_separator,
            \     },
            \ }

let g:buffet_buffer_types = [
            \    "Buffer",
            \    "ActiveBuffer",
            \    "CurrentBuffer",
            \    "ModBuffer",
            \    "ModActiveBuffer",
            \    "ModCurrentBuffer",
            \ ]

for s:type in g:buffet_buffer_types
    let g:buffet_has_separator["Tab"][s:type] = g:buffet_separator
    let g:buffet_has_separator[s:type] = {
                \     "RightTrunc": g:buffet_separator,
                \     "Tab": g:buffet_separator,
                \     "End": g:buffet_separator,
                \ }

    for s:t in g:buffet_buffer_types
        let g:buffet_has_separator[s:type][s:t] = g:buffet_separator
    endfor
endfor

function! s:GetHiAttr(name, attr)
    let vim_mode = "cterm"
    let attr_suffix = ""
    if has("gui")
        let vim_mode = "gui"
        let attr_suffix = "#"
    endif

    let value = synIDattr(synIDtrans(hlID(a:name)), a:attr . attr_suffix, vim_mode)

    return value
endfunction

function! s:SetHi(name, fg, bg)
    let vim_mode = "cterm"
    if has("gui")
        let vim_mode = "gui"
    endif

    let spec = ""
    if a:fg != ""
        let fg_spec = vim_mode . "fg=" . a:fg
        let spec = fg_spec
    endif

    if a:bg != ""
        let bg_spec = vim_mode . "bg=" . a:bg

        if spec != ""
            let bg_spec = " " . bg_spec
        endif

        let spec = spec . bg_spec
    endif

    if spec != ""
        exec "silent hi! " . a:name . " " . spec
    endif
endfunction

function! s:LinkHi(name, target)
    exec "silent hi! link " . a:name . " " . a:target
endfunction

function! s:GetBackGroundColor()
   let bgcolor = synIDattr(hlID("Normal"), "bg")
   if bgcolor ==''
       return 'NONE'
   else
       return bgcolor
   endif
endfunction

function! s:SetColors()
    let buffermidcolor = s:GetBackGroundColor()
    " TODO: try to match user's colorscheme
    " Issue: https://github.com/bagrat/vim-buffet/issues/5
    " if get(g:, "buffet_match_color_scheme", 1)

    hi! BuffetCurrentBuffer cterm=NONE ctermbg=106 ctermfg=8 guibg=#b8bb26 guifg=#000000
    hi! BuffetTrunc cterm=bold ctermbg=10 ctermfg=8 guibg=##999999 guifg=#000000
    hi! BuffetTab cterm=NONE ctermbg=203 ctermfg=8 guibg=#FF5555 guifg=#000000
    hi! BuffetActiveBuffer cterm=NONE ctermbg=10 ctermfg=239 guibg=#504945 guifg=#000000
    hi! BuffetBuffer cterm=NONE  ctermfg=10 guibg=buffermidcolor guifg=#504945

    hi! link BuffetModCurrentBuffer BuffetCurrentBuffer
    hi! link BuffetModActiveBuffer BuffetActiveBuffer
    hi! link BuffetModBuffer BuffetBuffer


    hi! link BuffetLeftTrunc BuffetTrunc
    hi! link BuffetRightTrunc BuffetTrunc
    hi! link BuffetEnd BuffetBuffer

    if exists("*g:BuffetSetCustomColors")
        call g:BuffetSetCustomColors()
    endif

    for left in keys(g:buffet_has_separator)
        for right in keys(g:buffet_has_separator[left])
            let vim_mode = "cterm"
            if has("gui")
                let vim_mode = "gui"
            endif

            let left_hi = g:buffet_prefix . left
            let right_hi = g:buffet_prefix . right
            let left_bg = s:GetHiAttr(left_hi, 'bg')
            let right_bg = s:GetHiAttr(right_hi, 'bg')

            if left_bg == ""
                let left_bg = "NONE"
            endif

            if right_bg == ""
                let right_bg = "NONE"
            endif

            let sep_hi = g:buffet_prefix . left . right
            if left_bg != right_bg
                let g:buffet_has_separator[left][right] = g:buffet_noseparator

                call s:SetHi(sep_hi, left_bg, right_bg)
            else
                let g:buffet_has_separator[left][right] = g:buffet_separator

                call s:LinkHi(sep_hi, left_hi)
            endif
        endfor
    endfor
endfunction

augroup buffet_set_colors
    autocmd!
    autocmd ColorScheme * call s:SetColors()
augroup end

" Set solors also at the startup
call s:SetColors()

if has("nvim")
    function! SwitchToBuffer(buffer_id, clicks, btn, flags)
        exec "silent buffer " . a:buffer_id
    endfunction
endif

function! buffet#bwipe_nerdtree_filter(bang, buffer)
    let is_in_nt = 0
    if exists("t:NERDTreeBufName")
        let ntwinnr = bufwinnr(t:NERDTreeBufName)

        if ntwinnr == winnr()
            let is_in_nt = 1
        endif
    endif

    if is_in_nt
        return 1
    endif
endfunction

let g:buffet_bwipe_filters = ["buffet#bwipe_nerdtree_filter"]

for s:n in range(1, g:buffet_max_plug)
    execute printf("noremap <silent> <Plug>BuffetSwitch(%d) :call buffet#bswitch(%d)<cr>", s:n, s:n)
endfor

command! -bang -complete=buffer -nargs=? Bw call buffet#bwipe(<q-bang>, <q-args>)
command! -bang -complete=buffer -nargs=? Bonly call buffet#bonly(<q-bang>, <q-args>)

set tabline=%!buffet#render()
