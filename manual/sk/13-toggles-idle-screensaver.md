# Prepínače, nečinnosť a šetrič obrazovky

Veľa z toho, čo denne meníte, nie je v skutočnosti nastavenie. Je to režim, ktorý zapnete na hodinu a potom zase vypnete: nočné svetlo, keď pracujete dlho do noci, režim nerušiť, keď prezentujete, zostať bdelý, keď niečo sledujete. Omarchy ich nazýva prepínačmi a všetky fungujú rovnako — klávesová skratka, položka v menu a príkaz, všetky ovládajú ten istý prepínač.

### Ponuka prepínačov

`Super + Ctrl + O` otvorí priamo _Trigger > Toggle_, alebo sa tam môžete dostať cez menu Omarchy (`Super + Space`). Všetko v tomto zozname je prepínač, ktorý môžete prepnúť bez premýšľania o tom, kde sa nachádza stav. Prepínače vzhľadu pracovnej plochy sú vedľa, v časti _Appearance_.

Z terminálu sú tie isté prepínače `omarchy toggle <thing>`. Spustite `omarchy toggle` samostatne a zobrazí sa celá skupina.

| Prepínač | Klávesová skratka | Príkaz |
| ------ | ------ | ------- |
| Nočné svetlo | — | `omarchy toggle nightlight` |
| Stíšenie oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zostať bdelý (bez zámku pri nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávanie pádov | — | `omarchy toggle crash-capture` |
| Šetrič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizácia témy [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Panel menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotyková obrazovka | — | `omarchy toggle touchscreen` |
| Uspávanie | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Prepínače touchpadu, dotykovej obrazovky a hybrid GPU sa nachádzajú v časti _Trigger > Hardware_ (`Super + Ctrl + H`) namiesto časti Toggle, pretože sa zobrazujú iba vtedy, keď daný hardvér skutočne máte. Prepínače touchpadu a dotykovej obrazovky prežijú opätovné načítanie Hyprland — názov vypnutého zariadenia sa uloží do malého súboru so stavom, ktorý Hyprland pri spustení prečíta, aby ho znova vypol.

_Appearance_ obsahuje panel menu a animácie plus niekoľko vecí, ktoré nie sú príkazmi `omarchy toggle`, ale správajú sa rovnako: percento batérie v paneli, predvolené rozloženie pracovných plôch a v časti _Windows_ medzery medzi oknami (`Super + Shift + Backspace`) a štvorcový pomer strán pre 1 okno (`Super + Ctrl + Backspace`).

Väčšina z nich je len súbor s príznakom v adresári `~/.local/state/omarchy/toggles/`. Ak sa podľa niektorého z nich chcete v skripte vetviť, `omarchy-toggle-enabled` vám poskytne návratový kód namiesto toho, aby ste ho museli hľadať:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Príznaky sú pomenované podľa vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže ich prítomnosť znamená, že funkcia je vypnutá.

### Indikátory v paneli

Keď je režim zapnutý, zobrazí sa vám v strede horného panela vedľa hodín malý glyf. To je widget indikátorov a obsahuje diktovanie, nahrávanie obrazovky, čakajúce pripomienky, nočné svetlo, režim nerušiť a zostať bdelý.

Neaktívne indikátory sú skryté. Umiestnite kurzor kdekoľvek na panel a zobrazia sa stlmené, takže na niektorý z nich môžete kliknúť a zapnúť ho bez toho, aby ste poznali jeho klávesovú skratku. Kliknutím na aktívny indikátor ho znova vypnete. Ak ich chcete radšej vidieť všetky stále, nastavte `alwaysShow` na `true` pri položke `omarchy.indicators` v súbore `~/.config/omarchy/shell.json` — pozrite si [horný panel](05-the-top-bar.md), kde nájdete informácie o konfigurácii widgetov panela.

### Nočné svetlo

Nočné svetlo zohreje obrazovku na 4000K a opätovným prepnutím ju vráti na 6500K. Prepnite ho z ponuky prepínačov (`Super + Ctrl + O`) alebo príkazom `omarchy toggle nightlight`. Poháňa ho hyprsunset, ktorý za vás prepínač spustí, ak ešte nebeží.

Predvolene hyprsunset s vašou obrazovkou nerobí vôbec nič. Súbor `~/.config/hypr/hyprsunset.conf` sa dodáva s identickým profilom práve preto, aby displej zostal nedotknutý, kým nepožiadate o teplo. Ak chcete radšej, aby sa prepínal podľa hodín, nahraďte ho časovým profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom spustite hyprsunset pri prihlásení pridaním `o.launch_on_start("hyprsunset")` do súboru `~/.config/hypr/autostart.lua`. Dvojica 4000K/6500K používaná prepínačom je pevná, takže ak chcete inú teplotu, musíte ísť do konfiguračného súboru.

### Režim nerušiť

`Super + Ctrl + Alt + ,` stíši oznámenia. Kým je zapnutý, nebudú vyskakovať žiadne toasty a prečiarknutý indikátor zvončeka v paneli vám bude pripomínať, prečo je na pracovnej ploche ticho.

Nič sa však nestratí. Stíšené oznámenia sa podržia: posledných niekoľko z nich vrátite na obrazovku klávesovou skratkou `Super + Shift + Alt + ,`. Pozrite si [oznámenia](10-notices.md), kde nájdete zvyšok.

Dva druhy správ stále prejdú: vlastné potvrdzovacie toasty Omarchy k niečomu, čo ste práve urobili ("Theme changed", "Screenshot saved"), a kritické upozornenia odoslané z príkazového riadka. Chatovacie aplikácie, ktoré označujú všetko za kritické, aby si vynútili cestu pred vás, do tejto kategórie nepatria.

### Nečinnosť

Správanie pri nečinnosti vlastní shell Omarchy a časové limity sú v najvyššej úrovni bloku `idle` v súbore `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe čísla sú sekundy počítané od okamihu, keď ste prestali byť aktívni — nie od seba navzájom. Takže pri predvolených nastaveniach sa šetrič obrazovky spustí po dvoch a pol minútach a uzamykacia obrazovka prevezme kontrolu po piatich minútach, bez ohľadu na to, či šetrič obrazovky bežal. Uložte súbor a shell okamžite prevezme nové časové limity.

Ak šetrič obrazovky zrušíte pred termínom uzamknutia, počíta sa to ako aktivita a čakajúce uzamknutie sa zruší. Neuzamkne vás len preto, že ste sa na počítač pozreli.

Ak chcete úplne zastaviť uzamykanie pri nečinnosti, `Super + Ctrl + I` — alebo `omarchy toggle idle` — zapne režim zostať bdelý a v paneli sa zobrazí indikátor šálky kávy. Ten použite pred dlhou prezentáciou alebo buildom, ktorý chcete sledovať. Stlačte ho znova, ak sa chcete vrátiť do normálu. `omarchy toggle idle status` vypíše aktuálny stav ako JSON, ak ho potrebujete zo skriptu.

Toto sa týka uzamykania a šetriča obrazovky, nie napájania. Uspávanie a hibernácia majú vlastné nastavenie v časti [uspanie systému](36-system-sleep.md).

### Šetrič obrazovky

Šetrič obrazovky Omarchy je ASCII grafika prechádzajúca náhodnými textovými efektmi, jedna inštancia na monitor. Akýkoľvek kláves alebo pohyb myši ho ukončí.

Môžete ho spustiť na požiadanie z časti _System > Screensaver_ (`Super + Esc`), čím ho vynútite, aj keď ste šetrič obrazovky pri nečinnosti vypli. Predvolene k nemu nie je priradená žiadna klávesová skratka.

`omarchy toggle screensaver` je to, čo vypne ten pri nečinnosti, ak chcete radšej prejsť priamo z práce na uzamknutú obrazovku. Akýkoľvek kláves, kliknutie, posúvanie alebo pohyb myši ho zatvorí.

Logo, ktoré kreslí, môžete zmeniť v časti _Appearance > Branding > Screensaver_. Nahrajte png alebo svg a Omarchy ho prevedie na ASCII. Pozrite si [vizuálnu identitu](41-branding.md).

### Uzamykacia obrazovka

`Super + Ctrl + L` uzamkne počítač. Tým sa spustí uzamykacia obrazovka zo shellu Omarchy, vyprázdni sa displej, resetuje sa rozloženie klávesnice na prvé, aby ste nezadávali heslo v nesprávnej abecede, a — ak ho máte spustený — cestou von uzamkne 1Password.

Uzamykacia obrazovka prijíma heslo a prijme aj odtlačok prsta, keď si ho nastavíte. To a ďalšie spôsoby overovania sú popísané v časti [hardvérové overovanie](37-hardware-authentication.md).
