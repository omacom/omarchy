# Mga Browser

May kasamang [Chromium](https://www.chromium.org/) ang Omarchy bilang default na browser. Ito ang plain na open-source build, na may temang tumutugma sa natitira mong sistema, at ito ang binubuksan ng `Super + Shift + Return` at kung saan tumatakbo ang bawat [web app](25-web-apps.md) sa loob.

Kung hindi mo gusto ang Chromium, hindi ka nakulong dito. Sa ilalim ng _Install > Browser_ sa Omarchy menu ay makikita mo ang Chrome, Edge, Brave, Brave Origin, Firefox, at [Zen](https://zen-browser.app/). Pumili ng isa at i-i-install ito ng Omarchy, ise-setup ang policy directory nito, at ilalapat ang iyong kasalukuyang tema dito.

## Paggawa sa isa bilang default

Ang pag-install ng browser ay hindi ito ginagawang default. Kapag nasa makina na ito, pumunta sa _Setup > Defaults > Browser_ at piliin ito — inililista lang ng menu ang mga browser na talagang na-install mo, at minamarkahan ang kasalukuyang default ng isang check.

Mula sa terminal, ito ay:

```bash
omarchy default browser firefox
```

Patakbuhin ito nang walang argumento at sasabihin nito sa iyo ang kasalukuyang default. Itinatakda nito ang XDG handler, kaya hindi lang ang mga hotkey ng Omarchy ang sumusunod — anumang nagbubukas ng link, mula sa isang chat app hanggang sa isang terminal command, ay napupunta sa browser na pinili mo.

## Copy URL at Download Video

Ang mga Chromium-family browser (Chromium mismo, Chrome, Edge, at Brave) ay may kasamang dalawang Omarchy extension na umaabot palabas ng browser at papasok sa natitira mong sistema.

Inilalagay ng **Copy URL** ang address ng kasalukuyang tab sa iyong clipboard gamit ang `Alt + Shift + L`. Mas mabilis iyon kaysa mag-click papasok sa address bar at kumopya, at dahil dumadaan ito sa system clipboard sa halip na sa browser, makakakuha ka ng Omarchy notification na nagkukumpirma nito at ang URL ay agad na magagamit sa [clipboard history](08-unified-clipboard-history.md) at sa bawat iba pang app. May toolbar button din, kung mas gusto mong mag-click.

Kinukuha ng **Download Video** ang video na tumutugtog sa pahinang tinitingnan mo gamit ang `Alt + Shift + D`. Ibinibigay nito ang URL sa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kaya gumagana ito sa mas marami pa kaysa sa YouTube, at dumadating ang download sa `~/Videos`. Lumalabas ang progress sa parehong on-screen display na ginagamit ng volume at brightness, nag-a-update sa lugar sa halip na magpatong-patong ng mga notipikasyon. Itakda ang `OMARCHY_YTDLP_DIR` kung mas gusto mong mapunta ang mga file sa ibang lugar — tingnan ang [FAQ](46-faq.md) para sa kung saan ilalagay ang mga environment variable.

Ang parehong extension ay nakikipag-usap sa Omarchy sa pamamagitan ng isang maliit na native messaging host, na ini-install para sa iyo kasama ng browser. Iyan ang piraso na nagbibigay-daan sa video ng isang web page na mapunta sa iyong home directory at sa isang URL na mapunta sa iyong clipboard manager, na hindi magagawa ng isang normal na extension nang mag-isa.

Para lang ito sa Chromium-family. Hindi ito nakukuha ng Firefox at Zen.

## Firefox at Zen

Ibang pamilya ang Firefox at Zen, kaya nakakakuha sila ng ibang pagtrato: ini-install ng Omarchy ang isang policies file para sa mga makatwirang default at inililipat sila sa native Wayland mode, na gusto mo para sa fractional scaling at maayos na trackpad scrolling.

Hindi nila nakukuha ang mga Chromium extension sa itaas, at hindi sila tinetema ng Omarchy, kaya ang mga bahaging iyon ng karanasan ay iyo nang i-setup.

## Pag-alis ulit ng isa

Anumang na-install mo rito ay maaaring alisin ulit sa ilalim ng _Remove > Browser_. Wala ang Chromium sa listahang iyon — bahagi ito ng base system.
