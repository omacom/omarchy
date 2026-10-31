# Pag-troubleshoot

### Nasira ko ang sistema ko dahil sa isang update!

Subukan munang [i-rollback ang iyong sistema](47-system-snapshots.md) sa bersyon bago ang iyong kamakailang update. Kung hindi iyon gumana, gamitin ang `omarchy-debug` upang ibahagi ang iyong problema sa #omarchy-help sa Discord. At kung mabigo ang lahat ng iyon, maaari mong muling i-install ang mga default na config at package gamit ang `omarchy-reinstall`.

### Bakit napakalaki ng ilang apps sa display ko?

Ipinapalagay ng Omarchy na 2x high-resolution display ang gamit mo, kaya itinatakda nito ang `GDK_SCALE` sa 2 hanggang sa pumili ka ng scale sa monitor panel. Kung nasa 1x display ka at lumalabas na sobrang laki ang GTK o X11 apps, pumili ng 1x para rito sa monitor panel, o idagdag ang `hl.env("GDK_SCALE", "1")` sa `~/.config/hypr/monitors.lua` (at pagkatapos ay i-restart ang anumang app na sobrang laki). Tingnan ang [manual tungkol sa mga monitor](33-monitors.md).

Para sa Spotify, maaari mong gamitin ang `Ctrl + Minus` upang paliitin ang UI (at ang `Ctrl + Plus` upang palakihin ito).

### Bakit tumigil sa paggana ang lahat ng Super key binds ko?

Sa ilang ASUS ROG at TUF na laptop, ang `Fn + Super` ay isang chord na madaling hindi mapansin na nagto-toggle ng firmware Windows-key lock (nilalayon para sa paglalaro upang hindi ka aksidenteng makalabas sa isang laro). Walang lumalabas sa screen na nagsasabi sa iyo na nangyari iyon. Habang naka-on ang lock, wala talagang inilalabas ang Super — kaya humihinto na lang ang bawat bind ng Omarchy na gumagamit ng Super, at mukhang nasira ang Hyprland.

Pindutin ang `Fn + Super` nang isang beses bago ka maghalungkat sa `~/.config/hypr/`, at kung hindi niyan maibalik ang Super, pindutin ito ulit upang hindi mo maiwang naka-on ang lock. Hindi ito Fn-lock, na binabago lamang kung ano ang ginagawa ng row ng F-key.

### Biglang tumigil sa paggana ang Wi-Fi, Bluetooth, audio, o trackpad ko

Bago ka mag-reboot, subukang i-restart nang mag-isa ang subsystem na may problema. Ang _Update > Hardware_ sa menu ng Omarchy ay may Wi-Fi, Bluetooth, Audio, at Trackpad, at ang pag-reload sa isa sa mga iyon ay nakalulutas sa karamihan ng mga sitwasyong "gumana ito limang minuto lang ang nakalipas" — isang Bluetooth headset na ayaw nang kumonekta ulit, isang trackpad na nawalan ng buhay pagkatapos ng suspend, tunog na nawala nang bunutin mo ang isang monitor.

### Bakit hindi tumutunog ang mga external speaker ko?

Marahil dahil hindi sila nakatakda bilang pangunahing output. I-click ang icon ng speaker sa kanang bahagi ng bar, at bubuksan nito ang volume popup kung saan maaari mong piliin ang output device (at maaari mo ring timplahin ang volume ng bawat app).

### Kakaiba ang tunog ng mga speaker ng laptop ko

Sa ilang laptop, awtomatikong naglalapat ang Omarchy ng speaker tuning na nagwawasto sa frequency response ng mga built-in na speaker. Sinasabi sa iyo ng `omarchy audio tuning status` kung may aktibo nito sa iyong machine, at pinapatay ito ng `omarchy audio tuning off` kung mas gusto mong marinig ang mga speaker nang walang pagbabago.

### Bakit hindi ako makapag-login o makapag-sudo gamit ang password ko?

Malamang ay mali ang na-type mo nang masyadong maraming beses at na-lock out ka. Kung nangyayari ito sa lock screen, maaari mong pindutin ang `CTRL + ALT + F2` upang magsimula ng bagong TTY kung saan maaari kang mag-login bilang root, pagkatapos ay patakbuhin ang `faillock --reset --user [your-username]`. Ire-reset niyan ang lockout, at ayos ka na.

### Bakit hindi lumalabas ang mga prompt ng awtorisasyon ng 1Password ko para sa 1Password SSH Agent / CLI?

Maaaring mangyari ito sa 2 dahilan:

Upang lumabas ang rich na approval prompt, kailangang naka-on ang Settings > Advanced > Use Hardware Acceleration. _Tandaan: Nangangailangan ito ng reboot upang magsimulang gumana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O kung hindi mo pa nailulunsad ang 1Password mula nang mag-boot up ka, hindi lalabas ang prompt.
