echo "Add any missing t2fanrd fan sections through Fan4"

# t2fanrd r16 reads [Fan1]..[FanN] for the N fans it detected and exits with
# "Missing FanN in config file" otherwise. Sections past N are never read.
# Installs before this only shipped [Fan1] and [Fan2], so a Mac Pro 2019
# (four fans) crash-loops and the fans stay at minimum (#18007). A missing
# file is left alone: the daemon generates one section per detected fan itself.
fan_conf="${OMARCHY_T2_FAN_CONF:-/etc/t2fand.conf}"

if [[ -f $fan_conf ]]; then
  for fan in 1 2 3 4; do
    if ! grep -Eq "^[[:space:]]*\[Fan${fan}\][[:space:]]*$" "$fan_conf"; then
      sudo tee -a "$fan_conf" >/dev/null <<EOF

[Fan${fan}]
low_temp=55
high_temp=75
speed_curve=linear
always_full_speed=false
EOF
    fi
  done
fi
