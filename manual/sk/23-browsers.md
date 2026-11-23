# Prehliadače

Omarchy sa dodáva s [Google Chrome](https://www.google.com/chrome/) ako predvoleným prehliadačom. Je zladený s témou zvyšku vášho systému a práve ten otvára `Super + Shift + Return` (alebo `Super + Shift + B`), pričom `Super + Shift + Alt + B` slúži na súkromné okno, a práve v ňom beží každá [webová aplikácia](25-web-apps.md). Otvorí sa rovno do okna prehliadača: žiadna uvítacia obrazovka ani výzva na prihlásenie, štatistiky používania a hlásenia o zlyhaní sa neodosielajú do Google a výzvy týkajúce sa ochrany súkromia pri reklamách sú vypnuté. Do svojho účtu Google sa stále môžete prihlásiť pomocou tlačidla profilu, kedykoľvek budete chcieť synchronizáciu.

Ak vám Chrome nevyhovuje, nie ste naň odkázaní. V ponuke Omarchy pod _Install > Browser_ nájdete [Chromium](https://www.chromium.org/) (čistú open-source zostavu, z ktorej je Chrome vytvorený), Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/) (Edge iba na počítačoch x86). Vyberte si jeden a Omarchy ho nainštaluje, nastaví jeho adresár politík a použije naň vašu aktuálnu tému.

## Nastavenie jedného ako predvoleného

Nainštalovanie prehliadača z neho neurobí predvolený. Ak chcete prepnúť, prejdite do _Setup > Defaults > Browser_ a vyberte jeden. Aktuálny predvolený je označený fajkou a výber prehliadača, ktorý ešte nemáte, ho najprv nainštaluje.

Z terminálu je to:

```bash
omarchy default browser firefox
```

Spustite to bez argumentu a povie vám aktuálny predvolený. Tým sa nastaví XDG handler, takže sa podľa toho neriadia len klávesové skratky Omarchy — čokoľvek, čo otvára odkaz, od chatovacej aplikácie po príkaz v termináli, prejde do prehliadača, ktorý ste si vybrali.

## Copy URL a Download Video

Prehliadače z rodiny Chromium (samotné Chromium, Chrome, Edge, Brave a Brave Origin) sa dodávajú s tromi rozšíreniami Omarchy: dve siahajú von z prehliadača do zvyšku vášho systému a jedno upratuje WhatsApp.

**Copy URL** vloží adresu aktuálnej karty do vašej schránky pomocou `Alt + Shift + L`. Je to rýchlejšie než klikať do panela s adresou a kopírovať, a keďže to ide cez systémovú schránku namiesto schránky prehliadača, dostanete potvrdenie v podobe oznámenia Omarchy a URL je okamžite dostupná v [histórii schránky](08-unified-clipboard-history.md) a v každej inej aplikácii. Ak radšej klikáte, je tu aj tlačidlo na paneli nástrojov.

**Download Video** stiahne video prehrávané na stránke, ktorú si práve pozeráte, pomocou `Alt + Shift + D`. URL odovzdá nástroju [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na oveľa viac než len YouTube, a stiahnutý súbor skončí v `~/Videos`. Priebeh sa zobrazuje v rovnakom zobrazení na obrazovke, aké používajú hlasitosť a jas, aktualizuje sa na mieste namiesto toho, aby sa hromadili oznámenia. Ak chcete, aby súbory išli niekam inam, nastavte `OMARCHY_YTDLP_DIR` — pozrite si [FAQ](46-faq.md), kde sa dozviete, kam umiestniť premenné prostredia.

Obe rozšírenia komunikujú s Omarchy prostredníctvom malého natívneho hostiteľa správ, ktorý sa vám nainštaluje spolu s prehliadačom. Práve ten umožňuje, aby video z webovej stránky skončilo vo vašom domovskom adresári a URL vo vašom správcovi schránky, čo bežné rozšírenie samo nedokáže.

**WhatsApp Slim** spôsobí, že WhatsApp Web nasleduje vašu systémovú tému a zbalí svoj zoznam chatov, keď je okno úzke.

Tieto sú určené len pre rodinu Chromium. Firefox a Zen ich nedostanú.

## Firefox a Zen

Firefox a Zen sú iná rodina, takže sa s nimi zaobchádza inak: Omarchy pre ne nainštaluje súbor politík pre rozumné predvolené nastavenia a prepne ich do natívneho režimu Wayland, ktorý chcete pre frakčné škálovanie a plynulé posúvanie trackpadom.

Nedostanú vyššie uvedené rozšírenia Chromium a Omarchy ich neladí témou, takže tieto časti zážitku si musíte nastaviť sami.

## Opätovné odstránenie

Ktorýkoľvek z týchto prehliadačov, vrátane Chrome, môžete znova odstrániť pod _Remove > Browser_. Odkazy potom prejdú do Chrome alebo Chromium, ak je ten druhý stále nainštalovaný.
