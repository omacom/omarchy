# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _VŠETKO!_ Keď sa systém prvýkrát spustí, len s myšou doslova nič neurobíte. Môžete však stlačiť `Super + Space` a zobraziť tak Omarchy Menu, odkiaľ zvládnete takmer všetko.

Ale Omarchy menu ani nemá byť väčšinu času hlavným spôsobom ovládania systému. Vieme to aj rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na samostatné klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste to urobiť jedno po druhom a uvidíte kúzlo dlaždicového usporiadania Hyprland v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a naukladať ich na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Stlačte `Super + J` znova a vrátite ich do pozícií vedľa seba. Potom skúste `Super + Shift + Arrow Right` na prehliadači a okná si vymenia miesta.

Teraz skúste `Super + Shift + T` a spustite monitor aktivity. Zobrazí sa ako plávajúce okno. Môžete ho zaradiť do dlaždíc pomocou `Super + T` (a opätovným stlačením z neho znova urobiť plávajúce). Teraz stlačte `Super + Shift + F` a otvorte správcu súborov. Budete mať pekné štvorcestné usporiadanie:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, sa pohybujete pomocou `Super + Arrow`. Tým sa prepne zameranie a kurzor sa presunie do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na tej strane.

Ak stlačíte `Super + Shift + 2`, presuniete aktuálne zameranú aplikáciu na druhý pracovný priestor. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie aktuálne zameranú aplikáciu na druhý pracovný priestor bez prepnutia naň).

Pri viac ako jednom monitore má každý monitor svoje vlastné pracovné priestory 1 až 10. `Super + 2` prejde na druhý pracovný priestor monitora, na ktorom ste, a horný panel každého monitora zobrazuje jeho vlastné pracovné priestory a ten, ktorý práve zobrazuje. `Super + Tab` cykluje cez pracovné priestory na monitore, na ktorom ste. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom ste, na monitor v danom smere, na pracovný priestor, ktorý zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovný priestor, na ktorom ste, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné priestory ponechá, keď ho odpojíte: pripoja sa k inej obrazovke, očíslované po tých, ktoré už má, a keď sa monitor vráti, vrátia sa pod svoje staré čísla.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť jeho umiestnenie. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F`, alebo dokonca len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F`, alebo na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (skvelé pre YouTube!).

### Rozloženie dwindle vs. posúvacie rozloženie

Predvolené rozloženie Omarchy sa nazýva dwindle. Všetky okná, ktoré otvoríte na jednom pracovnom priestore, udržiava neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však tiež rozhodnúť zmeniť pracovný priestor na posúvacie rozloženie, kde sú okná zoradené vedľa seba, až za viditeľný okraj displeja. Jeden pracovný priestor zmeníte na toto rozloženie pomocou `Super + L`.

Opätovným stlačením `Super + L` sa pracovný priestor zmení na plávajúci, kde sa okná voľne prekrývajú a umiestňujete si ich sami, a tretím stlačením sa vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — také, ktoré ste vyčlenili pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, keď sa pracovný priestor vráti k dlaždiciam. Horný panel označuje pracovný priestor, na ktorom ste, jeho rozložením: štvorec pre dwindle, kruh pre posúvacie a trojuholník pre plávajúce. Kliknutím na túto značku sa rozloženie tiež cykluje.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Voľba je pre každý pracovný priestor samostatná a zostáva zachovaná. Takže pracovný priestor 1 môžete mať na dwindle na prehliadanie a pracovný priestor 2 na posúvacom rozložení na kód a po reštarte sa vrátia presne tak.

Ak chcete posúvacie rozloženie používať ako predvolené, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné priestory

Plávajúci pracovný priestor funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami si ich presúvate a meníte ich veľkosť. Každé okno dostane titulný pruh vo farbách vašej témy, s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` tiež minimalizuje zamerané okno. Minimalizované okno čaká v docku; kliknutím na jeho aplikáciu ho vrátite späť. Kliknutím na okno ho prenesiete dopredu. Jeho veľkosť zmeníte z ktoréhokoľvek okraja alebo rohu. Dvojitým kliknutím na titulný pruh okno maximalizujete pri zachovaní horného panela v dohľade a ďalším dvojitým kliknutím mu vrátite jeho starú veľkosť.

Plávajúci pracovný priestor tiež zobrazuje dock, s vašimi pripnutými aplikáciami, všetkým, čo beží, a mriežkou každej aplikácie za tlačidlom aplikácií, ktoré otvára aj `Super + Alt + Space` a položka _Aplikácie_ v Omarchy menu. Kliknite pravým tlačidlom na aplikáciu v mriežke, alebo stlačte `Delete`, a odinštalujete ju. Kliknutím na aplikáciu ju otvoríte, alebo prenesiete jej okno dopredu; opätovným kliknutím cyklujete cez jej okná. Kliknutím stredným tlačidlom otvoríte nové okno. Potiahnutím ikony pozdĺž docku ju presuniete; potiahnutím bežiacej aplikácie medzi ostatné ju tam ponecháte. Kliknutím pravým tlačidlom aplikáciu ponecháte v docku, odstránite ju z neho alebo ju ukončíte. Dock ustúpi z cesty oknu na celú obrazovku. Kliknutím pravým tlačidlom na tlačidlo aplikácií presuniete dock na iný okraj alebo ho necháte skrývať, kým ukazovateľ nedosiahne jeho okraj. Pozícia je aj pod _Vzhľad > Dock > Pozícia docku_ a príkazy `omarchy dock position left` a `omarchy dock autohide on` oboje nastavia z terminálu. Aplikácie, ktoré máte v docku, sú vyblednuté, kým nebežia.

Nové pracovné priestory a všetky, ktorým ste pomocou `Super + L` nedali vlastné rozloženie, používajú predvolené rozloženie. Zmena predvoleného rozloženia obnoví naň každý pracovný priestor bez okien, zatiaľ čo ten, ktorý na sebe má okná, si ponechá rozloženie, ktoré má. Okno minimalizované do docku sa stále počíta ako okno na pracovnom priestore, ktorý opustilo. Vyberte ho pod _Vzhľad > Rozloženie pracovného priestoru_: Dlaždicové, Posúvacie alebo Plávajúce. Príkaz `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná môžete zoskupovať pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete pohybovať pomocou `Super + Ctrl + Arrow Left/Right` alebo `Super + Alt + 1/2/3/4` a prejsť priamo na zoskupené okno v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Nakoniec môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vyčleňovanie okien

Okno môžete vyčleniť z jeho priradenia k pracovnému priestoru pomocou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje, na ktorýkoľvek pracovný priestor prejdete. Skvelé pre prehrávače videa a podobne.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovný priestor scratchpad

Existuje špeciálny pracovný priestor scratchpad v plnej veľkosti, ktorý sa prekrýva cez ktorýkoľvek pracovný priestor, na ktorom práve ste. K tomu, čo je na ňom, sa dostanete pomocou `Super + S` a okná tam umiestňujete pomocou `Super + Alt + S`.

Dobre funguje pre ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálneho pracovného priestoru.

### Konzola Quake

Napokon je tu konzola Quake v polovičnej výške, ktorá sa spustí zhora cez ktorýkoľvek pracovný priestor, na ktorom práve ste. Prepnete ju pomocou `Super + Grave` a okno tam umiestnite pomocou `Super + Shift + Grave`.

Otvára sa s vaším predvoleným agentom pripraveným na použitie. Kým konzola obsahuje jedno okno, spúšťa sa ako vycentrovaný panel, namiesto toho, aby sa rozprestierala cez obrazovku. Umiestnite na ňu druhú aplikáciu a vráti sa do plnej šírky, takže obe majú priestor sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na iný pracovný priestor niečím ako `Super + Shift + 1`.

### Chvíľu trvá, kým si zvyknete!

Chvíľu trvá, kým si na takúto navigáciu na pracovnej ploche zvyknete, ale keď sa tak stane, bude ťažké vrátiť sa k tradičnému zážitku z pracovnej plochy ovládanej myšou!
