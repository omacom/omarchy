echo "Set Limine default boot entry to the first entry"

target_conf="${OMARCHY_LIMINE_CONF:-}"
if [[ -n $target_conf ]]; then
  configs=("$target_conf")
else
  configs=(/boot/limine.conf)
  if [[ -f /etc/default/limine ]]; then
    esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -1)
    if [[ -n $esp && -f "$esp/limine.conf" && "$esp/limine.conf" != "/boot/limine.conf" ]]; then
      configs+=("$esp/limine.conf")
    fi
  fi
fi

enroll_config=false
for conf in "${configs[@]}"; do
  if [[ -f $conf ]] && grep -qE '^[[:space:]]*default_entry:[[:space:]]*2[[:space:]]*$' "$conf"; then
    sudo sed -i -E 's/^([[:space:]]*default_entry:[[:space:]]*)2([[:space:]]*)$/\11\2/' "$conf"
  fi
  # Also enroll an already-updated config so a failed enrollment is retried.
  if [[ -f $conf ]] && grep -qE '^[[:space:]]*default_entry:[[:space:]]*1[[:space:]]*$' "$conf"; then
    enroll_config=true
  fi
done

if [[ $enroll_config == "true" ]]; then
  sudo limine-enroll-config
fi
