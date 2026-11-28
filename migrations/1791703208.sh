echo "Cap CPU package power on T2 MacBooks to avoid BMS power cuts"

# Fresh installs run this leaf through install/hardware/all.sh; existing
# installs reach it here so both populations share one implementation. The
# leaf guards on a T2 MacBook itself and is idempotent. Sourced, so it
# runs under the migration's errexit: a failed step fails the migration and
# it is retried.
source "$OMARCHY_PATH/install/hardware/apple/battery-cpu-limit.sh"
