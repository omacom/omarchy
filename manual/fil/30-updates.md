# Mga Update

Ang Omarchy at ang iyong mga package ay pinapanatiling up to date sa pamamagitan ng _Update > Omarchy_ sa menu ng Omarchy (`Super + Space`).

Ang Omarchy mismo ay naka-install bilang mga regular na pacman package mula sa [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), kaya mag-i-install ang isang update ng [pinakabagong release ng Omarchy](https://github.com/omacom/omarchy/releases), patatakbuhin ang anumang nakabinbing migration para i-sync ang iyong system sa pinakabago, at ia-update ang lahat ng system package mula sa [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) at [AUR](https://aur.archlinux.org/) (kung may na-install kang anumang AUR package).

Kapag may mga bagong release, may lalabas na icon na bilog na arrow sa kanan ng iyong orasan. I-click ito at magsisimula ang proseso ng pag-update.

![update-available](images/update-available.webp)

### Apat na channel

Ang Omarchy ay ina-update sa apat na channel: stable, RC, edge, at dev. Nagsisimula ang mga bagong installation sa stable channel, na sumusunod sa mga [opisyal na release](https://github.com/omacom/omarchy/releases/), pati na rin sa [stable na Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) na isang buwang nahuhuli sa pinakabago, para mahuli namin ang anumang bagong incompatibility na nangangailangan ng mga pagbabago sa config bago pa man ito magdulot ng problema sa mga tao.

Pero kung gusto mong tumulong na matukoy ang mga posibleng isyung iyon, maaari kang gumamit ng edge channel. Panatilihin niyon na sumusunod ang iyong mga Omarchy package sa pinakabagong development build, at hahayaan kang mag-update sa pinakabagong mga Arch package sa sandaling maging available ang mga ito. Gawin mo lang ito kung may karanasan ka na sa Linux, at marunong kang mag-recover ng system na nagkaproblema.

Bago ang anumang bagong major release, gagawa kami ng final validation gamit ang RC channel. Kung interesado kang tumulong sa huling pagpolish, tumambay ka sa #omarchy-release-candidates sa Discord.

Sa huli, nariyan ang dev channel, na direktang nag-uugnay sa Omarchy sa isang git checkout ng source code sa `~/omarchy`, kasama ng mga edge package. Gamitin mo lang ang channel na ito kung isa kang may karanasang Linux user, direktang nagtatrabaho sa Omarchy, at handang tiisin ang pagkasira.

Maaari kang lumipat sa pagitan ng mga channel gamit ang _Update > Channel_ sa menu ng Omarchy (o `omarchy-channel-set` sa terminal).

### Pagpapalit ng mga kernel

Ang Omarchy ay nagbo-boot gamit ang sarili nitong `linux-omarchy` kernel, pero maaari kang magpanatili ng iba pang naka-install sa tabi nito, tulad ng stock na Arch `linux` kernel o isang experimental build na sinusubukan mo. Kapag higit sa isa ang nariyan, ililista sila ng _Update > Kernel_ sa menu ng Omarchy na may check sa tabi ng isa na nagbo-boot bilang default. Pumili ng iba, ilagay ang iyong password nang isang beses, at magbo-boot ito pagkatapos ng susunod na restart. Mananatili ang iba pang mga kernel sa boot menu, kaya maaari ka pa ring pumili ng isa nang mano-mano kung magbibigay sa iyo ng problema ang bagong default. Sa terminal, `omarchy-kernel` para makita ang kasalukuyang default, `omarchy-kernel list` para sa kung ano ang naka-install, at `omarchy-kernel set <kernel>` para lumipat.

### Mga update sa firmware

Ang iyong mga package ay hindi lang ang naluluma. Maraming laptop at peripheral ang nagpapadala ng BIOS, SSD, at dock firmware sa pamamagitan ng Linux Vendor Firmware Service, at kukunin at i-install ng _Update > Firmware_ sa menu ng Omarchy ang anumang naghihintay para sa iyong hardware. I-install nito ang `fwupd` sa unang pagkakataon na patakbuhin mo ito. Maraming firmware ang maisusulat lang habang nagre-reboot, kaya huwag magulat kung hihilingan kang mag-reboot.

### Babala tungkol sa direktang mga update sa pacman/yay

Kung pamilyar ka na sa Arch, baka matukso kang patakbuhin na lang ang `pacman -Syu` o `yay -Syu` nang sarili mo, pero kung gagawin mo iyon, makakaligtaan mo ang snapshot, mga migration, at mga update sa configuration na pinapatakbo ng Omarchy kasama ng mga bagong package. Kaya naman talagang pipigilan ng Omarchy ang isang direktang system upgrade at ituturo ka sa `omarchy update` sa halip. (Kung talagang alam mo ang ginagawa mo, sasabihin sa iyo ng guard kung paano ito i-bypass para sa isang transaction.)

### Pag-rollback ng mga masamang update

Kung sakaling magkaproblema ka pagkatapos mag-update, maaari mong i-rollback ang iyong system sa snapshot na kinuha bago ang update. Mag-restart lang at piliin sa boot loading menu ang snapshot mula bago mo sinimulan ang update.

![bootloader](images/bootloader.webp)

Kung sa paanuman ay nasira ang iyong mga configuration file, maaari ka ring magsagawa ng muling pag-install ng Omarchy gamit ang `omarchy reinstall` sa terminal. Muli nitong i-install ang lahat ng default na Omarchy package, ilalagay ka sa stable at ida-downgrade ang anumang package na masyadong bago, at ire-reset ang lahat ng configuration file. Tandaan na mapapatungan ang lahat ng pagbabago mo sa user config sa mga default ng Omarchy kapag ginawa mo ito!
