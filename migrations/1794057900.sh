echo "Install tiny-dfr on Apple Silicon MacBook Pros with a Touch Bar"

# Intel T2 machines removed tiny-dfr in 1785944594 because the kernel drives
# their bar. This leaf's predicate is an Apple Silicon Touch Bar Mac, so a T2
# machine stays without the package and a second user here only repeats the
# idempotent install.
source "$OMARCHY_PATH/install/hardware/apple/touchbar.sh"
