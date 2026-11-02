# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _VŠETKO!_ Keď sa systém prvýkrát spustí, doslova nič neurobíte len s myšou. Môžete však stlačiť `Super + Space` a zobraziť Omarchy Menu a odtiaľ môžete urobiť takmer všetko.

Ale Omarchy menu ani väčšinu času nemá byť hlavným spôsobom ovládania systému. Vieme to aj rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste urobiť jedno po druhom a uvidíte kúzlo dlaždicového usporiadania Hyprland v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a naskladať ich na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova stlačte `Super + J` a vrátite ich do polohy vedľa seba. Potom skúste `Super + Shift + Arrow Right` v prehliadači a vymeníte okná.

Teraz skúste `Super + Shift + T` a spustite Activity monitor. Zobrazí sa ako plávajúce okno. Môžete z neho urobiť dlaždicu pomocou `Super + T` (a znova to stlačte, aby bolo opäť plávajúce). Teraz stlačte `Super + Shift + F` a otvorte správcu súborov. Budete mať pekné usporiadanie do štyroch častí:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete aktivovať, sa pohybujete pomocou `Super + Arrow`. Tým sa prepne zameranie a kurzor sa presunie do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na tej strane.

Ak stlačíte `Super + Shift + 2`, presuniete aktuálne zameranú aplikáciu na druhý pracovný priestor. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie aktuálne zameranú aplikáciu na druhý pracovný priestor bez prepnutia naň).

Pri viac ako jednom monitore má každý monitor svoje vlastné pracovné priestory 1 až 10. `Super + 2` prejde na druhý pracovný priestor monitora, na ktorom ste, a horný panel každého monitora zobrazuje jeho vlastné pracovné priestory a ten, ktorý zobrazuje. `Super + Tab` cykluje cez pracovné priestory na monitore, na ktorom ste. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom ste, na monitor v danom smere, na pracovný priestor, ktorý zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovný priestor, na ktorom ste, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné priestory zachová, keď ho odpojíte: pripoja sa k inej obrazovke, očíslované až za tie, ktoré už má, a keď sa monitor vráti, vrátia sa pod svoje staré čísla.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť, kde sa nachádza. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F` alebo len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F` alebo na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (skvelé pre YouTube!).

### Rozloženie dwindle vs. scrolling

Predvolené rozloženie Omarchy sa volá dwindle. Všetky okná, ktoré otvoríte na jednom pracovnom priestore, zostávajú neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale môžete sa tiež rozhodnúť zmeniť pracovný priestor na rozloženie scrolling, kde sú okná zoradené vedľa seba až za viditeľný okraj obrazovky. Jeden pracovný priestor zmeníte na toto rozloženie pomocou `Super + L`.

Opätovné stlačenie `Super + L` zmení pracovný priestor na plávajúci, kde sa okná voľne prekrývajú a umiestňujete si ich sami, a tretie stlačenie ho vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je plávajúce tak či tak — to, ktoré ste vytiahli pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, keď sa pracovný priestor vráti k dlaždicovému usporiadaniu. Horný panel označuje pracovný priestor, na ktorom ste, jeho rozložením: štvorec pre dwindle, kruh pre scrolling a trojuholník pre plávajúce. Kliknutie na túto značku tiež cykluje rozloženie.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Výber platí pre každý pracovný priestor zvlášť a zostáva zachovaný. Takže pracovný priestor 1 môžete mať na dwindle na prehliadanie a pracovný priestor 2 na scrolling na kód a po reštarte sa vrátia presne tak.

Ak chcete používať rozloženie scrolling ako predvolené, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné priestory

Plávajúci pracovný priestor funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami ich presúvate a meníte ich veľkosť. Každé okno dostane záhlavie vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` tiež minimalizuje zamerané okno. Minimalizované okno čaká v docku; kliknite na jeho aplikáciu a vrátite ho späť. Kliknite na okno a prenesiete ho dopredu. Jeho veľkosť zmeníte z ktoréhokoľvek okraja alebo rohu. Dvakrát kliknite na záhlavie a maximalizujete okno pri zachovaní viditeľného horného panela a znova, aby ste získali späť jeho starú veľkosť.

Plávajúci pracovný priestor tiež zobrazuje dock s vašimi pripnutými aplikáciami, všetkým, čo beží, a mriežkou všetkých aplikácií za tlačidlom aplikácií, ktoré otvára aj `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknite pravým tlačidlom na aplikáciu v mriežke alebo stlačte `Delete` a odinštalujete ju. Kliknite na aplikáciu a otvorte ju alebo prenesiete jej okno dopredu; kliknite znova a budete cyklovať cez jej okná. Kliknutie stredným tlačidlom otvorí nové okno. Potiahnite ikonu pozdĺž docku a presuniete ju; potiahnutie bežiacej aplikácie medzi ostatné ju tam ponechá. Kliknite pravým tlačidlom a ponechajte aplikáciu v docku, vyberte ju odtiaľ alebo ju ukončite. Dock uhne oknu na celú obrazovku. Kliknite pravým tlačidlom na tlačidlo aplikácií a presuniete dock na iný okraj alebo ho necháte skrývať, kým ukazovateľ nedosiahne jeho okraj. Poloha je tiež pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` nastavia obe z terminálu. Aplikácie, ktoré si ponecháte v docku, sú vyblednuté, kým nebežia.

Nové pracovné priestory a všetky, ktorým ste nedali vlastné rozloženie pomocou `Super + L`, používajú predvolené rozloženie. Zmena predvoleného rozloženia naň resetuje každý pracovný priestor bez okien, zatiaľ čo ten s oknami si zachová rozloženie, ktoré má. Okno minimalizované do docku sa stále počíta ako okno na pracovnom priestore, ktorý opustilo. Vyberiete ho pod _Appearance > Workspace Layout_: Tiling, Scrolling alebo Floating. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná môžete zoskupiť pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete pohybovať pomocou `Super + Ctrl + Arrow Left/Right` alebo `Super + Alt + 1/2/3/4` a prejsť priamo na zoskupené okná v poradí.

Okno môžete presunúť von zo zoskupenia pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Nakoniec môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vytiahnutie okien

Okno môžete vytiahnuť z jeho pridelenia pracovnému priestoru pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje na ktorýkoľvek pracovný priestor, na ktorý prejdete. Skvelé pre prehrávače videa a podobné veci.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovný priestor scratchpad

Existuje špeciálny pracovný priestor scratchpad v plnej veľkosti, ktorý prekrýva ktorýkoľvek pracovný priestor, na ktorom práve ste. K tomu, čo je na ňom, sa dostanete pomocou `Super + S` a okná tam umiestnite pomocou `Super + Alt + S`.

Dobre funguje pre ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálneho pracovného priestoru.

### Konzola Quake

Nakoniec je tu konzola Quake s polovičnou výškou, ktorá sa spustí cez ktorýkoľvek pracovný priestor, na ktorom práve ste. Prepnite ju pomocou `Super + Grave` a okno tam umiestnite pomocou `Super + Shift + Grave`.

Otvorí sa s vaším predvoleným agentom pripraveným na použitie. Kým konzola obsahuje jedno okno, spustí sa ako vycentrovaný panel, namiesto toho, aby zaberala celú šírku obrazovky. Umiestnite na ňu druhú aplikáciu a vráti sa na plnú šírku, aby mali obe miesto sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na iný pracovný priestor niečím ako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíľu trvá, kým si zvyknete na takúto navigáciu po pracovnej ploche, ale keď si zvyknete, bude ťažké vrátiť sa k tradičnej pracovnej ploche ovládanej myšou!
