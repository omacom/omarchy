# FAQ

### Paano ako magpapalipat-lipat sa pagitan ng mga keyboard layout?

I-edit ang iyong `~/.config/hypr/input.lua` file at idagdag ito para magpalit sa pagitan ng mga layout sa `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Awtomatikong ipapakita ng bar ang kasalukuyan mong keyboard layout kapag mayroon ka nang maraming layout na naka-configure (at maaari mo rin itong i-click para magpalit).

### Paano ko babaguhin ang format ng orasan para maging 12-hour?

I-right-click ang orasan sa bar para magpalit-palit sa mga karaniwang format, kasama ang mga 12-hour. Maaari mo ring direktang itakda ang format:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ipapakita nito ang Linggo 10:55 AM.

### Paano ko babaguhin ang aking timezone?

Patakbuhin ang _I-update > Timezone_ sa menu ng Omarchy at pumili mula sa listahan. Kung tama ang timezone pero ang orasan mismo ay lumihis na, ire-restart ng _I-update > Time_ ang pag-synchronize ng oras para sa iyo.

### Paano ko babaguhin ang aking DNS, ibabahagi ang aking Wi-Fi, o susuriin ang bilis ng aking koneksyon?

Nasa [networking](35-networking.md) ang lahat ng iyon.

### Paano ko susuriin kung gaano kabilis ang aking disk?

Sinusukat ng _Trigger > Pagsubok sa Bilis > Pagsubok sa Bilis ng Disk_ ang live na bilis ng pagbasa at pagsulat sa iyong drive, o ng `omarchy disk speedtest` mula sa terminal.

### Paano ako magdaragdag ng printer?

Naka-set up at gumagana na ang pag-print pagkalabas pa lang, at ikaw mismo ang magdaragdag ng bawat printer mula sa _Mga Setting ng Pag-print_ sa app launcher (`Super + Space`).

Piliin ang _Magdagdag_, at bigyan ito ng sandali para maghanap: matatagpuan para sa iyo ang printer na nakasaksak sa pamamagitan ng USB, at karamihan ng mga network printer. Kung wala ang sa iyo sa listahan, piliin ang _Network Printer > Internet Printing Protocol (ipp)_ at ilagay ang address nito — sasabihin sa iyo ng sariling display ng printer o ng web page nito kung ano iyon, kadalasan ay isang bagay tulad ng `192.168.1.50` na may queue na `ipp/print`. Mag-aalok pagkatapos ang _Forward_ ng driver, kung saan pinakamahusay na gumagana ang modernong printer sa driverless na _IPP Everywhere_ profile at ang mas luma ay nangangailangan ng sariling driver ng modelo.

I-right-click ang printer at piliin ang _Itakda bilang Default_ para piliin kung alin ang unang gagamitin ng iyong mga app, at ang _Mga Property_ para itakda ang laki ng papel, duplex at kalidad.

Pansamantalang naka-off ang awtomatikong discovery, kung saan lumalabas ang mga printer sa network nang hindi idinaragdag, habang inaayos pa ito, kaya ikaw ang gagawa ng unang hakbang sa itaas sa halip na awtomatiko ito. Gumagana ang pag-print sa isang PDF file kahit wala kang printer.

### Paano ko babaguhin kung saan nase-save ang mga screenshot o screenrecording?

Nase-save ang mga screenshot sa `~/Pictures/Screenshots` bilang default. Para gumamit ng ibang directory, idagdag ito sa isang file sa ilalim ng `~/.config/uwsm/env.d/` (tulad ng `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Magagawa mo rin ang pareho para sa mga screenrecording gamit ang `OMARCHY_SCREENRECORD_DIR`.

Awtomatikong ginagawa ng Omasnap ang screenshot directory nito. Ikaw mismo ang gumawa ng screenrecording directory, pagkatapos ay i-restart ang Omarchy para magkabisa ang alinmang pagbabago sa environment.

### Paano ko pagaganahin ang mga speaker + webcam sa aking Apple Studio Display?

Iisipin mong dapat gumana ang lahat sa pamamagitan lang ng pagsaksak ng USB C, pero sa kasamaang-palad, hindi ganoon. Ang solusyong nakita kong maaasahang nagpapagana nito ay ang paggamit ng [ang WJESOG DisplayPort + USB-A => USB-C na kable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pagkatapos, gumagana nang walang problema ang mga speaker at webcam.

Tandaan na mayroon kang built-in na kontrol sa brightness sa Omarchy para sa mga Apple Display (parehong Studio at XDR) gamit ang regular na mga button ng brightness sa keyboard.

### Paano ko aalisin ang lahat ng dagdag na software?

Kung ayaw mo ng mga program tulad ng Obsidian o LibreOffice o alinman sa iba pang naka-preinstall na bagay, napakadali mong maaalis ang mga ito.

Patakbuhin ang _Mag-alis > Package_ para makita ang bawat package na naka-install. Pagkatapos, maaari mong piliin ang anumang package na gusto mong alisin gamit ang tab, at simulan ang pag-alis sa lahat ng pinili mo gamit ang return.

At maaari mong gamitin ang _Mag-alis > Web App_ mula sa menu ng Omarchy para alisin ang anumang naka-preinstall na web app na ayaw mo.

O patakbuhin ang _Mag-alis > Mga Preinstall_ para alisin sa isang pasada ang lahat ng naka-preinstall na dagdag — mga web app, TUI, at opsyonal na application. Mawawala kasama ng mga ito ang mga hotkey na nagbubukas sa kanila, kaya maiiwan ka ng malinis na hanay ng mga binding na pupunan ng sarili mo sa `~/.config/hypr/bindings.lua`.

---

Para sa mga error at sirang bahagi, tingnan ang [seksyon ng Troubleshooting](45-troubleshooting.md).
