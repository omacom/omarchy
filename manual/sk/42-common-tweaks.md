# Bežné úpravy

Toto je zbierka bežných prispôsobení nastavenia Omarchy. Berte na vedomie, že pri systémových aktualizáciách môže byť občas potrebné obnoviť niektoré konfigurácie do pôvodného stavu. Ak sa to stane, vaše zmeny sa nestratia, ale uložia sa do súboru `.bak.<timestamp>` vedľa originálu.

Ak niečo pokazíte, jednotlivé konfigurácie môžete obnoviť do pôvodného nastavenia cez _Update > Config_ v menu Omarchy. Ak to _naozaj_ všetko pokazíte, všetky konfigurácie môžete resetovať cez `omarchy reinstall configs`, alebo preinštalovať každý predvolený balík a konfiguráciu pomocou `omarchy reinstall`.

### Všetky ikony v systémovej lište zobrazovať neustále

Ikony v systémovej lište, ako napríklad Dropbox, 1password alebo Steam, sú predvolene skryté za šípkou na rozbalenie lišty, ktorá ich odhalí, keď na ňu nabehnete myšou. Ak ich chcete mať odhalené neustále, kliknite pravým tlačidlom myši na šípku na rozbalenie, čím otvoríte správcu ikon v systémovej lište, a potom pripnite ikony, ktoré chcete mať stále viditeľné (môžete tiež skryť tie, ktoré nechcete vidieť nikdy).

### Zaoblené rohy okien

Predvolený dizajn Omarchy má hranaté rohy, ale ak ho chcete trochu zjemniť, vyberte _Appearance > Windows > Window Corners > Rounded Corners_ v menu Omarchy, alebo spustite `omarchy hyprland corners rounded`. _Theme Corners_ sa vráti k tomu, čo používa téma. Ak si chcete vybrať vlastný polomer, zostaňte pri _Theme Corners_ (`omarchy hyprland corners theme`), pretože Rounded a Sharp sa načítajú po vašej konfigurácii a prepíšu ju, a odkomentujte zaoblenie v `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Odstránenie medzier medzi oknami

Na displejoch notebookov niektorí ľudia radšej nemrhajú žiadnymi pixelmi na medzery medzi oknami (alebo dokonca na hornú lištu, ktorú môžete vypnúť pomocou `Super + Shift + Space`). Všetky medzery a okraje môžete zapínať a vypínať pomocou `Super + Shift + Backspace`, alebo ich natrvalo odstrániť odstránením komentárov v tejto časti `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
