if ! grep -q '^tmpfs /tmp tmpfs' /etc/fstab; then
    echo 'tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev,mode=1777 0 0' | sudo tee -a /etc/fstab
fi

if ! grep -q '^tmpfs /var/tmp tmpfs' /etc/fstab; then
    echo 'tmpfs /var/tmp tmpfs defaults,noexec,nosuid,nodev,mode=1777 0 0' | sudo tee -a /etc/fstab
fi
