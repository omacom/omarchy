# Běžné úpravy

Toto je sbírka běžných přizpůsobení nastavení Omarchy. Počítejte s tím, že občas může být při aktualizacích systému nutné obnovit některé konfigurace do původního stavu. Pokud k tomu dojde, vaše změny se neztratí, ale vloží se do souboru `.bak.<timestamp>` vedle původního.

Pokud něco pokazíte, můžete obnovit jednotlivé konfigurace do původního nastavení přes _Update > Config_ v nabídce Omarchy. Pokud to _opravdu_ pokazíte všechno, můžete resetovat všechny konfigurace pomocí `omarchy reinstall configs`, nebo přeinstalovat všechny výchozí balíčky a konfigurace pomocí `omarchy reinstall`.

### Zobrazovat všechny ikony v systémové liště pořád

Ve výchozím nastavení jsou ikony v systémové liště, jako Dropbox, 1password nebo Steam, skryté za šipkou pro rozbalení lišty, která je odhalí, když na ni najedete myší. Pokud je chcete mít odhalené pořád, klikněte pravým tlačítkem na šipku pro rozbalení, čímž otevřete správce ikon v systémové liště, a pak připněte ikony, které chcete mít pořád viditelné (můžete také skrýt ty, které nechcete nikdy vidět).

### Zaoblené rohy oken

Výchozí vzhled Omarchy má ostré rohy, ale pokud ho chcete trochu zjemnit, vyberte _Appearance > Windows > Window Corners > Rounded Corners_ v nabídce Omarchy, nebo spusťte `omarchy hyprland corners rounded`. _Theme Corners_ se vrátí k tomu, co používá dané téma. Chcete-li si zvolit vlastní poloměr, zůstaňte u _Theme Corners_ (`omarchy hyprland corners theme`), protože Rounded a Sharp se načítají až po vaší konfiguraci a přepíšou ji, a odkomentujte zaoblení v `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Odstranění mezer mezi okny

Na displejích notebooků někteří lidé raději neplýtvají ani pixelem na mezery mezi okny (nebo dokonce na horní lištu, kterou můžete vypnout pomocí `Super + Shift + Space`). Všechny mezery a okraje můžete vypnout pomocí `Super + Shift + Backspace`, nebo je trvale odstranit odstraněním komentářů v této části souboru `~/.config/hypr/looknfeel.lua`:

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
