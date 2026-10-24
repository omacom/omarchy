# Branding

Omarchy vám umožňuje nastaviť logo vašej spoločnosti alebo osobný obrázok pre odomknutie pri zavádzaní, pre šetrič obrazovky aj pre obrazovku Informácie.

### Odomknutie pri zavádzaní

Môžete použiť `omarchy plymouth preview`, ak chcete vidieť, ako by vyzerali vaše vlastné logo a farby. Berie farbu pozadia, farbu textu, logo vo formáte png a cestu pre ukážkový obrázok:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Potom nastavenie použite príkazom `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, čo dá prihlasovacej obrazovke SDDM rovnaké farby a logo. Ak sa chcete vrátiť späť, môžete použiť `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Šetrič obrazovky

Logo používané pre šetrič obrazovky môžete zmeniť v časti _Štýl > Šetrič obrazovky_. Je to ASCII logo, takže môžete text upravovať priamo, ale môžete mu dať aj obrázok png alebo svg a my ho premeníme na ASCII. Vyzerá to celkom dobre.

 ![branding-screensaver](images/branding-screensaver.webp)

V tej ponuke sú tri položky:

- **Upraviť text** otvorí `~/.config/omarchy/branding/screensaver.txt` vo vašom editore. Napíšte alebo prilepte, čo len chcete — ASCII umenie, svoje meno, neslušné slovo. Uložte a ukončite a šetrič obrazovky sa okamžite spustí, aby ste ho mohli vidieť.
- **Nastaviť z obrázka** otvorí výber súboru pre png alebo svg, premení ho na ASCII a ukáže vám výsledok. Logá s jasnou siluetou fungujú oveľa lepšie než fotografie.
- **Obnoviť predvolené** vráti späť logo Omarchy.

### Obrazovka Informácie

Rovnaké tri možnosti sú v časti _Štýl > Informácie_ pre obrazovku _Informácie_, ktorú získate z ponuky Omarchy, a fungujú rovnako — súbor je `~/.config/omarchy/branding/about.txt` a okno Informácie sa zobrazí po každej zmene. Grafika pre Informácie sa prevádza na menšiu veľkosť než grafika šetriča obrazovky, keďže sa musí zmestiť do okna, namiesto toho, aby zaplnila váš displej.

Kým je okno otvorené, každých pár sekúnd sa cez grafiku nakloní záblesk zelenej a potom ju znova nechá v pokoji. Aj vaša vlastná grafika ho dostane, pokiaľ je každý znak v nej široký jeden stĺpec — a čokoľvek, čo vytvorí _Nastaviť z obrázka_, taký je. Grafika postavená z emoji alebo znakov s dvojitou šírkou namiesto toho zostáva v pokoji a rovnako aj obrazovka, ak si ponecháte vlastnú konfiguráciu fastfetch: statické logo v týchto prípadoch znamená, že animácia sa drží bokom, namiesto toho, aby zlyhala, keďže posunutie záblesku cez ne by zvyšok riadka dostalo na nesprávne miesto.

 ![branding-about](images/branding-about.webp)

### Samotný prevod obrázkov

Obe možnosti _Nastaviť z obrázka_ len volajú `omarchy transcode ascii`, čo môžete spustiť aj priamo, ak chcete mať prevod pod kontrolou:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Berie `--width` a `--height` v stĺpcoch a riadkoch terminálu, `--mode` buď `braille` (predvolené a oveľa jemnejšie), alebo `block`, `--threshold` v percentách na určenie, ktoré pixely sa počítajú ako súčasť loga, a `--invert` pre prípad, keď je vaše logo svetlé na tmavom pozadí. Ak prevod vyjde ako jedna škvrna, prah je zvyčajne ten gombík, ktorým treba otočiť.

### Slová namiesto loga

`omarchy ascii` kreslí text písmom Delta Corps Priest 1, písmom FIGlet, ktorým je nakreslený samotný wordmark Omarchy, takže šetrič obrazovky môže niečo hovoriť, namiesto toho, aby ukazoval obrázok:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Berie text ako argumenty alebo ho číta z rúry, keď mu žiadne nedáte. Písmo nesie len písmená a medzery — bolo nakreslené bez číslic a interpunkcie — takže všetko ostatné sa zahodí a pomenúva na stderr, namiesto toho, aby sa ticho prehltlo.
