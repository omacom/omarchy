# FAQ

### Paano ako magpapalit-palit sa pagitan ng mga keyboard layout?

I-edit ang iyong `~/.config/hypr/input.lua` file at idagdag ito para magpalit-palit sa pagitan ng mga layout gamit ang `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Awtomatikong ipapakita ng bar ang iyong kasalukuyang keyboard layout kapag marami ka nang nakakonfigurang layout (at maaari mo rin itong i-click para magpalit din).

### Paano ko babaguhin ang format ng orasan sa 12-hour?

I-right-click ang orasan sa bar para maglibot sa mga karaniwang format, kasama ang mga 12-hour. Maaari mo ring itakda nang direkta ang format:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Magpapakita ito ng Linggo 10:55 AM.

### Paano ko babaguhin ang aking timezone?

Patakbuhin ang _Setup > Region > Timezone_ sa menu ng Omarchy at pumili mula sa listahan. Kung tama ang timezone pero ang mismong orasan ay lumihis na, ire-restart ng _Update > Time_ ang pag-synchronize ng oras para sa iyo.

### Paano ko babaguhin ang aking DNS, ibabahagi ang aking Wi-Fi, o titingnan ang bilis ng aking koneksyon?

Lahat ng iyan ay nasa [networking](35-networking.md).

### Paano ko titingnan kung gaano kabilis ang aking disk?

Sinusukat ng _Trigger > Speed Test > Disk Speed Test_ ang live na bilis ng pagbasa at pagsulat sa iyong drive, o ng `omarchy disk speedtest` mula sa terminal.

### Paano ako magdaragdag ng printer?

Naka-set up at gumagana na ang pag-print nang out of the box, at ikaw mismo ang magdaragdag ng bawat printer mula sa _Print Settings_ sa app launcher (`Super + Space`).

Piliin ang _Add_, at bigyan ito ng kaunting oras para maghanap: isang printer na nakakabit sa pamamagitan ng USB, at karamihan ng mga network printer, ay mahahanap para sa iyo. Kung wala ang sa iyo sa listahan, piliin ang _Network Printer > Internet Printing Protocol (ipp)_ at ilagay ang address nito — sasabihin sa iyo ng sariling display ng printer o ng web page nito kung ano iyon, kadalasan ay katulad ng `192.168.1.50` na may queue na `ipp/print`. Mag-aalok ang _Forward_ ng isang driver, kung saan pinakamainam ang isang modernong printer sa walang-driver na _IPP Everywhere_ profile at ang mas luma ay gusto ang sariling driver ng modelo.

I-right-click ang isang printer at piliin ang _Set as Default_ para piliin kung alin ang unang pupuntahan ng iyong mga app, at ang _Properties_ para itakda ang laki ng papel, duplex at kalidad.

Ang awtomatikong pagtuklas, kung saan lumalabas ang mga printer sa network nang hindi pa nadadagdag, ay pansamantalang naka-off habang ito ay muling ginagawa, kaya ang unang hakbang sa itaas ay sa iyo kaysa awtomatiko. Gumagana ang pag-print sa isang PDF file kahit walang anumang printer.

### Paano ko babaguhin kung saan sine-save ang mga screenshot o screenrecording?

Ang mga na-save na screenshot ay napupunta sa `~/Pictures/Screenshots` bilang default. Para gumamit ng ibang directory, idagdag ito sa isang file sa ilalim ng `~/.config/uwsm/env.d/` (tulad ng `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Magagawa mo rin ang pareho para sa mga screenrecording gamit ang `OMARCHY_SCREENRECORD_DIR`.

Awtomatikong ginagawa ng Omasnap ang directory ng screenshot nito. Ikaw mismo ang gumawa ng directory ng screenrecording, pagkatapos ay i-restart ang Omarchy para magkabisa ang alinmang pagbabago sa environment.

### Paano ko gagana ang mga speaker + webcam sa aking Apple Studio Display?

Iisipin mong dapat gumana ang lahat sa pagsaksak lang ng USB C, pero sa kasamaang-palad ay hindi ganoon ang kaso. Ang solusyon na nakita kong maaasahang gumagana ay ang paggamit ng [ang WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pagkatapos ay gumagana ang mga speaker at webcam nang walang problema.

Tandaan na mayroon kang built-in na kontrol sa brightness sa Omarchy para sa mga Apple Display (parehong Studio at XDR) gamit ang mga regular na button ng brightness sa keyboard.

### Paano ko maaalis ang lahat ng dagdag na software?

Kung ayaw mo ng mga programang tulad ng Obsidian o LibreOffice o alinman sa iba pang naka-preinstall na bagay, napakadali mong maaalis ang mga ito.

Patakbuhin ang _Remove > Package_ para makita ang bawat package na naka-install. Pagkatapos ay maaari mong piliin ang anumang package na gusto mong alisin gamit ang tab, at simulan ang pag-alis ng lahat ng iyong napili gamit ang return.

At maaari mong gamitin ang _Remove > Web App_ mula sa menu ng Omarchy para alisin ang alinman sa mga naka-preinstall na web app na ayaw mo.

O patakbuhin ang _Remove > Preinstalls_ para walisin palabas ang lahat ng naka-preinstall na dagdag — mga web app, TUI, at opsyonal na application — nang minsanan. Mawawala kasama ng mga ito ang mga hotkey na naglulunsad sa kanila, kaya maiiwan sa iyo ang isang malinis na hanay ng mga binding na pupunan ng sarili mo sa `~/.config/hypr/bindings.lua`.

---

Para sa mga error at sirang bahagi, tingnan ang [ang seksyon ng Troubleshooting](45-troubleshooting.md).
