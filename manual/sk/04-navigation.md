# Navigácia

Všetko v Omarchy sa robí klávesnicou — _VŠETKO!_ Keď sa systém prvýkrát spustí, samotnou myšou doslova nič neurobíte. Môžete však stlačiť `Super + Space`, čím zobrazíte ponuku Omarchy, a odtiaľ zvládnete takmer všetko.

Ponuka Omarchy však väčšinou ani nemá byť hlavným spôsobom ovládania systému. Dá sa to aj rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste to jedno po druhom a uvidíte kúzlo dlaždicového usporiadania v Hyprland v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a naskladať ich na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova stlačte `Super + J`, čím ich vrátite do polohy vedľa seba. Potom v prehliadači skúste `Super + Shift + Arrow Right`, čím okná vymeníte.

Teraz skúste `Super + Shift + T`, čím spustíte Activity monitor. Zobrazí sa ako plávajúce okno s titulkovým pruhom, za ktorý ho môžete ťahať, a s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. Každé plávajúce okno ho dostane, nech je kdekoľvek. Pomocou `Super + T` ho môžete usporiadať do dlaždíc (a opätovným stlačením ho znova premeníte na plávajúce). Teraz stlačte `Super + Shift + F`, čím otvoríte správcu súborov. Budete mať pekné štvorité usporiadanie:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, sa pohybujete pomocou `Super + Arrow`. Tým prepnete zameranie a presuniete kurzor do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na tej strane.

Ak stlačíte `Super + Shift + 2`, presuniete práve zameranú aplikáciu na druhý pracovný priestor. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie práve zameranú aplikáciu na druhý pracovný priestor bez prepnutia naň).

Pri viacerých monitoroch má každý monitor vlastné pracovné priestory 1 až 10. `Super + 2` prejde na druhý pracovný priestor monitora, na ktorom sa nachádzate, a horný panel každého monitora zobrazuje jeho vlastné pracovné priestory a ten, ktorý práve zobrazuje. `Super + Tab` cykluje pracovnými priestormi na monitore, na ktorom sa nachádzate. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom sa nachádzate, na monitor v danom smere, na pracovný priestor, ktorý zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovný priestor, na ktorom sa nachádzate, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné priestory zachová, aj keď ho odpojíte: pripoja sa k inej obrazovke, očíslované až po tých, ktoré už má, a keď sa monitor vráti, vrátia sa pod svojimi starými číslami.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť, kde sa nachádza. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F`, alebo dokonca len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F`, alebo na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (vhodné pre YouTube!).

### Dwindle vs rolovacie rozloženie

Predvolené rozloženie v Omarchy sa volá dwindle. Všetky okná, ktoré otvoríte na jednom pracovnom priestore, udržiava neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však tiež rozhodnúť zmeniť pracovný priestor na rolovacie rozloženie, kde sú okná zoradené vedľa seba až za viditeľný okraj displeja. Jeden pracovný priestor na toto rozloženie prepnete pomocou `Super + L`.

Opätovným stlačením `Super + L` sa pracovný priestor zmení na plávajúci, kde sa okná voľne prekrývajú a umiestňujete si ich sami, a tretím stlačením sa vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — také, ktoré ste vytiahli pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, keď sa pracovný priestor vráti k dlaždicovému usporiadaniu. Horný panel označuje pracovný priestor, na ktorom sa nachádzate, jeho rozložením: štvorec pre dwindle, kruh pre rolovacie a trojuholník pre plávajúce. Kliknutím na túto značku sa rozloženie tiež cykluje a rovnako to robí aj kláves displeja na notebookoch, ktoré ho majú.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Výber platí pre každý pracovný priestor zvlášť a zostáva zachovaný. Pracovný priestor 1 si tak môžete nechať na dwindle na prehliadanie a pracovný priestor 2 na rolovacom na kód a po reštarte sa vrátia presne tak.

Ak chcete rolovacie rozloženie používať ako predvolené, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné priestory

Plávajúci pracovný priestor funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami si ich presúvate a meníte ich veľkosť. Každé okno dostane titulkový pruh vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` minimalizuje aj zamerané okno. Minimalizované okno čaká v doku; kliknutím na jeho aplikáciu ho vrátite späť. Kliknutím na okno ho prenesiete dopredu. Jeho veľkosť môžete meniť z ktorejkoľvek hrany alebo rohu. Dvojitým kliknutím na titulkový pruh okno maximalizujete pri zachovaní viditeľného horného panela a opätovným dvojitým kliknutím získate späť jeho starú veľkosť. Chrome a iné prehliadače založené na Chromium, Disks a Document Viewer titulkový pruh vynechávajú a namiesto neho používajú vlastnú hlavičku; `Super + Alt + F` ich maximalizuje a `Super + M` ich minimalizuje.

Každý pracovný priestor má dok s vašimi pripnutými aplikáciami, všetkým, čo práve beží, a mriežkou všetkých aplikácií za tlačidlom aplikácií, ktoré otvára aj `Super + Alt + Space` a _Aplikácie_ v ponuke Omarchy. Kliknutím pravým tlačidlom na aplikáciu v mriežke alebo stlačením `Delete` ju odinštalujete. Kliknutím na aplikáciu ju otvoríte alebo prenesiete jej okno dopredu; opätovným kliknutím cyklujete jej oknami. Files vráti späť iba okno z pracovného priestoru, na ktorom sa nachádzate, a inak otvorí nové, a Terminal a Agent vždy spustia ďalšie, hoci minimalizované okno sa vráti ako prvé. Kliknutím stredným tlačidlom otvoríte nové okno. Potiahnutím ikony pozdĺž doku ju presuniete; potiahnutím bežiacej aplikácie medzi ostatné ju tam zachová. Kliknutím pravým tlačidlom aplikáciu v doku ponecháte, vyberiete ju z neho alebo ju ukončíte. Dok zostáva vonku, kým je pracovný priestor prázdny, a keď už pracovný priestor má okno, skrýva sa, dokiaľ ukazovateľ nedosiahne jeho okraj. Okno na celú obrazovku ho skrýva úplne. Potiahnutím tlačidla aplikácií k inému okraju obrazovky tam dok presuniete. Kliknite naň pravým tlačidlom pre _Pozíciu_, čím vyberiete okraj, a _Rozloženie_, čím nastavíte predvolené rozloženie tak, ako to robí _Vzhľad > Rozloženie pracovného priestoru_. Pozícia sa nachádza aj pod _Vzhľad > Dok > Pozícia doku_ a `omarchy dock position left` ju nastaví z terminálu. Aplikácie, ktoré si nechávate v doku, sú vyblednuté, kým nebežia. Ak chcete dok ponechať iba na plávajúce pracovné priestory, použite _Vzhľad > Dok > Dok iba na plávajúcich_ alebo `omarchy dock tiling off`.

Nové pracovné priestory a všetky, ktorým ste pomocou `Super + L` nedali vlastné rozloženie, používajú predvolené rozloženie. Zmena predvoleného rozloženia naň obnoví každý pracovný priestor bez okien, zatiaľ čo ten, ktorý na ňom okná má, si zachová rozloženie, ktoré má. Okno minimalizované do doku sa stále počíta ako okno na pracovnom priestore, ktorý opustilo. Vyberte ho pod _Vzhľad > Rozloženie pracovného priestoru_: Dlaždicové, Rolovacie alebo Plávajúce. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná môžete zoskupovať pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete pohybovať pomocou `Super + Ctrl + Arrow Left/Right` alebo `Super + Alt + 1/2/3/4`, čím prejdete priamo na zoskupené okná v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Nakoniec môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vyťahovanie okien

Okno môžete vytiahnuť z jeho pridelenia pracovnému priestoru pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje na každý pracovný priestor, na ktorý prejdete. Skvelé pre prehrávače videa a podobne.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Odkladací pracovný priestor

Existuje špeciálny odkladací pracovný priestor v plnej veľkosti, ktorý sa prekrýva cez pracovný priestor, na ktorom sa práve nachádzate. K tomu, čo je na ňom, sa dostanete pomocou `Super + S` a okná tam umiestňujete pomocou `Super + Alt + S`.

Dobre funguje pre ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálneho pracovného priestoru.

### Konzola Quake

Nakoniec je tu konzola Quake s polovičnou výškou, ktorá sa vysúva cez pracovný priestor, na ktorom sa práve nachádzate. Prepínate ju pomocou `Super + the key above Tab` (grave na amerických rozloženiach) a okno tam umiestnite pomocou `Super + Shift + the key above Tab`.

Pri prvom otvorení spustí vášho predvoleného agenta alebo vás požiada, aby ste si jedného vybrali, ak ste si ešte žiadneho nezvolili. Kým konzola obsahuje jediné okno, vysúva sa ako vycentrovaný panel namiesto toho, aby sa rozprestierala cez celú obrazovku. Umiestnite na ňu druhú aplikáciu a vráti sa na plnú šírku, aby mali obe miesto byť vedľa seba.

Ak chcete okno presunúť preč z odkladacieho priestoru alebo z konzoly, pošlite ho priamo na iný pracovný priestor pomocou niečoho ako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíľu trvá, kým si na takúto navigáciu po pracovnej ploche zvyknete, ale keď si zvyknete, bude ťažké vrátiť sa k tradičnému používaniu pracovnej plochy ovládanej myšou!
