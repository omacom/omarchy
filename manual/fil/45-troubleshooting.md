# Pag-troubleshoot

### Nasira ko ang sistema ko dahil sa isang update!

Subukan mo munang [i-rollback ang sistema mo](47-system-snapshots.md) sa bersyon bago ang iyong kamakailang update. Kung hindi iyon gumana, gamitin ang `omarchy-debug` para ibahagi ang problema mo sa #omarchy-help sa Discord. At kung mabigo ang lahat ng iyon, maaari mong muling i-install ang mga default na config at pakete gamit ang `omarchy-reinstall`.

### Bakit napakalaki ng ilang app sa display ko?

Ipinagpapalagay ng Omarchy ang isang 2x na display na may mataas na resolusyon, na nangangailangan ng pagtakda ng `GDK_SCALE` sa 2 sa `~/.config/hypr/monitors.lua`. Pero kung nasa isang 1x na display ka, maaari mong baguhin ang `local omarchy_gdk_scale = 2` patungong 1 (at pagkatapos ay i-restart ang anumang app na napakalaki). Tingnan ang [manwal tungkol sa mga monitor](33-monitors.md).

Para sa Spotify, maaari mong gamitin ang `Ctrl + Minus` para paliitin ang UI (at ang `Ctrl + Plus` para palakihin ito).

### Bigla na lang tumigil sa paggana ang Wi-Fi, Bluetooth, audio, o trackpad ko

Bago ka mag-reboot, subukang i-restart nang mag-isa ang subsistemang may sala. Ang _I-update > Hardware_ sa menu ng Omarchy ay may Wi-Fi, Bluetooth, Audio, at Trackpad, at ang pag-reload ng isa sa mga iyon ay nag-aayos ng karamihan ng mga sitwasyong "gumana pa ito limang minuto ang nakalipas" — isang Bluetooth headset na ayaw muling kumonekta, isang trackpad na namatay pagkatapos ng suspend, tunog na nawala nang bunutin mo ang isang monitor.

### Bakit hindi tumutugtog ang mga panlabas kong speaker?

Marahil dahil hindi sila nakatakda bilang pangunahing output. I-click ang icon ng speaker sa kanang bahagi ng bar, at bubuksan nito ang popup ng volume kung saan maaari mong piliin ang output device (at paghaluin ang mga volume bawat app din).

### Kakaiba ang tunog ng mga speaker ng laptop ko

Sa ilang laptop, awtomatikong inilalapat ng Omarchy ang isang pag-tune ng speaker na nagwawasto sa frequency response ng mga built-in na speaker. Sinasabi sa iyo ng `omarchy audio tuning status` kung may aktibong pag-tune sa makina mo, at ino-off ito ng `omarchy audio tuning off` kung mas gusto mong marinig ang mga speaker nang hilaw.

### Bakit hindi ako makapag-login o makapag-sudo gamit ang password ko?

Marahil ay mali ang pagka-type mo nito nang napakaraming beses at na-lock out ka. Kung nangyayari ito sa lock screen, maaari mong pindutin ang `CTRL + ALT + F2` para magsimula ng bagong TTY kung saan maaari kang mag-login bilang root, pagkatapos ay patakbuhin ang `faillock --reset --user [your-username]`. Ire-reset niyon ang lockout, at handa ka na.

### Bakit hindi lumalabas ang mga prompt ng awtorisasyon ng 1Password ko para sa 1Password SSH Agent / CLI?

Maaaring mangyari ito sa 2 dahilan:

Upang lumabas ang rich na prompt ng pag-apruba, dapat naka-on ang Settings > Advanced > Use Hardware Acceleration. _Tandaan: Nangangailangan ito ng reboot para magsimulang gumana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O kung hindi mo pa nailunsad ang 1Password mula nang mag-boot up, hindi lalabas ang prompt.
