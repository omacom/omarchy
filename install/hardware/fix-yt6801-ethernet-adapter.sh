# Fresh installs use the kernel's upstream dwmac-motorcomm driver and do not
# install yt6801-dkms. Existing systems retire that fallback in migration
# 1788279117 only after proving the running kernel alias and every live binding;
# a manual hardware-setup rerun must not remove it ahead of that cutover.
