# Branding

Omarchy vám umožňuje nastaviť logo vašej firmy alebo osobný obrázok pre odomknutie pri spustení, pre šetrič obrazovky aj pre obrazovku s informáciami.

### Odomknutie pri spustení

Pomocou `omarchy plymouth preview` si môžete pozrieť, ako by vyzeralo vaše vlastné logo a farby. Berie farbu pozadia, farbu textu, png s logom a cestu pre obrázok náhľadu:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Potom nastavenie použite pomocou `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, čím rovnaké farby a logo získa aj prihlasovacia obrazovka SDDM. Ak sa chcete vrátiť späť, môžete použiť `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Šetrič obrazovky

Logo použité pre šetrič obrazovky môžete zmeniť v časti _Appearance > Branding > Screensaver_. Je to ASCII logo, takže text môžete upravovať priamo, ale môžete mu dať aj obrázok png alebo svg a my ho prekonvertujeme do ASCII. Vyzerá to celkom cool.

 ![branding-screensaver](images/branding-screensaver.webp)

V tej ponuke sú tri položky:

- **Edit Text** otvorí `~/.config/omarchy/branding/screensaver.txt` vo vašom editore. Napíšte alebo prilepte, čo len chcete — ASCII art, vaše meno, neslušné slovo. Uložte a ukončite a šetrič obrazovky sa okamžite spustí, aby ste ho videli.
- **Set From Image** otvorí výber súboru pre png alebo svg, prekonvertuje ho do ASCII a ukáže vám výsledok. Logá s jasnou siluetou fungujú oveľa lepšie než fotografie.
- **Restore Default** vráti späť logo Omarchy.

### Obrazovka s informáciami

Rovnaké tri možnosti sú v časti _Appearance > Branding > About_ pre obrazovku _About_, ktorú získate z ponuky Omarchy, a fungujú identicky — súbor je `~/.config/omarchy/branding/about.txt` a okno About sa po každej zmene zobrazí. Grafika pre About sa konvertuje na menšiu veľkosť než grafika šetriča obrazovky, pretože sa musí zmestiť do okna, namiesto aby zaplnila celý displej.

Kým je okno otvorené, každých pár sekúnd sa cez grafiku šikmo preženie zelený záblesk a potom ju opäť nechá v pokoji. Vaša vlastná grafika ho dostane tiež, pokiaľ je každý znak v nej široký jeden stĺpec — a všetko, čo vyprodukuje _Set From Image_, takým je. Grafika vytvorená z emoji alebo zo znakov s dvojitou šírkou zostáva namiesto toho nehybná a rovnako aj obrazovka, ak si ponecháte vlastnú konfiguráciu fastfetch: nehybné logo je v týchto prípadoch tým, že animácia zostáva bokom, a nie zlyhaním, pretože posúvanie záblesku cez ne by zvyšok riadka dostalo na nesprávne miesto.

 ![branding-about](images/branding-about.webp)

### Samostatná konverzia obrázkov

Obe možnosti _Set From Image_ len volajú `omarchy transcode ascii`, ktoré môžete spustiť priamo, ak chcete mať nad konverziou kontrolu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Berie `--width` a `--height` v stĺpcoch a riadkoch terminálu, `--mode` buď `braille` (predvolené a oveľa jemnejšie), alebo `block`, percento `--threshold` na rozhodovanie o tom, ktoré pixely sa považujú za súčasť loga, a `--invert` pre prípad, keď je vaše logo svetlé na tmavom pozadí. Ak z konverzie vyjde škvrna, zvyčajne je to práve threshold, ktorým treba pohnúť.

### Slová namiesto loga

`omarchy ascii` kreslí text fontom Delta Corps Priest 1, fontom FIGlet, ktorým je nakreslený aj samotný wordmark Omarchy, takže šetrič obrazovky môže niečo povedať namiesto toho, aby ukazoval obrázok:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Berie text ako argumenty, alebo ho číta z rúry, keď mu žiadny nedáte. Font obsahuje iba písmená a medzery — bol nakreslený bez číslic a interpunkcie — takže všetko ostatné sa zahodí a pomenuje na stderr, namiesto aby sa to ticho prehltlo.
