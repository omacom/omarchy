# FAQ

### Paano ako magpapalipat-lipat sa pagitan ng mga keyboard layout?

I-edit ang file mong `~/.config/hypr/input.lua` at idagdag ito para magpalipat-lipat sa pagitan ng mga layout gamit ang `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Awtomatikong ipapakita ng bar ang kasalukuyang keyboard layout mo kapag marami ka nang layout na naka-configure (at puwede mo rin itong i-click para magpalit).

### Paano ko babaguhin ang format ng orasan sa 12-hour?

I-right-click ang orasan sa bar para umikot sa mga karaniwang format, kasama ang mga 12-hour. Puwede mo ring direktang itakda ang format:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ipapakita nito ang Linggo 10:55 AM.

### Paano ko babaguhin ang timezone ko?

Patakbuhin ang _Setup > Region > Timezone_ sa menu ng Omarchy at pumili mula sa listahan. Kung tama ang timezone pero mismong ang orasan ay nalihis na, muling sinisimulan ng _Update > Time_ ang pag-synchronize ng oras para sa iyo.

### Paano ko babaguhin ang DNS ko, ibabahagi ang Wi-Fi ko, o susuriin ang bilis ng koneksyon ko?

Nasa [networking](35-networking.md) ang lahat ng iyan.

### Paano ko susuriin kung gaano kabilis ang disk ko?

Sinusukat ng _Trigger > Speed Test > Disk Speed Test_ ang live na bilis ng pagbasa at pagsulat sa drive mo, o `omarchy disk speedtest` mula sa terminal.

### Paano ako magdaragdag ng printer?

Naka-setup at tumatakbo na ang pag-print pagkalabas pa lang sa kahon, at ikaw mismo ang magdaragdag ng bawat printer mula sa _Print Settings_ sa app launcher (`Super + Alt + Space`).

Piliin ang _Add_, at bigyan ito ng sandali para maghanap: mahahanap para sa iyo ang printer na nakasaksak sa pamamagitan ng USB, at karamihan sa mga network printer. Kung wala ang sa iyo sa listahan, piliin ang _Network Printer > Internet Printing Protocol (ipp)_ at ilagay ang address nito — sasabihin sa iyo ng sariling display ng printer o ng web page nito kung ano iyon, kadalasan ay parang `192.168.1.50` na may queue na `ipp/print`. Pagkatapos ay mag-aalok ang _Forward_ ng driver, kung saan pinakamahusay na gumagana ang modernong printer sa driverless na profile na _IPP Everywhere_ at gusto naman ng mas luma ang sariling driver ng modelo.

I-right-click ang isang printer at piliin ang _Set as Default_ para piliin kung alin ang unang pupuntahan ng mga app mo, at _Properties_ para itakda ang laki ng papel, duplex at kalidad.

Pansamantalang naka-off ang automatic discovery, kung saan lumilitaw ang mga printer sa network nang hindi idinaragdag, habang inaayos pa ito, kaya ikaw ang gumagawa ng unang hakbang sa itaas sa halip na awtomatiko ito. Gumagana ang pag-print sa PDF file kahit walang kahit anong printer.

### Paano ko babaguhin kung saan nase-save ang mga screenshot o screenrecording?

Napupunta ang mga naka-save na screenshot sa `~/Pictures/Screenshots` bilang default. Para gumamit ng ibang directory, idagdag ito sa isang file sa ilalim ng `~/.config/uwsm/env.d/` (tulad ng `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puwede mo ring gawin ang pareho para sa mga screenrecording gamit ang `OMARCHY_SCREENRECORD_DIR`.

Awtomatikong ginagawa ng Omasnap ang directory nito para sa screenshot. Ikaw mismo ang gumawa ng directory para sa screenrecording, pagkatapos ay i-restart ang Omarchy para magkabisa ang alinmang pagbabago sa environment.

### Paano ko pagaganahin ang speakers + webcam sa Apple Studio Display ko?

Akala mo dapat gumana lahat sa pagsaksak lang ng USB C, pero sa kasamaang-palad hindi ganoon ang kaso. Ang solusyong nakita kong maaasahang nagpapagana nito ay ang paggamit ng [WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pagkatapos ay gumagana nang walang problema ang speakers at webcam.

Tandaan na may built-in na brightness control ka sa Omarchy para sa mga Apple Display (parehong Studio at XDR) gamit ang regular na keyboard brightness buttons.

### Paano ko aalisin ang lahat ng dagdag na software?

Kung ayaw mo ng mga programang tulad ng Obsidian o LibreOffice o ng iba pang naka-preinstall na bagay, napakadali mong maaalis ang mga ito.

Patakbuhin ang _Remove > Package_ para makita ang bawat package na naka-install. Pagkatapos ay puwede mong piliin ang anumang package na gusto mong alisin gamit ang tab, at simulan ang pag-alis ng lahat ng napili mo gamit ang return.

At puwede mong gamitin ang _Remove > Web App_ mula sa menu ng Omarchy para alisin ang alinman sa mga naka-preinstall na web app na ayaw mo.

O patakbuhin ang _Remove > Preinstalls_ para walisin palabas ang lahat ng naka-preinstall na dagdag — mga web app, TUI, at opsyonal na application — sa isang bagsakan. Mawawala kasama ng mga ito ang mga hotkey na naglulunsad sa kanila, kaya maiiwan ka ng malinis na slate ng mga binding na pupunan ng sarili mo sa `~/.config/hypr/bindings.lua`.

---

Para sa mga error at sirang bahagi, tingnan ang [seksyon ng Troubleshooting](45-troubleshooting.md).
