# Branding

Omarchy vám umožňuje nastavit firemní logo nebo osobní obrázek pro odemčení při bootu, spořič obrazovky i obrazovku O aplikaci.

### Odemčení při bootu

Pomocí `omarchy plymouth preview` se můžete podívat, jak by vaše vlastní logo a barvy vypadaly. Přijímá barvu pozadí, barvu textu, png s logem a cestu pro náhledový obrázek:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Poté nastavení použijte pomocí `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, což dá přihlašovací obrazovce SDDM stejné barvy a logo. Pokud to chcete vrátit zpět, můžete použít `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Spořič obrazovky

Logo použité pro spořič obrazovky můžete změnit v _Vzhled > Branding > Spořič obrazovky_. Je to ASCII logo, takže můžete text upravovat přímo, ale můžete mu také předat obrázek png nebo svg a my ho převedeme do ASCII. Vypadá to docela cool.

 ![branding-screensaver](images/branding-screensaver.webp)

V tomto menu jsou tři položky:

- **Upravit text** otevře `~/.config/omarchy/branding/screensaver.txt` ve vašem editoru. Napište nebo vložte, co chcete — ASCII art, své jméno, sprosté slovo. Uložte a zavřete a spořič obrazovky se okamžitě spustí, abyste ho viděli.
- **Nastavit z obrázku** otevře výběr souboru pro png nebo svg, převede ho do ASCII a ukáže vám výsledek. Loga s jasnou siluetou fungují mnohem lépe než fotografie.
- **Obnovit výchozí** vrátí zpět logo Omarchy.

### Obrazovka O aplikaci

Stejné tři možnosti jsou v _Vzhled > Branding > O aplikaci_ pro obrazovku _O aplikaci_, kterou získáte z menu Omarchy, a fungují identicky — soubor je `~/.config/omarchy/branding/about.txt` a okno O aplikaci se po každé změně objeví. Kresba pro O aplikaci se převádí do menší velikosti než ta pro spořič obrazovky, protože se musí vejít do okna, místo aby vyplnila celý displej.

Dokud je okno otevřené, každých pár sekund se přes kresbu přežene zelený záblesk a pak ji zase nechá v klidu. Vaše vlastní kresba ho dostane také, pokud je každý znak v ní široký jeden sloupec — a všechno, co vytvoří _Nastavit z obrázku_, takové je. Kresba sestavená z emoji nebo znaků s dvojitou šířkou místo toho zůstává v klidu, a stejně tak obrazovka, pokud si ponecháte vlastní konfiguraci fastfetch: nehybné logo v těchto případech znamená, že se animace drží stranou, nikoli že selhává, protože posunutí záblesku přes ně by zbytek řádku dostalo na špatné místo.

 ![branding-about](images/branding-about.webp)

### Převod obrázků svépomocí

Obě možnosti _Nastavit z obrázku_ jen volají `omarchy transcode ascii`, který můžete spustit přímo, pokud chcete mít nad převodem kontrolu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Přijímá `--width` a `--height` ve sloupcích a řádcích terminálu, `--mode` buď `braille` (výchozí a mnohem jemnější), nebo `block`, procentuální `--threshold` pro rozhodování, které pixely se počítají jako součást loga, a `--invert` pro případy, kdy je vaše logo světlé na tmavém pozadí. Pokud převod vyjde jako flek, práh je obvykle ten knoflík, kterým je třeba otočit.

### Slova místo loga

`omarchy ascii` kreslí text fontem Delta Corps Priest 1, FIGlet fontem, kterým je nakreslen samotný wordmark Omarchy, takže spořič obrazovky může něco říkat, místo aby ukazoval obrázek:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Přijímá text jako argumenty, nebo ho čte z roury, když žádné nedostane. Font obsahuje pouze písmena a mezery — byl nakreslen bez číslic a interpunkce — takže cokoli jiného je vyřazeno a pojmenováno na stderr, místo aby to bylo tiše spolknuto.
