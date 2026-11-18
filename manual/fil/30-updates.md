# Mga Update

Pinapanatiling napapanahon ang Omarchy at ang iyong mga package sa pamamagitan ng _I-update > Omarchy_ sa menu ng Omarchy (`Super + Space`).

Ang Omarchy mismo ay naka-install bilang mga regular na pacman package mula sa [Repository ng Package ng Omarchy](https://github.com/omacom-io/omarchy-pkgs), kaya nag-i-install ang isang update ng [pinakabagong release ng Omarchy](https://github.com/omacom/omarchy/releases), nagpapatakbo ng anumang nakabinbing mga migration para mai-sync ang iyong system sa pinakabago, at ina-update ang lahat ng package ng system mula sa [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) at [AUR](https://aur.archlinux.org/) (kung may na-install kang anumang package ng AUR).

Kapag may inilabas na mga bagong release, may lalabas na icon na pabilog na arrow sa kanan ng iyong orasan. I-click ito at magsisimula ang proseso ng pag-update.

![update-available](images/update-available.webp)

### Apat na channel

Ina-update ang Omarchy sa apat na channel: stable, RC, edge, at dev. Nagsisimula ang mga bagong installation sa stable channel, na sumusunod sa [mga opisyal na release](https://github.com/omacom/omarchy/releases/), pati na rin sa [stable na Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) na nahuhuli ng isang buwan sa pinakabago, para mahuli namin ang anumang bagong incompatibility na nangangailangan ng mga pagbabago sa config bago pa ito magdulot ng problema sa mga tao.

Pero kung gusto mong tumulong sa pagtukoy sa mga posibleng isyung iyon, puwede kang gumamit ng edge channel. Pinapanatili nitong sumusunod ang iyong mga package ng Omarchy sa pinakabagong mga development build, at hinahayaan kang mag-update sa pinakabagong mga package ng Arch sa sandaling maging available ang mga ito. Gawin mo lang ito kung may karanasan ka na sa Linux, at alam mo kung paano bawiin ang isang system na nagkaproblema.

Bago ang anumang bagong major release, gagawin namin ang panghuling validation gamit ang RC channel. Kung interesado kang tumulong sa panghuling pagpolish, tumambay ka sa #omarchy-release-candidates sa Discord.

Sa wakas, nariyan ang dev channel, na direktang nag-uugnay sa Omarchy sa isang git checkout ng source code sa `~/omarchy`, na isinama sa mga edge package. Gamitin mo lang ang channel na ito kung isa kang bihasang user ng Linux, direktang nagtatrabaho sa Omarchy, at handang tiisin ang pagkasira.

Maaari kang lumipat-lipat sa mga channel gamit ang _I-update > Channel_ mula sa menu ng Omarchy (o `omarchy-channel-set` sa terminal).

### Pagpapalit ng mga kernel

Nagbo-boot ang Omarchy gamit ang sarili nitong `linux-omarchy` kernel, pero puwede kang magpanatili ng iba pang naka-install sa tabi nito, tulad ng stock na Arch `linux` kernel o isang experimental na build na sinusubukan mo. Kapag higit sa isa ang mga ito, inililista sila ng _I-update > Kernel_ sa menu ng Omarchy na may check sa tabi ng nagbo-boot bilang default. Pumili ng iba, ilagay ang iyong password nang isang beses, at magbo-boot ito pagkatapos ng susunod na restart. Mananatili ang iba pang mga kernel sa boot menu, kaya puwede mo pa ring manu-manong pumili ng isa kung bigyan ka ng problema ng bagong default. Sa terminal, `omarchy-kernel` ito para makita ang kasalukuyang default, `omarchy-kernel list` para sa kung ano ang naka-install, at `omarchy-kernel set <kernel>` para lumipat.

### Mga update sa firmware

Hindi lang ang iyong mga package ang naluluma. Maraming laptop at peripheral ang nagpapadala ng BIOS, SSD, at dock firmware sa pamamagitan ng Linux Vendor Firmware Service, at kukunin at i-install ng _I-update > Firmware_ sa menu ng Omarchy ang anumang naghihintay para sa iyong hardware. Nag-i-install ito ng `fwupd` sa unang pagkakataong patakbuhin mo ito. Maraming firmware ang maisusulat lang habang nagre-reboot, kaya huwag kang magulat kung hilingin sa iyo na mag-reboot.

Kapag kailangan mong baguhin ang isang setting sa BIOS mismo, pindutin nang matagal ang `Alt` sa system menu (`Super + Escape`) at ang _I-reboot_ ay magiging _I-reboot sa BIOS_, na direktang magre-restart papunta sa firmware setup nang hindi mo na kailangang abangan ang tamang key sa pag-boot. Mula sa terminal, `omarchy system firmware` ito.

### Babala tungkol sa direktang mga update sa pacman/yay

Kung pamilyar ka na sa Arch, maaaring matukso kang patakbuhin na lang mismo ang `pacman -Syu` o `yay -Syu`, pero kung gagawin mo iyon, makakaligtaan mo ang snapshot, mga migration, at mga update sa configuration na pinapatakbo ng Omarchy kasabay ng mga bagong package. Kaya talagang pipigilan ng Omarchy ang isang direktang pag-upgrade ng system at ituturo ka sa `omarchy update` sa halip. (Kung talagang alam mo ang ginagawa mo, sasabihin sa iyo ng guard kung paano ito i-bypass para sa iisang transaksyon.)

### Pag-rollback sa mga pumalpak na update

Kung sakaling magkaproblema ka pagkatapos mag-update, maaari mong i-rollback ang iyong system sa snapshot na kinuha bago ang update. Mag-restart lang at piliin sa boot loading menu ang snapshot mula sa bago mo sinimulan ang update.

![bootloader](images/bootloader.webp)

Kung sakaling nasira ang iyong mga configuration file sa anumang paraan, maaari ka ring magsagawa ng muling pag-install ng Omarchy gamit ang `omarchy reinstall` sa terminal. Muli nitong i-install ang lahat ng default na package ng Omarchy, ilalagay ka sa stable at ida-downgrade ang anumang package na masyadong bago, at ire-reset ang lahat ng configuration file. Tandaan na mapapatungan ang lahat ng binago mo sa user config sa mga default ng Omarchy kapag ginawa mo ito!
