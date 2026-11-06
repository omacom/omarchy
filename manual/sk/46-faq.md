# Časté otázky

### Ako prepínam medzi rozloženiami klávesnice?

Upravte svoj súbor `~/.config/hypr/input.lua` a pridajte toto, ak chcete prepínať medzi rozloženiami skratkou `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Lišta automaticky ukáže vaše aktuálne rozloženie klávesnice, keď budete mať nakonfigurovaných viacero rozložení (a môžete na ňu kliknúť a prepnúť tiež).

### Ako zmením formát hodín na 12-hodinový?

Pravým tlačidlom myši kliknite na hodiny v lište, ak chcete prechádzať bežnými formátmi vrátane 12-hodinových. Formát môžete nastaviť aj priamo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tým sa zobrazí Sunday 10:55 AM.

### Ako zmením svoje časové pásmo?

Spustite _Aktualizovať > Timezone_ v ponuke Omarchy a vyberte zo zoznamu. Ak je časové pásmo správne, ale hodiny samotné sa posunuli, _Aktualizovať > Time_ za vás reštartuje synchronizáciu času.

### Ako zmením svoje DNS, zdieľam svoju Wi-Fi alebo skontrolujem rýchlosť pripojenia?

To všetko nájdete v časti [siete](35-networking.md).

### Ako skontrolujem, ako rýchly je môj disk?

_Akcie > Test rýchlosti > Test rýchlosti disku_ meria aktuálnu rýchlosť čítania a zápisu na vašom disku, alebo `omarchy disk speedtest` z terminálu.

### Prečo sa nemôžem prihlásiť do svojho účtu Google v prehliadači Chromium?

Bežná open source zostava Chromium sa nedodáva s prihlasovacími údajmi OAuth, ktoré Google vyžaduje na prihlásenie do účtu. Spustite _Inštalovať > Service > Chromium Account_ v ponuke Omarchy, ak ich chcete pridať, reštartujte prehliadač a prihlásenie prejde.

### Ako pridám tlačiareň?

Tlač je nastavená a funguje hneď po vybalení a každú tlačiareň si pridáte sami z časti _Print Settings_ v spúšťači aplikácií (`Super + Space`).

Vyberte _Add_ a dajte mu chvíľu na hľadanie: tlačiareň zapojená cez USB a väčšina sieťových tlačiarní sa nájde za vás. Ak vaša nie je v zozname, vyberte _Network Printer > Internet Printing Protocol (ipp)_ a zadajte jej adresu — vlastný displej tlačiarne alebo jej webová stránka vám povedia, aká je, zvyčajne niečo ako `192.168.1.50` s frontom `ipp/print`. _Forward_ potom ponúkne ovládač, pričom moderná tlačiareň funguje najlepšie na bezovládačovom profile _IPP Everywhere_ a staršia chce vlastný ovládač daného modelu.

Pravým tlačidlom myši kliknite na tlačiareň a vyberte _Set as Default_, ak chcete určiť, po ktorej budú vaše aplikácie siahať ako po prvej, a _Properties_, ak chcete nastaviť veľkosť papiera, obojstrannú tlač a kvalitu.

Automatické objavovanie, pri ktorom sa tlačiarne v sieti objavia bez pridávania, je dočasne vypnuté, kým sa prepracúva, a preto je prvý krok vyššie na vás, nie automatický. Tlač do súboru PDF funguje úplne bez akejkoľvek tlačiarne.

### Ako zmením, kam sa ukladajú snímky obrazovky alebo nahrávky obrazovky?

Uložené snímky obrazovky predvolene idú do `~/Pictures/Screenshots`. Ak chcete použiť iný adresár, pridajte toto do súboru v `~/.config/uwsm/env.d/` (napríklad `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Rovnako môžete urobiť pre nahrávky obrazovky pomocou `OMARCHY_SCREENRECORD_DIR`.

Omasnap si adresár snímok obrazovky vytvorí automaticky. Adresár nahrávok obrazovky si vytvorte sami a potom reštartujte Omarchy, aby sa ktorákoľvek zmena prostredia prejavila.

### Ako dosiahnem, aby fungovali reproduktory + webkamera na mojom Apple Studio Display?

Človek by si myslel, že by to všetko malo fungovať len zapojením USB C, ale bohužiaľ to tak nie je. Riešenie, ktoré som našiel, aby to spoľahlivo fungovalo, je použiť [kábel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potom reproduktory a webkamera fungujú ako hodinky.

Pamätajte, že jas displejov Apple (Studio aj XDR) máte v Omarchy vstavane ovládateľný pomocou bežných tlačidiel jasu na klávesnici.

### Ako sa zbavím všetkého dodatočného softvéru?

Ak nechcete programy ako Obsidian alebo LibreOffice ani žiadne iné predinštalované veci, môžete ich veľmi ľahko odstrániť.

Spustite _Odstrániť > Package_, ak chcete vidieť každý nainštalovaný balík. Potom môžete klávesom tab vybrať každý balík, ktorý chcete odstrániť, a klávesom Enter začať odstraňovať všetko, čo ste vybrali.

A z ponuky Omarchy môžete použiť _Odstrániť > Web App_ na odstránenie ľubovoľných predinštalovaných webových aplikácií, ktoré nechcete.

Alebo spustite _Odstrániť > Preinstalls_, ak chcete na jeden raz vymiesť všetky predinštalované doplnky — webové aplikácie, TUI a voliteľné aplikácie. Klávesové skratky, ktoré ich spúšťali, s nimi odídu tiež, takže vám zostane čistý stôl väzieb, ktoré môžete zaplniť vlastnými v `~/.config/hypr/bindings.lua`.

---

Pre chyby a pokazené časti pozrite časť [Riešenie problémov](45-troubleshooting.md).
