# Prepínače, nečinnosť a šetrič obrazovky

Veľa z toho, čo meníte zo dňa na deň, vlastne nie je nastavenie. Je to režim, ktorý na hodinu zapnete a potom znova vypnete: nočné svetlo, keď pracujete dlho do noci, režim nerušiť, keď prezentujete, zostať hore, keď niečo sledujete. Omarchy ich nazýva prepínačmi a všetky fungujú rovnako — klávesová skratka, položka v menu a príkaz, všetky trafia ten istý prepínač.

### Menu prepínačov

`Super + Ctrl + O` otvorí priamo _Trigger > Toggle_, alebo sa tam dostanete z menu Omarchy (`Super + Space`). Všetko v tom zozname je prepínač, ktorý môžete prepnúť bez premýšľania o tom, kde sa ten stav ukladá. Prepínače pre vzhľad pracovnej plochy sedia hneď vedľa, pod _Appearance_.

Z terminálu sú tie isté prepínače `omarchy toggle <thing>`. Spustite samotné `omarchy toggle` a uvidíte celú skupinu.

| Prepínač | Klávesová skratka | Príkaz |
| ------ | ------ | ------- |
| Nočné svetlo | — | `omarchy toggle nightlight` |
| Stíšiť oznámenia | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zostať hore (bez zámku pri nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávanie pádov | — | `omarchy toggle crash-capture` |
| Šetrič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizácia témy [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Lišta menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotyková obrazovka | — | `omarchy toggle touchscreen` |
| Pozastaviť | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Prepínače pre touchpad, dotykovú obrazovku a hybrid GPU žijú pod _Trigger > Hardware_ (`Super + Ctrl + H`) namiesto pod Toggle, keďže sa zobrazia len vtedy, keď taký hardvér skutočne máte. Prepínače touchpadu a dotykovej obrazovky prežijú reštart Hyprland — názov vypnutého zariadenia sa uloží do malého stavového súboru, ktorý Hyprland pri štarte prečíta, aby ho znova vypol.

_Appearance_ obsahuje lištu menu a animácie, plus pár vecí, ktoré nie sú príkazmi `omarchy toggle`, ale správajú sa rovnako: percento batérie v lište, predvolené rozloženie pracovných plôch a pod _Windows_ medzery medzi oknami (`Super + Shift + Backspace`) a štvorcový pomer strán pre 1 okno (`Super + Ctrl + Backspace`).

Väčšina z nich je len príznakový súbor pod `~/.local/state/omarchy/toggles/`. Ak sa na niektorý chcete vetviť v skripte, `omarchy-toggle-enabled` vám dá návratový kód, namiesto aby ste ho museli hľadať:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Príznaky sú pomenované podľa vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže ich prítomnosť znamená, že funkcia je vypnutá.

### Indikátory v lište

Keď je režim zapnutý, dostanete malý glyf v strede hornej lišty vedľa hodín. To je widget indikátorov a nesie diktovanie, nahrávanie obrazovky, čakajúce pripomienky, nočné svetlo, režim nerušiť a zostať hore.

Neaktívne indikátory sú skryté. Prejdite kurzorom kamkoľvek nad lištu a zobrazia sa vyblednuté, takže na niektorý môžete kliknúť a zapnúť ho bez toho, aby ste poznali jeho klávesovú skratku. Kliknutím na aktívny ho znova vypnete. Ak ich chcete radšej vidieť všetky stále, nastavte `alwaysShow` na `true` pri položke `omarchy.indicators` v `~/.config/omarchy/shell.json` — pozrite si [hornú lištu](05-the-top-bar.md) o tom, ako sa widgety lišty konfigurujú.

### Nočné svetlo

Nočné svetlo zahreje obrazovku na 4000K a opätovným prepnutím ju vráti späť na 6500K. Prepnite ho z menu prepínačov (`Super + Ctrl + O`) alebo pomocou `omarchy toggle nightlight`. Poháňa ho hyprsunset, ktorý prepínač za vás spustí, ak ešte nebeží.

Štandardne hyprsunset s vašou obrazovkou nerobí vôbec nič. `~/.config/hypr/hyprsunset.conf` sa dodáva s identitným profilom práve preto, aby displej zostal nedotknutý, kým si nepožiadate o teplo. Ak ho chcete radšej prepínať podľa hodín, nahraďte to časovým profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom spustite hyprsunset pri prihlásení pridaním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojica 4000K/6500K, ktorú používa prepínač, je pevná, takže konfiguračný súbor je miesto, kam ísť, ak chcete inú teplotu.

### Režim nerušiť

`Super + Ctrl + Alt + ,` stíši oznámenia. Kým je zapnutý, nevyskakujú žiadne toasty a prečiarknutý zvonček v lište vám pripomína, prečo pracovná plocha stíchla.

Nič sa však nestratí. Stíšené oznámenia sa podržia: posledných pár vráťte späť na obrazovku pomocou `Super + Shift + Alt + ,`. Pozrite si [oznámenia](10-notices.md) pre zvyšok.

Dva druhy správ sa stále dostanú cez: vlastné potvrdzovacie toasty Omarchy pre niečo, čo ste práve urobili ("Theme changed", "Screenshot saved"), a kritické upozornenia poslané z príkazového riadka. Chatovacie aplikácie, ktoré označujú všetko za kritické, aby si vynútili cestu pred vás, sa nepočítajú.

### Nečinnosť

Prostredie Omarchy vlastní správanie pri nečinnosti a časy sú vrcholový blok `idle` v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe čísla sú sekundy počítané od okamihu, keď ste prestali byť aktívni — nie jedno od druhého. Takže pri predvolených hodnotách sa šetrič obrazovky objaví po dvoch a pol minútach a zamykacia obrazovka prevezme vládu o päť minút, bez ohľadu na to, či šetrič obrazovky bežal. Uložte súbor a prostredie si nové časy prevezme hneď.

Ak šetrič obrazovky zrušíte pred termínom uzamknutia, počíta sa to ako aktivita a čakajúce uzamknutie sa zruší. Nezostanete zamknutí vonku za to, že ste sa pozreli na svoj stroj.

Ak chcete úplne zastaviť zamykanie pri nečinnosti, `Super + Ctrl + I` — alebo `omarchy toggle idle` — zapne režim zostať hore a v lište sa objaví indikátor šálky kávy. Ten treba stlačiť pred dlhou prezentáciou alebo buildom, ktorý chcete sledovať. Stlačte ho znova, aby ste sa vrátili do normálu. `omarchy toggle idle status` vypíše aktuálny stav ako JSON, ak ho potrebujete zo skriptu.

Toto je o zamykaní a šetriči obrazovky, nie o napájaní. Pozastavenie a hibernácia majú vlastné nastavenie v [spánku systému](36-system-sleep.md).

### Šetrič obrazovky

Šetrič obrazovky Omarchy je ASCII art bežiaci cez náhodné textové efekty, jedna inštancia na monitor. Akýkoľvek kláves alebo pohyb myši ho ukončí.

Môžete ho spustiť na požiadanie zo _System > Screensaver_ (`Super + Esc`), čo ho vynúti aj vtedy, ak ste nečinný šetrič obrazovky vypli. Štandardne k nemu nie je viazaná žiadna klávesová skratka.

`omarchy toggle screensaver` je to, čo vypne ten nečinný, ak chcete radšej ísť rovno z práce do zamknutého stavu. Potrebuje terminál, ktorý vie, ako nakonfigurovať — Alacritty, Foot, Ghostty alebo Kitty — a povie vám to, ak je váš predvolený terminál niečo iné.

Logo, ktoré kreslí, si môžete zmeniť pod _Appearance > Branding > Screensaver_. Nahrajte png alebo svg a Omarchy ho prevedie na ASCII. Pozrite si [značku](41-branding.md).

### Zamykacia obrazovka

`Super + Ctrl + L` zamkne stroj. To spustí zamykaciu obrazovku z prostredia Omarchy, zhasne displej, resetuje rozloženie klávesnice na prvé, aby ste heslo nepísali v nesprávnej abecede, a — ak ho máte spustený — po ceste von zamkne 1Password.

Zamykacia obrazovka prijíma heslo a prijme aj odtlačok prsta, keď si ho nastavíte. To a ďalšie spôsoby overovania sú pokryté v [hardvérovom overovaní](37-hardware-authentication.md).
