# PAM password quality hardening
sudo tee /etc/security/pwquality.conf >/dev/null <<'EOF'
minlen = 16
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
difok = 5
minclass = 4
maxrepeat = 3
maxclassrepeat = 3
gecoscheck = 1
dictcheck = 1
usercheck = 1
enforcing = 1
retry = 3
EOF

# Login access control: only root and wheel locally
sudo tee /etc/security/access.conf >/dev/null <<'EOF'
+:root:LOCAL
+:wheel:LOCAL
-:ALL:ALL
EOF

# Tighter faillock: 3 attempts, 5 minute unlock
sudo sed -i 's|^deny = .*|deny = 3|' /etc/security/faillock.conf
sudo sed -i 's|^unlock_time = .*|unlock_time = 300|' /etc/security/faillock.conf
grep -q '^deny' /etc/security/faillock.conf || echo 'deny = 3' | sudo tee -a /etc/security/faillock.conf
grep -q '^unlock_time' /etc/security/faillock.conf || echo 'unlock_time = 300' | sudo tee -a /etc/security/faillock.conf
