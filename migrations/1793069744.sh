echo "Recheck FIDO2 authfile paths previously marked repaired"

# The original repair returned success for symlinked or non-regular authfiles.
# Recheck even when that migration already has a completion marker. Unresolved
# paths now fail and remain pending until the user reviews and repairs them.
source "$OMARCHY_PATH/migrations/1787494718.sh"
