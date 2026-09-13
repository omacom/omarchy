for mount_point in /tmp /var/tmp; do
    if grep -q "^tmpfs $mount_point tmpfs" /etc/fstab; then
        if grep -q "^tmpfs $mount_point tmpfs.*noexec" /etc/fstab; then
            sudo sed -i "s|^tmpfs $mount_point tmpfs.*|tmpfs $mount_point tmpfs defaults,nosuid,nodev,mode=1777 0 0|" /etc/fstab
        fi
    else
        echo "tmpfs $mount_point tmpfs defaults,nosuid,nodev,mode=1777 0 0" | sudo tee -a /etc/fstab
    fi
done
