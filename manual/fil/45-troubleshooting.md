# Pag-troubleshoot

### Nasira ko ang system ko dahil sa isang update!

Unang subukang [ibalik ang iyong system](47-system-snapshots.md) sa bersyon bago ang kamakailan mong update. Kung hindi iyon gumana, gamitin ang `omarchy-debug` para ibahagi ang iyong problema sa #omarchy-help sa Discord. At kung mabigo ang lahat ng iyon, maaari mong muling i-install ang mga default na config at package gamit ang `omarchy-reinstall`.

### Bakit ang lalaki ng ilang app sa display ko?

Ipinapalagay ng Omarchy na may 2x high-resolution display ka, na nangangailangan na itakda ang `GDK_SCALE` sa 2 sa `~/.config/hypr/monitors.lua`. Pero kung nasa 1x display ka, maaari mong baguhin ang `local omarchy_gdk_scale = 2` sa 1 (at pagkatapos ay i-restart ang anumang app na masyadong malaki). Tingnan ang [manual tungkol sa mga monitor](33-monitors.md).

Para sa Spotify, maaari mong gamitin ang `Ctrl + Minus` upang paliitin ang UI (at `Ctrl + Plus` upang palakihin ito).

### Bakit biglang huminto sa paggana ang lahat ng Super key bind ko?

Sa ilang ASUS ROG at TUF na laptop, ang `Fn + Super` ay isang chord na madaling makaligtaan na nagto-toggle ng firmware Windows-key lock (para sa gaming ito para hindi ka aksidenteng makalabas sa isang laro). Walang lumalabas sa screen para sabihin sa iyo na nangyari ito. Habang naka-on ang lock, wala talagang inilalabas ang Super — kaya humihinto lang ang bawat Omarchy bind na gumagamit ng Super, at mukhang nasira ang Hyprland.

Pindutin ang `Fn + Super` nang isang beses bago ka maghalungkat sa `~/.config/hypr/`, at kung hindi niyan maibalik ang Super, pindutin itong muli para hindi mo maiwan na naka-on ang lock. Hindi ito Fn-lock, na binabago lang kung ano ang ginagawa ng F-key row.

### Biglang huminto sa paggana ang Wi-Fi, Bluetooth, audio, o trackpad ko

Bago ka mag-reboot, subukang i-restart nang mag-isa ang may problemang subsystem. May Wi-Fi, Bluetooth, Audio, at Trackpad ang _Update > Hardware_ sa Omarchy menu, at inaayos ng pag-reload ng isa sa mga iyon ang karamihan sa mga sitwasyong "gumana ito limang minuto lang ang nakalipas" — isang Bluetooth headset na ayaw muling kumonekta, isang trackpad na namatay pagkatapos ng isang suspend, tunog na nawala nang bunutin mo ang isang monitor.

### Bakit hindi tumutugtog ang mga external speaker ko?

Marahil dahil hindi sila nakatakda bilang pangunahing output. I-click ang icon ng speaker sa kanang bahagi ng bar, at bubuksan nito ang volume popup kung saan maaari mong piliin ang output device (at ihalo rin ang mga volume bawat app).

### Parang hindi tama ang tunog ng mga speaker ng laptop ko

Sa ilang laptop, awtomatikong naglalapat ang Omarchy ng isang speaker tuning na nagwawasto sa frequency response ng mga built-in speaker. Sinasabi sa iyo ng `omarchy audio tuning status` kung may aktibo nito sa iyong machine, at pinapatay ito ng `omarchy audio tuning off` kung mas gusto mong marinig ang mga speaker nang hilaw.

### Bakit hindi ako makapag-login o makapag-sudo gamit ang password ko?

Marahil ay mali ang na-type mo nang napakaraming beses at na-lock out ka. Kung nangyayari ito sa lock screen, maaari mong pindutin ang `CTRL + ALT + F2` para magsimula ng bagong TTY kung saan maaari kang mag-login bilang root, pagkatapos ay patakbuhin ang `faillock --reset --user [your-username]`. Ire-reset niyan ang lockout, at ayos ka na.

### Bakit hindi lumalabas ang mga authorization prompt ng 1Password ko para sa 1Password SSH Agent / CLI?

Maaari itong mangyari sa 2 dahilan:

Para lumabas ang rich approval prompt, kailangang naka-on ang Settings > Advanced > Use Hardware Acceleration. _Tandaan: Nangangailangan ito ng reboot para magsimulang gumana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O kung hindi mo pa nailulunsad ang 1Password mula nang mag-boot up, hindi lalabas ang prompt.
