# Pagsisimula

Ang Omarchy ay ini-install gamit ang isang ISO. Maaari kang pumili sa pagitan ng full-disk install, na umaangkin sa buong drive, o free-space install, na naglalagay ng Omarchy sa hindi pa nakalaang espasyo sa isang drive — ganyan ka mag-dual boot kasama ng Windows o ng ibang OS (tingnan ang [install para sa dual-boot](50-dual-boot-install.md) — tandaan na kailangan mo munang i-off ang BitLocker sa Windows). Alinman ang piliin, naka-full encryption ang installation bilang default, at buburahin ng full-disk na opsyon ang napiling drive, kaya siguraduhing mag-backup bago gumamit ng dati nang drive!

[I-download muna ang Omarchy ISO](https://omarchy.org/), ilagay ito sa isang USB stick (gamitin ang [Rufus](https://rufus.ie/) sa Windows, [balenaEtcher](https://etcher.balena.io/) sa Mac, o [caligula](https://github.com/ifd3f/caligula) sa Linux), at mag-boot mula sa stick.

_Kailangan mong i-off ang Secure Boot at/o TPM sa BIOS. Kailangan mong i-off ang mga ito para ma-install ang Omarchy. Mga scheme ng seguridad ng Microsoft ang mga ito na para sa Windows at sa mga Linux distribution na kaakibat ng Microsoft._

Pagkatapos ay sagutin ang mga tanong sa configuration, at kumpirmahin ang mga ito nang ganito:

 ![install-config](images/install-config.webp)

Pagkatapos ay pumili ng drive para sa iyong installation, at maupo na lang at panoorin ang palabas ng installation. Maaari itong matapos sa loob ng wala pang isang minuto sa pinakamabilis na mga modernong makina, pero hindi ito dapat tumagal nang higit sa 5 minuto kahit sa mas lumang computer.

 ![install-done](images/install-done.webp)

Handa ka na ngayong mag-Omarchy!

### Gumamit ng wired o 2.4ghz na keyboard!

Hindi ka hahayaan ng full-disk encryption na maglagay ng password mula sa isang Bluetooth keyboard sa startup. Katulad ng hindi mo magagamit ang Bluetooth keyboard para pumasok sa BIOS sa isang PC. Kakailanganin mo ng keyboard na gumagamit ng 2.4ghz dongle o ng cable (na mas mainam para sa latency pa rin!). Personal kong gusto ang [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Pag-install para sa ibang may-ari

Kung nagse-setup ka ng makina para sa ibang tao — isang kapamilya, isang bagong empleyado, isang mamimili — hindi mo dapat sagutin ang mga personal na tanong para sa kanila. Pindutin ang `Ctrl + C` sa pinakaunang screen ng installer (ang pagpili ng keyboard), at aalukin ka ng Omarchy na ihanda ang makina para sa ibang may-ari sa halip. Agad na mai-install ang system, pero ang lahat ng personal na setup — layout ng keyboard, username, password — ay ipagpapaliban hanggang sa unang mag-boot ang makina. Naka-encrypt pa rin ang drive bilang default, at ang password na pipiliin ng bagong may-ari sa unang boot na iyon ang magiging encryption password din. (Maaari ring ibigay ang makinang ginagamit mo na nang hindi nagre-reinstall — tingnan ang [pag-reset ng computer](48-security.md).)

### Mga unattended install

Maaari ring mag-install nang kusa ang ISO — walang keyboard, walang wizard — kapag ibinigay dito ang configuration nito sa pangalawang drive. Iyan ang paraan para ituring ang Omarchy bilang base image para sa mga VM at mga makinang pang-fleet. Tingnan ang [mga unattended install](51-unattended-installs.md).

### Mga installation na walang encryption

Naka-install ang Omarchy na may encryption bilang default. Ito ang ligtas at responsableng pagpipilian para sa anumang computer na maaaring mawala o manakaw. Ayaw mong makuha ng sinumang may access sa hardware mo ang data mo!

Pero sa mga espesyal na pagkakataon, tulad ng mga remote na install ng Omarchy sa mga protektadong computer o para sa mga pansamantalang installation na walang sensitibong data, maaaring gusto mong mag-install nang walang encryption. Maaari mong pindutin ang `Ctrl + C` sa kumpirmasyon ng pag-format ng disk para lumipat sa installation na walang encryption.

### Wika

Nagsasalita ang Omarchy ng 50 wika — kaparehong set ng omarchy.org — at English ang default. Para lumipat, buksan ang menu ng Omarchy at pumunta sa _Setup > Region > Language_, o patakbuhin ang `omarchy language <code>` sa isang terminal (ipinapakita ng `omarchy language list` ang mga code). Agad na nagbabago ng wika ang menu, desktop, at sariling mga notification ng Omarchy, at sumusunod din ang bawat application na bubuksan mo pagkatapos. Ang mga app na nakabukas na ay lumilipat kapag ni-restart mo ang mga ito.

Para panatilihin ang wika pero isulat ang mga petsa, oras, numero, pera, unit at laki ng papel sa paraang ginagawa ng ibang rehiyon (English na may European na mga petsa at 24-oras na orasan, halimbawa), pumili ng rehiyon sa ilalim ng _Setup > Region > Formats_, kung saan ipinapakita ng bawat pagpipilian ang isang halimbawa, o patakbuhin ang `omarchy region <code>` (ipinapakita ng `omarchy region list` ang mga code). Bumabalik ang _Same as language_ sa sariling mga format ng wika. Katulad ng pagpalit ng wika, umaabot ito sa mga app na bubuksan mo pagkatapos.

### Tulong kung ma-stuck ka

Kung ma-stuck ka, karaniwan kang makakahanap ng taong handang tumulong sa _#omarchy-help_ channel sa [Discord ng komunidad](https://omarchy.org/discord).
