# FAQ

### Paano ako lilipat sa pagitan ng mga layout ng keyboard?

I-edit ang file mong `~/.config/hypr/input.lua` at idagdag ito para lumipat sa pagitan ng mga layout sa `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Awtomatikong ipapakita ng bar ang kasalukuyang layout ng keyboard mo kapag mayroon ka nang maraming layout na naka-configure (at maaari mo rin itong i-click para lumipat).

### Paano ko papalitan ang format ng orasan patungong 12-oras?

I-right-click ang orasan sa bar para umikot sa mga karaniwang format, kasama ang mga 12-oras. Maaari mo ring itakda ang format nang direkta:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ipapakita nito ang Sunday 10:55 AM.

### Paano ko papalitan ang sona ng oras ko?

Patakbuhin ang _I-update > Sona ng Oras_ sa menu ng Omarchy at pumili mula sa listahan. Kung tama ang sona ng oras pero ang orasan mismo ang lumihis, ire-restart ng _I-update > Oras_ ang pag-synchronize ng oras para sa iyo.

### Paano ko papalitan ang DNS ko, ibabahagi ang Wi-Fi ko, o titingnan ang bilis ng koneksyon ko?

Lahat ng iyon ay nakatira sa [networking](35-networking.md).

### Paano ko titingnan kung gaano kabilis ang disk ko?

Sinusukat ng _Mag-trigger > Test ng Bilis > Test ng Bilis ng Disk_ ang live na bilis ng pagbasa at pagsulat sa drive mo, o `omarchy disk speedtest` mula sa terminal.

### Bakit hindi ako makapag-sign in sa Google account ko sa Chromium?

Ang karaniwang open source na build ng Chromium ay walang kasamang mga kredensyal ng OAuth na kinakailangan ng Google para sa pag-sign in sa account. Patakbuhin ang _I-install > Serbisyo > Account ng Chromium_ sa menu ng Omarchy para idagdag ang mga ito, i-restart ang browser, at matutuloy ang pag-sign in.

### Paano ako magdaragdag ng printer?

Ang pag-print ay naka-setup at tumatakbo agad, at idinadagdag mo ang bawat printer nang sarili mo mula sa _Print Settings_ sa app launcher (`Super + Space`).

Piliin ang _Add_, at bigyan ito ng sandali para humanap: ang printer na nakasaksak sa pamamagitan ng USB, at karamihan ng mga printer sa network, ay matatagpuan para sa iyo. Kung wala ang iyo sa listahan, piliin ang _Network Printer > Internet Printing Protocol (ipp)_ at ilagay ang address nito — ang sariling display ng printer o ang web page nito ay magsasabi sa iyo kung ano iyon, karaniwang isang bagay tulad ng `192.168.1.50` na may queue na `ipp/print`. Pagkatapos ay nag-aalok ang _Forward_ ng isang driver, kung saan ang isang modernong printer ay pinakamahusay na gumagana sa driverless na profile na _IPP Everywhere_ at ang isang luma ay nais ang sariling driver ng modelo.

I-right-click ang isang printer at piliin ang _Set as Default_ para piliin kung alin ang unang aabutin ng mga app mo, at ang _Properties_ para itakda ang sukat ng papel, duplex at kalidad.

Ang awtomatikong pagtuklas, kung saan lumalabas ang mga printer sa network nang hindi idinadagdag, ay pansamantalang naka-off habang ito ay muling ginagawa, kaya ang unang hakbang sa itaas ay sa iyo imbes na awtomatiko. Ang pag-print sa isang PDF file ay gumagana nang walang anumang printer.

### Paano ko papalitan kung saan sine-save ang mga screenshot o screenrecording?

Ang mga sine-saved na screenshot ay napupunta sa `~/Pictures/Screenshots` bilang default. Para gumamit ng ibang direktoryo, idagdag ito sa isang file sa ilalim ng `~/.config/uwsm/env.d/` (tulad ng `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Maaari mo ring gawin ang pareho para sa mga screenrecording gamit ang `OMARCHY_SCREENRECORD_DIR`.

Awtomatikong ginagawa ng Omasnap ang direktoryo nito para sa screenshot. Gawin mo mismo ang direktoryo para sa screenrecording, pagkatapos ay i-restart ang Omarchy para magkabisa ang alinmang pagbabago sa environment.

### Paano ko pagaganahin ang mga speaker + webcam sa Apple Studio Display ko?

Iisipin mong dapat gumana ang lahat sa pamamagitan lang ng pagsaksak ng USB C, pero sa kasamaang palad ay hindi ganoon. Ang solusyong natagpuan ko para paganahin itong maaasahan ay ang paggamit ng [kablyeng WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pagkatapos niyon ay gumagana ang mga speaker at webcam nang walang problema.

Tandaan na mayroon kang built-in na kontrol ng liwanag sa Omarchy para sa mga Apple Display (parehong Studio at XDR) gamit ang mga regular na button ng liwanag sa keyboard.

### Paano ko aalisin ang lahat ng dagdag na software?

Kung ayaw mo ng mga programang tulad ng Obsidian o LibreOffice o alinman sa iba pang naka-preinstall na bagay, madali mo itong maaalis.

Patakbuhin ang _Alisin > Pakete_ para makita ang bawat paketeng naka-install. Pagkatapos ay maaari kang pumili ng anumang paketeng gusto mong alisin gamit ang tab, at simulan ang pag-aalis ng lahat ng napili mo gamit ang return.

At maaari mong gamitin ang _Alisin > Web App_ mula sa menu ng Omarchy para alisin ang anumang naka-preinstall na web app na ayaw mo.

O patakbuhin ang _Alisin > Mga Preinstall_ para walisin ang lahat ng naka-preinstall na dagdag — mga web app, TUI, at opsyonal na aplikasyon — nang sabay-sabay. Ang mga hotkey na naglunsad sa kanila ay mawawala kasama nila, kaya maiiwan ka na may malinis na hanay ng mga binding na pupunuin ng sarili mo sa `~/.config/hypr/bindings.lua`.

---

Para sa mga error at sirang bahagi, tingnan ang [seksyon ng Pag-troubleshoot](45-troubleshooting.md).
