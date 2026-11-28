# Branding

Omarchy vám umožňuje nastavit firemní logo nebo osobní obrázek jak pro spořič obrazovky, tak pro obrazovku About.

### Spořič obrazovky

Logo použité pro spořič obrazovky můžete změnit v _Appearance > Branding > Screensaver_. Je to ASCII logo, takže text můžete upravovat přímo, ale můžete mu také předat obrázek png nebo svg a my ho převedeme do ASCII. Vypadá to docela cool.

 ![branding-screensaver](images/branding-screensaver.webp)

V této nabídce jsou tři položky:

- **Edit Text** otevře `~/.config/omarchy/branding/screensaver.txt` ve vašem editoru. Napište nebo vložte, cokoli chcete — ASCII art, své jméno, sprosté slovo. Uložte a zavřete a spořič obrazovky se okamžitě spustí, abyste ho viděli.
- **Set From Image** otevře výběr souboru pro png nebo svg, převede ho do ASCII a ukáže vám výsledek. Loga s jasnou siluetou fungují mnohem lépe než fotografie.
- **Restore Default** vrátí zpět logo Omarchy.

### Obrazovka About

Stejné tři možnosti jsou v _Appearance > Branding > About_ pro obrazovku _About_, kterou získáte z nabídky Omarchy, a fungují naprosto stejně — soubor je `~/.config/omarchy/branding/about.txt` a okno About se po každé změně objeví. Obrázek pro About se převádí na menší velikost než ten pro spořič obrazovky, protože se musí vejít do okna, místo aby vyplnil celý váš displej.

Dokud je okno otevřené, každých pár sekund se přes obrázek přežene pás jasného bílého světla a pak ho zase nechá v klidu. Váš vlastní obrázek ho dostane taky, pokud je v něm každý znak široký jeden sloupec — a všechno, co vytvoří _Set From Image_, takový je. Obrázek vytvořený z emoji nebo ze znaků o dvojité šířce místo toho zůstává v klidu, a stejně tak obrazovka, pokud si ponecháte vlastní konfiguraci fastfetch: nehybné logo v těchto případech znamená, že se animace drží stranou, ne že selhala, protože posunutí odlesku přes ně by zbytek řádku dostalo na špatné místo.

 ![branding-about](images/branding-about.webp)

### Převádění obrázků svépomocí

Obě možnosti _Set From Image_ jen volají `omarchy transcode ascii`, který můžete spustit přímo, pokud chcete mít nad převodem kontrolu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Bere `--width` a `--height` ve sloupcích a řádcích terminálu, `--mode` buď `braille` (výchozí a mnohem jemnější), nebo `block`, `--threshold` v procentech pro rozhodnutí, které pixely se počítají jako součást loga, a `--invert` pro případy, kdy je vaše logo světlé na tmavém pozadí. Pokud z převodu vyjde flek, threshold je obvykle ten parametr, kterým je třeba otočit.

### Slova místo loga

`omarchy ascii` kreslí text fontem Delta Corps Priest 1, FIGlet fontem, kterým je nakreslený samotný nápis Omarchy, takže spořič obrazovky může něco říkat, místo aby ukazoval obrázek:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Text bere jako argumenty, nebo ho čte z roury, když žádné nedostane. Font obsahuje pouze písmena a mezery — byl nakreslen bez číslic a interpunkce — takže cokoli jiného je vynecháno a pojmenováno na stderr, místo aby to bylo tiše spolknuto.
