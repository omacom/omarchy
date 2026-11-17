# Pag-troubleshoot

### Nasira ko ang system ko dahil sa update!

Subukan mo muna [ibalik sa dati ang system mo](47-system-snapshots.md) sa bersyon bago ang kamakailan mong update. Kung hindi iyon gumana, gamitin ang `omarchy-debug` para ibahagi ang problema mo sa #omarchy-help sa Discord. At kung palpak ang lahat ng iyon, maaari mong muling i-install ang mga default na config at package gamit ang `omarchy-reinstall`.

### Bakit ang lalaki ng ilang app sa display ko?

Ipinagpapalagay ng Omarchy na 2x high-resolution ang display mo, kaya itinatakda nito ang `GDK_SCALE` sa 2 hanggang pumili ka ng scale sa monitor panel. Kung nasa 1x display ka at lumalabas na sobrang laki ang mga GTK o X11 app, piliin ang 1x para dito sa monitor panel, o idagdag ang `hl.env("GDK_SCALE", "1")` sa `~/.config/hypr/monitors.lua` (at pagkatapos ay i-restart ang anumang app na sobrang laki). Tingnan ang [manual tungkol sa mga monitor](33-monitors.md).

Para sa Spotify, maaari mong gamitin ang `Ctrl + Minus` para paliitin ang UI (at `Ctrl + Plus` para palakihin ito).

### Bakit tumigil sa pagganang lahat ng Super key bind ko?

Sa ilang ASUS ROG at TUF laptop, ang `Fn + Super` ay isang madaling makaligtaang chord na nagto-toggle ng firmware Windows-key lock (para sa gaming para hindi ka aksidenteng makalabas sa laro). Walang anumang lumalabas sa screen na nagsasabing nangyari ito. Habang naka-on ang lock, wala talagang inilalabas ang Super — kaya tumitigil ang bawat bind ng Omarchy na gumagamit ng Super, at mukhang nasira ang Hyprland.

Pindutin ang `Fn + Super` nang isang beses bago ka maghalungkat sa `~/.config/hypr/`, at kung hindi niyan maibalik ang Super, pindutin ulit ito para hindi mo maiwan na naka-on ang lock. Hindi ito Fn-lock, na binabago lang kung ano ang ginagawa ng hilera ng F-key.

### Bigla na lang tumigil sa paggana ang Wi-Fi, Bluetooth, audio, o trackpad ko

Bago ka mag-reboot, subukan munang i-restart nang mag-isa ang subsystem na may problema. May Wi-Fi, Bluetooth, Audio, at Trackpad ang _Update > Hardware_ sa menu ng Omarchy, at nalulutas ng pag-reload sa isa sa mga iyon ang karamihan sa mga sitwasyong "gumagana pa ito limang minuto ang nakalipas" — isang Bluetooth headset na ayaw nang kumonekta ulit, isang trackpad na namatay pagkatapos ng suspend, tunog na nawala nang bunutin mo ang isang monitor.

### Bakit hindi tumutunog ang mga external speaker ko?

Marahil ay dahil hindi sila nakatakda bilang pangunahing output. I-click ang icon ng speaker sa kanang bahagi ng bar, at bubuksan nito ang popup ng volume kung saan maaari mong piliin ang output device (at maaari mo ring i-mix ang volume ayon sa app).

### Kakaiba ang tunog ng mga speaker ng laptop ko

Sa ilang laptop, awtomatikong naglalapat ang Omarchy ng speaker tuning na nagtatama sa frequency response ng mga built-in na speaker. Sinasabi sa iyo ng `omarchy audio tuning status` kung may aktibo sa machine mo, at pinapatay ito ng `omarchy audio tuning off` kung mas gusto mong marinig ang mga speaker nang walang pag-tune.

### Bakit hindi ako makapag-login o makapag-sudo gamit ang password ko?

Marahil ay mali ang na-type mo nang napakaraming beses kaya na-lock out ka. Kung nangyayari ito sa lock screen, maaari mong pindutin ang `CTRL + ALT + F2` para magbukas ng bagong TTY kung saan maaari kang mag-login bilang root, pagkatapos ay patakbuhin ang `faillock --reset --user [your-username]`. Ire-reset niyan ang lockout, at ayos ka na.

### Tinatanggap ang password ko, pero bumabalik ako sa login screen

Maaaring pigilan ng sirang session environment file ang pagsisimula ng desktop kahit tama ang password mo. Lalo na itong sulit suriin pagkatapos mong i-edit ang `~/.config/uwsm/env.d/`.

Pindutin ang `Ctrl + Alt + F2`, mag-login gamit ang normal mong username at password, at suriin ang user journal ng kasalukuyang boot:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hanapin ang error na tumutukoy sa isa sa mga environment file mo, gaya ng `bad substitution`, bago ang mensaheng hindi nakita ang env output mark. Ilipat ang file na iyon palabas ng `env.d` bago subukang mag-login ulit. Halimbawa, kung tinutukoy ng error ang `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

Nilalaktawan ng UWSM ang file na may syntax error, pero maaari pa ring pigilan ng nakamamatay na error na lumalabas lang habang tumatakbo ang file, gaya ng `bad substitution`, ang pagsisimula ng desktop. Hindi inaayos ng rollback ng system snapshot ang mga file na ito, dahil hindi niro-rollback ang `/home`.

Kapag nakapag-login ka na, ayusin ang na-save na kopya bago ito ibalik. Nahuhuli ng `sh -n` ang mga syntax error nang hindi tumatakbo ang file, pero hindi nito nahuhuli ang bawat error na nangyayari kapag isinource ito. Panatilihing bukas ang gumaganang terminal habang sinusubukan ang mga pagbabago.

### Bakit hindi lumalabas ang mga prompt ng awtorisasyon ng 1Password ko para sa 1Password SSH Agent / CLI?

Maaari itong mangyari dahil sa 2 dahilan:

Para lumabas ang rich na prompt ng pag-apruba, kailangang naka-on ang Settings > Advanced > Use Hardware Acceleration. _Tandaan: Kailangan nito ng reboot para magsimulang gumana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O kung hindi mo pa nailulunsad ang 1Password mula nang mag-boot, hindi lalabas ang prompt.
