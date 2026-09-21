# The Spark profile installs these optional applications. Enable system services
# for the next boot; Workbench account access is requested on first launch.
if omarchy-pkg-present nvidia-ai-workbench; then
  nvidia-ctk runtime configure --runtime=docker
fi

if omarchy-pkg-present dgx-dashboard; then
  systemctl enable dgx-dashboard.service
fi
