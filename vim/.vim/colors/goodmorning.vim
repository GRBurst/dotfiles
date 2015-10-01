" Vim color file - goodmorning
set background=light
if version > 580
 hi clear
 if exists("syntax_on")
  syntax reset
 endif
endif

set t_Co=256
let g:colors_name = "goodmorning"

" Self defined syntax groups
hi GuiInactive            guifg=#595959 ctermfg=240 guibg=#c7ffd4 ctermbg=194 guisp=#c7ffd4 gui=NONE 
hi GuiInactiveFull        guifg=#c7ffd4 ctermfg=194 guibg=#c7ffd4 ctermbg=194 guisp=#c7ffd4 gui=NONE 
hi GuiActive              guifg=#000000 ctermfg=0 guibg=#5bcf74 ctermbg=78 guisp=#5bcf74 gui=bold cterm=bold
hi GuiActiveFull          guifg=#5bcf74 ctermfg=78 guibg=#5bcf74 ctermbg=78 guisp=#5bcf74 gui=bold cterm=bold
hi GuiAlternateActive     guifg=#000000 ctermfg=0 guibg=#00C8FF ctermbg=45 guisp=#00C8FF gui=bold cterm=bold
hi GuiAlternateActiveFull guifg=#00C8FF ctermfg=45 guibg=#00C8FF ctermbg=45 guisp=#00C8FF gui=bold cterm=bold
hi GuiHighlight           guifg=#005200 ctermfg=22 guibg=#bbffa6 ctermbg=157 guisp=#bbffa6 gui=NONE 
hi GuiAlternateHighlight  guifg=#000000 ctermfg=0 guibg=#00C8FF ctermbg=45 guisp=#00C8FF gui=NONE cterm=NONE

" General UI
hi Normal guifg=#000000 ctermfg=0 guibg=#ffffff ctermbg=15 guisp=#ffffff gui=NONE 
hi Cursor guifg=#ffffff ctermfg=15 guibg=#000000 ctermbg=0 guisp=NONE gui=NONE 
hi iCursor guifg=#ffffff ctermfg=15 guibg=#5bcf74 ctermbg=78 guisp=NONE gui=NONE 
hi CursorLine guifg=NONE guibg=NONE guisp=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE 
hi! link Cursorlinenr GuiAlternateActive
hi LineNr guifg=#808080 ctermfg=244 guibg=NONE guisp=NONE gui=NONE 
hi! link SignColumn LineNr
hi NonText guifg=#ffffff ctermfg=15 guibg=#ffffff ctermbg=15 guisp=#ffffff gui=NONE 
hi! link StatusLineNC GuiInactive
hi! link StatusLine GuiActive
hi! link ModeMsg GuiAlternateActive
hi! link VertSplit GuiInactiveFull
hi! link WildMenu GuiAlternateActive
hi ErrorMsg guifg=#c90000 ctermfg=1 guibg=#ffe4e4 ctermbg=224 guisp=#ffe4e4 gui=NONE 
hi! link Search GuiHighlight
hi! link IncSearch GuiHighlight
hi! link MatchParen GuiHighlight
hi! link Visual GuiAlternateHighlight
hi SpecialKey guifg=#cfcfcf ctermfg=252 guibg=NONE guisp=NONE gui=NONE 
hi! link Pmenu GuiInactive
hi! link PmenuSel GuiActive
hi! link PmenuThumb GuiAlternateActive
hi! link PMenuSbar GuiInactive
hi DiffAdd guifg=#00660f ctermfg=22 guibg=#d0f0d0 ctermbg=194 guisp=#d0f0d0 gui=NONE 
hi DiffChange guifg=#af5f00 guibg=#ffffaf guisp=#ffffaf gui=NONE ctermfg=130 ctermbg=229 cterm=NONE
hi DiffDelete guifg=#ba0028 ctermfg=124 guibg=#ffd9e9 ctermbg=224 guisp=#ffd9e9 gui=NONE 

" Overwrite default highlighting groups
hi Comment guifg=#8c8c8c ctermfg=245 guibg=NONE guisp=NONE gui=NONE 
hi Constant guifg=#5100ff ctermfg=57 guibg=NONE guisp=NONE gui=NONE 
"cterm=bold
hi Special guifg=#50A000 ctermfg=70 guibg=NONE guisp=NONE gui=NONE 
hi Identifier guifg=#ff0088 ctermfg=198 guibg=NONE guisp=NONE gui=bold cterm=bold
hi Statement guifg=#006fe6 ctermfg=26 guibg=NONE guisp=NONE gui=bold cterm=bold
hi PreProc guifg=#b900de ctermfg=128 guibg=NONE guisp=NONE gui=bold cterm=bold
hi Type guifg=#009CF7 ctermfg=39 guibg=NONE guisp=NONE gui=bold cterm=bold 
hi! link Underlined Normal
hi! link Ignore Normal
hi! link Error ErrorMsg
hi! link Todo GuiAlternateHighlight

" Constant
hi! link Number Constant
hi! link Float Constant
hi Boolean guifg=#ff00ca ctermfg=200 guibg=NONE guisp=NONE gui=NONE 
hi String guifg=#ff6600 ctermfg=202 guibg=NONE guisp=NONE gui=NONE 
hi! link Character String

" Identifier
"hi Function guifg=#ff0088 ctermfg=198 guibg=NONE guisp=NONE gui=bold cterm=bold

" Statement
hi! link Conditional Statement
hi! link Repeat Statement
hi! link Label Statement
hi! link Operator Statement
hi! link Keyword Statement
hi! link Exception Statement

" PreProc
hi! link Include PreProc
hi! link Define PreProc
hi! link Macro PreProc
hi! link PreCondit PreProc

" Type
hi! StorageClass guifg=#00AF2B ctermfg=34 guibg=NONE guisp=NONE gui=bold cterm=bold
hi! link Structure Type
hi! link Typedef Type

" Special
hi SpecialChar guifg=#9D0000 ctermfg=124 guibg=NONE guisp=NONE gui=bold cterm=bold
hi! link Tag Special
hi! link Delemiter Special
hi! link SpecialComment Special
hi! link Debug Special

"TODO: latex, html, bash, tabs


" Java
hi! link JavaStorageClass StorageClass
hi! link JavaParen Statement
hi! link JavaParen1 Type
hi! link JavaParen2 Identifier

" Scala
" StorageClass
hi! ScalaKeyWord guifg=#00AF2B ctermfg=34 guibg=NONE guisp=NONE gui=bold cterm=bold
hi! ScalaKeyWordModifier guifg=#00AF2B ctermfg=34 guibg=NONE guisp=NONE gui=bold cterm=bold
hi! link ScalaInstanceDeclaration Type
hi! link ScalaCapitalWord Type
hi! link ScalaSquareBrackets Statement
hi! link ScalaNameDefinition Statement
hi! link ScalaEscapedChar SpecialChar
hi! link ScalaUnicodeChar SpecialChar
hi! link ScalaStringEmbeddedQuote SpecialChar
hi! link ScalaSpecial PreProc
hi! link ScalaCaseFollowing Statement
hi! link ScalaIString String
hi! link ScalaInterpolation Statement
hi! link ScalaFInterpolation Statement
hi! link ScalaTypeTypePostDeclaration Identifier
hi! link ScalaTypeDeclaration Identifier

" MarkDown
hi! link MarkDownCode Statement
hi! link MarkDownCodeDelimiter Function

" MiniBufExpl
hi! link MBENormal GuiInactive
hi! link MBEChanged GuiInactive
hi! link MBEVisibleNormal GuiInactive
hi! link MBEVisibleChanged GuiInactive
hi! link MBEVisibleActiveNormal GuiActive
hi! link MBEVisibleActiveChanged GuiActive



"hi SignColumn -- no settings --
hi Title guifg=#000000 ctermfg=0 guibg=#ffffff ctermbg=15 guisp=#ffffff gui=bold cterm=bold
hi Folded guifg=#20605c ctermfg=23 guibg=#b8e8dc ctermbg=152 guisp=#b8e8dc gui=NONE 
"hi CTagsMember -- no settings --
"hi CTagsGlobalConstant -- no settings --
hi DiffText guifg=#ba0028 ctermfg=124 guibg=#ffd9e9 ctermbg=224 guisp=#ffd9e9 gui=NONE 
"hi CTagsImport -- no settings --
"hi CTagsGlobalVariable -- no settings --
"hi SpellRare -- no settings --
"hi EnumerationValue -- no settings --
"hi TabLineSel -- no settings --
"hi Union -- no settings --
"hi TabLineFill -- no settings --
hi! link Question Normal
hi WarningMsg guifg=#ff0000 ctermfg=9 guibg=#ffe4e4 ctermbg=224 guisp=#ffe4e4 gui=NONE 
"hi VisualNOS -- no settings --
"hi CursorColumn -- no settings --
hi FoldColumn guifg=#40a098 ctermfg=72 guibg=#f0f0f0 ctermbg=7 guisp=#f0f0f0 gui=NONE 
"hi EnumerationName -- no settings --
hi MoreMsg guifg=#009070 ctermfg=29 guibg=NONE guisp=NONE gui=NONE 
"hi SpellCap -- no settings --
"hi SpellLocal -- no settings --
"hi DefinedName -- no settings --
"hi LocalVariable -- no settings --
"hi SpellBad -- no settings --
"hi CTagsClass -- no settings --
hi Directory guifg=#0070b8 ctermfg=25 guibg=NONE guisp=NONE gui=NONE 
hi Underlined guifg=#ffffff ctermfg=15 guibg=#ffffff ctermbg=15 guisp=#ffffff gui=NONE 
"hi TabLine -- no settings --
"hi lcursor guifg=#f8f8f8 ctermfg=15 guibg=#8000ff ctermbg=93 guisp=#8000ff gui=NONE 
"hi cursorim guifg=#f8f8f8 ctermfg=15 guibg=#8000ff ctermbg=93 guisp=#8000ff gui=NONE 
"hi clear -- no settings --


