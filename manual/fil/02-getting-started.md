# Pagsisimula

Ini-install ang Omarchy gamit ang isang ISO. Maaari kang pumili sa pagitan ng full-disk install, na sasakop sa buong drive, o free-space install, na maglalagay sa Omarchy sa hindi pa nagagamit na espasyo sa isang drive — ganiyan ka magda-dual boot kasama ang Windows o ibang OS (tingnan ang [pag-install ng dual boot](50-dual-boot-install.md) — tandaan na kailangan mo munang i-off ang BitLocker sa Windows). Alinman ang piliin mo, naka-default ang pag-install sa buong encryption, at buburahin ng opsyong full-disk ang napiling drive, kaya siguraduhing mag-backup ka muna bago gamitin ang isang dati nang drive!

[I-download muna ang Omarchy ISO](https://omarchy.org/), ilagay ito sa isang USB stick (gumamit ng [balenaEtcher](https://etcher.balena.io/) sa Mac/Windows o [caligula](https://github.com/ifd3f/caligula) sa Linux), at mag-boot mula sa stick.

_Kailangan mong i-off ang Secure Boot at/o TPM sa BIOS. Kailangan mong i-off ang mga ito para ma-install ang Omarchy. Mga scheme ng seguridad ito ng Microsoft na para sa Windows at sa mga pamamahagi ng Linux na kaakibat ng Microsoft._

Pagkatapos, sagutin ang mga tanong sa configuration, at kumpirmahin ang mga ito nang ganito:

 ![install-config](images/install-config.webp)

Pagkatapos, pumili ng drive para sa iyong pag-install, at mag-relax at panoorin ang pag-install. Maaari itong matapos sa wala pang isang minuto sa pinakamabilis na modernong mga makina, pero hindi ito dapat lumampas sa 5 minuto kahit sa isang mas lumang computer.

 ![install-done](images/install-done.webp)

Handa ka nang mag-Omarchy!

### Gumamit ng wired o 2.4ghz na keyboard!

Hindi ka papayagan ng full-disk encryption na ilagay ang password mula sa isang Bluetooth na keyboard pagka-start. Tulad ng hindi mo magagamit ang Bluetooth na keyboard para pumasok sa BIOS sa isang PC. Kakailanganin mo ng keyboard na gumagamit ng 2.4ghz na dongle o ng cable (na mas mainam para sa latency pa rin naman!). Personal na gustong-gusto ko ang [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Pag-i-install para sa ibang may-ari

Kung nagse-setup ka ng makina para sa ibang tao — isang kapamilya, isang bagong empleyado, isang bibili — hindi mo dapat sagutin ang mga personal na tanong para sa kanila. Pindutin ang `Ctrl + C` sa pinakaunang screen ng installer (ang pagpili ng keyboard), at aalukin ka ng Omarchy na ihanda ang makina para sa ibang may-ari. Agad na mai-install ang system, pero ang lahat ng personal na setup — layout ng keyboard, username, password — ay ipagpapaliban hanggang sa unang mag-boot ang makina. Naka-encrypt pa rin ang drive bilang default, at ang password na pipiliin ng bagong may-ari sa unang boot na iyon ang magiging password din para sa encryption. (Ang makinang ginamit mo na ay maaari ring iabot nang hindi nagre-reinstall — tingnan ang [pag-reset ng computer](48-security.md).)

### Mga pag-install na walang bantay

Maaari ring mag-install ang ISO nang lubos nang mag-isa — walang keyboard, walang wizard — kapag binigyan ito ng configuration nito sa isang pangalawang drive. Iyan ang paraan para ituring ang Omarchy bilang base image para sa mga VM at mga makinang pang-fleet. Tingnan ang [mga pag-install na walang bantay](51-unattended-installs.md).

### Mga pag-install na walang encryption

Naka-install ang Omarchy nang may encryption bilang default. Ito ang ligtas at responsableng pagpipilian para sa anumang computer na maaaring mawala o manakaw. Ayaw mong makuha ng sinumang may access sa iyong hardware ang iyong data!

Pero sa mga espesyal na sitwasyon, tulad ng mga remote na pag-install ng Omarchy sa mga protektadong computer o para sa mga pag-install na puwedeng itapon nang walang sensitibong data, baka gusto mong mag-install nang walang encryption. Maaari mong pindutin ang `Ctrl + C` sa kumpirmasyon ng pag-format ng disk para lumipat sa isang pag-install na walang encryption.

### Wika

Nagsasalita ang Omarchy ng 50 wika — parehong set sa omarchy.org — at English ang default. Para lumipat, buksan ang menu ng Omarchy at pumunta sa _Setup > Language_, o patakbuhin ang `omarchy language <code>` sa isang terminal (ipinapakita ng `omarchy language list` ang mga code). Agad na magpapalit ng wika ang menu, desktop, at sariling mga notification ng Omarchy, at susunod din ang bawat application na bubuksan mo pagkatapos. Ang mga app na nakabukas na ay magpapalit kapag ni-restart mo ang mga ito.

### Tulong kung mai-stuck ka

Kung mai-stuck ka, karaniwan ay makakahanap ka ng taong handang tumulong sa channel na _#omarchy-help_ sa [Discord ng komunidad](https://omarchy.org/discord).
