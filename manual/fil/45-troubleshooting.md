# Pag-troubleshoot

### Nasira ko ang sistema ko dahil sa isang update!

Subukan mo munang [i-rollback ang sistema mo](47-system-snapshots.md) sa bersyon bago ang pinakabago mong update. Kung hindi iyon gumana, gamitin ang `omarchy-debug` para ibahagi ang problema mo sa #omarchy-help sa Discord. At kung mabigo ang lahat ng iyon, maaari mong i-reinstall ang mga default na config at package gamit ang `omarchy-reinstall`.

### Bakit ang lalaki ng ilang app sa display ko?

Ipinapalagay ng Omarchy na 2x high-resolution display ang gamit mo, kaya itinatakda nito ang `GDK_SCALE` sa 2 hanggang sa pumili ka ng scale sa monitor panel. Kung nasa 1x display ka at lumalabas na napakalaki ng mga GTK o X11 app, piliin ang 1x para rito sa monitor panel, o idagdag ang `hl.env("GDK_SCALE", "1")` sa `~/.config/hypr/monitors.lua` (at pagkatapos ay i-restart ang anumang app na napakalaki). Tingnan [ang manual tungkol sa mga monitor](33-monitors.md).

Para sa Spotify, maaari mong gamitin ang `Ctrl + Minus` para paliitin ang UI (at `Ctrl + Plus` para palakihin ito).

### Bakit huminto sa paggana ang lahat ng Super key bind ko?

Sa ilang ASUS ROG at TUF laptop, ang `Fn + Super` ay isang chord na madaling makaligtaan na nagto-toggle ng firmware Windows-key lock (para sa gaming ito kaya hindi ka aksidenteng makalabas sa isang laro). Walang lumalabas sa screen na magsasabi sa iyo na nangyari ito. Habang naka-on ang lock, wala talagang inilalabas ang Super — kaya humihinto ang bawat Omarchy bind na gumagamit ng Super, at mukhang nasira ang Hyprland.

Pindutin ang `Fn + Super` nang isang beses bago ka maghalungkat sa `~/.config/hypr/`, at kung hindi niyan maibalik ang Super, pindutin itong muli para hindi mo maiwan na naka-on ang lock. Hindi ito Fn-lock, na binabago lang kung ano ang ginagawa ng F-key row.

### Huminto na lang sa paggana ang Wi-Fi, Bluetooth, audio, o trackpad ko

Bago ka mag-reboot, subukang i-restart nang mag-isa ang problemadong subsystem. Ang _Update > Hardware_ sa Omarchy menu ay may Wi-Fi, Bluetooth, Audio, at Trackpad, at ang pag-reload sa isa sa mga iyon ay nag-aayos sa karamihan ng mga sitwasyong "gumagana ito limang minuto ang nakalipas" — isang Bluetooth headset na ayaw mag-reconnect, isang trackpad na namatay pagkatapos ng suspend, tunog na nawala nang bunutin mo ang isang monitor.

### Bakit hindi tumutunog ang mga external speaker ko?

Malamang dahil hindi sila nakatakda bilang pangunahing output. I-click ang speaker icon sa kanang bahagi ng bar, at bubuksan nito ang volume popup kung saan maaari mong piliin ang output device (at i-mix din ang volume ng bawat app).

### Kakaiba ang tunog ng mga laptop speaker ko

Sa ilang laptop, awtomatikong naglalapat ang Omarchy ng speaker tuning na nagwawasto sa frequency response ng mga built-in speaker. Sinasabi sa iyo ng `omarchy audio tuning status` kung may aktibo sa machine mo, at pinapatay ito ng `omarchy audio tuning off` kung mas gusto mong marinig ang mga speaker nang hilaw.

### Bakit hindi ako makapag-login o makapag-sudo gamit ang password ko?

Malamang sampung beses mo itong na-type nang mali at na-lock out ka. Kusang mawawala ang lockout pagkalipas ng dalawang minuto. Kung hindi ka makapaghintay, at nangyayari ito sa lock screen, maaari mong pindutin ang `CTRL + ALT + F2` para magsimula ng bagong TTY kung saan maaari kang mag-login bilang root, pagkatapos ay patakbuhin ang `faillock --reset --user [your-username]`. Ire-reset niyan ang lockout, at ayos ka na.

### Tinatanggap ang password ko, pero bumabalik ako sa login screen

Maaaring pigilan ng sirang session environment file ang desktop na magsimula kahit tama ang password mo. Lalo itong dapat suriin pagkatapos i-edit ang `~/.config/uwsm/env.d/`.

Pindutin ang `Ctrl + Alt + F2`, mag-login gamit ang normal mong username at password, at suriin ang user journal ng kasalukuyang boot:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Maghanap ng error na nagpapangalan sa isa sa environment file mo, tulad ng `bad substitution`, bago ang isang mensahe na hindi nahanap ang env output mark. Ilipat ang file na iyon palabas ng `env.d` bago subukang mag-login muli. Halimbawa, kung pinapangalanan ng error ang `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

Nilalaktawan ng UWSM ang isang file na may syntax error, ngunit ang isang fatal error na lumalabas lang habang tumatakbo ang file, tulad ng `bad substitution`, ay maaari pa ring pigilan ang desktop na magsimula. Hindi inaayos ng system snapshot rollback ang mga file na ito, dahil hindi niro-rollback ang `/home`.

Kapag nakapag-login ka na, ayusin ang naka-save na kopya bago ito ibalik. Nahuhuli ng `sh -n` ang mga syntax error nang hindi pinapatakbo ang file, ngunit hindi nito mahuhuli ang bawat error na nangyayari kapag ito ay na-source. Panatilihing bukas ang isang gumaganang terminal habang sinusubukan ang mga pagbabago.

### Bakit hindi lumalabas ang mga authorization prompt ng 1Password ko para sa 1Password SSH Agent / CLI?

Maaari itong mangyari sa 2 dahilan:

Para lumabas ang rich approval prompt, kailangang naka-on ang Settings > Advanced > Use Hardware Acceleration. _Paalala: Kailangan ng reboot para magsimula itong gumana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O kung hindi mo pa nailulunsad ang 1Password mula nang mag-boot up, hindi lalabas ang prompt.
