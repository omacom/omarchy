add_newline = true
command_timeout = 200
format = "[$directory$git_branch$git_status]($style)$character"

[character]
error_symbol = "[✗](bold {{ red }})"
success_symbol = "[❯](bold {{ accent }})"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold {{ accent }}"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "

[git_branch]
format = "[$branch]($style) "
style = "italic {{ blue }}"

[git_status]
format     = '[$all_status]($style)'
style      = "{{ accent }}"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""
