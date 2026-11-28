# Prehliadače

Omarchy sa dodáva s [Google Chrome](https://www.google.com/chrome/) ako predvoleným prehliadačom. Je tematicky zladený so zvyškom vášho systému a je to to, čo otvára `Super + Shift + Return` (alebo `Super + Shift + B`), pričom `Super + Shift + Alt + B` slúži na súkromné okno, a to, v čom beží každá [webová aplikácia](25-web-apps.md). Otvára sa rovno do okna prehliadača: žiadna uvítacia obrazovka ani výzva na prihlásenie, štatistiky používania a hlásenia o pádoch sa neposielajú spoločnosti Google a výzvy týkajúce sa ochrany súkromia pri reklamách sú vypnuté. Do svojho účtu Google sa stále môžete prihlásiť pomocou tlačidla profilu, kedykoľvek budete chcieť synchronizáciu.

Ak vám Chrome nevyhovuje, nie ste naň odkázaní. V ponuke Omarchy v časti _Install > Browser_ nájdete [Chromium](https://www.chromium.org/) (čistú open-source verziu, z ktorej je vytvorený Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) a [Ladybird](https://ladybird.org/) (Edge len na počítačoch x86). Vyberte si jeden a Omarchy ho nainštaluje, nastaví jeho adresár politík a použije naň vašu aktuálnu tému.

## Ako nastaviť jeden ako predvolený

Inštalácia prehliadača ho nepovýši na predvolený. Ak ho chcete prepnúť, prejdite do časti _Setup > Defaults > Browser_ a jeden si vyberte. Aktuálny predvolený je označený začiarknutím a výber prehliadača, ktorý ešte nemáte, ho najprv nainštaluje.

Z terminálu je to:

```bash
omarchy default browser firefox
```

Spustite ho bez argumentu a povie vám, ktorý je aktuálne predvolený. Týmto sa nastaví XDG handler, takže ho nenasledujú len klávesové skratky Omarchy — všetko, čo otvára odkaz, od chatovacej aplikácie po príkaz v termináli, prejde do prehliadača, ktorý ste si vybrali.

## Kopírovanie URL a sťahovanie videa

Prehliadače z rodiny Chromium (samotné Chromium, Chrome, Edge, Brave a Brave Origin) sa dodávajú s tromi rozšíreniami Omarchy: dvoma, ktoré siahajú von z prehliadača do zvyšku vášho systému, a jedným, ktoré upratuje WhatsApp.

**Copy URL** umiestni adresu aktuálnej karty do vašej schránky pomocou `Alt + Shift + L`. Je to rýchlejšie než klikanie do panela s adresou a kopírovanie, a keďže to ide cez systémovú schránku namiesto schránky prehliadača, dostanete potvrdenie v podobe oznámenia Omarchy a URL je okamžite k dispozícii v [histórii schránky](08-unified-clipboard-history.md) a v každej inej aplikácii. Ak radšej klikáte, je tu aj tlačidlo na paneli nástrojov.

**Download Video** zachytí video prehrávané na stránke, na ktorú sa pozeráte, pomocou `Alt + Shift + D`. Odovzdá URL nástroju [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na oveľa viac než len YouTube, a stiahnutý súbor skončí v `~/Videos`. Priebeh sa zobrazuje v tom istom zobrazení na obrazovke, ktoré používajú hlasitosť a jas, a aktualizuje sa na mieste namiesto hromadenia oznámení. Nastavte `OMARCHY_YTDLP_DIR`, ak chcete, aby súbory išli niekam inam — v [Častých otázkach](46-faq.md) nájdete, kam umiestniť premenné prostredia.

Obe rozšírenia komunikujú s Omarchy prostredníctvom malého natívneho hostiteľa správ, ktorý sa pre vás nainštaluje spolu s prehliadačom. To je tá časť, ktorá umožňuje, aby video z webovej stránky skončilo vo vašom domovskom adresári a URL vo vašom správcovi schránky, čo bežné rozšírenie samo osebe nedokáže.

**WhatsApp Slim** zabezpečí, aby WhatsApp Web sledoval vašu systémovú tému, a zbalí jeho zoznam chatov, keď je okno úzke.

Tieto sú určené len pre rodinu Chromium. Firefox a Zen ich nedostanú.

## Firefox a Zen

Firefox a Zen sú iná rodina, takže sa s nimi zaobchádza inak: Omarchy nainštaluje súbor politík pre rozumné predvolené nastavenia a prepne ich do natívneho režimu Wayland, ktorý chcete pre zlomkové škálovanie a plynulé posúvanie trackpadom.

Nedostanú vyššie uvedené rozšírenia Chromium a Omarchy ich ani netematizuje, takže tie časti zážitku si musíte nastaviť sami.

## Ladybird

Ladybird je prehliadač napísaný od nuly, s vlastným enginom namiesto enginu Chromium alebo Firefoxu. Stále je v alfa verzii, takže očakávajte stránky, ktoré ešte nefungujú, a Omarchy ho nainštaluje tak, ako prichádza: žiadne rozšírenia, žiadna téma, žiadne politiky. Nemá ani súkromné okno, takže `Super + Shift + Alt + B` ho otvorí s dočasným profilom, ktorý sa po jeho zatvorení vymaže. [Webové aplikácie](25-web-apps.md) naďalej bežia v Chrome alebo Chromium.

## Opätovné odstránenie jedného z nich

Ktorýkoľvek z týchto prehliadačov vrátane Chrome môžete znova odstrániť v časti _Remove > Browser_. Odkazy potom prejdú na Chrome alebo Chromium, ak je ten druhý stále nainštalovaný.
