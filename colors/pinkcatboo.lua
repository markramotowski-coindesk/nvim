-- Pink Cat Boo — Neovim port of the VSCode theme
-- Source: ~/.vscode/extensions/ftsamoyed.theme-pink-cat-boo-1.3.0 (by Fiona Fan)
-- Palette and syntax mapping generated to match the VSCode theme's colors.

local c = {
  -- surfaces
  bg         = "#202330", -- editor.background
  bg_dark    = "#1b1e29", -- darker (floats border bg / dashboard)
  bg_sidebar = "#2d2f42", -- sideBar.background
  bg_float   = "#2a2c3d",
  bg_high    = "#472541", -- lineHighlight / selection (plum)
  bg_visual  = "#573050",
  bg_sel     = "#3a3d52", -- inactive selection / menu sel

  -- text
  fg        = "#fff0f5", -- editor.foreground (lavender white)
  fg_dark   = "#c9bcc4",
  fg_muted  = "#9498a1", -- tab.inactiveForeground
  gutter    = "#565a74", -- line numbers
  cursor    = "#ffedf0",

  -- pinks
  pink      = "#fe7c8e", -- primary accent (focus, active tab, button)
  pink_soft = "#f3b4bf", -- statusbar
  magenta   = "#ff4791", -- keyword
  hotpink   = "#ff38a2", -- number
  rose      = "#eba4ac", -- variable
  tagpink   = "#fa508c", -- tag
  classpink = "#f5a6c6", -- class name
  constpink = "#ff7f9d", -- character/other constant

  -- warm
  gold      = "#fec831", -- storage
  amber     = "#ffc85b", -- function name
  yellow    = "#fae8b6", -- string
  headgold  = "#d0b344", -- headings / sql
  bracket   = "#d0963a",

  -- greens
  green     = "#58b896", -- builtin constant / hint / git add
  green2    = "#37e884", -- inherited class
  param     = "#9cd162", -- parameter

  -- blues / purples
  blue      = "#a2c2eb", -- support function / info
  blue2     = "#94afe8", -- support type
  cyan      = "#73b5d7",
  purple    = "#dcbff2", -- storage.type / property
  purple2   = "#e6a1ff", -- attribute
  debug     = "#b267e6",

  -- states
  error     = "#ff62a5",
  warn      = "#fec831",
  info      = "#a2c2eb",
  hint      = "#58b896",

  -- git / diff
  add       = "#58b896",
  change    = "#e5ac40",
  delete    = "#ff62a5",
  diff_add  = "#26352f",
  diff_del  = "#3b2530",
  diff_chg  = "#39331f",
  diff_text = "#4a4326",

  none      = "NONE",
}

local function setup()
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "pinkcatboo"

  local hl = vim.api.nvim_set_hl
  local function h(group, spec)
    hl(0, group, spec)
  end

  local groups = {
    -- ── Editor UI ────────────────────────────────────────────────
    Normal       = { fg = c.fg, bg = c.bg },
    NormalNC     = { fg = c.fg, bg = c.bg },
    NormalFloat  = { fg = c.fg, bg = c.bg_float },
    FloatBorder  = { fg = c.pink, bg = c.bg_float },
    FloatTitle   = { fg = c.pink, bg = c.bg_float, bold = true },
    ColorColumn  = { bg = c.bg_sidebar },
    Cursor       = { fg = c.bg, bg = c.cursor },
    lCursor      = { fg = c.bg, bg = c.cursor },
    CursorLine   = { bg = c.bg_high },
    CursorColumn = { bg = c.bg_high },
    CursorLineNr = { fg = c.pink, bold = true },
    LineNr       = { fg = c.gutter },
    SignColumn   = { fg = c.gutter, bg = c.bg },
    Folded       = { fg = c.fg_muted, bg = c.bg_sidebar },
    FoldColumn   = { fg = c.gutter, bg = c.bg },
    VertSplit    = { fg = c.bg_sel },
    WinSeparator = { fg = c.bg_sel },
    Visual       = { bg = c.bg_visual },
    VisualNOS    = { bg = c.bg_visual },
    Search       = { fg = c.bg, bg = c.gold },
    IncSearch    = { fg = c.bg, bg = c.pink },
    CurSearch    = { fg = c.bg, bg = c.pink },
    MatchParen   = { fg = c.gold, bold = true, underline = true },
    NonText      = { fg = c.bg_sel },
    Whitespace   = { fg = c.bg_sel },
    SpecialKey   = { fg = c.bg_sel },
    EndOfBuffer  = { fg = c.bg },
    Winbar       = { fg = c.fg_muted, bg = c.none },
    WinbarNC     = { fg = c.fg_muted, bg = c.none },

    Pmenu        = { fg = c.fg, bg = c.bg_float },
    PmenuSel     = { fg = c.fg, bg = c.bg_high, bold = true },
    PmenuSbar    = { bg = c.bg_sidebar },
    PmenuThumb   = { bg = c.pink_soft },
    WildMenu     = { fg = c.bg, bg = c.pink },

    StatusLine   = { fg = c.fg, bg = c.bg_sidebar },
    StatusLineNC = { fg = c.fg_muted, bg = c.bg_sidebar },
    TabLine      = { fg = c.fg_muted, bg = c.bg_sidebar },
    TabLineFill  = { bg = c.bg_dark },
    TabLineSel   = { fg = c.pink, bg = c.bg },

    MsgArea      = { fg = c.fg },
    ModeMsg      = { fg = c.fg, bold = true },
    MoreMsg      = { fg = c.pink },
    Question     = { fg = c.green },
    ErrorMsg     = { fg = c.error, bold = true },
    WarningMsg   = { fg = c.warn },
    Title        = { fg = c.pink, bold = true },
    Directory    = { fg = c.blue },
    QuickFixLine = { bg = c.bg_high, bold = true },

    -- ── Legacy syntax groups ─────────────────────────────────────
    Comment        = { fg = "#6d7a72", italic = true },
    Constant       = { fg = c.constpink },
    String         = { fg = c.yellow },
    Character      = { fg = c.constpink },
    Number         = { fg = c.hotpink },
    Float          = { fg = c.hotpink },
    Boolean        = { fg = c.green },
    Identifier     = { fg = c.rose },
    Function       = { fg = c.amber },
    Statement      = { fg = c.magenta },
    Conditional    = { fg = c.magenta },
    Repeat         = { fg = c.magenta },
    Label          = { fg = c.magenta },
    Operator       = { fg = c.pink },
    Keyword        = { fg = c.magenta },
    Exception      = { fg = c.magenta },
    PreProc        = { fg = c.gold },
    Include        = { fg = c.magenta },
    Define         = { fg = c.gold },
    Macro          = { fg = c.gold },
    PreCondit      = { fg = c.gold },
    Type           = { fg = c.purple, italic = true },
    StorageClass   = { fg = c.gold },
    Structure      = { fg = c.blue2, italic = true },
    Typedef        = { fg = c.purple, italic = true },
    Special        = { fg = c.amber },
    SpecialChar    = { fg = c.constpink },
    Tag            = { fg = c.tagpink },
    Delimiter      = { fg = c.fg_dark },
    SpecialComment = { fg = c.fg_muted, italic = true },
    Debug          = { fg = c.debug },
    Underlined     = { underline = true },
    Bold           = { bold = true },
    Italic         = { italic = true },
    Error          = { fg = c.error },
    Todo           = { fg = c.bg, bg = c.gold, bold = true },

    -- ── Diagnostics ──────────────────────────────────────────────
    DiagnosticError = { fg = c.error },
    DiagnosticWarn  = { fg = c.warn },
    DiagnosticInfo  = { fg = c.info },
    DiagnosticHint  = { fg = c.hint },
    DiagnosticOk    = { fg = c.green },
    DiagnosticUnderlineError = { undercurl = true, sp = c.error },
    DiagnosticUnderlineWarn  = { undercurl = true, sp = c.warn },
    DiagnosticUnderlineInfo  = { undercurl = true, sp = c.info },
    DiagnosticUnderlineHint  = { undercurl = true, sp = c.hint },
    DiagnosticVirtualTextError = { fg = c.error, bg = "#2f1f2b" },
    DiagnosticVirtualTextWarn  = { fg = c.warn, bg = "#2f2a1c" },
    DiagnosticVirtualTextInfo  = { fg = c.info, bg = "#22283a" },
    DiagnosticVirtualTextHint  = { fg = c.hint, bg = "#1f2e2a" },

    -- ── Treesitter ───────────────────────────────────────────────
    ["@comment"]              = { link = "Comment" },
    ["@comment.todo"]         = { fg = c.bg, bg = c.gold, bold = true },
    ["@comment.note"]         = { fg = c.bg, bg = c.info, bold = true },
    ["@comment.warning"]      = { fg = c.bg, bg = c.warn, bold = true },
    ["@comment.error"]        = { fg = c.bg, bg = c.error, bold = true },
    ["@variable"]             = { fg = c.rose },
    ["@variable.builtin"]     = { fg = c.constpink, italic = true },
    ["@variable.parameter"]   = { fg = c.param, italic = true },
    ["@variable.member"]      = { fg = c.purple },
    ["@constant"]             = { fg = c.constpink },
    ["@constant.builtin"]     = { fg = c.green },
    ["@constant.macro"]       = { fg = c.gold },
    ["@module"]               = { fg = c.blue2 },
    ["@label"]                = { fg = c.magenta },
    ["@string"]               = { fg = c.yellow },
    ["@string.escape"]        = { fg = c.constpink },
    ["@string.regexp"]        = { fg = c.param },
    ["@string.special"]       = { fg = c.amber },
    ["@character"]            = { fg = c.constpink },
    ["@number"]               = { fg = c.hotpink },
    ["@number.float"]         = { fg = c.hotpink },
    ["@boolean"]              = { fg = c.green },
    ["@function"]             = { fg = c.amber },
    ["@function.builtin"]     = { fg = c.blue, bold = true },
    ["@function.call"]        = { fg = c.amber },
    ["@function.macro"]       = { fg = c.gold },
    ["@function.method"]      = { fg = c.amber },
    ["@function.method.call"] = { fg = c.amber },
    ["@constructor"]          = { fg = c.classpink },
    ["@keyword"]              = { fg = c.magenta },
    ["@keyword.function"]     = { fg = c.magenta },
    ["@keyword.operator"]     = { fg = c.magenta },
    ["@keyword.return"]       = { fg = c.magenta },
    ["@keyword.import"]       = { fg = c.magenta },
    ["@keyword.conditional"]  = { fg = c.magenta },
    ["@keyword.repeat"]       = { fg = c.magenta },
    ["@keyword.exception"]    = { fg = c.magenta },
    ["@operator"]             = { fg = c.pink },
    ["@punctuation.delimiter"]= { fg = c.fg_dark },
    ["@punctuation.bracket"]  = { fg = c.fg_muted },
    ["@punctuation.special"]  = { fg = c.pink },
    ["@type"]                 = { fg = c.purple, italic = true },
    ["@type.builtin"]         = { fg = c.blue2, italic = true },
    ["@type.definition"]      = { fg = c.purple, italic = true },
    ["@type.qualifier"]       = { fg = c.gold },
    ["@attribute"]            = { fg = c.purple2 },
    ["@property"]             = { fg = c.purple },
    ["@field"]                = { fg = c.rose },
    ["@namespace"]            = { fg = c.blue2 },

    -- markup / markdown
    ["@markup.heading"]       = { fg = c.headgold, bold = true },
    ["@markup.raw"]           = { fg = "#ff0080" },
    ["@markup.link"]          = { fg = c.cyan, underline = true },
    ["@markup.link.label"]    = { fg = c.tagpink },
    ["@markup.list"]          = { fg = c.cyan },
    ["@markup.quote"]         = { fg = "#9e6dbc", italic = true },
    ["@markup.strong"]        = { fg = c.pink, bold = true },
    ["@markup.italic"]        = { fg = c.blue, italic = true },

    -- html / jsx / css
    ["@tag"]                  = { fg = c.tagpink },
    ["@tag.builtin"]          = { fg = c.tagpink },
    ["@tag.attribute"]        = { fg = c.purple2 },
    ["@tag.delimiter"]        = { fg = c.fg },

    -- ── LSP semantic tokens ──────────────────────────────────────
    ["@lsp.type.class"]         = { fg = c.classpink },
    ["@lsp.type.decorator"]     = { fg = c.purple2 },
    ["@lsp.type.enum"]          = { fg = c.blue2, italic = true },
    ["@lsp.type.enumMember"]    = { fg = c.green },
    ["@lsp.type.function"]      = { fg = c.amber },
    ["@lsp.type.interface"]     = { fg = c.blue2, italic = true },
    ["@lsp.type.macro"]         = { fg = c.gold },
    ["@lsp.type.method"]        = { fg = c.amber },
    ["@lsp.type.namespace"]     = { fg = c.blue2 },
    ["@lsp.type.parameter"]     = { fg = c.param, italic = true },
    ["@lsp.type.property"]      = { fg = c.purple },
    ["@lsp.type.struct"]        = { fg = c.blue2, italic = true },
    ["@lsp.type.type"]          = { fg = c.purple, italic = true },
    ["@lsp.type.variable"]      = { fg = c.rose },
    ["@lsp.typemod.variable.readonly"] = { fg = c.constpink },
    ["@lsp.typemod.variable.global"]   = { fg = c.rose },

    -- ── Git / diff ───────────────────────────────────────────────
    DiffAdd      = { bg = c.diff_add },
    DiffChange   = { bg = c.diff_chg },
    DiffDelete   = { bg = c.diff_del },
    DiffText     = { bg = c.diff_text },
    diffAdded    = { fg = c.add },
    diffRemoved  = { fg = c.delete },
    diffChanged  = { fg = c.change },
    Added        = { fg = c.add },
    Removed      = { fg = c.delete },
    Changed      = { fg = c.change },

    GitSignsAdd    = { fg = c.add },
    GitSignsChange = { fg = c.change },
    GitSignsDelete = { fg = c.delete },

    -- ── nvim-cmp / blink.cmp ─────────────────────────────────────
    CmpItemAbbr            = { fg = c.fg_dark },
    CmpItemAbbrMatch       = { fg = c.pink, bold = true },
    CmpItemAbbrMatchFuzzy  = { fg = c.pink, bold = true },
    CmpItemKind            = { fg = c.purple },
    CmpItemMenu            = { fg = c.fg_muted },
    BlinkCmpLabel          = { fg = c.fg_dark },
    BlinkCmpLabelMatch     = { fg = c.pink, bold = true },
    BlinkCmpKind           = { fg = c.purple },
    BlinkCmpMenuBorder     = { fg = c.pink, bg = c.bg_float },

    -- ── Telescope ────────────────────────────────────────────────
    TelescopeNormal        = { fg = c.fg, bg = c.bg_float },
    TelescopeBorder        = { fg = c.pink, bg = c.bg_float },
    TelescopeTitle         = { fg = c.pink, bold = true },
    TelescopePromptNormal  = { fg = c.fg, bg = c.bg_sidebar },
    TelescopePromptBorder  = { fg = c.pink, bg = c.bg_sidebar },
    TelescopePromptTitle   = { fg = c.bg, bg = c.pink, bold = true },
    TelescopePreviewTitle  = { fg = c.bg, bg = c.green, bold = true },
    TelescopeResultsTitle  = { fg = c.bg_float, bg = c.bg_float },
    TelescopeSelection     = { bg = c.bg_high },
    TelescopeMatching      = { fg = c.pink, bold = true },

    -- ── Snacks (LazyVim default picker/dashboard) ────────────────
    SnacksPickerDir        = { fg = c.fg_muted },
    SnacksPickerMatch      = { fg = c.pink, bold = true },
    SnacksPickerBorder     = { fg = c.pink, bg = c.bg_float },
    SnacksPickerGitStatusUntracked = { fg = c.delete }, -- new files red, not grey (snacks links it to NonText)
    SnacksPickerPathHidden  = { fg = c.fg }, -- hidden files same colour as normal files (snacks links it to NonText)
    SnacksDashboardHeader  = { fg = c.pink },
    SnacksDashboardDesc    = { fg = c.fg },
    SnacksDashboardIcon    = { fg = c.gold },
    SnacksDashboardKey     = { fg = c.hotpink },
    SnacksDashboardFooter  = { fg = c.fg_muted },
    SnacksIndent           = { fg = c.bg_sel },
    SnacksIndentScope      = { fg = c.pink },

    -- ── Neo-tree ─────────────────────────────────────────────────
    NeoTreeNormal          = { fg = c.fg, bg = c.bg_sidebar },
    NeoTreeNormalNC        = { fg = c.fg, bg = c.bg_sidebar },
    NeoTreeDirectoryName   = { fg = c.blue },
    NeoTreeDirectoryIcon   = { fg = c.blue },
    NeoTreeRootName        = { fg = c.pink, bold = true },
    NeoTreeFileName        = { fg = c.fg },
    NeoTreeGitModified     = { fg = c.change },
    NeoTreeGitAdded        = { fg = c.add },
    NeoTreeGitDeleted      = { fg = c.delete },
    NeoTreeIndentMarker    = { fg = c.bg_sel },

    -- ── WhichKey ─────────────────────────────────────────────────
    WhichKey          = { fg = c.pink },
    WhichKeyGroup     = { fg = c.blue },
    WhichKeyDesc      = { fg = c.fg },
    WhichKeySeparator = { fg = c.fg_muted },
    WhichKeyFloat     = { bg = c.bg_float },
    WhichKeyBorder    = { fg = c.pink, bg = c.bg_float },

    -- ── bufferline ───────────────────────────────────────────────
    BufferLineFill              = { bg = c.bg_dark },
    BufferLineBackground        = { fg = c.fg_muted, bg = c.bg_sidebar },
    BufferLineBufferSelected    = { fg = c.pink, bg = c.bg, bold = true },
    BufferLineBufferVisible     = { fg = c.fg_muted, bg = c.bg_sidebar },
    BufferLineModified          = { fg = c.green },
    BufferLineModifiedSelected  = { fg = c.green },
    BufferLineIndicatorSelected = { fg = c.pink },

    -- ── notify / mini / flash ────────────────────────────────────
    NotifyERRORBorder = { fg = c.error }, NotifyERRORTitle = { fg = c.error },
    NotifyWARNBorder  = { fg = c.warn },  NotifyWARNTitle  = { fg = c.warn },
    NotifyINFOBorder  = { fg = c.info },  NotifyINFOTitle  = { fg = c.info },
    MiniIndentscopeSymbol = { fg = c.pink },
    IndentBlanklineChar   = { fg = c.bg_sel },
    IblScope              = { fg = c.pink },
    FlashLabel            = { fg = c.bg, bg = c.pink, bold = true },

    -- ── LSP references / inlay hints ─────────────────────────────
    LspReferenceText  = { bg = "#4747a1" },
    LspReferenceRead  = { bg = "#4747a1" },
    LspReferenceWrite = { bg = "#6767ce" },
    LspInlayHint      = { fg = c.gutter, bg = c.bg_sidebar, italic = true },
    LspSignatureActiveParameter = { fg = c.pink, bold = true },
  }

  for group, spec in pairs(groups) do
    h(group, spec)
  end

  -- terminal colors
  vim.g.terminal_color_0  = c.bg
  vim.g.terminal_color_1  = c.magenta
  vim.g.terminal_color_2  = c.green
  vim.g.terminal_color_3  = c.gold
  vim.g.terminal_color_4  = c.blue
  vim.g.terminal_color_5  = c.purple
  vim.g.terminal_color_6  = c.cyan
  vim.g.terminal_color_7  = c.fg
  vim.g.terminal_color_8  = c.gutter
  vim.g.terminal_color_9  = c.hotpink
  vim.g.terminal_color_10 = c.green2
  vim.g.terminal_color_11 = c.amber
  vim.g.terminal_color_12 = c.blue2
  vim.g.terminal_color_13 = c.pink
  vim.g.terminal_color_14 = c.cyan
  vim.g.terminal_color_15 = c.fg
end

setup()
