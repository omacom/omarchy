# The platform package's own setup for this user, last so it builds on every
# other leaf (omarchy-lifecycle-dispatch setup-user, see
# docs/lifecycle-dispatch.md). A no-op where the platform registers none. In an
# image build the detector would read the build host, so it waits for first run
# on the machine, which runs it again.
if [[ -e ${OMARCHY_IMAGE_ROOT:-}/var/lib/omarchy/image/target ]]; then
  echo "Image build: the platform's user setup waits for first run on the machine"
else
  omarchy-lifecycle-dispatch setup-user
fi
