# Prepínače, nečinnosť a šetrič obrazovky

Veľa z toho, čo meníte zo dňa na deň, vlastne ani nie je nastavenie. Je to režim, ktorý zapnete na hodinu a potom zase vypnete: nočné svetlo, keď pracujete dlho do noci, režim nerušiť, keď prezentujete, zostať hore, keď niečo sledujete. Omarchy im hovorí prepínače a všetky fungujú rovnako — klávesová skratka, položka v menu a príkaz, všetky mieria na ten istý prepínač.

### Menu prepínačov

`Super + Ctrl + O` otvorí priamo _Trigger > Toggle_, alebo sa tam dostanete cez menu Omarchy (`Super + Space`). Všetko v tom zozname je prepínač, ktorý prepnete bez premýšľania o tom, kde žije jeho stav. Prepínače toho, ako pracovná plocha vyzerá, sedia hneď vedľa, pod _Appearance_.

Z terminálu sú tie isté prepínače `omarchy toggle <thing>`. Spustite samotné `omarchy toggle` a uvidíte celú skupinu.

| Prepínač | Klávesová skratka | Príkaz |
| ------ | ------ | ------- |
| Nočné svetlo | — | `omarchy toggle nightlight` |
| Stíšiť oznámenia | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zostať hore (bez uzamknutia pri nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávanie pádov | — | `omarchy toggle crash-capture` |
| Šetrič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizácia témy [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Lišta menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pracovná plocha na celú obrazovku (bez lišty, bez medzier) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animácie, rozmazanie a tiene | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Dotyková obrazovka | — | `omarchy device touchscreen` |
| Uspať | — | `omarchy toggle suspend` |
| Hybridná GPU | — | `omarchy device gpu hybrid` |

Prepínače touchpadu, dotykovej obrazovky a hybridnej GPU žijú pod _Trigger > Hardware_ (`Super + Ctrl + H`), nie pod Toggle, pretože sa ukážu len vtedy, keď taký hardvér skutočne máte. Prepínače touchpadu a dotykovej obrazovky prežijú opätovné načítanie Hyprland — názov vypnutého zariadenia sa uloží do malého stavového súboru, ktorý Hyprland pri spustení prečíta a zariadenie znova vypne.

_Appearance_ ukrýva lištu menu a animácie a k tomu pár vecí, ktoré nie sú príkazmi `omarchy toggle`, ale správajú sa rovnako: percento batérie v lište, predvolené rozloženie pracovných plôch a pod _Windows_ medzery medzi oknami (`Super + Shift + Backspace`) a štvorcový pomer strán pre 1 okno (`Super + Ctrl + Backspace`).

Keď Hyprland nemá GPU, ktorou by kreslil, a vykresľuje namiesto toho cez CPU (llvmpipe), ako na Macoch, ktorých GPU zatiaľ nie je podporovaná, vo väčšine virtuálnych strojov alebo keď sa nepodarí načítať grafický ovládač, Omarchy pre danú reláciu vypne animácie, rozmazanie a tiene a raz vám to oznámi notifikáciou. _Appearance > Animations On_ ich vráti späť a Omarchy si to zapamätá aj pre ďalšie relácie.

Väčšina z toho je len súbor s príznakom pod `~/.local/state/omarchy/toggles/`. Ak sa podľa nejakého chcete v skripte vetviť, `omarchy-toggle-enabled` vám dá návratový kód, namiesto aby ste ho museli ísť hľadať:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Príznaky sú pomenované podľa vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže ich prítomnosť znamená, že funkcia je vypnutá.

### Indikátory v lište

Keď je nejaký režim zapnutý, dostanete malý glyf v strede hornej lišty vedľa hodín. To je widget indikátorov a nesie nahrávanie obrazovky, čakajúce pripomienky, nočné svetlo, režim nerušiť a zostať hore, plus varovania, keď je zapnuté sudo bez hesla alebo je niekto pripojený k vzdialenej relácii.

Neaktívne indikátory sú skryté. Prejdite kurzorom kamkoľvek na lištu a stmavnuté sa jemne zobrazia, takže na niektorý môžete kliknúť a zapnúť ho bez poznania jeho klávesovej skratky. Kliknutím na aktívny ho zase vypnete. Ak ich chcete radšej vidieť všetky stále, nastavte `alwaysShow` na `true` v položke `omarchy.indicators` v `~/.config/omarchy/shell.json` — pozrite si [hornú lištu](05-the-top-bar.md), kde nájdete, ako sa widgety lišty konfigurujú.

### Nočné svetlo

Nočné svetlo zohreje obrazovku na 4000K a opätovným prepnutím ju vráti na 6500K. Prepnite ho z menu prepínačov (`Super + Ctrl + O`) alebo príkazom `omarchy toggle nightlight`. Poháňa ho hyprsunset, ktorý za vás prepínač spustí, ak ešte nebeží.

hyprsunset štandardne s vašou obrazovkou nerobí vôbec nič. `~/.config/hypr/hyprsunset.conf` sa dodáva s identickým profilom práve preto, aby displej zostal nedotknutý, kým si nezažiadate teplo. Ak chcete, aby sa prepínal podľa hodín, vymeňte ho za časový profil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom hyprsunset spúšťajte pri prihlásení pridaním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojica 4000K/6500K, ktorú prepínač používa, je pevná, takže ak chcete inú teplotu, musíte do konfiguračného súboru.

### Nerušiť

`Super + Ctrl + Alt + ,` stíši oznámenia. Kým je zapnutý, nevyskakujú žiadne toasty a indikátor prečiarknutého zvončeka sedí v lište, aby vám pripomínal, prečo pracovná plocha stíchla.

Nič sa však nestratí. Stíšené oznámenia sa podržia: posledných pár vráťte na obrazovku pomocou `Super + Shift + Alt + ,`. Zvyšok nájdete v [oznámeniach](10-notices.md).

Tri druhy správ aj tak prejdú: vlastné potvrdzovacie toasty Omarchy o niečom, čo ste práve urobili ("Téma sa zmenila", "Snímka obrazovky sa uložila"), kritické upozornenia poslané z príkazového riadka a overovacie kódy. Chatovacie aplikácie, ktoré označujú všetko ako kritické, aby si vynútili cestu pred vás, sa nekvalifikujú.

### Nečinnosť

Správanie pri nečinnosti vlastní shell Omarchy a časovania sú blok `idle` na najvyššej úrovni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obe čísla sú sekundy počítané od okamihu, keď ste prešli do nečinnosti — nie jedno od druhého. S predvolenými hodnotami sa teda šetrič obrazovky ukáže po dvoch a pol minútach a uzamykacia obrazovka prevezme miesto o piatej minúte, bez ohľadu na to, či šetrič bežal. Uložte súbor a shell si nové časovania prevezme hneď.

Ak šetrič obrazovky zrušíte pred termínom uzamknutia, počíta sa to ako aktivita a čakajúce uzamknutie sa zruší. Nezostanete uzamknutí len za to, že ste sa pozreli na svoj stroj.

Ak chcete uzamykanie pri nečinnosti zastaviť úplne, `Super + Ctrl + I` — alebo `omarchy toggle idle` — zapne zostať hore a v lište sa objaví indikátor šálky kávy. Ten stlačte pred dlhou prezentáciou alebo buildom, ktorý chcete sledovať. Stlačte ho znova a vrátite sa do normálu. `omarchy toggle idle status` vypíše aktuálny stav ako JSON, ak ho potrebujete zo skriptu.

Toto je o uzamykaní a šetriči obrazovky, nie o napájaní. Uspatie a hibernácia majú vlastné nastavenie v [uspaní systému](36-system-sleep.md).

### Šetrič obrazovky

Šetrič obrazovky Omarchy je ASCII art prechádzajúci náhodnými textovými efektmi, jedna inštancia na monitor. Opustíte ho akýmkoľvek klávesom alebo pohybom myši.

Na požiadanie ho spustíte zo _System > Screensaver_ (`Super + Esc`), čo ho vynúti aj vtedy, keď ste šetrič pri nečinnosti vypli. Štandardne naň nie je naviazaná žiadna klávesová skratka.

`omarchy toggle screensaver` vypína ten pri nečinnosti, ak chcete ísť radšej rovno z práce do uzamknutého stavu. Zatvorí ho akýkoľvek kláves, kliknutie, posun alebo pohyb myši.

Logo, ktoré kreslí, si môžete zmeniť pod _Appearance > Branding > Screensaver_. Nahrajte png alebo svg a Omarchy ho prevedie na ASCII. Pozrite si [branding](41-branding.md).

### Uzamykacia obrazovka

`Super + Ctrl + L` stroj uzamkne. Spustí to uzamykaciu obrazovku zo shellu Omarchy, vyprázdni displej, resetuje rozloženie klávesnice na prvé, aby ste heslo nepísali v nesprávnej abecede, a — ak ho máte spustený — cestou von uzamkne 1Password.

Uzamykacia obrazovka prijme heslo a prijme aj odtlačok prsta, keď si ho nastavíte. To a ďalšie spôsoby overenia pokrýva [hardvérové overovanie](37-hardware-authentication.md).
