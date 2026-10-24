# Vlastní logo

Omarchy umožňuje nastavit firemní logo nebo osobní obrázek pro odemknutí při spouštění, spořič obrazovky i obrazovku O aplikaci.

### Odemknutí při spouštění

Pomocí příkazu `omarchy plymouth preview` se můžete podívat, jak by vaše vlastní logo a barvy vypadaly. Přijímá barvu pozadí, barvu textu, logo ve formátu png a cestu k náhledovému obrázku:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Poté nastavení použijete příkazem `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, který stejné barvy a logo přiřadí také přihlašovací obrazovce SDDM. Pokud to chcete vrátit zpět, můžete použít příkaz `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Spořič obrazovky

Logo používané pro spořič obrazovky můžete změnit v části _Styl > Spořič obrazovky_. Jde o logo ve formě ASCII, takže můžete text přímo upravovat, ale můžete mu předat také obrázek png nebo svg a my ho převedeme na ASCII. Vypadá to docela dobře.

 ![branding-screensaver](images/branding-screensaver.webp)

V nabídce jsou tři položky:

- **Upravit text** otevře soubor `~/.config/omarchy/branding/screensaver.txt` ve vašem editoru. Napište nebo vložte cokoli — ASCII art, svoje jméno, sprosté slovo. Uložte a ukončete a spořič obrazovky se ihned spustí, abyste ho viděli.
- **Nastavit z obrázku** otevře výběr souboru png nebo svg, převede ho na ASCII a výsledek vám ukáže. Loga s jasnou siluetou fungují mnohem lépe než fotografie.
- **Obnovit výchozí** vrátí zpět logo Omarchy.

### Obrazovka O aplikaci

Stejné tři volby se nacházejí v části _Styl > O aplikaci_ pro obrazovku _O aplikaci_, kterou vyvoláte z nabídky Omarchy, a fungují totožně — soubor je `~/.config/omarchy/branding/about.txt` a okno O aplikaci se po každé změně zobrazí. Kresba na obrazovce O aplikaci se převádí na menší velikost než u spořiče obrazovky, protože se musí vejít do okna, nikoli vyplnit displej.

Dokud je okno otevřené, občas přes kresbu přejede zelený odlesk a poté ji opět nechá v klidu. Vaše vlastní kresba ho dostane také, pokud je každý její znak široký jeden sloupec — a to platí pro vše, co vytvoří příkaz _Nastavit z obrázku_. Kresba tvořená emoji nebo znaky s dvojitou šířkou namísto toho zůstane v klidu, a stejně tak obrazovka, pokud máte vlastní konfiguraci fastfetch: statické logo v těchto případech znamená, že animace drží stranou, místo aby selhala, protože posun odlesku napříč by posunul zbytek řádku na nesprávné místo.

 ![branding-about](images/branding-about.webp)

### Vlastní převod obrázků

Obě volby _Nastavit z obrázku_ ve skutečnosti pouze volají příkaz `omarchy transcode ascii`, který můžete spustit přímo, pokud chcete mít převod pod kontrolou:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Přijímá parametry `--width` a `--height` ve sloupcích a řádcích terminálu, `--mode` buď `braille` (výchozí a mnohem jemnější), nebo `block`, `--threshold` v procentech pro určení, které pixely se počítají jako součást loga, a `--invert` pro případy, kdy je vaše logo světlé na tmavém pozadí. Pokud převod dopadne jako jedna skvrna, obvykle pomůže právě úprava prahové hodnoty.

### Slova místo loga

Příkaz `omarchy ascii` vykreslí text písmem Delta Corps Priest 1, tedy písmem FIGlet, kterým je zhotovený i samotný slovní znak Omarchy, takže spořič obrazovky může něco říkat, místo aby zobrazoval obrázek:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Přijímá text jako argumenty, nebo ho čte z roury, pokud žádné nedostane. Písmo obsahuje pouze písmena a mezery — bylo nakresleno bez číslic a interpunkce — takže vše ostatní se zahodí a vypíše na standardní chybový výstup, místo aby se tiše vytratilo.
