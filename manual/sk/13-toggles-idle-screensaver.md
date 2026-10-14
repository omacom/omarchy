# Prepínače, nečinnosť a šetrič obrazovky

Veľa z toho, čo deň za dňom meníte, nie je skutočne nastavenie. Je to režim, ktorý zapnete na hodinu a znova vypnete: nočné svetlo, kým pracujete neskoro, nerušiť, kým prezentujete, zostať hore, kým na niečo pozeráte. Omarchy ich nazýva prepínače a všetky fungujú rovnako — klávesová skratka, položka menu a príkaz, všetky zasahujú ten istý prepínač.

### Menu prepínačov

`Super + Ctrl + O` otvára _Akcie > Prepnúť_ priamo, alebo tam môžete ísť z menu Omarchy (`Super + Space`). Všetko v tomto zozname je prepínač, ktorý môžete prepnúť bez rozmýšľania, kde stav žije. Prepínače na to, ako pracovná plocha vyzerá, sedia vedľa neho, pod _Akcie > Vzhľad_.

Z terminálu sú rovnaké prepínače `omarchy toggle <thing>`. Spustite `omarchy toggle` samotné, aby ste videli celú skupinu.

| Prepínač | Skratka | Príkaz |
| ------ | ------ | ------- |
| Nočné svetlo | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Stíšiť upozornenia | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Zostať hore (žiadny zámok pri nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávanie pádov | — | `omarchy toggle crash-capture` |
| Šetrič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizácia témy [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Lišta menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotyková obrazovka | — | `omarchy toggle touchscreen` |
| Pozastaviť | — | `omarchy toggle suspend` |
| Hybridné GPU | — | `omarchy toggle hybrid gpu` |

Prepínače touchpadu, dotykovej obrazovky a hybridného GPU žijú pod _Akcie > Hardvér_ (`Super + Ctrl + H`) namiesto pod Prepnúť, keďže sa objavia len, keď ten hardvér skutočne máte. Tie pre touchpad a dotykovú obrazovku prežijú opätovné načítanie Hyprlandu — názov zakázaného zariadenia sa uloží do malého súboru stavu, ktorý Hyprland číta pri spustení, aby ho znova zakázal.

_Akcie > Vzhľad_ drží lištu menu a animácie, plus niekoľko vecí, ktoré nie sú príkazmi `omarchy toggle`, ale správajú sa rovnako: percento batérie v lište, predvolené rozloženie pracovnej plochy, medzery okien (`Super + Shift + Backspace`) a štvorcový pomer 1 okna (`Super + Ctrl + Backspace`).

Väčšina z nich je len súbor príznaku pod `~/.local/state/omarchy/toggles/`. Ak sa chcete na jednom vetviť v skripte, `omarchy-toggle-enabled` vám dáva návratový kód namiesto toho, aby ste museli hľadať:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Príznaky sú pomenované podľa vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže ich prítomnosť znamená, že funkcia je zakázaná.

### Indikátory v lište

Keď je režim zapnutý, dostanete malý glyf v strede hornej lišty vedľa hodín. Je to widget indikátorov a nesie diktovanie, nahrávanie obrazovky, čakajúce pripomienky, nočné svetlo, nerušiť a zostať hore.

Neaktívne indikátory sú skryté. Prejdite kurzorom cez oblasť okolo nich a vyblednuto sa objavia, takže môžete kliknúť na jeden, aby ste ho zapli, bez toho, aby ste poznali jeho klávesovú skratku. Kliknutie na aktívny ho znova vypne. Ak by ste ich radšej videli všetky stále, nastavte `alwaysShow` na `true` na položke `omarchy.indicators` v `~/.config/omarchy/shell.json` — pozrite si [hornú lištu](05-the-top-bar.md), ako sa widgety lišty konfigurujú.

### Nočné svetlo

`Super + Ctrl + N` zohreje obrazovku na 4000 K a opätovné stlačenie ju vráti na 6500 K. Riadi ho hyprsunset, ktorý prepínač za vás spustí, ak ešte nebeží.

Hyprsunset predvolene nerobí s vašou obrazovkou vôbec nič. `~/.config/hypr/hyprsunset.conf` sa dodáva s identitným profilom práve preto, aby displej zostal nedotknutý, kým nepožiadate o teplo. Ak by ste radšej mali prepínanie podľa hodín, nahraďte ho časovým profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom spustite hyprsunset pri prihlásení pridaním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Pár 4000 K/6500 K použitý prepínačom je pevný, takže konfiguračný súbor je miestom, kam idete, ak chcete inú teplotu.

### Nerušiť

`Super + Ctrl + ,` stíši upozornenia. Kým je zapnuté, nevyskakujú žiadne toasty a indikátor prečiarknutého zvončeka sedí v lište, aby vám pripomínal, prečo pracovná plocha stíchla.

Nič sa však nestráca. Stíšené upozornenie sa zapíše priamo do vašej histórie upozornení, čo je presne ten záznam, ktorý chcete, keď sa vrátite a divíte sa, čo ste zameškali. Otvorte ju pomocou `Super + Shift + Alt + ,`. Pozrite si [oznámenia](10-notices.md) pre zvyšok príbehu o upozorneniach.

Dva druhy správ stále prechádzajú: vlastné potvrdzovacie toasty Omarchy za niečo, čo ste práve urobili ("Theme changed", "Screenshot saved"), a kritické výstrahy odoslané z príkazového riadku. Chatovacie aplikácie, ktoré označujú všetko ako kritické, aby sa vnútili pred vás, sa nepočítajú.

### Nečinnosť

Shell Omarchy vlastní správanie pri nečinnosti a načasovania sú blokom `idle` na najvyššej úrovni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obidve čísla sú sekundy počítané od momentu, keď ste išli do nečinnosti — nie od seba navzájom. Takže s predvolenými hodnotami príde šetrič obrazovky po dvoch a pol minúte a uzamykacia obrazovka prevezme po piatich minútach, či už šetrič obrazovky bežal alebo nie. Uložte súbor a shell okamžite preberie nové načasovania.

Ak šetrič obrazovky zrušíte pred termínom uzamknutia, počíta sa to ako aktivita a čakajúci zámok sa zruší. Kvôli pohľadu na svoj stroj sa nezamknete von.

Ak chcete úplne zastaviť zamykanie pri nečinnosti, `Super + Ctrl + I` — alebo `omarchy toggle idle` — prepne zostať hore na zapnuté a v lište sa objaví indikátor šálky kávy. Na to stlačíte pred dlhou prezentáciou alebo buildom, ktorý chcete sledovať. Znova stlačte, aby ste sa vrátili do normálu. `omarchy toggle idle status` vytlačí aktuálny stav ako JSON, ak ho potrebujete zo skriptu.

Ide o uzamykanie a šetrič obrazovky, nie o napájanie. Pozastavenie a hibernácia majú svoje vlastné nastavenie vo [spánku systému](36-system-sleep.md).

### Šetrič obrazovky

Šetrič obrazovky Omarchy je ASCII art bežiaci cez náhodné textové efekty, jedna inštancia na monitor. Ľubovoľný kláves alebo pohyb myši ho ukončí.

Môžete ho spustiť na požiadanie zo _Systém > Šetrič obrazovky_ (`Super + Esc`), čo ho vynúti, aj keď ste šetrič obrazovky pri nečinnosti vypli. Predvolene k nemu nie je viazaná žiadna klávesová skratka.

`omarchy toggle screensaver` je to, čo vypína ten pri nečinnosti, ak by ste radšej išli priamo z práce na uzamknutie. Potrebuje terminál, ktorý vie, ako nakonfigurovať — Alacritty, Foot, Ghostty alebo Kitty — a povie vám to, ak je váš predvolený terminál niečo iné.

Logo, ktoré kreslí, môžete zmeniť pod _Štýl > Šetrič obrazovky_. Nahrajte png alebo svg a Omarchy ho prevedie na ASCII. Pozrite si [branding](41-branding.md).

### Uzamykacia obrazovka

`Super + Ctrl + L` uzamkne stroj. To spustí uzamykaciu obrazovku zo shellu Omarchy, vyprázdni displej, resetuje vaše rozloženie klávesnice na prvé, aby ste nepísali heslo v nesprávnej abecede, a — ak ho máte spustený — pri odchode uzamkne 1Password.

Uzamykacia obrazovka prijíma heslo a prijme aj odtlačok prsta, keď si ho nastavíte. To a ostatné spôsoby autentifikácie sú opísané v [hardvérovej autentifikácii](37-hardware-authentication.md).
