" Inspired by lunaperche, a vim build-in themes authored by Maxim Kim. Thanks
" he/she excellent work.
" License: MIT License

hi clear
let g:colors_name = 'hueless'

let g:terminal_ansi_colors = ['#000000', '#af5f5f', '#5faf5f', '#af875f', '#5f87af', '#d787d7', '#5fafaf', '#c6c6c6', '#767676', '#ff5f5f', '#5fd75f', '#ffd787', '#5fafff', '#ff87ff', '#5fd7d7', '#ffffff']

hi! link helpVim Title
hi! link helpHeader Title
hi! link helpHyperTextJump Underlined
hi! link fugitiveSymbolicRef PreProc
hi! link fugitiveHeading Statement
hi! link fugitiveStagedHeading Statement
hi! link fugitiveUnstagedHeading Statement
hi! link fugitiveUntrackedHeading Statement
hi! link fugitiveStagedModifier PreProc
hi! link fugitiveUnstagedModifier PreProc
hi! link fugitiveHash Constant
hi! link diffFile PreProc
hi! link markdownHeadingDelimiter Special
hi! link rstSectionDelimiter Statement
hi! link rstDirective PreProc
hi! link rstHyperlinkReference Special
hi! link rstFieldName Constant
hi! link rstDelimiter Special
hi! link rstInterpretedText Special
hi! link rstCodeBlock Normal
hi! link rstLiteralBlock rstCodeBlock
hi! link markdownUrl String
hi! link colortemplateKey Statement
hi! link xmlTagName Statement
hi! link javaScriptFunction Statement
hi! link javaScriptIdentifier Statement
hi! link sqlKeyword Statement
hi! link yamlBlockMappingKey Statement
hi! link rubyMacro Statement
hi! link rubyDefine Statement
hi! link vimGroup Normal
hi! link vimVar Normal
hi! link vimOper Normal
hi! link vimSep Normal
hi! link vimParenSep Normal
hi! link vimOption Normal
hi! link vimCommentString Comment
hi! link pythonInclude Statement
hi! link shQuote Constant
hi! link shNoQuote Normal
hi! link shTestOpr Normal
hi! link shOperator Normal
hi! link shSetOption Normal
hi! link shOption Normal
hi! link shCommandSub Normal
hi! link shDerefPattern shQuote
hi! link shDerefOp Special
hi! link phpStorageClass Statement
hi! link phpStructure Statement
hi! link phpInclude Statement
hi! link phpDefine Statement
hi! link phpSpecialFunction Normal
hi! link phpParent Normal
hi! link phpComparison Normal
hi! link phpOperator Normal
hi! link phpVarSelector Special
hi! link phpMemberSelector Special
hi! link phpDocCustomTags phpDocTags
hi! link javaExternal Statement
hi! link javaType Statement
hi! link javaScopeDecl Statement
hi! link javaClassDecl Statement
hi! link javaStorageClass Statement
hi! link javaDocParam PreProc
hi! link csStorage Statement
hi! link csAccessModifier Statement
hi! link csClass Statement
hi! link csModifier Statement
hi! link csAsyncModifier Statement
hi! link csLogicSymbols Normal
hi! link csClassType Normal
hi! link csType Statement
hi! link Terminal Normal
hi! link StatuslineTerm Statusline
hi! link StatuslineTermNC StatuslineNC
hi! link LineNrAbove LineNr
hi! link LineNrBelow LineNr
hi! link MessageWindow PMenu
hi! link PopupNotification Todo
hi! link PopupSelected PmenuSel
hi Normal guifg=#c6c6c6 guibg=#000000 gui=NONE cterm=NONE
hi Statusline guifg=#c6c6c6 guibg=#000000 gui=bold,reverse cterm=bold,reverse
hi StatuslineNC guifg=#767676 guibg=#000000 gui=reverse cterm=reverse
hi VertSplit guifg=#767676 guibg=#767676 gui=NONE cterm=NONE
hi TabLine guifg=#000000 guibg=#c6c6c6 gui=NONE cterm=NONE
hi TabLineFill guifg=NONE guibg=#767676 gui=NONE cterm=NONE
hi TabLineSel guifg=#ffffff guibg=#000000 gui=bold cterm=bold
hi ToolbarLine guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi ToolbarButton guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
hi QuickFixLine guifg=#000000 guibg=#5fafff gui=NONE cterm=NONE
hi CursorLineNr guifg=#ffffff guibg=NONE gui=bold cterm=bold
hi LineNr guifg=#585858 guibg=NONE gui=NONE cterm=NONE
hi NonText guifg=#585858 guibg=NONE gui=NONE cterm=NONE
hi FoldColumn guifg=#585858 guibg=NONE gui=NONE cterm=NONE
hi SpecialKey guifg=#585858 guibg=NONE gui=NONE cterm=NONE
hi EndOfBuffer guifg=#585858 guibg=NONE gui=NONE cterm=NONE
hi Pmenu guifg=NONE guibg=#303030 gui=NONE cterm=NONE
hi PmenuSel guifg=NONE guibg=#4e4e4e gui=NONE cterm=NONE
hi PmenuThumb guifg=NONE guibg=#c6c6c6 gui=NONE cterm=NONE
hi PmenuSbar guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi PmenuKind guifg=#ff5f5f guibg=#303030 gui=NONE cterm=NONE
hi PmenuKindSel guifg=#ff5f5f guibg=#4e4e4e gui=NONE cterm=NONE
hi PmenuExtra guifg=#767676 guibg=#303030 gui=NONE cterm=NONE
hi PmenuExtraSel guifg=#767676 guibg=#4e4e4e gui=NONE cterm=NONE
hi PmenuMatch guifg=#d787d7 guibg=#303030 gui=NONE cterm=NONE
hi PmenuMatchSel guifg=#d787d7 guibg=#4e4e4e gui=NONE cterm=NONE
hi SignColumn guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi Error guifg=#ffffff guibg=#ff5f5f gui=NONE cterm=NONE
hi ErrorMsg guifg=#ffffff guibg=#ff5f5f gui=NONE cterm=NONE
hi ModeMsg guifg=#ffd787 guibg=NONE gui=reverse cterm=reverse
hi MoreMsg guifg=#5fd75f guibg=NONE gui=NONE cterm=NONE
hi Question guifg=#ff87ff guibg=NONE gui=NONE cterm=NONE
hi WarningMsg guifg=#ff5f5f guibg=NONE gui=NONE cterm=NONE
hi Todo guifg=#5fd7d7 guibg=#000000 gui=reverse cterm=reverse
hi Search guifg=#000000 guibg=#ffd787 gui=NONE cterm=NONE
hi IncSearch guifg=#000000 guibg=#5fd75f gui=NONE cterm=NONE
hi CurSearch guifg=#000000 guibg=#5fd75f gui=NONE cterm=NONE
hi WildMenu guifg=#000000 guibg=#ffd787 gui=bold cterm=bold
hi debugPC guifg=#5f87af guibg=NONE gui=reverse cterm=reverse
hi debugBreakpoint guifg=#5fafaf guibg=NONE gui=reverse cterm=reverse
hi Cursor guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
hi lCursor guifg=#ff5fff guibg=#000000 gui=reverse cterm=reverse
hi Visual guifg=#ffffff guibg=#005f87 gui=NONE cterm=NONE
hi MatchParen guifg=#ff00af guibg=NONE gui=bold cterm=bold
hi VisualNOS guifg=#000000 guibg=#5fafaf gui=NONE cterm=NONE
hi CursorLine guifg=NONE guibg=#262626 gui=NONE cterm=NONE
hi CursorColumn guifg=NONE guibg=#262626 gui=NONE cterm=NONE
hi Folded guifg=#767676 guibg=#303030 gui=NONE cterm=NONE
hi ColorColumn guifg=NONE guibg=#303030 gui=NONE cterm=NONE
hi SpellBad guifg=NONE guibg=NONE guisp=#ff5f5f gui=undercurl ctermfg=NONE ctermbg=NONE cterm=NONE
hi SpellCap guifg=NONE guibg=NONE guisp=#5fafaf gui=undercurl ctermfg=NONE ctermbg=NONE cterm=NONE
hi SpellLocal guifg=NONE guibg=NONE guisp=#5faf5f gui=undercurl ctermfg=NONE ctermbg=NONE cterm=NONE
hi SpellRare guifg=NONE guibg=NONE guisp=#ff87ff gui=undercurl ctermfg=NONE ctermbg=NONE cterm=NONE
hi Comment guifg=#5fafff guibg=NONE gui=NONE cterm=NONE
hi Constant guifg=#ff87ff guibg=NONE gui=NONE cterm=NONE
hi String guifg=#5fd75f guibg=NONE gui=NONE cterm=NONE
hi Identifier guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi Statement guifg=#e4e4e4 guibg=NONE gui=bold cterm=bold
hi Type guifg=#ffd787 guibg=NONE gui=NONE cterm=NONE
hi PreProc guifg=#5fd7d7 guibg=NONE gui=NONE cterm=NONE
hi Special guifg=#5fafaf guibg=NONE gui=NONE cterm=NONE
hi Underlined guifg=NONE guibg=NONE gui=underline ctermfg=NONE ctermbg=NONE cterm=underline
hi Title guifg=NONE guibg=NONE gui=bold ctermfg=NONE ctermbg=NONE cterm=bold
hi Directory guifg=#5fafff guibg=NONE gui=bold cterm=bold
hi Conceal guifg=#585858 guibg=NONE gui=NONE cterm=NONE
hi Ignore guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi DiffAdd guifg=#c6c6c6 guibg=#875f87 gui=NONE cterm=NONE
hi DiffChange guifg=#c6c6c6 guibg=#5f5f5f gui=NONE cterm=NONE
hi DiffText guifg=#afffff guibg=#5f8787 gui=NONE cterm=NONE
hi DiffDelete guifg=#d78787 guibg=NONE gui=NONE cterm=NONE
hi Added guifg=#5fd75f guibg=NONE gui=NONE cterm=NONE
hi Changed guifg=#5fafff guibg=NONE gui=NONE cterm=NONE
hi Removed guifg=#d78787 guibg=NONE gui=NONE cterm=NONE
hi diffSubname guifg=#ff87ff guibg=NONE gui=NONE cterm=NONE
hi dirType guifg=#d787d7 guibg=NONE gui=NONE cterm=NONE
hi dirPermissionUser guifg=#5faf5f guibg=NONE gui=NONE cterm=NONE
hi dirPermissionGroup guifg=#af875f guibg=NONE gui=NONE cterm=NONE
hi dirPermissionOther guifg=#5fafaf guibg=NONE gui=NONE cterm=NONE
hi dirOwner guifg=#767676 guibg=NONE gui=NONE cterm=NONE
hi dirGroup guifg=#767676 guibg=NONE gui=NONE cterm=NONE
hi dirTime guifg=#767676 guibg=NONE gui=NONE cterm=NONE
hi dirSize guifg=#ffd787 guibg=NONE gui=NONE cterm=NONE
hi dirSizeMod guifg=#d787d7 guibg=NONE gui=NONE cterm=NONE
hi FilterMenuDirectorySubtle guifg=#878787 guibg=NONE gui=NONE cterm=NONE
hi dirFilterMenuBookmarkPath guifg=#878787 guibg=NONE gui=NONE cterm=NONE
hi dirFilterMenuHistoryPath guifg=#878787 guibg=NONE gui=NONE cterm=NONE
hi FilterMenuLineNr guifg=#878787 guibg=NONE gui=NONE cterm=NONE
hi CocSearch guifg=#ffd787 guibg=NONE gui=NONE cterm=NONE

" Background: dark
" Color: color00                 #000000        16             black
" Color: color08                 #767676        243            darkgrey
" Color: color01                 #AF5F5F        131            darkred
" Color: color09                 #FF5F5F        203            red
" Color: color02                 #5FAF5F        71             darkgreen
" Color: color10                 #5FD75F        77             green
" Color: color03                 #AF875F        137            darkyellow
" Color: color11                 #FFD787        222            yellow
" Color: color04                 #5F87AF        67             darkblue
" Color: color12                 #5FAFFF        75             blue
" Color: color05                 #D787D7        176            darkmagenta
" Color: color13                 #FF87FF        213            magenta
" Color: color06                 #5FAFAF        73             darkcyan
" Color: color14                 #5FD7D7        116            cyan
" Color: color07                 #C6C6C6        251            grey
" Color: color15                 #FFFFFF        231            white
" Color: colorDimWhite           #E4E4E4        254            grey
" Color: colorLine               #262626        235            darkgrey
" Color: colorB                  #303030        236            darkgrey
" Color: colorNonT               #585858        240            grey
" Color: colorTab                #585858        240            grey
" Color: colorC                  #FFFFFF        231            white
" Color: colorlC                 #FF5FFF        207            magenta
" Color: colorV                  #005F87        24             darkblue
" Color: colorMP                 #ff00af        199            magenta
" Color: colorPMenuSel           #4e4e4e        239            darkcyan
" Color: colorDim                #878787        102            grey
" Color: diffAdd                 #875f87        96             darkmagenta
" Color: diffDelete              #D78787        174            darkred
" Color: diffChange              #5f5f5f        59             darkgreen
" Color: diffText                #5f8787        66             cyan
" Color: fgDiffText              #afffff        159            black
" Color: fgDiff                  #C6C6C6        251            white
" vim: et ts=8 sw=2 sts=2
