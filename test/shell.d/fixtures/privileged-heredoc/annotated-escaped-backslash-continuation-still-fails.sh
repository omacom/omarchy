# omarchy:heredoc-expands paths=none -- literal backslash
cat <<EOF | sudo tee /etc/omarchy/dns.conf >/dev/null
value=literal\\
$(printf '%s\n' attacker)
EOF
