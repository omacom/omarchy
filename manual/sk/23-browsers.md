# Prehliadače

Omarchy sa dodáva s [Google Chrome](https://www.google.com/chrome/) ako predvoleným prehliadačom. Je zladený s témou zvyšku vášho systému a práve ten sa otvára pomocou `Super + Shift + Return` a práve v ňom beží každá [webová aplikácia](25-web-apps.md). Otvára sa rovno do okna prehliadača: žiadna uvítacia obrazovka ani výzva na prihlásenie, štatistiky používania a správy o zlyhaní sa neodosielajú do Google a výzvy týkajúce sa súkromia pri reklamách sú vypnuté. Do svojho účtu Google sa stále môžete prihlásiť pomocou tlačidla profilu, kedykoľvek budete chcieť synchronizáciu.

Ak vám Chrome nevyhovuje, nemusíte pri ňom zostať. V časti _Install > Browser_ v ponuke Omarchy nájdete [Chromium](https://www.chromium.org/) (jednoduchú open-source verziu, z ktorej je Chrome vytvorený), Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/). Vyberte si jeden a Omarchy ho nainštaluje, nastaví jeho adresár politík a použije naň vašu aktuálnu tému.

## Ako nastaviť jeden ako predvolený

Inštalácia prehliadača ho nepovýši na predvolený. Keď už je v počítači, prejdite do _Setup > Defaults > Browser_ a vyberte ho — ponuka uvádza iba prehliadače, ktoré máte skutočne nainštalované, a aktuálny predvolený označuje začiarknutím.

Z terminálu je to:

```bash
omarchy default browser firefox
```

Spustite to bez argumentu a povie vám aktuálny predvolený prehliadač. Tým sa nastaví XDG handler, takže to nie sú len klávesové skratky Omarchy, ktoré sa prispôsobia — čokoľvek, čo otvára odkaz, od chatovacej aplikácie až po príkaz v termináli, prejde do prehliadača, ktorý ste si vybrali.

## Kopírovať URL a Stiahnuť video

Prehliadače z rodiny Chromium (samotné Chromium, Chrome, Edge a Brave) sa dodávajú s dvoma rozšíreniami Omarchy, ktoré dosahujú von z prehliadača do zvyšku vášho systému.

**Copy URL** umiestni adresu aktuálnej karty do vašej schránky pomocou `Alt + Shift + L`. Je to rýchlejšie než klikať do panela s adresou a kopírovať, a keďže to prechádza cez systémovú schránku namiesto schránky prehliadača, dostanete oznámenie Omarchy, ktoré to potvrdí, a URL je okamžite k dispozícii v [histórii schránky](08-unified-clipboard-history.md) a v každej inej aplikácii. Ak radšej klikáte, je tu aj tlačidlo na paneli nástrojov.

**Download Video** stiahne video prehrávané na stránke, ktorú si pozeráte, pomocou `Alt + Shift + D`. Odovzdá URL nástroju [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na oveľa viac než len YouTube, a stiahnutý súbor skončí v `~/Videos`. Priebeh sa zobrazuje v rovnakom zobrazení na obrazovke, aké používajú hlasitosť a jas, a aktualizuje sa na mieste namiesto hromadenia oznámení. Ak chcete, aby súbory išli niekam inam, nastavte `OMARCHY_YTDLP_DIR` — pozrite si [FAQ](46-faq.md), kde sa dozviete, kam umiestniť premenné prostredia.

Obe rozšírenia komunikujú s Omarchy prostredníctvom malého natívneho hostiteľa správ, ktorý sa nainštaluje spolu s prehliadačom. To je tá časť, ktorá umožňuje, aby video z webovej stránky skončilo vo vašom domovskom adresári a URL vo vašom správcovi schránky, čo bežné rozšírenie samo nedokáže.

Tieto sú určené len pre rodinu Chromium. Firefox a Zen ich nedostanú.

## Firefox a Zen

Firefox a Zen sú iná rodina, takže sa s nimi zaobchádza inak: Omarchy nainštaluje súbor politík pre rozumné predvolené nastavenia a prepne ich do natívneho režimu Wayland, ktorý chcete pre frakčné škálovanie a plynulé posúvanie trackpadom.

Nedostanú vyššie uvedené rozšírenia Chromium a Omarchy ich neladí témou, takže tie časti zážitku si musíte nastaviť sami.

## Opätovné odstránenie

Ktorýkoľvek z týchto prehliadačov, vrátane Chrome, môžete znova odstrániť v časti _Remove > Browser_. Odkazy potom prejdú do Chrome alebo Chromium, ak je ten druhý stále nainštalovaný.
