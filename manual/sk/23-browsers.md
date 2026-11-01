# Prehliadače

Omarchy sa dodáva s prehliadačom [Chromium](https://www.chromium.org/) ako predvoleným prehliadačom. Je to obyčajná open-source zostava, tematicky zladená so zvyškom tvojho systému, a práve ju otvára `Super + Shift + Return` a práve v nej beží každá [webová aplikácia](25-web-apps.md).

Ak ti Chromium nevyhovuje, nemusíš pri ňom zostať. V časti _Inštalovať > Prehliadač_ v menu Omarchy nájdeš Chrome, Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/). Vyber si jeden a Omarchy ho nainštaluje, nastaví jeho adresár politík a použije naň tvoju aktuálnu tému.

## Nastavenie jedného ako predvoleného

Nainštalovanie prehliadača z neho neurobí predvolený. Keď už je v počítači, prejdi do časti _Nastavenie > Predvolené > Prehliadač_ a vyber ho — menu uvádza len prehliadače, ktoré máš skutočne nainštalované, a aktuálny predvolený označuje fajkou.

Z terminálu je to:

```bash
omarchy default browser firefox
```

Spusti to bez argumentu a povie ti, ktorý je aktuálny predvolený. Tým sa nastaví obsluha XDG, takže podľa toho nejdú len klávesové skratky Omarchy — čokoľvek, čo otvára odkaz, od chatovej aplikácie až po príkaz v termináli, smeruje do prehliadača, ktorý si si vybral.

## Kopírovanie URL a sťahovanie videa

Prehliadače z rodiny Chromium (samotné Chromium, Chrome, Edge a Brave) sa dodávajú s dvomi rozšíreniami Omarchy, ktoré siahajú von z prehliadača do zvyšku tvojho systému.

**Copy URL** vloží adresu aktuálnej karty do tvojej schránky pomocou `Alt + Shift + L`. Je to rýchlejšie než klikať do adresného riadka a kopírovať, a keďže to ide cez systémovú schránku, a nie schránku prehliadača, dostaneš potvrdenie notifikáciou Omarchy a URL je okamžite dostupná v [histórii schránky](08-unified-clipboard-history.md) a v každej inej aplikácii. K dispozícii je aj tlačidlo na paneli nástrojov, ak radšej klikáš.

**Download Video** uchmatne video prehrávané na stránke, na ktorú sa pozeráš, pomocou `Alt + Shift + D`. Odovzdá URL nástroju [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na oveľa viac než len na YouTube, a stiahnutý súbor pristane v `~/Videos`. Priebeh sa zobrazuje v tom istom zobrazení na obrazovke, ktoré používajú hlasitosť a jas, a aktualizuje sa na mieste, namiesto toho, aby sa kopili notifikácie. Nastav `OMARCHY_YTDLP_DIR`, ak chceš, aby súbory išli radšej niekam inam — kde umiestniť premenné prostredia, nájdeš v časti [Časté otázky](46-faq.md).

Obe rozšírenia komunikujú s Omarchy prostredníctvom malého natívneho hostiteľa správ (native messaging host), ktorý sa nainštaluje spolu s prehliadačom. To je tá súčasť, ktorá umožňuje, aby video z webovej stránky skončilo v tvojom domovskom adresári a URL v tvojom správcovi schránky, čo bežné rozšírenie samo nedokáže.

Tie sú len pre rodinu Chromium. Firefox a Zen ich nedostanú.

## Firefox a Zen

Firefox a Zen patria do inej rodiny, takže sa s nimi zaobchádza inak: Omarchy pre ne nainštaluje súbor politík s rozumnými predvolenými nastaveniami a prepne ich do natívneho režimu Wayland, ktorý chceš pre zlomkové škálovanie a plynulé posúvanie trackpadom.

Nedostanú vyššie uvedené rozšírenia Chromium a Omarchy ich netémuje, takže tieto časti zážitku si musíš nastaviť sám.

## Opätovné odstránenie jedného z nich

Čokoľvek, čo si tu nainštaloval, môžeš opäť odstrániť v časti _Odstrániť > Prehliadač_. Chromium v tomto zozname nie je — je súčasťou základného systému.
