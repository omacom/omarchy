# FAQ

### Ako prepínať medzi rozloženiami klávesnice?

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

Panel automaticky zobrazí vaše aktuálne rozloženie klávesnice, keď budete mať nakonfigurovaných viac rozložení (a kliknutím naň môžete prepínať aj vy).

### Ako zmeniť formát hodín na 12-hodinový?

Kliknite pravým tlačidlom na hodiny v paneli a cyklicky prepínajte medzi bežnými formátmi vrátane 12-hodinových. Formát môžete nastaviť aj priamo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Zobrazí sa nedeľa 10:55 AM.

### Ako zmeniť časové pásmo?

Spustite _Nastavenie > Región > Časové pásmo_ v ponuke Omarchy a vyberte zo zoznamu. Ak je časové pásmo správne, ale samotné hodiny sa posunuli, _Aktualizácia > Čas_ za vás reštartuje synchronizáciu času.

### Ako zmeniť DNS, zdieľať Wi-Fi alebo skontrolovať rýchlosť pripojenia?

To všetko nájdete v časti [sieťové nastavenia](35-networking.md).

### Ako skontrolovať, aký rýchly je môj disk?

_Spúšťač > Test rýchlosti > Test rýchlosti disku_ meria aktuálnu rýchlosť čítania a zápisu na vašom disku, alebo `omarchy disk speedtest` z terminálu.

### Ako pridať tlačiareň?

Tlač je nastavená a funguje hneď po vybalení a každú tlačiareň si pridáte sami z _Nastavenia tlače_ v spúšťači aplikácií (`Super + Alt + Space`).

Vyberte _Pridať_ a chvíľu počkajte, kým sa vyhľadá: tlačiareň pripojená cez USB a väčšina sieťových tlačiarní sa nájde za vás. Ak vaša v zozname nie je, vyberte _Sieťová tlačiareň > Internet Printing Protocol (ipp)_ a zadajte jej adresu — displej samotnej tlačiarne alebo jej webová stránka vám povie, aká to je, zvyčajne niečo ako `192.168.1.50` s frontom `ipp/print`. _Ďalej_ potom ponúkne ovládač, pričom moderná tlačiareň funguje najlepšie na bezovládačovom profile _IPP Everywhere_ a staršia chce vlastný ovládač pre daný model.

Kliknite pravým tlačidlom na tlačiareň a vyberte _Nastaviť ako predvolenú_, aby ste určili, po ktorej vaše aplikácie siahnu ako prvej, a _Vlastnosti_ na nastavenie veľkosti papiera, obojstrannej tlače a kvality.

Automatické vyhľadávanie, pri ktorom sa tlačiarne v sieti objavia bez pridávania, je dočasne vypnuté, kým sa prepracúva, a preto je prvý krok vyššie na vás, nie automatický. Tlač do súboru PDF funguje aj úplne bez akejkoľvek tlačiarne.

### Ako zmeniť, kam sa ukladajú snímky obrazovky alebo nahrávky obrazovky?

Uložené snímky obrazovky idú predvolene do `~/Pictures/Screenshots`. Ak chcete použiť iný adresár, pridajte toto do súboru v `~/.config/uwsm/env.d/` (napríklad `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To isté môžete urobiť pre nahrávky obrazovky pomocou `OMARCHY_SCREENRECORD_DIR`.

Omasnap vytvorí svoj adresár pre snímky obrazovky automaticky. Adresár pre nahrávky obrazovky si vytvorte sami a potom reštartujte Omarchy, aby sa ktorákoľvek zmena prostredia prejavila.

### Ako rozbehnúť reproduktory + webkameru na mojom Apple Studio Display?

Človek by čakal, že všetko bude fungovať len po zapojení USB C, ale bohužiaľ to tak nie je. Riešenie, ktoré som našiel a vďaka ktorému to funguje spoľahlivo, je použiť [kábel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potom reproduktory a webkamera fungujú ako po masle.

Pamätajte, že v Omarchy máte zabudované ovládanie jasu pre Apple displeje (Studio aj XDR) pomocou bežných klávesov na ovládanie jasu na klávesnici.

### Ako sa zbaviť všetkého softvéru navyše?

Ak nechcete programy ako Obsidian alebo LibreOffice alebo čokoľvek iné z predinštalovaných vecí, môžete ich veľmi jednoducho odstrániť.

Spustite _Odstrániť > Balíček_, aby ste videli každý nainštalovaný balíček. Potom môžete klávesom tab vybrať ľubovoľný balíček, ktorý chcete odstrániť, a klávesom return začať odstraňovať všetko, čo ste vybrali.

A z ponuky Omarchy môžete použiť _Odstrániť > Webová aplikácia_ na odstránenie ktorejkoľvek z predinštalovaných webových aplikácií, ktoré nechcete.

Alebo spustite _Odstrániť > Predinštalované_ a jedným ťahom vymetiete všetky predinštalované doplnky — webové aplikácie, TUI a voliteľné aplikácie. Klávesové skratky, ktoré ich spúšťali, zmiznú spolu s nimi, takže vám zostane čistý štít skratiek, ktorý si zaplníte vlastnými v `~/.config/hypr/bindings.lua`.

---

Pre chyby a pokazené veci pozrite [časť Riešenie problémov](45-troubleshooting.md).
