# Branding

Omarchy vám umožňuje nastavit logo vaší firmy nebo osobní obrázek pro odemknutí při bootu, spořič obrazovky i obrazovku O aplikaci.

### Odemknutí při bootu

Pomocí `omarchy plymouth preview` si můžete prohlédnout, jak by vaše vlastní logo a barvy vypadaly. Příkaz bere barvu pozadí, barvu textu, png s logem a cestu pro náhledový obrázek:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Nastavení pak použijete příkazem `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, který stejné barvy a logo nastaví i na přihlašovací obrazovce SDDM. Pokud se chcete vrátit zpět, můžete použít `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Spořič obrazovky

Logo použité pro spořič obrazovky můžete změnit v nabídce _Vzhled > Branding > Spořič obrazovky_. Je to ASCII logo, takže můžete text upravit přímo, ale můžete mu také předat obrázek png nebo svg a my ho převedeme do ASCII. Vypadá to docela cool.

 ![branding-screensaver](images/branding-screensaver.webp)

V této nabídce jsou tři položky:

- **Upravit text** otevře `~/.config/omarchy/branding/screensaver.txt` ve vašem editoru. Napište nebo vložte, co chcete — ASCII art, vaše jméno, sprosté slovo. Uložte a ukončete editor a spořič obrazovky se okamžitě spustí, abyste si ho mohli prohlédnout.
- **Nastavit z obrázku** otevře výběr souboru pro png nebo svg, převede ho do ASCII a ukáže vám výsledek. Loga s jasnou siluetou fungují mnohem lépe než fotografie.
- **Obnovit výchozí** vrátí zpět logo Omarchy.

### Obrazovka O aplikaci

Stejné tři možnosti najdete v nabídce _Vzhled > Branding > O aplikaci_ pro obrazovku _O aplikaci_, kterou otevřete z nabídky Omarchy, a fungují úplně stejně — soubor je `~/.config/omarchy/branding/about.txt` a okno O aplikaci se po každé změně samo otevře. Grafika pro O aplikaci se převádí do menší velikosti než grafika spořiče obrazovky, protože se musí vejít do okna, nikoli vyplnit celý displej.

Dokud je okno otevřené, každých pár sekund se přes grafiku nakloní pruh jasného bílého světla a pak ji zase nechá v klidu. Vaše vlastní grafika ho dostane také, pokud je každý znak v ní široký jeden sloupec — a vše, co vytvoří _Nastavit z obrázku_, takovou podmínku splňuje. Grafika vytvořená z emoji nebo dvojitě širokých znaků místo toho zůstane v klidu, stejně jako obrazovka, pokud si ponecháte vlastní konfiguraci fastfetch: nehybné logo je v těchto případech animace, která se drží stranou, nikoli selhání, protože posunutí odlesku přes ně by zbytek řádku dostalo na špatné místo.

 ![branding-about](images/branding-about.webp)

### Převod obrázků svépomocí

Obě možnosti _Nastavit z obrázku_ pouze volají `omarchy transcode ascii`, které můžete spustit přímo, pokud chcete mít nad převodem kontrolu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Příkaz bere `--width` a `--height` ve sloupcích a řádcích terminálu, `--mode` buď `braille` (výchozí a mnohem jemnější), nebo `block`, procentuální `--threshold` pro rozhodování, které pixely se počítají jako součást loga, a `--invert` pro případ, kdy je vaše logo světlé na tmavém pozadí. Pokud převod vyjde jako flek, obvykle je třeba pootočit právě prahem.

### Slova místo loga

`omarchy ascii` kreslí text písmem Delta Corps Priest 1, písmem FIGlet, kterým je nakreslený i samotný wordmark Omarchy, takže spořič obrazovky může něco říkat, místo aby ukazoval obrázek:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Text bere jako argumenty, nebo ho při jejich absenci čte z roury. Písmo obsahuje pouze písmena a mezery — bylo nakresleno bez číslic a interpunkce — takže vše ostatní se zahodí a vypíše na stderr, místo aby to bylo tiše spolknuto.
