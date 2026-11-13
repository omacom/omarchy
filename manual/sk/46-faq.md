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

Panel automaticky zobrazí vaše aktuálne rozloženie klávesnice, hneď ako budete mať nakonfigurovaných viacero rozložení (a kliknutím naň môžete prepínať tiež).

### Ako zmením formát hodín na 12-hodinový?

Kliknite pravým tlačidlom na hodiny na paneli a cyklicky prepínajte bežné formáty vrátane 12-hodinových. Formát môžete nastaviť aj priamo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Týmto sa zobrazí nedeľa 10:55 AM.

### Ako zmením svoje časové pásmo?

Spustite _Update > Timezone_ v ponuke Omarchy a vyberte si zo zoznamu. Ak je časové pásmo správne, ale hodiny samotné sa posunuli, _Update > Time_ za vás reštartuje synchronizáciu času.

### Ako zmením svoj DNS, zdieľam svoju Wi-Fi alebo skontrolujem rýchlosť pripojenia?

To všetko nájdete v časti [sieťovanie](35-networking.md).

### Ako skontrolujem, aký rýchly je môj disk?

_Trigger > Speed Test > Disk Speed Test_ meria aktuálnu rýchlosť čítania a zápisu na vašom disku, alebo `omarchy disk speedtest` z terminálu.

### Ako pridám tlačiareň?

Tlač je nastavená a beží hneď po inštalácii a každú tlačiareň si pridáte sami cez _Print Settings_ v spúšťači aplikácií (`Super + Space`).

Vyberte _Add_ a dajte tomu chvíľu na vyhľadanie: tlačiareň pripojenú cez USB a väčšinu sieťových tlačiarní to nájde za vás. Ak vaša v zozname nie je, vyberte _Network Printer > Internet Printing Protocol (ipp)_ a zadajte jej adresu — tú vám povie vlastný displej tlačiarne alebo jej webová stránka, zvyčajne niečo ako `192.168.1.50` s frontom `ipp/print`. _Forward_ potom ponúkne ovládač, pričom moderná tlačiareň funguje najlepšie na profile _IPP Everywhere_ bez ovládača a staršia chce vlastný ovládač pre daný model.

Kliknite pravým tlačidlom na tlačiareň a vyberte _Set as Default_, čím určíte, po ktorej vaše aplikácie siahnu ako prvej, a _Properties_ na nastavenie veľkosti papiera, obojstrannej tlače a kvality.

Automatické vyhľadávanie, pri ktorom sa tlačiarne v sieti objavia bez pridávania, je dočasne vypnuté, kým sa prerába, a preto je prvý krok vyššie na vás, nie automatický. Tlač do súboru PDF funguje úplne bez tlačiarne.

### Ako zmením, kam sa ukladajú snímky obrazovky alebo nahrávky obrazovky?

Uložené snímky obrazovky idú predvolene do `~/Pictures/Screenshots`. Ak chcete použiť iný adresár, pridajte toto do súboru v `~/.config/uwsm/env.d/` (napríklad `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To isté môžete urobiť pre nahrávky obrazovky pomocou `OMARCHY_SCREENRECORD_DIR`.

Omasnap vytvorí svoj adresár pre snímky obrazovky automaticky. Adresár pre nahrávky obrazovky si vytvorte sami a potom reštartujte Omarchy, aby sa ktorákoľvek zmena prostredia prejavila.

### Ako rozbehnem reproduktory + webkameru na mojom Apple Studio Display?

Človek by si myslel, že to všetko bude fungovať jednoducho po pripojení cez USB C, ale bohužiaľ to tak nie je. Riešenie, ktoré som našiel, aby to fungovalo spoľahlivo, je použiť [kábel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potom reproduktory a webkamera fungujú ako po masle.

Nezabudnite, že v Omarchy máte zabudované ovládanie jasu pre Apple displeje (Studio aj XDR) pomocou bežných klávesov na ovládanie jasu na klávesnici.

### Ako sa zbavím všetkého softvéru navyše?

Ak nechcete programy ako Obsidian alebo LibreOffice ani nič z ďalšieho predinštalovaného balastu, môžete ich veľmi jednoducho odstrániť.

Spustite _Remove > Package_, aby ste videli každý nainštalovaný balík. Potom môžete klávesom tab vybrať ľubovoľný balík, ktorý chcete odstrániť, a klávesom return spustiť odstraňovanie všetkého vybraného.

A cez _Remove > Web App_ z ponuky Omarchy môžete odstrániť ktorúkoľvek z predinštalovaných webových aplikácií, ktorú nechcete.

Alebo spustite _Remove > Preinstalls_ a vymetiete všetky predinštalované extra veci — webové aplikácie, TUIs a voliteľné aplikácie — naraz. Klávesové skratky, ktoré ich spúšťali, zmiznú spolu s nimi, takže vám zostane čistý štít väzieb, ktorý si môžete naplniť vlastnými v `~/.config/hypr/bindings.lua`.

---

Pri chybách a pokazených veciach pozrite [časť Riešenie problémov](45-troubleshooting.md).
