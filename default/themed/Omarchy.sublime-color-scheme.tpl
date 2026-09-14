{
    "name": "Omarchy",
    "author": "Omarchy",
    "variables":
    {
        "bg": "{{ background }}",
        "fg": "{{ foreground }}",
        "muted": "{{ muted }}",
        "accent": "{{ accent }}",
        "caret": "{{ bright_foreground }}",
        "lighter": "{{ lighter_background }}",
        "red": "{{ red }}",
        "orange": "{{ orange }}",
        "yellow": "{{ yellow }}",
        "green": "{{ green }}",
        "cyan": "{{ cyan }}",
        "blue": "{{ blue }}",
        "magenta": "{{ magenta }}",
        "bright_red": "{{ bright_red }}",
        "bright_yellow": "{{ bright_yellow }}",
        "bright_green": "{{ bright_green }}",
        "bright_cyan": "{{ bright_cyan }}",
        "bright_blue": "{{ bright_blue }}",
        "bright_magenta": "{{ bright_magenta }}",
        "bright_fg": "{{ bright_foreground }}"
    },
    "globals":
    {
        "background": "var(bg)",
        "foreground": "var(fg)",
        "accent": "var(accent)",
        "caret": "var(caret)",
        "block_caret": "color(var(caret) alpha(0.4))",
        "block_caret_border": "var(caret)",
        "line_highlight": "color(var(fg) alpha(0.06))",
        "selection": "color(var(accent) alpha(0.35))",
        "selection_border": "color(var(accent) alpha(0.0))",
        "inactive_selection": "color(var(accent) alpha(0.18))",
        "inactive_selection_border": "color(var(accent) alpha(0.0))",
        "selection_corner_radius": "2",
        "highlight": "var(accent)",
        "find_highlight": "var(yellow)",
        "find_highlight_foreground": "var(bg)",
        "misspelling": "var(red)",
        "shadow": "color(var(bg) alpha(0.5))",
        "gutter": "var(bg)",
        "gutter_foreground": "var(muted)",
        "gutter_foreground_highlight": "var(fg)",
        "line_diff_width": "2",
        "line_diff_added": "var(green)",
        "line_diff_modified": "var(blue)",
        "line_diff_deleted": "var(red)",
        "guide": "color(var(muted) alpha(0.45))",
        "active_guide": "var(accent)",
        "stack_guide": "color(var(accent) alpha(0.45))",
        "brackets_options": "underline",
        "brackets_foreground": "var(accent)",
        "bracket_contents_options": "underline",
        "bracket_contents_foreground": "var(cyan)",
        "tags_options": "stippled_underline",
        "tags_foreground": "var(magenta)",
        "fold_marker": "var(accent)",
        "minimap_border": "color(var(muted) alpha(0.3))"
    },
    "rules":
    [
        {
            "name": "Comment",
            "scope": "comment, punctuation.definition.comment",
            "foreground": "var(muted)",
            "font_style": "italic"
        },
        {
            "name": "String",
            "scope": "string",
            "foreground": "var(green)"
        },
        {
            "name": "String Key",
            "scope": "meta.mapping.key string - meta.mapping.key meta meta | meta.mapping.key meta.mapping.key string - meta.mapping.key meta.mapping.key meta meta",
            "foreground": "var(cyan)"
        },
        {
            "name": "String Escape",
            "scope": "constant.character.escape, string punctuation.definition.escape",
            "foreground": "var(bright_cyan)"
        },
        {
            "name": "Regexp",
            "scope": "string.regexp",
            "foreground": "var(bright_cyan)"
        },
        {
            "name": "Punctuation definition",
            "scope": "punctuation.definition - punctuation.definition.numeric.base",
            "foreground": "var(cyan)"
        },
        {
            "name": "Number",
            "scope": "constant.numeric",
            "foreground": "var(orange)"
        },
        {
            "name": "Number suffix",
            "scope": "storage.type.numeric",
            "foreground": "var(magenta)",
            "font_style": "italic"
        },
        {
            "name": "Language constant",
            "scope": "constant.language",
            "foreground": "var(red)",
            "font_style": "italic"
        },
        {
            "name": "User constant",
            "scope": "constant.character, constant.other",
            "foreground": "var(magenta)"
        },
        {
            "name": "Member",
            "scope": "variable.member, variable.other.member, variable.other.property, support.other.property",
            "foreground": "var(cyan)"
        },
        {
            "name": "Keyword",
            "scope": "keyword - keyword.operator, keyword.operator.word",
            "foreground": "var(bright_magenta)"
        },
        {
            "name": "Operator",
            "scope": "keyword.operator",
            "foreground": "var(bright_blue)"
        },
        {
            "name": "Separator",
            "scope": "punctuation.separator, punctuation.terminator",
            "foreground": "var(muted)"
        },
        {
            "name": "Section punctuation",
            "scope": "punctuation.section",
            "foreground": "var(fg)"
        },
        {
            "name": "Accessor",
            "scope": "punctuation.accessor",
            "foreground": "var(muted)"
        },
        {
            "name": "Annotation punctuation",
            "scope": "punctuation.definition.annotation",
            "foreground": "var(cyan)"
        },
        {
            "name": "Storage",
            "scope": "storage",
            "foreground": "var(bright_magenta)"
        },
        {
            "name": "Storage type",
            "scope": "storage.type",
            "foreground": "var(magenta)",
            "font_style": "italic"
        },
        {
            "name": "Function",
            "scope": "entity.name.function",
            "foreground": "var(blue)"
        },
        {
            "name": "Type name",
            "scope": "entity.name - (entity.name.section | entity.name.tag | entity.name.label | entity.name.function)",
            "foreground": "var(yellow)"
        },
        {
            "name": "Inherited class",
            "scope": "entity.other.inherited-class",
            "foreground": "var(cyan)",
            "font_style": "italic"
        },
        {
            "name": "Parameter",
            "scope": "variable.parameter",
            "foreground": "var(cyan)",
            "font_style": "italic"
        },
        {
            "name": "Language variable",
            "scope": "variable.language",
            "foreground": "var(red)",
            "font_style": "italic"
        },
        {
            "name": "Tag",
            "scope": "entity.name.tag",
            "foreground": "var(red)"
        },
        {
            "name": "Attribute",
            "scope": "entity.other.attribute-name",
            "foreground": "var(magenta)"
        },
        {
            "name": "Function call",
            "scope": "variable.function, variable.annotation",
            "foreground": "var(blue)"
        },
        {
            "name": "Library function",
            "scope": "support.function, support.macro",
            "foreground": "var(cyan)",
            "font_style": "italic"
        },
        {
            "name": "Library constant",
            "scope": "support.constant",
            "foreground": "var(magenta)",
            "font_style": "italic"
        },
        {
            "name": "Library type",
            "scope": "support.type, support.class",
            "foreground": "var(yellow)",
            "font_style": "italic"
        },
        {
            "name": "Invalid",
            "scope": "invalid",
            "foreground": "var(bright_fg)",
            "background": "var(red)"
        },
        {
            "name": "Deprecated",
            "scope": "invalid.deprecated",
            "foreground": "var(bright_fg)",
            "background": "var(orange)"
        },
        {
            "name": "YAML key",
            "scope": "entity.name.tag.yaml",
            "foreground": "var(cyan)"
        },
        {
            "name": "YAML unquoted string",
            "scope": "source.yaml string.unquoted",
            "foreground": "var(fg)"
        },
        {
            "name": "CSS property",
            "scope": "support.type.property-name",
            "foreground": "var(fg)"
        },
        {
            "name": "Markup heading",
            "scope": "markup.heading",
            "font_style": "bold"
        },
        {
            "name": "Markup heading punctuation",
            "scope": "markup.heading punctuation.definition.heading",
            "foreground": "var(orange)"
        },
        {
            "name": "Markup h1",
            "scope": "markup.heading.1 punctuation.definition.heading",
            "foreground": "var(red)"
        },
        {
            "name": "Markup link",
            "scope": "string.other.link, markup.underline.link",
            "foreground": "var(blue)"
        },
        {
            "name": "Markup bold",
            "scope": "markup.bold",
            "font_style": "bold"
        },
        {
            "name": "Markup italic",
            "scope": "markup.italic",
            "font_style": "italic"
        },
        {
            "name": "Markup underline",
            "scope": "markup.underline",
            "font_style": "underline"
        },
        {
            "name": "Markup hr",
            "scope": "punctuation.definition.thematic-break",
            "foreground": "var(orange)"
        },
        {
            "name": "Markup list",
            "scope": "markup.list.numbered.bullet, markup.list punctuation.definition.list_item",
            "foreground": "var(green)"
        },
        {
            "name": "Markup quote",
            "scope": "markup.quote punctuation.definition.blockquote",
            "foreground": "var(magenta)"
        },
        {
            "name": "Markup code",
            "scope": "markup.raw",
            "foreground": "var(green)",
            "background": "color(var(fg) alpha(0.06))"
        },
        {
            "name": "Diff header",
            "scope": "meta.diff, meta.diff.header",
            "foreground": "var(magenta)"
        },
        {
            "name": "Diff deleted",
            "scope": "markup.deleted, diff.deleted",
            "foreground": "var(red)"
        },
        {
            "name": "Diff inserted",
            "scope": "markup.inserted, diff.inserted",
            "foreground": "var(green)"
        },
        {
            "name": "Diff changed",
            "scope": "markup.changed, diff.changed",
            "foreground": "var(orange)"
        },
        {
            "scope": "diff.deleted",
            "background": "color(var(red) alpha(0.15))"
        },
        {
            "scope": "diff.deleted.char",
            "background": "color(var(red) alpha(0.30))"
        },
        {
            "scope": "diff.inserted",
            "background": "color(var(green) alpha(0.15))"
        },
        {
            "scope": "diff.inserted.char",
            "background": "color(var(green) alpha(0.30))"
        },
        {
            "scope": "constant.numeric.line-number.match",
            "foreground": "var(red)"
        },
        {
            "scope": "message.error",
            "foreground": "var(red)"
        },
        {
            "scope": "message.warning",
            "foreground": "var(yellow)"
        },
        {
            "scope": "message.info",
            "foreground": "var(blue)"
        }
    ]
}
