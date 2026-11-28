# Branding

Omarchy vám umožňuje nastaviť si firemné logo alebo osobný obrázok pre odomknutie pri štarte, šetrič obrazovky aj obrazovku s informáciami.

### Odomknutie pri štarte

Pomocou `omarchy plymouth preview` si môžete pozrieť, ako by vyzeralo vaše vlastné logo a farby. Príkaz prijíma farbu pozadia, farbu textu, logo vo formáte png a cestu k obrázku ukážky:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Nastavenie potom použijete príkazom `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, ktorý rovnaké farby a logo priradí aj prihlasovacej obrazovke SDDM. Ak to chcete vrátiť späť, môžete použiť `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Šetrič obrazovky

Logo použité pre šetrič obrazovky môžete zmeniť v časti _Vzhľad > Branding > Šetrič obrazovky_. Je to ASCII logo, takže text môžete upravovať priamo, ale môžete mu aj odovzdať obrázok png alebo svg a my ho prevedieme do ASCII. Vyzerá to fakt dobre.

 ![branding-screensaver](images/branding-screensaver.webp)

V tomto menu sú tri položky:

- **Upraviť text** otvorí `~/.config/omarchy/branding/screensaver.txt` vo vašom editore. Napíšte alebo prilepte, čo len chcete — ASCII obrázok, vaše meno, neslušné slovo. Uložte a zatvorte a šetrič obrazovky sa okamžite spustí, aby ste si to mohli pozrieť.
- **Nastaviť z obrázka** otvorí výber súboru pre png alebo svg, prevedie ho do ASCII a ukáže vám výsledok. Logá s jasnou siluetou fungujú oveľa lepšie ako fotografie.
- **Obnoviť predvolené** vráti späť logo Omarchy.

### Obrazovka s informáciami

Tie isté tri možnosti sú v časti _Vzhľad > Branding > Informácie_ pre obrazovku _Informácie_, ktorú získate z menu Omarchy, a fungujú úplne rovnako — súbor je `~/.config/omarchy/branding/about.txt` a okno Informácie sa zobrazí po každej zmene. Obrázok pre Informácie sa prevádza na menšiu veľkosť ako obrázok pre šetrič obrazovky, pretože sa musí zmestiť do okna, a nie vyplniť celú vašu obrazovku.

Kým je okno otvorené, každých pár sekúnd sa cez obrázok preženie pás jasného bieleho svetla a potom ho zase nechá v pokoji. Dostane ho aj váš vlastný obrázok, pokiaľ je každý znak v ňom široký jeden stĺpec — a všetko, čo vytvorí _Nastaviť z obrázka_, také je. Obrázok zložený z emoji alebo znakov s dvojnásobnou šírkou namiesto toho zostáva nehybný, a rovnako aj obrazovka, ak si ponecháte vlastnú konfiguráciu fastfetch: nehybné logo je v týchto prípadoch tým, že sa animácia drží bokom, a nie tým, že zlyhala, pretože posúvanie odlesku cez ne by zvyšok riadka dostalo na nesprávne miesto.

 ![branding-about](images/branding-about.webp)

### Prevod obrázkov vlastnoručne

Obe možnosti _Nastaviť z obrázka_ len volajú `omarchy transcode ascii`, čo môžete spustiť aj priamo, ak chcete mať prevod pod kontrolou:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Prijíma `--width` a `--height` v stĺpcoch a riadkoch terminálu, `--mode` buď `braille` (predvolené a oveľa jemnejšie), alebo `block`, percentuálnu hodnotu `--threshold` na rozhodnutie, ktoré pixely sa považujú za súčasť loga, a `--invert` pre prípad, keď je vaše logo svetlé na tmavom pozadí. Ak prevod vyjde ako fľak, zvyčajne pomôže pohnúť práve thresholdom.

### Slová namiesto loga

`omarchy ascii` kreslí text písmom Delta Corps Priest 1, FIGlet písmom, ktorým je nakreslený aj samotný wordmark Omarchy, takže šetrič obrazovky môže niečo povedať, a nie len ukázať obrázok:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Preberá text ako argumenty, alebo ho číta z rúry, keď nedostane žiadny. Písmo obsahuje len písmená a medzery — bolo nakreslené bez číslic a interpunkcie — takže všetko ostatné sa zahodí a vypíše na stderr, namiesto aby sa to potichu prehltlo.
