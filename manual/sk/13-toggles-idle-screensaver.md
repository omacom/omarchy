# Prepínače, nečinnosť a šetrič obrazovky

Veľa z toho, čo denne meníte, v skutočnosti nie je nastavenie. Je to režim, ktorý zapnete na hodinu a potom zase vypnete: nočné svetlo, keď pracujete dlho do noci, nerušiť, keď prezentujete, zostať hore, keď niečo sledujete. Omarchy ich nazýva prepínače a všetky fungujú rovnako — klávesová skratka, položka v ponuke a príkaz, všetky trafia ten istý spínač.

### Ponuka prepínačov

`Super + Ctrl + O` otvorí priamo _Trigger > Toggle_, alebo sa tam môžete dostať cez ponuku Omarchy (`Super + Space`). Všetko v tom zozname je spínač, ktorý môžete prepnúť bez premýšľania o tom, kde sa ukladá jeho stav. Spínače pre vzhľad plochy sedia vedľa, pod _Appearance_.

Z terminálu sú tie isté spínače `omarchy toggle <thing>`. Spustite samotné `omarchy toggle` a uvidíte celú skupinu.

| Prepínač | Klávesová skratka | Príkaz |
| ------ | ------ | ------- |
| Nočné svetlo | — | `omarchy toggle nightlight` |
| Stíšenie oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zostať hore (bez uzamknutia pri nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávanie pádov | — | `omarchy toggle crash-capture` |
| Šetrič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizácia témy [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Panel ponuky | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Dotyková obrazovka | — | `omarchy device touchscreen` |
| Uspatie | — | `omarchy toggle suspend` |
| Hybridná GPU | — | `omarchy toggle hybrid gpu` |

Prepínače pre touchpad, dotykovú obrazovku a hybridnú GPU nájdete pod _Trigger > Hardware_ (`Super + Ctrl + H`), nie pod Toggle, pretože sa zobrazia len vtedy, keď taký hardvér skutočne máte. Prepínače pre touchpad a dotykovú obrazovku prežijú opätovné načítanie Hyprland — názov vypnutého zariadenia sa uloží do malého stavového súboru, ktorý Hyprland pri spustení prečíta, aby ho znova vypol.

_Appearance_ obsahuje panel ponuky a animácie, plus pár vecí, ktoré nie sú príkazmi `omarchy toggle`, ale správajú sa rovnako: percento batérie v paneli, predvolené rozloženie pracovnej plochy a pod _Windows_ medzery medzi oknami (`Super + Shift + Backspace`) a štvorcový pomer strán pre 1 okno (`Super + Ctrl + Backspace`).

Keď Hyprland nemá GPU, s ktorou by mohol kresliť, a namiesto toho vykresľuje na CPU (llvmpipe), ako na Macoch, ktorých GPU ešte nie je podporovaná, vo väčšine virtuálnych počítačov alebo keď sa nepodarí načítať grafický ovládač, Omarchy pre danú reláciu vypne animácie, rozmazanie a tiene a raz vám to oznámi oznámením. _Appearance > Animations On_ ich vráti späť a Omarchy si to zapamätá aj pre ďalšie relácie.

Väčšina z nich je len súbor s príznakom pod `~/.local/state/omarchy/toggles/`. Ak na niektorom chcete v skripte vetviť, `omarchy-toggle-enabled` vám dá návratový kód, namiesto toho, aby ste ho museli ísť hľadať:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Príznaky sú pomenované podľa vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže ich prítomnosť znamená, že funkcia je vypnutá.

### Indikátory v paneli

Keď je režim zapnutý, dostanete malý glyf v strede horného panela vedľa hodín. To je widget indikátorov a nesie diktovanie, nahrávanie obrazovky, čakajúce pripomienky, nočné svetlo, nerušiť a zostať hore.

Neaktívne indikátory sú skryté. Prejdite myšou kamkoľvek na panel a zobrazia sa stlmené, takže na jeden môžete kliknúť a zapnúť ho bez toho, aby ste poznali jeho klávesovú skratku. Kliknutím na aktívny ho znova vypnete. Ak ich chcete radšej vidieť všetky stále, nastavte `alwaysShow` na `true` pri položke `omarchy.indicators` v `~/.config/omarchy/shell.json` — pozrite si [horný panel](05-the-top-bar.md), kde nájdete, ako sa konfigurujú widgety panela.

### Nočné svetlo

Nočné svetlo zohreje obrazovku na 4000K a opätovným prepnutím ju vráti na 6500K. Prepnite ho z ponuky prepínačov (`Super + Ctrl + O`) alebo pomocou `omarchy toggle nightlight`. Poháňa ho hyprsunset, ktorý prepínač za vás spustí, ak ešte nebeží.

Predvolene hyprsunset s vašou obrazovkou nerobí vôbec nič. `~/.config/hypr/hyprsunset.conf` sa dodáva s profilom identity práve preto, aby displej zostal nedotknutý, kým nepožiadate o teplo. Ak chcete radšej, aby sa prepínal podľa hodín, nahraďte ho časovým profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom spustite hyprsunset pri prihlásení pridaním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Pár 4000K/6500K, ktorý prepínač používa, je pevný, takže ak chcete inú teplotu, idete do konfiguračného súboru.

### Nerušiť

`Super + Ctrl + Alt + ,` stíši oznámenia. Kým je zapnuté, nevyskakujú žiadne toasty a prečiarknutý zvonček v paneli vám pripomína, prečo plocha stíchla.

Nič sa však nestratí. Stíšené oznámenia sa podržia: posledných pár vrátite na obrazovku pomocou `Super + Shift + Alt + ,`. Zvyšok nájdete v [oznámeniach](10-notices.md).

Cez to stále prejdú dva druhy správ: vlastné potvrdzovacie toasty Omarchy k niečomu, čo ste práve urobili ("Theme changed", "Screenshot saved"), a kritické upozornenia odoslané z príkazového riadka. Chatovacie aplikácie, ktoré označujú všetko ako kritické, aby si vynútili cestu pred vás, sa nekvalifikujú.

### Nečinnosť

Shell Omarchy vlastní správanie pri nečinnosti a časovania sú vrcholový blok `idle` v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe čísla sú sekundy počítané od momentu, keď ste prestali byť aktívni — nie jedno od druhého. Takže pri predvolených hodnotách sa šetrič obrazovky objaví po dvoch a pol minútach a uzamykacia obrazovka prevezme kontrolu po piatich minútach, bez ohľadu na to, či šetrič obrazovky bežal alebo nie. Uložte súbor a shell si nové časovania prevezme okamžite.

Ak šetrič obrazovky zavriete pred termínom uzamknutia, počíta sa to ako aktivita a čakajúce uzamknutie sa zruší. Nezablokujete sa len za to, že ste sa pozreli na svoj počítač.

Ak chcete úplne zastaviť uzamykanie pri nečinnosti, `Super + Ctrl + I` — alebo `omarchy toggle idle` — zapne režim zostať hore a v paneli sa objaví indikátor šálky kávy. Ten si stlačte pred dlhou prezentáciou alebo buildom, ktorý chcete sledovať. Stlačte ho znova, aby ste sa vrátili do normálu. `omarchy toggle idle status` vypíše aktuálny stav ako JSON, ak ho potrebujete zo skriptu.

Toto je o uzamykaní a šetriči obrazovky, nie o napájaní. Uspatie a hibernácia majú svoje vlastné nastavenie v [spánku systému](36-system-sleep.md).

### Šetrič obrazovky

Šetrič obrazovky Omarchy je ASCII art, ktorý prechádza náhodnými textovými efektmi, jedna inštancia na monitor. Ukončí ho akákoľvek klávesa alebo pohyb myši.

Môžete ho spustiť na požiadanie z _System > Screensaver_ (`Super + Esc`), čo ho vynúti aj vtedy, keď ste šetrič obrazovky pri nečinnosti vypli. Predvolene k nemu nie je priradená žiadna klávesová skratka.

`omarchy toggle screensaver` je to, čo vypne ten pri nečinnosti, ak chcete radšej prejsť rovno z práce na uzamknutú obrazovku. Zatvorí ho akákoľvek klávesa, kliknutie, posúvanie alebo pohyb myši.

Logo, ktoré kreslí, môžete zmeniť pod _Appearance > Branding > Screensaver_. Nahrajte png alebo svg a Omarchy ho prevedie na ASCII. Pozrite si [značku](41-branding.md).

### Uzamykacia obrazovka

`Super + Ctrl + L` uzamkne počítač. Tým sa spustí uzamykacia obrazovka zo shellu Omarchy, vyprázdni displej, resetuje rozloženie klávesnice na prvé, aby ste heslo nepísali v nesprávnej abecede, a — ak ho máte spustený — cestou von uzamkne 1Password.

Uzamykacia obrazovka prijíma heslo a prijme aj odtlačok prsta, keď si ho nastavíte. To a ďalšie spôsoby overovania sú pokryté v [hardvérovom overovaní](37-hardware-authentication.md).
