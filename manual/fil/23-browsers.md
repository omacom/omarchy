# Mga Browser

Kasama na sa Omarchy ang [Google Chrome](https://www.google.com/chrome/) bilang default na browser. Naka-tema ito para tumugma sa iba pang bahagi ng iyong system, at ito ang bubukas ng `Super + Shift + Return` (o `Super + Shift + B`), kasama ang `Super + Shift + Alt + B` para sa private window, at dito rin tumatakbo ang bawat [web app](25-web-apps.md). Direkta itong bubukas sa isang browser window: walang welcome screen o sign-in prompt, hindi ipinapadala sa Google ang usage statistics at crash reports, at naka-off ang mga ad privacy prompt. Maaari ka pa ring mag-sign in sa iyong Google account mula sa profile button kahit kailan mo gustong mag-sync.

Kung hindi mo gusto ang Chrome, hindi ka nakakulong dito. Sa ilalim ng _Install > Browser_ sa Omarchy menu, makikita mo ang [Chromium](https://www.chromium.org/) (ang plain na open-source build na pinagmulan ng Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), at [Ladybird](https://ladybird.org/) (Edge sa mga x86 machine lang). Pumili ng isa at i-i-install ito ng Omarchy, ise-set up ang policy directory nito, at ilalapat dito ang iyong kasalukuyang theme.

## Pagtatakda sa isa bilang default

Hindi itataas bilang default ang isang browser kapag nag-install ka nito. Para lumipat, pumunta sa _Setup > Defaults > Browser_ at pumili ng isa. Minamarkahan ng check ang kasalukuyang default, at kung pipili ka ng browser na wala ka pa, i-i-install muna ito.

Mula sa terminal, ito ang command:

```bash
omarchy default browser firefox
```

Patakbuhin ito nang walang argument at sasabihin nito sa iyo ang kasalukuyang default. Itinatakda nito ang XDG handler, kaya hindi lang ang mga hotkey ng Omarchy ang sumusunod — anumang magbubukas ng link, mula sa chat app hanggang sa terminal command, ay pupunta sa browser na pinili mo.

## Copy URL at Download Video

Ang mga browser ng pamilyang Chromium (ang Chromium mismo, Chrome, Edge, Brave, at Brave Origin) ay may kasamang tatlong Omarchy extension: dalawang umaabot palabas ng browser papunta sa iba pang bahagi ng iyong system, at isang nag-aayos sa WhatsApp.

**Copy URL** inilalagay ang address ng kasalukuyang tab sa iyong clipboard gamit ang `Alt + Shift + L`. Mas mabilis iyon kaysa sa pag-click sa address bar at pagkopya, at dahil dumadaan ito sa system clipboard sa halip na sa clipboard ng browser, makakatanggap ka ng Omarchy notification na nagkukumpirma nito at agad na available ang URL sa [kasaysayan ng clipboard](08-unified-clipboard-history.md) at sa bawat iba pang app. May toolbar button din, kung mas gusto mong mag-click.

**Download Video** kinukuha ang video na tumutugtog sa page na tinitingnan mo gamit ang `Alt + Shift + D`. Ibinibigay nito ang URL sa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kaya gumagana ito sa higit pa sa YouTube, at mapupunta ang download sa `~/Videos`. Lumalabas ang progress sa parehong on-screen display na ginagamit ng volume at brightness, at nag-a-update ito nang in place sa halip na magpatong-patong ng mga notification. Itakda ang `OMARCHY_YTDLP_DIR` kung mas gusto mong mapunta ang mga file sa ibang lugar — tingnan ang [FAQ](46-faq.md) para sa kung saan ilalagay ang mga environment variable.

Parehong nakikipag-usap ang dalawang extension sa Omarchy sa pamamagitan ng isang maliit na native messaging host, na i-i-install para sa iyo kasama ng browser. Iyon ang pirasong nagbibigay-daan para mapunta ang video ng isang web page sa iyong home directory at ang isang URL sa iyong clipboard manager, na hindi magagawa ng isang normal na extension nang mag-isa.

**WhatsApp Slim** pinapasunod ang WhatsApp Web sa iyong system theme at tinutupi ang chat list nito kapag makitid ang window.

Para lang ito sa pamilyang Chromium. Hindi ito makukuha ng Firefox at Zen.

## Firefox at Zen

Magkaibang pamilya ang Firefox at Zen, kaya iba ang trato sa kanila: nag-i-install ang Omarchy ng policies file para sa mga makatwirang default at inililipat sila sa native Wayland mode, na gusto mo para sa fractional scaling at maayos na trackpad scrolling.

Hindi nila makukuha ang mga Chromium extension sa itaas, at hindi sila tine-tema ng Omarchy, kaya ikaw na ang bahalang mag-set up sa mga bahaging iyon ng karanasan.

## Ladybird

Ang Ladybird ay isang browser na isinulat mula sa simula, na may sariling engine sa halip na sa Chromium o sa Firefox. Alpha pa rin ito, kaya asahan ang mga site na hindi pa gumagana, at i-i-install ito ng Omarchy kung ano ito: walang mga extension, walang theme, walang mga policy. Wala rin itong private window, kaya bubuksan ito ng `Super + Shift + Alt + B` gamit ang isang temporary profile na mabubura kapag isinara mo ito. Patuloy na tumatakbo ang mga [web app](25-web-apps.md) sa Chrome o Chromium.

## Pag-alis muli ng isa

Anuman sa mga browser na ito, kasama ang Chrome, ay maaaring alisin muli sa ilalim ng _Remove > Browser_. Pupunta pagkatapos ang mga link sa Chrome o Chromium kung naka-install pa ang isa pa.
