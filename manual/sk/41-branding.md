# Branding

Omarchy vám umožňuje nastaviť logo vašej firmy alebo osobný obrázok pre šetrič obrazovky aj pre obrazovku About.

### Šetrič obrazovky

Logo použité pre šetrič obrazovky môžete zmeniť v časti _Vzhľad > Branding > Šetrič obrazovky_. Je to ASCII logo, takže text môžete upravovať priamo, ale môžete mu poskytnúť aj obrázok png alebo svg a my ho prevedieme do ASCII. Vyzerá to celkom dobre.

 ![branding-screensaver](images/branding-screensaver.webp)

V tomto menu sú tri položky:

- **Upraviť text** otvorí `~/.config/omarchy/branding/screensaver.txt` vo vašom editore. Napíšte alebo prilepte čokoľvek, čo chcete — ASCII art, vaše meno, neslušné slovo. Uložte a ukončite a šetrič obrazovky sa okamžite spustí, aby ste si ho mohli pozrieť.
- **Nastaviť z obrázka** otvorí výber súboru pre png alebo svg, prevedie ho do ASCII a ukáže vám výsledok. Logá s jasnou siluetou fungujú oveľa lepšie ako fotografie.
- **Obnoviť predvolené** vráti späť logo Omarchy.

### Obrazovka About

Rovnaké tri možnosti sú v časti _Vzhľad > Branding > About_ pre obrazovku _About_, ktorú získate z menu Omarchy, a fungujú rovnako — súbor je `~/.config/omarchy/branding/about.txt` a okno About sa zobrazí po každej zmene. Grafika About sa prevádza na menšiu veľkosť ako grafika šetriča obrazovky, pretože sa musí zmestiť do okna, nie vyplniť celý váš displej.

Kým je okno otvorené, každých pár sekúnd sa cez grafiku nakloní pás jasného bieleho svetla a potom ju opäť nechá nehybnú. Vaša vlastná grafika ho dostane tiež, pokiaľ je každý znak v nej široký jeden stĺpec — všetko, čo vytvorí _Nastaviť z obrázka_, také je. Grafika vytvorená z emoji alebo dvojšírkových znakov zostáva namiesto toho nehybná, a rovnako aj obrazovka, ak si ponecháte vlastnú konfiguráciu fastfetch: nehybné logo je v týchto prípadoch animácia, ktorá ustupuje z cesty, a nie zlyháva, pretože posunutie odlesku cez ne by posunulo zvyšok riadka na nesprávne miesto.

 ![branding-about](images/branding-about.webp)

### Prevod obrázkov svojpomocne

Obe možnosti _Nastaviť z obrázka_ len volajú `omarchy transcode ascii`, ktorý môžete spustiť priamo, ak chcete mať prevod pod kontrolou:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Preberá `--width` a `--height` v stĺpcoch a riadkoch terminálu, `--mode` buď `braille` (predvolené a oveľa jemnejšie), alebo `block`, percento `--threshold` na rozhodnutie, ktoré pixely sa považujú za súčasť loga, a `--invert` pre prípad, keď je vaše logo svetlé na tmavom pozadí. Ak z prevodu vyjde machuľa, zvyčajne je tým správnym ovládačom práve threshold.

### Slová namiesto loga

`omarchy ascii` kreslí text fontom Delta Corps Priest 1, fontom FIGlet, ktorým je nakreslený aj samotný wordmark Omarchy, takže šetrič obrazovky môže niečo hovoriť, namiesto toho, aby ukazoval obrázok:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Preberá text ako argumenty, alebo ho číta z rúry, keď nedostane žiadny. Font obsahuje iba písmená a medzery — bol nakreslený bez číslic a interpunkcie — takže čokoľvek iné sa zahodí a uvedie na stderr, namiesto toho, aby to ticho prehltol.
