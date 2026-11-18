# Navigácia

Všetko v Omarchy prebieha cez klávesnicu — _VŠETKO!_ Keď sa systém prvýkrát spustí, doslova nič nedokážete urobiť len myšou. Môžete však stlačiť `Super + Space` a zobraziť Omarchy Menu a odtiaľ môžete urobiť takmer všetko.

Ale Omarchy menu ani nie je určené na to, aby bolo väčšinu času hlavným spôsobom ovládania systému. Dokážeme to rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste urobiť jedno po druhom a uvidíte kúzlo dlaždicového usporiadania Hyprland v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a naskladať ich na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Stlačte `Super + J` znova, aby sa vrátili do polôh vedľa seba. Potom skúste `Super + Shift + Arrow Right`, keď ste v prehliadači, a okná vymeníte.

Teraz skúste `Super + Shift + T` na spustenie monitora aktivity. Ten sa zobrazí ako plávajúce okno. Môžete ho zaradiť do dlaždíc pomocou `Super + T` (a opätovným stlačením ho znova urobíte plávajúcim). Teraz stlačte `Super + Shift + F` na otvorenie správcu súborov. Budete mať pekné usporiadanie štyroch okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, prechádzate pomocou `Super + Arrow`. Tým sa prepne zameranie a kurzor sa presunie do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na tej strane.

Ak stlačíte `Super + Shift + 2`, presuniete aktuálne zameranú aplikáciu na druhý pracovný priestor. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie aktuálne zameranú aplikáciu na druhý pracovný priestor bez prepnutia naň).

Pri viac ako jednom monitore má každý monitor svoje vlastné pracovné priestory 1 až 10. `Super + 2` prejde na druhý pracovný priestor monitora, na ktorom ste, a horný panel každého monitora zobrazuje jeho vlastné pracovné priestory a ten, ktorý práve zobrazuje. `Super + Tab` prechádza pracovnými priestormi na monitore, na ktorom ste, dokola. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom ste, na monitor v danom smere, na pracovný priestor, ktorý zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovný priestor, na ktorom ste, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné priestory ponechá, keď ho odpojíte: pripoja sa k inej obrazovke, očíslované za tými, ktoré už má, a keď sa monitor vráti, vrátia sa pod svoje staré čísla.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť jeho umiestnenie. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete okno voľne meniť veľkosť.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F` alebo dokonca len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F`, prípadne na celú obrazovku vnútri okna pomocou `Super + Ctrl + F` (vhodné pre YouTube!).

### Rozloženie dwindle vs. posúvacie rozloženie

Predvolené rozloženie Omarchy sa nazýva dwindle. Všetky okná, ktoré otvoríte na jednom pracovnom priestore, udržiava neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale môžete sa tiež rozhodnúť zmeniť pracovný priestor na posúvacie rozloženie, kde sú okná zoradené vedľa seba až za viditeľný okraj displeja. Jeden pracovný priestor zmeníte na toto rozloženie pomocou `Super + L`.

Opätovné stlačenie `Super + L` zmení pracovný priestor na plávajúci, kde sa okná voľne prekrývajú a umiestňujete ich sami, a tretie stlačenie ho vráti do dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — také, ktoré ste vysunuli pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, keď sa pracovný priestor vráti do dlaždicového režimu. Horný panel označuje pracovný priestor, na ktorom ste, jeho rozložením: štvorec pre dwindle, kruh pre posúvacie a trojuholník pre plávajúce. Kliknutie na túto značku tiež prepína rozloženie dokola.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Výber je pre každý pracovný priestor samostatný a zostáva zachovaný. Takže pracovný priestor 1 si môžete nechať na dwindle na prehliadanie a pracovný priestor 2 na posúvacom na kód a po reštarte sa vrátia presne tak.

Ak chcete používať posúvacie rozloženie ako predvolené, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné priestory

Plávajúci pracovný priestor funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami ich presúvate a meníte ich veľkosť. Každé okno dostane titulný pruh vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` minimalizuje aj zamerané okno. Minimalizované okno čaká v docku; kliknutím na jeho aplikáciu ho prinesiete späť. Kliknutím na okno ho prinesiete dopredu. Jeho veľkosť zmeníte z ľubovoľného okraja alebo rohu. Dvojitým kliknutím na titulný pruh okno maximalizujete pri zachovaní viditeľného horného panela a opätovným dvojitým kliknutím získate späť jeho starú veľkosť. Chrome a iné prehliadače založené na Chromium, Disks a Document Viewer titulný pruh vynechávajú a namiesto toho používajú vlastnú hlavičku; `Super + Alt + F` ich maximalizuje a `Super + M` ich minimalizuje.

Plávajúci pracovný priestor zobrazuje aj dock s vašimi pripnutými aplikáciami, všetkým, čo práve beží, a mriežkou všetkých aplikácií za tlačidlom aplikácií, ktorú otvárajú aj `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknutím pravým tlačidlom na aplikáciu v mriežke alebo stlačením `Delete` ju odinštalujete. Kliknutím na aplikáciu ju otvoríte alebo prinesiete jej okno dopredu; opätovným kliknutím prechádzate jej oknami dokola. Files prinesie späť len okno z pracovného priestoru, na ktorom ste, a inak otvorí nové, a Terminal a Agent vždy spustia ďalšiu, hoci minimalizované okno sa vráti ako prvé. Kliknutie stredným tlačidlom otvorí nové okno. Potiahnutím ikony pozdĺž docku ju presuniete; potiahnutie bežiacej aplikácie medzi ostatné ju tam ponechá. Kliknutím pravým tlačidlom aplikáciu v docku ponecháte, odstránite ju z neho alebo ju ukončíte. Dock uhne z cesty oknu na celú obrazovku. Kliknutím pravým tlačidlom na tlačidlo aplikácií presuniete dock na iný okraj alebo ho necháte skrytý, kým ukazovateľ nedosiahne jeho okraj. Poloha je aj pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` nastavujú obe z terminálu. Aplikácie, ktoré máte v docku, sú vyblednuté, keď nebežia.

Nové pracovné priestory a všetky, ktorým ste nedali vlastné rozloženie pomocou `Super + L`, používajú predvolené rozloženie. Zmena predvoleného nastaví naň každý pracovný priestor bez okien, zatiaľ čo ten s oknami si ponechá rozloženie, ktoré má. Okno minimalizované do docku sa stále počíta ako okno na pracovnom priestore, ktorý opustilo. Vyberiete ho pod _Appearance > Workspace Layout_: Tiling, Scrolling alebo Floating. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná môžete zoskupiť pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete presúvať pomocou `Super + Ctrl + Arrow Left/Right` alebo pomocou `Super + Alt + 1/2/3/4` prejdete priamo na zoskupené okná v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Napokon môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vysúvanie okien

Okno môžete vysunúť z jeho priradenia pracovnému priestoru pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje na ktorýkoľvek pracovný priestor, na ktorý prejdete. Skvelé pre prehrávače videa a podobne.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovný priestor scratchpad

Existuje špeciálny pracovný priestor scratchpad v plnej veľkosti, ktorý sa prekrýva cez pracovný priestor, na ktorom práve ste. K tomu, čo je na ňom, sa dostanete pomocou `Super + S` a okná tam umiestnite pomocou `Super + Alt + S`.

Dobre funguje pre ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálneho pracovného priestoru.

### Konzola Quake

Napokon je tu konzola Quake s polovičnou výškou, ktorá sa vysunie cez pracovný priestor, na ktorom práve ste. Prepnete ju pomocou `Super + Grave` a okno tam umiestnite pomocou `Super + Shift + Grave`.

Otvorí sa s vaším predvoleným agentom pripraveným na použitie. Kým konzola obsahuje jedno okno, vysúva sa ako vycentrovaný panel namiesto toho, aby sa rozprestierala cez celú obrazovku. Umiestnite na ňu druhú aplikáciu a vráti sa na plnú šírku, aby mali obe miesto sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na iný pracovný priestor niečím ako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíľu trvá, kým si na takúto navigáciu pracovnej plochy zvyknete, ale keď sa tak stane, bude ťažké vrátiť sa k tradičnému zážitku z pracovnej plochy ovládanej myšou!
