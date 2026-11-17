# Pagsisimula

Ini-install ang Omarchy gamit ang isang ISO. Maaari kang pumili sa pagitan ng full-disk install, na sasakupin ang buong drive, o ng free-space install, na maglalagay ng Omarchy sa hindi pa nakalaang espasyo sa isang drive — ganyan ka magdu-dual boot kasama ng Windows o ng isa pang OS (tingnan ang [pag-install na dual-boot](50-dual-boot-install.md) — tandaan na kailangan mo munang i-off ang BitLocker sa Windows). Alinman ang piliin mo, naka-full encryption ang installation bilang default, at buburahin ng full-disk na opsyon ang napiling drive, kaya siguraduhing mag-backup bago gumamit ng dati nang drive!

[I-download ang Omarchy ISO](https://omarchy.org/) muna, ilagay ito sa isang USB stick (gamitin ang [Rufus](https://rufus.ie/) sa Windows, ang [balenaEtcher](https://etcher.balena.io/) sa Mac, o ang [caligula](https://github.com/ifd3f/caligula) sa Linux), at mag-boot mula sa stick.

_Kailangan mong i-off ang Secure Boot at/o TPM sa BIOS. Kailangan mong i-off ang mga ito para ma-install mo ang Omarchy. Mga security scheme ito ng Microsoft na ginawa para sa Windows at sa mga Linux distribution na kaakibat ng Microsoft._

Pagkatapos ay sagutin ang mga tanong sa configuration, at kumpirmahin ang mga ito nang ganito:

 ![install-config](images/install-config.webp)

Pagkatapos ay pumili ng drive para sa installation mo, at maupo at panoorin ang palabas ng installation. Maaari itong matapos sa loob ng wala pang isang minuto sa pinakamabilis na modernong mga machine, pero hindi ito dapat tumagal nang higit sa 5 minuto kahit sa mas lumang computer.

 ![install-done](images/install-done.webp)

Handa ka nang mag-Omarchy!

### Gumamit ng wired o 2.4ghz na keyboard!

Hindi ka hahayaan ng full-disk encryption na ilagay ang password mula sa isang Bluetooth keyboard sa startup. Tulad ng hindi mo magagamit ang Bluetooth keyboard para pumasok sa BIOS sa isang PC. Kakailanganin mo ng keyboard na gumagamit ng 2.4ghz dongle o ng cable (na mas maganda rin naman para sa latency!). Personal kong gustong-gusto ang [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Pag-install para sa ibang may-ari

Kung nagse-setup ka ng machine para sa ibang tao — isang kapamilya, isang bagong empleyado, isang bibili — hindi mo dapat sagutin ang mga personal na tanong para sa kanila. Pindutin ang `Ctrl + C` sa pinakaunang screen ng installer (ang pagpili ng keyboard), at aalukin ka ng Omarchy na ihanda na lang ang machine para sa ibang may-ari. Mai-install agad ang system, pero ang lahat ng personal na setup — keyboard layout, username, password — ay ipagpapaliban hanggang sa unang mag-boot ang machine. Naka-encrypt pa rin ang drive bilang default, at ang password na pipiliin ng bagong may-ari sa unang boot na iyon ang magiging encryption password din. (Ang machine na nagamit mo na ay maaari ring ibigay nang hindi nagre-reinstall — tingnan ang [pag-reset ng computer](48-security.md).)

### Mga unattended na pag-install

Maaari ring mag-install nang kusa ang ISO — walang keyboard, walang wizard — kapag ibinigay dito ang configuration nito sa isang pangalawang drive. Iyan ang paraan para ituring ang Omarchy bilang base image para sa mga VM at fleet machine. Tingnan ang [mga unattended na pag-install](51-unattended-installs.md).

### Mga pag-install na walang encryption

Ini-install ang Omarchy na may encryption bilang default. Ito ang ligtas at responsableng pagpipilian para sa anumang computer na maaaring mawala o manakaw. Ayaw mong makuha ng sinumang may access sa hardware mo ang data mo!

Pero sa mga espesyal na sitwasyon, tulad ng mga remote na pag-install ng Omarchy sa mga protektadong computer o para sa mga throw-away na installation na walang sensitibong data, maaaring gusto mong mag-install nang walang encryption. Maaari mong pindutin ang `Ctrl + C` sa kumpirmasyon ng disk formatting para lumipat sa installation na walang encryption.

### Wika

Nagsasalita ang Omarchy ng 50 wika — ang parehong set ng omarchy.org — at Ingles ang default. Para lumipat, buksan ang Omarchy menu at pumunta sa _Setup > Language_, o patakbuhin ang `omarchy language <code>` sa isang terminal (ipinapakita ng `omarchy language list` ang mga code). Agad na magpapalit ng wika ang menu, desktop, at ang sariling mga notification ng Omarchy, at susunod din ang bawat application na bubuksan mo pagkatapos. Ang mga app na nakabukas na ay magpapalit kapag ni-restart mo ang mga ito.

### Tulong kung hindi ka maka-usad

Kung hindi ka maka-usad, karaniwan kang makakahanap ng taong handang tumulong sa _#omarchy-help_ channel sa [Discord ng komunidad](https://omarchy.org/discord).
