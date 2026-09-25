echo "Disable system sleep on the DGX Spark, as DGX OS does"

# Suspend has not been shown to work on the Spark. Existing installs predate the
# install-time setting, so apply it here too.
omarchy-hw-dgx-spark || exit 0
[[ -f /etc/systemd/sleep.conf.d/omarchy-dgx-spark.conf ]] && exit 0

sudo bash "$OMARCHY_PATH/install/hardware/nvidia-dgx-spark.sh"
