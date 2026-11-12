# Mga Browser

Kasama ng Omarchy ang [Google Chrome](https://www.google.com/chrome/) bilang default na browser. May tema itong tumutugma sa iba pang bahagi ng system mo, at ito ang binubuksan ng `Super + Shift + Return` at dito rin tumatakbo ang bawat [web app](25-web-apps.md). Deretso itong bumubukas sa isang browser window: walang welcome screen o sign-in prompt, hindi ipinapadala sa Google ang mga usage statistic at crash report, at naka-off ang mga ad privacy prompt. Maaari ka pa ring mag-sign in sa Google account mo mula sa profile button anumang oras na gusto mo ng sync.

Kung hindi mo gusto ang Chrome, hindi ka nakakulong dito. Sa ilalim ng _Install > Browser_ sa menu ng Omarchy, mahahanap mo ang [Chromium](https://www.chromium.org/) (ang plain na open-source build kung saan gawa ang Chrome), Edge, Brave, Brave Origin, Firefox, at [Zen](https://zen-browser.app/). Pumili ng isa at i-install ito ng Omarchy, i-set up ang policy directory nito, at ilalapat dito ang kasalukuyan mong tema.

## Gawing default ang isa

Hindi ito awtomatikong nagiging default kapag nag-install ka ng browser. Kapag nasa machine na ito, pumunta sa _Setup > Defaults > Browser_ at piliin ito — mga browser lang na talagang naka-install sa iyo ang inililista ng menu, at minamarkahan nito ng check ang kasalukuyang default.

Mula sa terminal, ito iyon:

```bash
omarchy default browser firefox
```

Patakbuhin ito nang walang argument at sasabihin nito sa iyo ang kasalukuyang default. Itinatakda nito ang XDG handler, kaya hindi lang mga hotkey ng Omarchy ang sumusunod — anumang nagbubukas ng link, mula sa isang chat app hanggang sa isang terminal command, ay pupunta sa browser na pinili mo.

## Copy URL at Download Video

Ang mga browser na nasa pamilya ng Chromium (Chromium mismo, Chrome, Edge, at Brave) ay may kasamang dalawang extension ng Omarchy na umaabot palabas ng browser at papasok sa iba pang bahagi ng system mo.

Inilalagay ng **Copy URL** ang address ng kasalukuyang tab sa clipboard mo gamit ang `Alt + Shift + L`. Mas mabilis iyan kaysa pag-click sa address bar at pagkopya, at dahil dumadaan ito sa system clipboard sa halip na sa browser, makakatanggap ka ng notification mula sa Omarchy na nagkukumpirma nito at agad na available ang URL sa [kasaysayan ng clipboard](08-unified-clipboard-history.md) at sa bawat iba pang app. May toolbar button din, kung mas gusto mong mag-click.

Kinukuha ng **Download Video** ang video na nagpe-play sa page na tinitingnan mo gamit ang `Alt + Shift + D`. Ipinapasa nito ang URL sa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kaya gumagana ito sa higit pa sa YouTube, at napupunta ang download sa `~/Videos`. Lumalabas ang progress sa parehong on-screen display na ginagamit ng volume at brightness, na nag-a-update sa mismong lugar sa halip na magpatong-patong ng mga notification. Itakda ang `OMARCHY_YTDLP_DIR` kung mas gusto mong mapunta ang mga file sa ibang lugar — tingnan ang [FAQ](46-faq.md) para sa kung saan ilalagay ang mga environment variable.

Parehong nakikipag-usap ang dalawang extension sa Omarchy sa pamamagitan ng isang maliit na native messaging host, na ini-install para sa iyo kasama ng browser. Iyon ang bahaging nagbibigay-daan para mapunta ang video ng isang web page sa home directory mo at ang isang URL sa clipboard manager mo, na hindi kayang gawin ng isang normal na extension nang mag-isa.

Para lang ito sa pamilya ng Chromium. Hindi ito makukuha ng Firefox at Zen.

## Firefox at Zen

Ibang pamilya ang Firefox at Zen, kaya iba rin ang trato sa kanila: nag-i-install ang Omarchy ng isang policies file para sa makatwirang mga default at inililipat sila sa native na Wayland mode, na gusto mo para sa fractional scaling at maayos na trackpad scrolling.

Hindi nila makukuha ang mga Chromium extension sa itaas, at hindi sila tine-theme ng Omarchy, kaya ikaw na ang bahalang mag-set up sa mga bahaging iyon ng karanasan.

## Pag-alis ulit ng isa

Alinman sa mga browser na ito, kasama ang Chrome, ay maaari uling alisin sa ilalim ng _Remove > Browser_. Pupunta ang mga link sa Chrome o Chromium kung naka-install pa ang isa sa kanila.
