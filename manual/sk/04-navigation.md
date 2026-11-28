# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _VŠETKO!_ Keď sa systém prvýkrát spustí, doslova nič neurobíte len myšou. Môžete však stlačiť `Super + Space`, čím zobrazíte Omarchy Menu, a odtiaľto môžete robiť takmer všetko.

Ale Omarchy menu ani nie je určené na to, aby bolo väčšinu času hlavným spôsobom ovládania systému. Dokážeme to rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste urobiť jedno po druhom a uvidíte kúzlo dlaždicového usporiadania Hyprland v praxi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J`, aby ste ich uložili na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Opätovným stlačením `Super + J` ich vrátite do pozícií vedľa seba. Potom v prehliadači skúste `Super + Shift + Arrow Right`, čím okná vymeníte.

Teraz skúste `Super + Shift + T` na spustenie monitora aktivity. Ten sa zobrazí ako plávajúce okno s titulkovým pruhom, za ktorý ho môžete ťahať, a s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. Každé plávajúce okno ho dostane, nech je kdekoľvek. Môžete ho usporiadať do dlaždíc pomocou `Super + T` (a opätovným stlačením ho znova urobíte plávajúcim). Teraz stlačte `Super + Shift + F` na otvorenie správcu súborov. Budete mať úhľadné usporiadanie do štyroch okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, sa pohybujete pomocou `Super + Arrow`. Tým sa prepne zameranie a kurzor sa presunie do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na tej strane.

Ak stlačíte `Super + Shift + 2`, presuniete aktuálne zameranú aplikáciu na druhý pracovný priestor. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie aktuálne zameranú aplikáciu na druhý pracovný priestor bez prepnutia naň).

Pri viac ako jednom monitore má každý monitor svoje vlastné pracovné priestory 1 až 10. `Super + 2` prejde na druhý pracovný priestor monitora, na ktorom ste, a horný pruh každého monitora zobrazuje jeho vlastné pracovné priestory a ten, ktorý práve zobrazuje. `Super + Tab` cykluje cez pracovné priestory na monitore, na ktorom ste. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom ste, na monitor v danom smere, na pracovný priestor, ktorý zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovný priestor, na ktorom ste, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné priestory zachová, keď ho odpojíte: pripoja sa k pracovným priestorom inej obrazovky, očíslované za tými, ktoré už má, a keď sa monitor vráti, vrátia sa pod svoje staré čísla.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť usporiadanie toho, kde sa nachádza. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F` alebo dokonca len na celú šírku (pri zachovaní horného pruhu) pomocou `Super + Alt + F` alebo na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (dobré pre YouTube!).

### Usporiadanie dwindle vs. posúvateľné usporiadanie

Predvolené usporiadanie Omarchy sa nazýva dwindle. Všetky okná, ktoré otvoríte na jednom pracovnom priestore, udržiava neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však tiež rozhodnúť zmeniť pracovný priestor na posúvateľné usporiadanie, kde sú okná zoradené vedľa seba, za viditeľným okrajom displeja. Jeden pracovný priestor na toto usporiadanie zmeníte pomocou `Super + L`.

Opätovné stlačenie `Super + L` zmení pracovný priestor na plávajúci, kde sa okná voľne prekrývajú a umiestňujete ich sami, a tretie stlačenie ho vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré aj tak pláva — také, ktoré ste vybrali pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávať, keď sa pracovný priestor vráti do dlaždicového usporiadania. Horný pruh označuje pracovný priestor, na ktorom ste, jeho usporiadaním: štvorec pre dwindle, kruh pre posúvateľné a trojuholník pre plávajúce. Kliknutie na túto značku tiež cykluje usporiadanie, a rovnako aj kláves displeja na notebookoch, ktoré ho majú.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Voľba je pre každý pracovný priestor a zostáva zachovaná. Takže pracovný priestor 1 môžete mať na dwindle na prehliadanie a pracovný priestor 2 na posúvateľnom usporiadaní na kód, a po reštarte sa vrátia takto.

Ak si želáte používať posúvateľné usporiadanie ako predvolené, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné priestory

Plávajúci pracovný priestor funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami ich presúvate a meníte ich veľkosť. Každé okno dostane titulkový pruh vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` tiež minimalizuje zamerané okno. Minimalizované okno čaká v docku; kliknutím na jeho aplikáciu ho prinesiete späť. Kliknutím na okno ho prinesiete dopredu. Jeho veľkosť zmeníte z ľubovoľného okraja alebo rohu. Dvojitým kliknutím na titulkový pruh okno maximalizujete pri zachovaní horného pruhu v dohľade a opätovným dvojitým kliknutím získate späť jeho starú veľkosť. Chrome a iné prehliadače založené na Chromium, Disks a Document Viewer titulkový pruh preskakujú a namiesto neho používajú vlastnú hlavičku; `Super + Alt + F` ich maximalizuje a `Super + M` ich minimalizuje.

Každý pracovný priestor má dock s vašimi pripnutými aplikáciami, všetkým, čo beží, a mriežkou každej aplikácie za tlačidlom aplikácií, ktoré otvárajú aj `Super + Alt + Space` a _Aplikácie_ v Omarchy menu. Kliknutím pravým tlačidlom na aplikáciu v mriežke alebo stlačením `Delete` ju odinštalujete. Kliknutím na aplikáciu ju otvoríte alebo prinesiete jej okno dopredu; opätovným kliknutím cyklujete cez jej okná. Files prinesie späť len okno z pracovného priestoru, na ktorom ste, a inak otvorí nové, a Terminal a Agent vždy spustia ďalšie, hoci minimalizované okno sa vráti ako prvé. Kliknutie stredným tlačidlom otvorí nové okno. Ťahaním ikony pozdĺž docku ju presuniete; vtiahnutie bežiacej aplikácie medzi ostatné ju tam ponechá. Kliknutím pravým tlačidlom aplikáciu ponecháte v docku, vyberiete ju z neho alebo ju ukončíte. Dock zostáva vonku, kým je pracovný priestor prázdny, a keď už pracovný priestor má okno, skrýva sa, dokiaľ ukazovateľ nedosiahne jeho okraj. Okno na celú obrazovku ho skrýva úplne. Ťahaním tlačidla aplikácií smerom k inému okraju obrazovky tam dock presuniete. Kliknutím pravým tlačidlom naň získate _Poloha_ na výber okraja, _Rozloženie_ na nastavenie predvoleného usporiadania tak, ako to robí _Vzhľad > Rozloženie pracovného priestoru_, a _Viditeľnosť_ na ponechanie docku stále zapnutého, na to, aby ho prvá aplikácia skryla, alebo na jeho stále skrytie. `omarchy dock visibility always` to nastaví z terminálu. Poloha je tiež v časti _Vzhľad > Dock > Poloha docku_ a `omarchy dock position left` ju nastaví z terminálu. Aplikácie, ktoré si ponecháte v docku, sú vyblednuté, kým nebežia. Ak chcete dock ponechať len pre plávajúce pracovné priestory, použite _Vzhľad > Dock > Dock iba na plávajúcich_ alebo `omarchy dock tiling off`.

Nové pracovné priestory a všetky, ktorým ste nedali vlastné usporiadanie pomocou `Super + L`, používajú predvolené usporiadanie. Zmena predvoleného usporiadania naň resetuje každý pracovný priestor bez okien, zatiaľ čo ten s oknami si ponechá usporiadanie, ktoré má. Okno minimalizované do docku sa stále počíta ako okno na pracovnom priestore, ktorý opustilo. Vyberiete ho v časti _Vzhľad > Rozloženie pracovného priestoru_: Dlaždicové, Posúvateľné alebo Plávajúce. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná je možné zoskupiť pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete pohybovať pomocou `Super + Ctrl + Arrow Left/Right` alebo `Super + Alt + 1/2/3/4`, čím prejdete priamo na zoskupené okná v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Nakoniec môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vyčleňovanie okien

Okno môžete vyčleniť z jeho pridelenia pracovnému priestoru pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje na ktorýkoľvek pracovný priestor, na ktorý prejdete. Skvelé pre prehrávače videa a podobne.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovný priestor scratchpad

Existuje špeciálny pracovný priestor scratchpad v plnej veľkosti, ktorý prekrýva ktorýkoľvek pracovný priestor, na ktorom práve ste. K tomu, čo je na ňom, sa dostanete pomocou `Super + S` a okná tam umiestňujete pomocou `Super + Alt + S`.

Funguje dobre pre ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálneho pracovného priestoru.

### Konzola Quake

Nakoniec je tu konzola Quake v polovičnej výške, ktorá sa spustí cez ktorýkoľvek pracovný priestor, na ktorom práve ste. Prepínate ju pomocou `Super + the key above Tab` (na amerických rozloženiach grave) a okno tam umiestnite pomocou `Super + Shift + the key above Tab`.

Pri prvom otvorení spustí vášho predvoleného agenta alebo vás požiada, aby ste si jedného vybrali, ak ste si ešte žiadneho nezvolili. Kým konzola obsahuje jedno okno, spúšťa sa ako centrovaný panel namiesto toho, aby sa rozprestierala cez obrazovku. Dajte na ňu druhú aplikáciu a vráti sa na celú šírku, aby mali obe miesto sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na iný pracovný priestor niečím ako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíľu trvá, kým si zvyknete na takúto navigáciu po pracovnej ploche, ale keď si zvyknete, bude ťažké vrátiť sa k tradičnému zážitku z pracovnej plochy ovládanej myšou!
