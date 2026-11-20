# FAQ

### Ako prepínam medzi rozloženiami klávesnice?

Upravte súbor `~/.config/hypr/input.lua` a pridajte toto na prepínanie medzi rozloženiami pomocou `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Panel automaticky zobrazí vaše aktuálne rozloženie klávesnice, keď budete mať nakonfigurovaných viacero rozložení (a prepínať môžete aj kliknutím naň).

### Ako zmením formát hodín na 12-hodinový?

Kliknite pravým tlačidlom na hodiny v paneli a prechádzajte bežnými formátmi vrátane 12-hodinových. Formát môžete nastaviť aj priamo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Zobrazí sa Nedeľa 10:55 AM.

### Ako zmením svoje časové pásmo?

Spustite _Setup > Region > Timezone_ v ponuke Omarchy a vyberte zo zoznamu. Ak je časové pásmo správne, ale samotné hodiny sa posunuli, _Update > Time_ za vás reštartuje synchronizáciu času.

### Ako zmením svoj DNS, zdieľam svoju Wi-Fi alebo skontrolujem rýchlosť svojho pripojenia?

To všetko nájdete v časti [sieťovanie](35-networking.md).

### Ako skontrolujem, aký rýchly je môj disk?

_Trigger > Speed Test > Disk Speed Test_ meria aktuálnu rýchlosť čítania a zápisu na vašom disku, alebo `omarchy disk speedtest` z terminálu.

### Ako pridám tlačiareň?

Tlač je nastavená a beží hneď po vybalení a každú tlačiareň si pridávate sami z _Print Settings_ v spúšťači aplikácií (`Super + Space`).

Vyberte _Add_ a dajte tomu chvíľku na hľadanie: tlačiareň pripojená cez USB a väčšina sieťových tlačiarní sa nájde za vás. Ak vaša v zozname nie je, vyberte _Network Printer > Internet Printing Protocol (ipp)_ a zadajte jej adresu — tú vám povie vlastný displej tlačiarne alebo jej webová stránka, zvyčajne niečo ako `192.168.1.50` s frontom `ipp/print`. _Forward_ potom ponúkne ovládač, pričom moderná tlačiareň funguje najlepšie na bezovládačovom profile _IPP Everywhere_ a staršia chce vlastný ovládač daného modelu.

Kliknite pravým tlačidlom na tlačiareň a vyberte _Set as Default_, aby ste zvolili, po ktorej vaše aplikácie siahnu ako po prvej, a _Properties_ na nastavenie veľkosti papiera, obojstrannej tlače a kvality.

Automatické vyhľadávanie, pri ktorom sa tlačiarne v sieti objavia bez pridávania, je dočasne vypnuté, kým sa prepracúva, a preto je prvý krok vyššie na vás, nie automatický. Tlač do súboru PDF funguje úplne bez akejkoľvek tlačiarne.

### Ako zmením, kam sa ukladajú snímky obrazovky alebo nahrávky obrazovky?

Uložené snímky obrazovky idú predvolene do `~/Pictures/Screenshots`. Ak chcete použiť iný adresár, pridajte toto do súboru pod `~/.config/uwsm/env.d/` (napríklad `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To isté môžete urobiť pre nahrávky obrazovky pomocou `OMARCHY_SCREENRECORD_DIR`.

Omasnap si svoj adresár pre snímky obrazovky vytvorí automaticky. Adresár pre nahrávky obrazovky si vytvorte sami a potom reštartujte Omarchy, aby sa ktorákoľvek zmena prostredia prejavila.

### Ako rozbehnem reproduktory + webkameru na mojom Apple Studio Display?

Človek by si myslel, že to všetko musí fungovať len po pripojení cez USB C, ale bohužiaľ to tak nie je. Riešenie, ktoré som našiel, aby to fungovalo spoľahlivo, je použiť [kábel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potom reproduktory a webkamera fungujú bezchybne.

Nezabudnite, že v Omarchy máte zabudované ovládanie jasu pre Apple displeje (Studio aj XDR) pomocou bežných klávesov na ovládanie jasu na klávesnici.

### Ako sa zbavím všetkého softvéru navyše?

Ak nechcete programy ako Obsidian alebo LibreOffice alebo čokoľvek iné z predinštalovaných vecí, môžete to veľmi jednoducho odstrániť.

Spustite _Remove > Package_, aby ste videli každý nainštalovaný balík. Potom môžete pomocou tab vybrať ľubovoľný balík, ktorý chcete odstrániť, a pomocou return spustiť odstraňovanie všetkého, čo ste vybrali.

A z ponuky Omarchy môžete použiť _Remove > Web App_ na odstránenie ktorejkoľvek predinštalovanej webovej aplikácie, ktorú nechcete.

Alebo spustite _Remove > Preinstalls_ a vymeťte všetky predinštalované veci navyše — webové aplikácie, TUIs a voliteľné aplikácie — naraz. Klávesové skratky, ktoré ich spúšťali, zmiznú spolu s nimi, takže vám zostane čistý štít väzieb, ktorý si môžete naplniť vlastnými v `~/.config/hypr/bindings.lua`.

---

Pre chyby a pokazené veci pozrite [časť Riešenie problémov](45-troubleshooting.md).
