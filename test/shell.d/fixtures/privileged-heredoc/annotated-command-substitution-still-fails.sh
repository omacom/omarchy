# omarchy:heredoc-expands paths=none -- command substitution
cat <<EOF | sudo tee /etc/omarchy/dns.conf >/dev/null
value=$(id -u)
EOF
