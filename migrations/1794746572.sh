echo "Install the OEM firmware packages added since the first run"

# Five Lenovo laptops got firmware packages after 1793650506.sh had run on
# most machines: the IdeaPad 5x 2-in-1, IdeaPad Slim 5x, IdeaPad Slim 3x,
# ThinkBook 16 G7 QOY and Flex 5G. Run it again so installed machines get
# theirs. It installs nothing on a machine whose firmware is all there.
source "$OMARCHY_PATH/migrations/1793650506.sh"
