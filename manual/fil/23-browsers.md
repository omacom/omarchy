# Mga Browser

Kasama na sa Omarchy ang [Google Chrome](https://www.google.com/chrome/) bilang default na browser. Tinutugma ang tema nito sa iba pang bahagi ng iyong system, at ito ang bubukas ng `Super + Shift + Return` (o `Super + Shift + B`), kasama ang `Super + Shift + Alt + B` para sa private window, at dito rin tumatakbo ang bawat [web app](25-web-apps.md). Deretso itong bubukas sa isang browser window: walang welcome screen o prompt para mag-sign in, hindi ipinapadala sa Google ang usage statistics at mga crash report, at naka-off ang mga ad privacy prompt. Maaari ka pa ring mag-sign in sa iyong Google account mula sa profile button kahit kailan mo gustong mag-sync.

Kung hindi mo gusto ang Chrome, hindi ka nakakulong dito. Sa ilalim ng _Install > Browser_ sa menu ng Omarchy, makikita mo ang [Chromium](https://www.chromium.org/) (ang plain na open-source build kung saan gawa ang Chrome), Edge, Brave, Brave Origin, Firefox, at [Zen](https://zen-browser.app/) (Edge lang sa mga x86 na machine). Pumili ng isa at i-install ito ng Omarchy, ise-set up ang policy directory nito, at ilalapat dito ang kasalukuyan mong tema.

## Gawing default ang isa

Hindi ito awtomatikong nagiging default kapag nag-install ka ng browser. Para lumipat, pumunta sa _Setup > Defaults > Browser_ at pumili ng isa. May check ang kasalukuyang default, at kung pipili ka ng browser na wala ka pa, i-install muna ito.

Mula sa terminal, ito ang command:

```bash
omarchy default browser firefox
```

Patakbuhin ito nang walang argument at sasabihin nito sa iyo ang kasalukuyang default. Itinatakda nito ang XDG handler, kaya hindi lang mga hotkey ng Omarchy ang sumusunod — anumang magbubukas ng link, mula sa chat app hanggang sa terminal command, ay pupunta sa browser na pinili mo.

## Pagkopya ng URL at Pag-download ng Video

May tatlong Omarchy extension ang mga browser na kabilang sa pamilyang Chromium (Chromium mismo, Chrome, Edge, Brave, at Brave Origin): dalawang umaabot palabas ng browser papunta sa iba pang bahagi ng iyong system, at isang nag-aayos sa WhatsApp.

Inilalagay ng **Copy URL** ang address ng kasalukuyang tab sa iyong clipboard gamit ang `Alt + Shift + L`. Mas mabilis ito kaysa sa pag-click sa address bar at pagkopya, at dahil dumadaan ito sa system clipboard sa halip na sa browser, makakatanggap ka ng notification mula sa Omarchy na nagkukumpirma nito at agad na magagamit ang URL sa [kasaysayan ng clipboard](08-unified-clipboard-history.md) at sa bawat iba pang app. May toolbar button din, kung mas gusto mong mag-click.

Kinukuha ng **Download Video** ang video na nagpe-play sa page na tinitingnan mo gamit ang `Alt + Shift + D`. Ibinibigay nito ang URL sa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kaya gumagana ito sa higit pa sa YouTube, at mapupunta ang download sa `~/Videos`. Lumalabas ang progress sa parehong on-screen display na ginagamit ng volume at brightness, na nag-a-update sa mismong lugar sa halip na magpatong-patong ng mga notification. Itakda ang `OMARCHY_YTDLP_DIR` kung mas gusto mong mapunta ang mga file sa ibang lugar — tingnan ang [FAQ](46-faq.md) kung saan ilalagay ang mga environment variable.

Nakikipag-usap ang dalawang extension sa Omarchy sa pamamagitan ng isang maliit na native messaging host, na i-install para sa iyo kasama ng browser. Iyon ang pirasong nagbibigay-daan para mapunta ang video ng isang web page sa iyong home directory at ang isang URL sa iyong clipboard manager, na hindi kayang gawin ng isang normal na extension nang mag-isa.

Pinapasunod ng **WhatsApp Slim** ang WhatsApp Web sa tema ng iyong system at pinapaliit nito ang listahan ng chat kapag makitid ang window.

Para lang ito sa pamilyang Chromium. Hindi ito makukuha ng Firefox at Zen.

## Firefox and Zen

Ibang pamilya ang Firefox at Zen, kaya iba rin ang trato sa kanila: nag-i-install ang Omarchy ng policies file para sa mga makatwirang default at inililipat sila sa native Wayland mode, na gusto mo para sa fractional scaling at maayos na trackpad scrolling.

Hindi nila makukuha ang mga Chromium extension sa itaas, at hindi sila tinithema ng Omarchy, kaya ikaw na ang bahalang mag-set up sa mga bahaging iyon ng karanasan.

## Pag-alis ulit ng isa

Maaaring alisin ulit ang alinman sa mga browser na ito, kasama ang Chrome, sa ilalim ng _Remove > Browser_. Mapupunta ang mga link sa Chrome o Chromium kung naka-install pa ang isa sa kanila.
