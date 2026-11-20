# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _VŠETKO!_ Keď sa systém prvýkrát spustí, len myšou doslova nič nespravíte. Môžete však stlačiť `Super + Space`, čím otvoríte Omarchy Menu, a odtiaľ už zvládnete takmer všetko.

Omarchy menu však väčšinu času ani nemá byť hlavným spôsobom, ako sa systém ovláda. Dá sa to aj rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste urobiť jedno po druhom a uvidíte kúzlo dlaždicového usporiadania Hyprlandu v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a zoradia sa na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Stlačte `Super + J` znova a vrátia sa do polohy vedľa seba. Potom v prehliadači skúste `Super + Shift + Arrow Right` a okná sa vymenia.

Teraz skúste `Super + Shift + T` na spustenie monitora Activity. Zobrazí sa ako plávajúce okno. Do dlaždíc ho dostanete pomocou `Super + T` (a stlačením znova ho opäť urobíte plávajúcim). Teraz stlačte `Super + Shift + F` a otvorí sa správca súborov. Budete mať pekné usporiadanie na štyri časti:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, sa pohybujete pomocou `Super + Arrow`. Tým sa prepne zameranie a kurzor sa presunie do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor v danom smere.

Keď stlačíte `Super + Shift + 2`, presuniete práve zameranú aplikáciu na druhú pracovnú plochu. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie práve zameranú aplikáciu na druhú pracovnú plochu bez toho, aby ste sa na ňu prepli).

Pri viac než jednom monitore má každý monitor vlastné pracovné plochy 1 až 10. `Super + 2` prejde na druhú pracovnú plochu monitora, na ktorom sa nachádzate, a horný panel každého monitora ukazuje jeho vlastné pracovné plochy a tú, ktorú práve zobrazuje. `Super + Tab` cykluje pracovné plochy na monitore, na ktorom sa nachádzate. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom ste, na monitor v danom smere, na pracovnú plochu, ktorú práve zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovnú plochu, na ktorej ste, na monitor v danom smere, kde si vezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné plochy podrží, aj keď ho odpojíte: pridajú sa k inej obrazovke, očíslované po tých, ktoré už má, a keď sa monitor vráti, vráti sa im aj ich staré číslovanie.

Keď podržíte `Super` a kliknete myšou na okno, budete môcť presunúť, kde sedí. Keď podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Na celú obrazovku môžete prejsť pomocou `Super + F`, prípadne len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F`, alebo na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (skvelé na YouTube!).

### Rozloženie dwindle vs. rolujúce rozloženie

Predvolené rozloženie Omarchy sa volá dwindle. Všetky okná, ktoré otvoríte na jednej pracovnej ploche, udržuje stále viditeľné, aj keď ich na to musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však rozhodnúť aj premeniť pracovnú plochu na rolujúce rozloženie, kde sú okná zoradené vedľa seba až za viditeľný okraj displeja. Jednu pracovnú plochu do tohto rozloženia prepnete pomocou `Super + L`.

Opätovné stlačenie `Super + L` prepne pracovnú plochu na plávajúcu, kde sa okná voľne prekrývajú a ukladáte si ich sami, a tretie stlačenie ju vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — také, ktoré ste si vytiahli pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, aj keď sa pracovná plocha vráti na dlaždicové usporiadanie. Horný panel označuje pracovnú plochu, na ktorej ste, jej rozložením: štvorec pre dwindle, kruh pre rolujúce a trojuholník pre plávajúce. Kliknutím na túto značku sa rozloženie tiež cykluje, rovnako ako klávesom displeja na laptopoch, ktoré ho majú.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Voľba je na každú pracovnú plochu a zostáva zachovaná. Môžete si tak nechať pracovnú plochu 1 na dwindle na prehliadanie a pracovnú plochu 2 na rolujúcom na kód a po reštarte sa vrátia presne takto.

Ak chcete rolujúce rozloženie používať ako predvolené, môžete ho nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné plochy

Plávajúca pracovná plocha funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami si ich presúvate a meníte ich veľkosť. Každé okno dostane titulkový pruh vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` minimalizuje aj zamerané okno. Minimalizované okno čaká v docku; kliknutím na jeho aplikáciu ho vrátite späť. Kliknutím na okno ho prenesiete dopredu. Jeho veľkosť zmeníte z ktoréhokoľvek okraja alebo rohu. Dvojitým kliknutím na titulkový pruh okno maximalizujete, pričom horný panel zostane viditeľný, a opätovným dvojitým kliknutím mu vrátite jeho starú veľkosť. Chrome a iné prehliadače založené na Chromiu, Disks a Document Viewer titulkový pruh preskakujú a namiesto toho používajú vlastnú hlavičku; `Super + Alt + F` ich maximalizuje a `Super + M` ich minimalizuje.

Plávajúca pracovná plocha ukazuje aj dock s vašimi pripnutými aplikáciami, všetkým, čo práve beží, a mriežkou všetkých aplikácií za tlačidlom aplikácií, ktorú otvárajú aj `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknutím pravým tlačidlom na aplikáciu v mriežke, alebo stlačením `Delete`, ju odinštalujete. Kliknutím na aplikáciu ju otvoríte, alebo prenesiete jej okno dopredu; opätovným kliknutím cyklujete jej oknami. Files vráti späť len okno z pracovnej plochy, na ktorej ste, a inak otvorí nové, a Terminal a Agent vždy spustia ďalšie, hoci minimalizované okno sa vráti ako prvé. Kliknutím stredným tlačidlom otvoríte nové okno. Pretiahnutím ikony pozdĺž docku ju presuniete; pretiahnutie bežiacej aplikácie medzi ostatné ju tam ponechá. Kliknutím pravým tlačidlom aplikáciu v docku ponecháte, vyberiete ju z neho alebo ju ukončíte. Dock ustúpi oknu na celú obrazovku. Kliknutím pravým tlačidlom na tlačidlo aplikácií dock presuniete na iný okraj alebo ho necháte skrývať sa, kým ukazovateľ nedosiahne jeho okraj. Poloha sa nachádza aj v _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` oboje nastavia z terminálu. Aplikácie, ktoré si ponecháte v docku, sú vyblednuté, kým nebežia.

Nové pracovné plochy a všetky, ktorým ste pomocou `Super + L` nedali vlastné rozloženie, používajú predvolené rozloženie. Zmena predvoleného rozloženia naň resetuje každú pracovnú plochu bez okien, zatiaľ čo tá, ktorá na sebe okná má, si ponechá rozloženie, ktoré má. Okno minimalizované do docku sa stále počíta ako okno na pracovnej ploche, ktorú opustilo. Vybrať si ho môžete v _Appearance > Workspace Layout_: Tiling, Scrolling alebo Floating. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná sa dajú zoskupovať pomocou `Super + G`. Keď ste raz v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete pohybovať pomocou `Super + Ctrl + Arrow Left/Right` alebo `Super + Alt + 1/2/3/4`, čím prejdete priamo na zoskupené okná v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G`, alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Napokon môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vytiahnutie okien

Okno môžete vytiahnuť z jeho priradenia k pracovnej ploche pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje, na ktorúkoľvek pracovnú plochu prejdete. Skvelé pre prehrávače videa a podobné.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovná plocha scratchpad

Existuje špeciálna pracovná plocha scratchpad v plnej veľkosti, ktorá prekrýva ktorúkoľvek pracovnú plochu, na ktorej práve ste. K tomu, čo je na nej, sa dostanete pomocou `Super + S` a okná tam ukladáte pomocou `Super + Alt + S`.

Dobre sa hodí na ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálnej pracovnej plochy.

### Konzola Quake

Nakoniec je tu konzola Quake v polovičnej výške, ktorá sa vysunie cez ktorúkoľvek pracovnú plochu, na ktorej práve ste. Prepínate ju pomocou `Super + Grave` a okno tam umiestnite pomocou `Super + Shift + Grave`.

Keď sa otvorí prvýkrát, spustí vášho predvoleného agenta, alebo vás požiada, aby ste si jedného vybrali, ak ste si ešte žiadneho nezvolili. Kým konzola drží jediné okno, vysúva sa ako vycentrovaný panel, namiesto aby sa tiahla cez celú obrazovku. Dajte na ňu druhú aplikáciu a vráti sa na plnú šírku, aby mali obe miesto sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na inú pracovnú plochu niečím ako `Super + Shift + 1`.

### Chvíľu trvá, kým si na to zvyknete!

Chvíľu trvá, kým si zvyknete pohybovať sa po svojej pracovnej ploche takto, ale keď sa vám to podarí, bude ťažké vrátiť sa k tradičnému zážitku z pracovnej plochy ovládanej myšou!
