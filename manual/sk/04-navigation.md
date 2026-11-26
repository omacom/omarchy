# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _ÚPLNE VŠETKO!_ Keď sa systém prvýkrát spustí, doslova nič neurobíte len s myšou. Môžete však stlačiť `Super + Space`, čím zobrazíte Omarchy Menu, a odtiaľ už urobíte takmer všetko.

Ale Omarchy menu ani väčšinu času nemá byť hlavným spôsobom ovládania systému. Vieme to aj rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste urobiť jedno po druhom a uvidíte v akcii kúzlo dlaždicového usporiadania v Hyprlande:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J`, čím ich naskladáte na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova stlačte `Super + J`, čím ich vrátite do polohy vedľa seba. Potom v prehliadači skúste `Super + Shift + Arrow Right`, čím okná vymeníte.

Teraz skúste `Super + Shift + T`, čím spustíte monitor aktivity. Ten sa zobrazí ako plávajúce okno. Do dlaždíc ho zaradíte pomocou `Super + T` (a opätovným stlačením ho znova urobíte plávajúcim). Teraz stlačte `Super + Shift + F`, čím otvoríte správcu súborov. Budete mať pekné usporiadanie na štyri časti:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, prechádzate pomocou `Super + Arrow`. Tým prepnete zameranie a presuniete kurzor do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na danej strane.

Ak stlačíte `Super + Shift + 2`, presuniete práve zameranú aplikáciu na druhú pracovnú plochu. Pomocou `Super + Shift + 1` ju presuniete späť. (A `Super + Shift + Alt + 2` presunie práve zameranú aplikáciu na druhú pracovnú plochu bez prepnutia na ňu).

Pri viacerých monitoroch má každý monitor vlastné pracovné plochy 1 až 10. `Super + 2` prejde na druhú pracovnú plochu monitora, na ktorom sa nachádzate, a horný panel každého monitora zobrazuje jeho vlastné pracovné plochy a tú, ktorú práve zobrazuje. `Super + Tab` cykluje pracovnými plochami na monitore, na ktorom sa nachádzate. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom sa nachádzate, na monitor v danom smere, na pracovnú plochu, ktorú práve zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovnú plochu, na ktorej sa nachádzate, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné plochy zachová, keď ho odpojíte: pripoja sa k inej obrazovke, očíslované po tých, ktoré už má, a po návrate monitora sa vrátia pod svoje staré čísla.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť jeho umiestnenie. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F` alebo dokonca len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F`, prípadne na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (vhodné pre YouTube!).

### Rozloženie dwindle vs. posúvateľné rozloženie

Predvolené rozloženie v Omarchy sa nazýva dwindle. Všetky okná, ktoré otvoríte na jednej pracovnej ploche, udržiava neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však tiež rozhodnúť zmeniť pracovnú plochu na posúvateľné rozloženie, kde sú okná zoradené vedľa seba za viditeľným okrajom displeja. Jednu pracovnú plochu na toto rozloženie prepnete pomocou `Super + L`.

Opätovné stlačenie `Super + L` prepne pracovnú plochu na plávajúcu, kde sa okná voľne prekrývajú a umiestňujete ich sami, a tretie stlačenie ju vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — také, ktoré ste vysunuli pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, keď sa pracovná plocha vráti do dlaždicového usporiadania. Horný panel označuje pracovnú plochu, na ktorej sa nachádzate, jej rozložením: štvorec pre dwindle, kruh pre posúvateľné a trojuholník pre plávajúce. Kliknutím na túto značku sa rozloženie tiež cykluje, rovnako ako klávesom displeja na notebookoch, ktoré ho majú.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Voľba platí pre každú pracovnú plochu zvlášť a zostáva zachovaná. Môžete si teda nechať pracovnú plochu 1 na dwindle na prehliadanie a pracovnú plochu 2 na posúvateľnom rozložení na kód a po reštarte sa vrátia rovnakým spôsobom.

Ak chcete ako predvolené používať posúvateľné rozloženie, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné plochy

Plávajúca pracovná plocha funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami ich presúvate a meníte ich veľkosť. Každé okno dostane titulkový pruh vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` minimalizuje aj zamerané okno. Minimalizované okno čaká v doku; kliknite na jeho aplikáciu, čím ho prinesiete späť. Kliknite na okno, čím ho prinesiete dopredu. Jeho veľkosť môžete meniť z ktorejkoľvek hrany alebo rohu. Dvojitým kliknutím na titulkový pruh okno maximalizujete pri zachovaní viditeľného horného panela a opätovným dvojitým kliknutím získate späť jeho starú veľkosť. Chrome a iné prehliadače založené na prehliadači Chromium, Disks a Document Viewer titulkový pruh vynechávajú a namiesto neho používajú vlastnú hlavičku; `Super + Alt + F` ich maximalizuje a `Super + M` ich minimalizuje.

Plávajúca pracovná plocha tiež zobrazuje dok s vašimi pripnutými aplikáciami, všetkým, čo práve beží, a mriežkou všetkých aplikácií za tlačidlom aplikácií, ktorú otvárajú aj `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknite pravým tlačidlom myši na aplikáciu v mriežke alebo stlačte `Delete`, čím ju odinštalujete. Kliknite na aplikáciu, čím ju otvoríte alebo prinesiete jej okno dopredu; kliknite znova, čím budete cyklovať jej oknami. Files prinesie späť len okno z pracovnej plochy, na ktorej sa nachádzate, a inak otvorí nové, a Terminal a Agent vždy spustia ďalšie, hoci minimalizované okno sa vráti ako prvé. Kliknutie stredným tlačidlom otvorí nové okno. Potiahnutím ikony pozdĺž doku ju presuniete; potiahnutím bežiacej aplikácie medzi ostatné ju tam ponecháte. Kliknite pravým tlačidlom myši, čím aplikáciu ponecháte v doku, vyberiete ju z neho alebo ju ukončíte. Dok sa uhne oknu na celú obrazovku. Kliknite pravým tlačidlom myši na tlačidlo aplikácií, čím dok presuniete na inú hranu alebo ho necháte skrývať, kým ukazovateľ nedosiahne jeho hranu. Poloha je tiež pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` obe nastavia z terminálu. Aplikácie, ktoré máte v doku, sú vyblednuté, kým nebežia.

Nové pracovné plochy a všetky, ktorým ste pomocou `Super + L` nedali vlastné rozloženie, používajú predvolené rozloženie. Zmena predvoleného rozloženia obnoví naň každú pracovnú plochu bez okien, zatiaľ čo tá s oknami si zachová rozloženie, ktoré má. Okno minimalizované do doku sa stále počíta ako okno na pracovnej ploche, ktorú opustilo. Vyberte ho pod _Appearance > Workspace Layout_: Tiling, Scrolling alebo Floating. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná môžete zoskupiť pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete presúvať pomocou `Super + Ctrl + Arrow Left/Right` alebo pomocou `Super + Alt + 1/2/3/4` prejdete priamo na zoskupené okná v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Nakoniec môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vysúvanie okien

Okno môžete vysunúť z jeho pridelenia pracovnej ploche pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje na ktorúkoľvek pracovnú plochu, na ktorú prejdete. Skvelé pre prehrávače videa a podobné aplikácie.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovná plocha scratchpad

Existuje špeciálna pracovná plocha scratchpad v plnej veľkosti, ktorá prekrýva ktorúkoľvek pracovnú plochu, na ktorej sa práve nachádzate. K tomu, čo je na nej, sa dostanete pomocou `Super + S` a okná tam umiestnite pomocou `Super + Alt + S`.

Dobre funguje pre ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálnej pracovnej plochy.

### Konzola Quake

Nakoniec je tu konzola Quake s polovičnou výškou, ktorá sa vysunie cez ktorúkoľvek pracovnú plochu, na ktorej sa práve nachádzate. Prepnete ju pomocou `Super + the key above Tab` (grave na rozloženiach US) a okno tam umiestnite pomocou `Super + Shift + the key above Tab`.

Pri prvom otvorení spustí vášho predvoleného agenta alebo vás požiada, aby ste si jedného vybrali, ak ste si ešte žiadneho nevybrali. Kým konzola obsahuje jedno okno, vysunie sa ako vycentrovaný panel namiesto toho, aby sa rozprestierala cez obrazovku. Umiestnite na ňu druhú aplikáciu a vráti sa na plnú šírku, aby mali obe miesto sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na inú pracovnú plochu niečím ako `Super + Shift + 1`.

### Chvíľu trvá, kým si na to zvyknete!

Chvíľu trvá, kým si zvyknete na takúto navigáciu na pracovnej ploche, ale keď si zvyknete, bude ťažké vrátiť sa k tradičnému používaniu pracovnej plochy ovládanej myšou!
