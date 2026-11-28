# Pagpapatunay sa hardware

### Pagpapatunay gamit ang fingerprint

Maraming laptop ang may kasamang fingerprint sensor para sa pagpapatunay. Magagamit mo ito sa Omarchy sa pamamagitan ng pagpapatakbo ng _Setup > Security > Fingerprint_ sa menu ng Omarchy (`Super + Space`).

Magbubukas iyon ng full-screen na fingerprint na unti-unting napupuno habang hinahawakan mo ang sensor. Sa likod nito, i-install ng Omarchy ang fingerprint package, kukunin ang iyong print, beberipikahin ito, at handa ka nang gamitin ang iyong fingerprint para mag-unlock mula sa lock screen (na maaari mong buksan gamit ang `Super + Ctrl + L`), pumasok sa sudo mode, at mag-authorize ng mga system prompt.

Kapag pinatay na ng lock screen ang display, magpapahinga ang sensor para makatipid sa kuryente, kaya gisingin muna ang screen gamit ang anumang key o ang touchpad bago ito hawakan.

Kapag nakasara ang takip ng iyong laptop, awtomatikong nilalaktawan ang fingerprint prompt, kaya diretso ka sa password prompt sa halip na maghintay sa isang sensor na hindi mo maabot. Kung kailangan mo namang gumamit ng external keyboard na walang sensor, pindutin lang ang `CTRL + C`, kapag hiningan ka ng iyong fingerprint habang nasa `sudo`.

Maaari mong alisin ang pagpapatunay gamit ang fingerprint sa ilalim ng _Remove > Security > Fingerprint_ sa menu ng Omarchy.

### Pagpapatunay gamit ang Fido2

Kung gumagamit ka ng Fido2 device, maaari mo itong i-set up para sa `sudo` authentication gamit ang _Setup > Security > Fido2_ sa menu ng Omarchy (`Super + Space`). Saklaw nito ang `sudo` at mga system authorization prompt, pero hindi ang pag-unlock ng iyong computer.

Maaari mong alisin ang pagpapatunay gamit ang fido2 sa ilalim ng _Remove > Security > Fido2_ sa menu ng Omarchy.
