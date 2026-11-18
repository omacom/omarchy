# Běžné úpravy

Toto je sbírka běžných přizpůsobení nastavení Omarchy. Mějte na paměti, že někdy může být u aktualizací systému nutné obnovit určité konfigurace do původního stavu. Pokud se to stane, vaše změny se neztratí, ale uloží se do souboru `.bak` ve stejném adresáři.

Pokud něco pokazíte, můžete obnovit jednotlivé konfigurace do původního nastavení v nabídce Omarchy v části _Aktualizovat > Config_. Pokud to pokazíte _opravdu_ všechno, můžete obnovit všechny konfigurace příkazem `omarchy-reinstall`.

### Trvalé zobrazení všech ikon v oblasti oznámení

Ve výchozím nastavení jsou ikony v oblasti oznámení, například Dropbox, 1password nebo Steam, skryté za šipkou pro rozbalení, která je zobrazí po přejetí ukazatelem myši. Pokud je chcete mít neustále na očích, klikněte pravým tlačítkem na rozbalovací šipku, čímž otevřete správce ikon v oblasti oznámení, a poté připněte ikony, které chcete ponechat viditelné (můžete také skrýt ty, které nikdy nechcete vidět).

### Zaoblené rohy oken

Výchozím stylem Omarchy jsou pravoúhlé rohy, ale pokud ho chcete trochu změkčit, můžete upravit soubor `~/.config/hypr/looknfeel.lua` tak, aby parametr rounding už nebyl zakomentovaný:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Odebrání mezer mezi okny

Na displejích notebooků někteří lidé nechtějí plýtvat ani jedním pixelem na mezery mezi okny (nebo dokonce na horní panel, který lze přepnout zkratkou `Super + Shift + Space`). Všechny mezery a ohraničení můžete vypnout zkratkou `Super + Shift + Backspace`, nebo je odstranit natrvalo odstraněním komentářů v této části souboru `~/.config/hypr/looknfeel.lua`:

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
