echo "Restore USB and Thunderbolt behavior before automatic device approval"

source "$OMARCHY_PATH/install/helpers/accessory-authorization-rollback.sh"
accessory_authorization_rollback
