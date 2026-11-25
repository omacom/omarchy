# Pagsisimula

Ini-install ang Omarchy gamit ang isang ISO. Maaari kang pumili sa pagitan ng full-disk install, na sumasakop sa buong drive, o free-space install, na naglalagay sa Omarchy sa hindi pa nakalaang espasyo sa isang drive — ganyan ka magdu-dual boot kasama ng Windows o ng ibang OS (tingnan ang [dual-boot install](50-dual-boot-install.md) — tandaan na kailangan mo munang i-off ang BitLocker sa Windows). Alinman ang piliin mo, naka-full encryption ang installation bilang default, at buburahin ng full-disk na opsyon ang napiling drive, kaya siguraduhing mag-backup bago gamitin ang isang kasalukuyang drive!

Sa isang Apple Silicon Mac, mag-i-install ka mula sa macOS sa halip, nang walang ISO o USB stick. Tingnan ang [Omarchy for Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[I-download muna ang Omarchy ISO](https://omarchy.org/), ilagay ito sa isang USB stick (gamitin ang [Rufus](https://rufus.ie/) sa Windows, [balenaEtcher](https://etcher.balena.io/) sa Mac, o [caligula](https://github.com/ifd3f/caligula) sa Linux), at mag-boot mula sa stick.

_Kailangan mong i-off ang Secure Boot at/o TPM sa BIOS. Kailangan mong i-off ang mga ito para makapag-install ng Omarchy. Mga scheme ng seguridad ito ng Microsoft na para sa Windows at sa mga Linux distribution na kaakibat ng Microsoft._

Pagkatapos ay sagutin ang mga tanong sa configuration, at kumpirmahin ang mga ito nang ganito:

 ![install-config](images/install-config.webp)

Pagkatapos ay pumili ng drive para sa iyong installation, at maupo na lang at panoorin ang palabas ng installation. Matatapos ito sa loob ng wala pang isang minuto sa pinakamabilis na mga modernong makina, pero hindi ito dapat tumagal nang higit sa 5 minuto kahit sa isang mas lumang computer.

 ![install-done](images/install-done.webp)

Handa ka nang mag-Omarchy!

### Gumamit ng wired o 2.4ghz na keyboard!

Hindi ka hahayaan ng full-disk encryption na ilagay ang password mula sa isang Bluetooth keyboard sa startup. Tulad ng hindi mo magagamit ang isang Bluetooth keyboard para pumasok sa BIOS sa isang PC. Kailangan mo ng keyboard na gumagamit ng 2.4ghz dongle o ng cable (na mas maganda rin naman para sa latency!). Personal kong gustong-gusto ang [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Pag-install para sa ibang may-ari

Kung nagse-setup ka ng makina para sa ibang tao — isang kapamilya, isang bagong empleyado, isang mamimili — hindi mo dapat sagutin ang mga personal na tanong para sa kanila. Pindutin ang `Ctrl + C` sa pinakaunang screen ng installer (ang pagpili ng keyboard), at aalukin ka ng Omarchy na ihanda ang makina para sa ibang may-ari sa halip. Agad na mai-install ang system, pero ang lahat ng personal na setup — keyboard layout, username, password — ay ipagpapaliban hanggang sa unang mag-boot ang makina. Naka-encrypt pa rin ang drive bilang default, at ang password na pipiliin ng bagong may-ari sa unang boot na iyon ang magiging encryption password din. (Ang makinang nagamit mo na ay maaari ring ibigay nang walang reinstall — tingnan ang [resetting the computer](48-security.md).)

### Mga unattended install

Maaari ring mag-install nang kusa ang ISO — walang keyboard, walang wizard — kapag ibinigay dito ang configuration nito sa isang pangalawang drive. Iyan ang paraan para ituring ang Omarchy bilang isang base image para sa mga VM at fleet machine. Tingnan ang [unattended installs](51-unattended-installs.md).

### Mga install na walang encryption

Ini-install ang Omarchy nang may encryption bilang default. Ito ang ligtas at responsableng pagpipilian para sa anumang computer na posibleng mawala o manakaw. Ayaw mong makuha ng sinumang may access sa iyong hardware ang iyong data!

Pero sa mga espesyal na pagkakataon, tulad ng mga remote na Omarchy install sa mga protektadong computer o para sa mga disposable na installation na walang sensitibong data, maaaring gusto mong mag-install nang walang encryption. Maaari mong pindutin ang `Ctrl + C` sa kumpirmasyon ng pag-format ng disk para lumipat sa isang installation na walang encryption.

### Wika

Nagsasalita ang Omarchy ng 50 wika — ang parehong set ng omarchy.org — at English ang default. Para lumipat, buksan ang Omarchy menu at pumunta sa _Setup > Region > Language_, o patakbuhin ang `omarchy language <code>` sa isang terminal (ipapakita ng `omarchy language list` ang mga code). Agad na magpapalit ng wika ang menu, desktop, at ang sariling mga notification ng Omarchy, at susunod din ang bawat application na bubuksan mo pagkatapos. Ang mga app na nakabukas na ay magpapalit kapag ni-restart mo ang mga ito.

Para panatilihin ang wika pero isulat ang mga petsa, oras, numero, pera, unit at laki ng papel sa paraang ginagawa ng ibang rehiyon (English na may mga petsang European at 24-hour clock, halimbawa), pumili ng rehiyon sa ilalim ng _Setup > Region > Formats_, kung saan nagpapakita ng sample ang bawat pagpipilian, o patakbuhin ang `omarchy region formats <code>` (ipapakita ng `omarchy region formats list` ang mga code). Ibabalik ka ng _Same as language_ sa sariling mga format ng wika. Tulad ng pagpapalit ng wika, aabot ito sa mga app na bubuksan mo pagkatapos.

### Tulong kung hindi ka makaalis

Kung hindi ka makaalis, karaniwan ay makakahanap ka ng taong handang tumulong sa _#omarchy-help_ channel sa [community Discord](https://omarchy.org/discord).
