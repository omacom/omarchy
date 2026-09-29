echo "Cap Intel CPU power on battery to avoid BMS power cuts"

# Fresh installs run this leaf through install/hardware/all.sh; existing
# installs reach it here so both populations share one implementation. The
# leaf guards on Intel + battery itself and is idempotent.
bash "$OMARCHY_PATH/install/hardware/intel/battery-cpu-limit.sh"
