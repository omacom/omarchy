echo "Install the IPU7 camera stack on laptops with a Sony IMX471 webcam"

# Not the whole installer: its OVTI08F4 check would reinstall the stack on Meteor Lake
# machines whose owners removed it because it breaks their webcam (#7697).
for imx471 in /sys/bus/acpi/devices/SONY471A:*; do
  if [[ -r $imx471/status ]] && (( $(<"$imx471/status") & 1 )); then
    omarchy-pkg-add intel-ipu7-camera
    break
  fi
done
