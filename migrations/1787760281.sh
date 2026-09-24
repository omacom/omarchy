echo "Skip the retired Hermes CLI wrapper"

# Superseded. The wrapper this wrote built Hermes through mise, which left it
# with no checkout for `hermes update` to move; a later migration retires that
# copy and installs the self-updating runtime in its place. Nothing to do here.
exit 0
