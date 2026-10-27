# Pagpapatunay gamit ang hardware

### Pagpapatunay gamit ang fingerprint

Maraming laptop ang may fingerprint sensor para sa pagpapatunay. Magagamit mo ito sa Omarchy sa pamamagitan ng pagpapatakbo ng _Setup > Security > Fingerprint_ sa menu ng Omarchy (`Super + Space`).

Iyon ang mag-i-install ng fingerprint package, kukunin ang print mo, ive-verify ito, at handa ka nang gamitin ang fingerprint mo para mag-unlock mula sa lock screen (na maaari mong i-trigger gamit ang `Super + Ctrl + L`), pumasok sa sudo mode, at mag-awtorisa ng mga system prompt.

Kapag pinatay na ng lock screen ang display, nagpapahinga ang sensor para makatipid ng kuryente, kaya gisingin muna ang screen gamit ang anumang key o ang touchpad bago ito hawakan.

Kapag nakasara ang takip ng laptop mo, awtomatikong nilalaktawan ang fingerprint prompt, kaya diretso ka sa password prompt sa halip na maghintay sa sensor na hindi mo maabot. Kung kailangan mong magtrabaho gamit ang external keyboard na walang sensor, pindutin lang ang `CTRL + C` kapag na-prompt ka para sa fingerprint mo habang nasa `sudo`.

Maaari mong alisin ang pagpapatunay gamit ang fingerprint sa ilalim ng _Remove > Security > Fingerprint_ sa menu ng Omarchy.

### Pagpapatunay gamit ang Fido2

Kung gumagamit ka ng Fido2 device, maaari mo itong i-setup para sa pagpapatunay sa `sudo` gamit ang _Setup > Security > Fido2_ sa menu ng Omarchy (`Super + Space`). Sakop nito ang `sudo` at ang mga system authorization prompt, pero hindi ang pag-unlock ng computer mo.

Maaari mong alisin ang pagpapatunay gamit ang fido2 sa ilalim ng _Remove > Security > Fido2_ sa menu ng Omarchy.
