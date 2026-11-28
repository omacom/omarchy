# Mga Update

Pinapanatiling napapanahon ang Omarchy at ang iyong mga package sa pamamagitan ng _Update > Omarchy_ sa menu ng Omarchy (`Super + Space`).

Naka-install ang Omarchy mismo bilang mga regular na package ng pacman mula sa [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), kaya nag-i-install ang isang update ng [pinakabagong release ng Omarchy](https://github.com/omacom/omarchy/releases), pinapatakbo ang anumang nakabinbing migration para mai-sync ang iyong system sa pinakabago, at ina-update ang lahat ng package ng system mula sa [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) at [AUR](https://aur.archlinux.org/) (kung may na-install kang anumang package ng AUR).

Kapag may mga bagong release, may lalabas na icon na bilog na arrow sa kanan ng iyong orasan. I-click ito at magsisimula ang proseso ng pag-update.

![update-available](images/update-available.webp)

### Apat na channel

Ina-update ang Omarchy sa apat na channel: stable, RC, edge, at dev. Nagsisimula ang mga bagong installation sa stable na channel, na sumusubaybay sa [mga opisyal na release](https://github.com/omacom/omarchy/releases/), pati na rin sa [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) na isang buwan ang pagkaantala kumpara sa pinakabago, para mahuli namin ang anumang bagong incompatibility na nangangailangan ng mga pagbabago sa config bago pa man ito magdulot ng problema sa mga tao.

Pero kung gusto mong tumulong na matukoy ang mga posibleng isyung iyon, puwede kang tumakbo sa edge na channel. Pananatilihin nitong sumusunod ang iyong mga package ng Omarchy sa pinakabagong development builds, at hahayaan kang mag-update sa pinakabagong mga package ng Arch sa sandaling maging available na ang mga ito. Dapat mo lang itong gawin kung may karanasan ka na sa Linux, at alam mo kung paano bawiin ang isang system na nagkaproblema.

Bago ang anumang bagong major release, gagawa kami ng panghuling validation gamit ang RC na channel. Kung interesado kang tumulong sa panghuling pagpulido, makisama ka sa #omarchy-release-candidates sa Discord.

Panghuli, nariyan ang dev na channel, na direktang nag-uugnay sa Omarchy sa isang git checkout ng source code sa `~/omarchy`, kasama ng mga edge na package. Dapat mo lang gamitin ang channel na ito kung isa kang bihasang user ng Linux, direktang nagtatrabaho sa Omarchy, at handang tiisin ang pagkasira.

Puwede kang lumipat sa pagitan ng mga channel gamit ang _Update > Channel_ mula sa menu ng Omarchy (o `omarchy channel set <stable|rc|edge|dev>` sa terminal, kasama ng `omarchy channel current` para makita kung nasaan ka).

### Pagpapalit ng mga kernel

Ginagamit ng Omarchy sa pag-boot ang sarili nitong `linux-omarchy` kernel, pero puwede kang magpanatili ng iba pang naka-install sa tabi nito, tulad ng stock na Arch `linux` kernel o isang experimental na build na sinusubukan mo. Kapag higit sa isa ang nariyan, inililista sila ng _Update > Kernel_ sa menu ng Omarchy na may check sa tabi ng isa na nagbu-boot bilang default. Pumili ng iba, ilagay ang iyong password nang isang beses, at magbu-boot ito pagkatapos ng susunod na pag-restart. Mananatili ang iba pang kernel sa boot menu, kaya puwede ka pa ring pumili ng isa nang mano-mano kung magbibigay sa iyo ng problema ang bagong default. Sa terminal, `omarchy kernel` ito para makita ang kasalukuyang default, `omarchy kernel list` para sa kung ano ang naka-install, at `omarchy kernel set <kernel>` para lumipat.

### Mga update sa firmware

Hindi lang ang iyong mga package ang naluluma. Maraming laptop at peripheral ang nagpapadala ng BIOS, SSD, at dock firmware sa pamamagitan ng Linux Vendor Firmware Service, at kukunin at i-i-install ng _Update > Firmware_ sa menu ng Omarchy ang anumang naghihintay para sa iyong hardware. Ini-install nito ang `fwupd` sa unang beses na patakbuhin mo ito. Maraming firmware ang maisusulat lang sa panahon ng isang reboot, kaya huwag magulat kung hihilingin sa iyo ang isa.

Kapag kailangan mong baguhin ang isang setting sa BIOS mismo, pindutin nang matagal ang `Alt` sa system menu (`Super + Escape`) at ang _Reboot_ ay magiging _Reboot to BIOS_, na direktang magre-restart papunta sa firmware setup nang hindi mo kailangang abangan ang tamang key sa pag-boot. Mula sa terminal, `omarchy system firmware` ito.

### Babala tungkol sa direktang mga update ng pacman/yay

Kung pamilyar ka na sa Arch, baka matukso kang patakbuhin na lang mismo ang `pacman -Syu` o `yay -Syu`, pero kung gagawin mo iyon, makakaligtaan mo ang snapshot, mga migration, at mga update sa configuration na pinapatakbo ng Omarchy kasama ng mga bagong package. Kaya talagang pipigilan ng Omarchy ang isang direktang pag-upgrade ng system at ituturo ka sa `omarchy update` sa halip. (Kung talagang alam mo ang ginagawa mo, sasabihin sa iyo ng guard kung paano ito i-bypass para sa isang transaksyon.)

### Pag-rollback ng mga masamang update

Kung magkaproblema ka kailanman pagkatapos mag-update, puwede mong i-rollback ang iyong system sa snapshot na kinuha bago ang update. Mag-restart lang at piliin sa boot loading menu ang snapshot mula bago mo sinimulan ang update.

![bootloader](images/bootloader.webp)

Kung sakaling nasira ang iyong mga configuration file, puwede ka ring magsagawa ng muling pag-install ng Omarchy gamit ang `omarchy reinstall` sa terminal. Muli nitong i-i-install ang lahat ng default na package ng Omarchy, ilalagay ka sa stable (edge sa Apple Silicon) at ida-downgrade ang anumang package na masyadong bago, at ire-reset ang lahat ng configuration file. Tandaan na mapapatungan ang lahat ng pagbabagong ginawa mo bilang user sa mga default ng Omarchy kapag ginawa mo ito!
