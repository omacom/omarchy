# Bežné úpravy

Toto je zbierka bežných prispôsobení nastavenia Omarchy. Vedzte, že občas môže byť potrebné, aby aktualizácie systému obnovili určité konfigurácie do pôvodného stavu. Ak sa to stane, vaše zmeny sa nestratia, ale uložia sa do súboru `.bak` v rovnakom adresári.

Ak niečo pokazíte, môžete jednotlivé konfigurácie obnoviť do pôvodného nastavenia cez _Aktualizovať > Config_ v ponuke Omarchy. Ak _naozaj_ pokazíte všetko, môžete všetky konfigurácie obnoviť príkazom `omarchy-reinstall`.

### Vždy zobrazovať všetky ikony v oznamovacej oblasti

Ikony v oznamovacej oblasti, ako Dropbox, 1password alebo Steam, sú predvolene skryté za šípkou rozbalenia oznamovacej oblasti, ktorá ich zobrazí, keď na ňu nasmerujete kurzor. Ak by ste ich chceli mať zobrazené stále, kliknite pravým tlačidlom na šípku rozbalenia, čím otvoríte správcu ikon oznamovacej oblasti, a potom pripnite ikony, ktoré chcete mať viditeľné (môžete tiež skryť tie, ktoré nechcete nikdy vidieť).

### Zaoblené rohy okien

Predvolený dizajn Omarchy je dizajn hranatých rohov, ale ak to chcete trochu zjemniť, môžete zmeniť `~/.config/hypr/looknfeel.lua` tak, aby zaoblenie už nebolo zakomentované:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Odstránenie medzier medzi oknami

Na displejoch notebookov niektorí ľudia nechcú plytvať žiadnymi pixelmi na medzery medzi oknami (alebo dokonca na hornú lištu, ktorú môžete vypnúť skratkou `Super + Shift + Space`). Všetky medzery a okraje môžete vypnúť skratkou `Super + Shift + Backspace` alebo ich odstrániť natrvalo odstránením komentárov v tejto časti súboru `~/.config/hypr/looknfeel.lua`:

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
