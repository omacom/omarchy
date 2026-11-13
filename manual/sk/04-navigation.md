# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _ÚPLNE VŠETKO!_ Keď sa systém prvýkrát spustí, myšou samotnou doslova nič nespravíte. Môžete však stlačiť `Super + Space` a zobraziť tak Omarchy Menu a odtiaľ už spravíte takmer všetko.

Ale ponuka Omarchy ani nemá byť hlavným spôsobom ovládania systému po väčšinu času. Dokážeme to aj rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte pomocou `Super + Return` a prehliadač pomocou `Super + Shift + Return`. Skúste urobiť jedno po druhom a uvidíte kúzlo dlaždicového usporiadania v Hyprland v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a poskladať ich na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova stlačte `Super + J` a vrátia sa do polohy vedľa seba. Potom v prehliadači skúste `Super + Shift + Arrow Right` a okná si vymenia miesta.

Teraz skúste `Super + Shift + T` a spustite monitor aktivity. Ten sa zobrazí ako plávajúce okno. Môžete ho usporiadať do dlaždíc pomocou `Super + T` (a opätovným stlačením ho znova spravíte plávajúcim). Teraz stlačte `Super + Shift + F` a otvorte správcu súborov. Budete mať pekné štvorité usporiadanie:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, prechádzate pomocou `Super + Arrow`. Tým sa prepne zameranie a kurzor sa presunie do stredu novej aplikácie. Na okraji obrazovky pokračuje na monitor na tej strane.

Ak stlačíte `Super + Shift + 2`, presuniete aktuálne zameranú aplikáciu na druhú pracovnú plochu. `Super + Shift + 1` ju presunie späť. (A `Super + Shift + Alt + 2` presunie aktuálne zameranú aplikáciu na druhú pracovnú plochu bez toho, aby ste na ňu prepli).

Pri viac ako jednom monitore má každý monitor svoje vlastné pracovné plochy 1 až 10. `Super + 2` prejde na druhú pracovnú plochu monitora, na ktorom ste, a horný panel každého monitora zobrazuje jeho vlastné pracovné plochy a tú, ktorú práve zobrazuje. `Super + Tab` cykluje pracovnými plochami na monitore, na ktorom ste. `Super + Shift + Ctrl + Arrows` presunie okno, na ktorom ste, na monitor v danom smere, na pracovnú plochu, ktorú zobrazuje, a `Super + Shift + Alt + Arrows` presunie pracovnú plochu, na ktorej ste, na monitor v danom smere, kde prevezme rovnaké číslo, ak je voľné. Monitor si svoje pracovné plochy zachová, aj keď ho odpojíte: pripoja sa k inej obrazovke, očíslované až po tých, ktoré už má, a keď sa monitor vráti, vrátia sa pod svoje staré čísla.

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť jeho umiestnenie. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte pomocou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte pomocou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku pomocou `Super + F` alebo aj len na celú šírku (pri zachovaní horného panela) pomocou `Super + Alt + F`, alebo na celú obrazovku v rámci okna pomocou `Super + Ctrl + F` (vhodné pre YouTube!).

### Rozloženie dwindle vs. rolovacie rozloženie

Predvolené rozloženie v Omarchy sa volá dwindle. Všetky okná, ktoré otvoríte na jednej pracovnej ploche, udržiava neustále viditeľné, aj keď ich na to musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však tiež rozhodnúť zmeniť pracovnú plochu na rolovacie rozloženie, v ktorom sú okná zoradené vedľa seba až za viditeľný okraj displeja. Jednu pracovnú plochu na toto rozloženie prepnete pomocou `Super + L`.

Ďalším stlačením `Super + L` sa pracovná plocha prepne na plávajúcu, kde sa okná voľne prekrývajú a umiestňujete ich sami, a tretím stlačením sa vráti na dwindle. `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — okno, ktoré ste vytiahli pomocou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce, aj keď sa pracovná plocha vráti k dlaždicovému usporiadaniu. Horný panel označuje pracovnú plochu, na ktorej ste, jej rozložením: štvorcom pre dwindle, kruhom pre rolovacie a trojuholníkom pre plávajúce. Kliknutím na túto značku sa rozloženie tiež prepína.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Voľba je pre každú pracovnú plochu samostatná a zostáva zachovaná. Pracovnú plochu 1 si tak môžete nechať na dwindle na prehliadanie a pracovnú plochu 2 na rolovacom rozložení na kód a po reštarte sa vrátia presne tak.

Ak chcete rolovacie rozloženie používať ako predvolené, môžete to nastaviť v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné plochy

Plávajúca pracovná plocha funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami ich presúvate a meníte ich veľkosť. Každé okno dostane titulkový pruh vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. `Super + M` minimalizuje aj zamerané okno. Minimalizované okno čaká v doku; kliknutím na jeho aplikáciu ho prinesiete späť. Kliknutím na okno ho prenesiete do popredia. Jeho veľkosť zmeníte z ktoréhokoľvek okraja alebo rohu. Dvojitým kliknutím na titulkový pruh okno maximalizujete pri zachovaní horného panela na dohľad a ďalším dvojitým kliknutím mu vrátite starú veľkosť. Chrome a ostatné prehliadače založené na Chromium, Disks a Document Viewer titulkový pruh vynechávajú a namiesto neho používajú vlastné záhlavie; `Super + Alt + F` ich maximalizuje a `Super + M` ich minimalizuje.

Plávajúca pracovná plocha zobrazuje aj dok s vašimi pripnutými aplikáciami, všetkým, čo práve beží, a mriežkou všetkých aplikácií za tlačidlom aplikácií, ktorú otvára aj `Super + Alt + Space` a _Aplikácie_ v ponuke Omarchy. Kliknite pravým tlačidlom na aplikáciu v mriežke alebo stlačte `Delete`, ak ju chcete odinštalovať. Kliknutím na aplikáciu ju otvoríte alebo prenesiete jej okno do popredia; ďalším kliknutím cyklujete jej oknami. Kliknutie stredným tlačidlom otvorí nové okno. Potiahnutím ikony pozdĺž doku ju presuniete; potiahnutím bežiacej aplikácie medzi ostatné ju tam ponecháte. Kliknite pravým tlačidlom, ak chcete aplikáciu v doku ponechať, odstrániť ju z neho alebo ju ukončiť. Dok ustúpi z cesty oknu na celú obrazovku. Kliknutím pravým tlačidlom na tlačidlo aplikácií presuniete dok na iný okraj alebo ho necháte skrývať, kým ukazovateľ nedosiahne jeho okraj. Pozícia je aj pod _Vzhľad > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` nastavia oboje z terminálu. Aplikácie, ktoré máte v doku, sú vyblednuté, kým nebežia.

Nové pracovné plochy a všetky, ktorým ste pomocou `Super + L` nedali vlastné rozloženie, používajú predvolené rozloženie. Zmena predvoleného nastavenia naň resetuje každú pracovnú plochu bez okien, zatiaľ čo plocha s oknami si zachová rozloženie, ktoré má. Okno minimalizované do doku sa stále počíta ako okno na pracovnej ploche, z ktorej odišlo. Vyberiete ho pod _Vzhľad > Workspace Layout_: Dlaždicové, Rolovacie alebo Plávajúce. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Zoskupovanie okien

Okná môžete zoskupiť pomocou `Super + G`. Keď ste v skupine, každé okno, ktoré spustíte, kým je aktívna, bude patriť do skupiny. Medzi týmito zoskupenými oknami sa môžete pohybovať pomocou `Super + Ctrl + Arrow Left/Right` alebo pomocou `Super + Alt + 1/2/3/4` prejsť priamo na zoskupené okná v poradí.

Okno môžete zo zoskupenia presunúť von pomocou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Nakoniec môžete okná mimo skupiny presunúť do nej pomocou `Super + Alt + Arrows`.

### Vyťahovanie okien

Okno môžete pomocou `Super + O` vytiahnuť z jeho priradenia k pracovnej ploche. Tým sa pripne ako plávajúce okno, ktoré vás nasleduje na ktorúkoľvek pracovnú plochu, na ktorú prejdete. Skvelé pre videoprehrávače a podobne.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovná plocha scratchpad

Existuje špeciálna pracovná plocha scratchpad v plnej veľkosti, ktorá prekrýva ktorúkoľvek pracovnú plochu, na ktorej práve ste. K tomu, čo je na nej, sa dostanete pomocou `Super + S` a okná tam umiestnite pomocou `Super + Alt + S`.

Dobre funguje na ovládacie prvky alebo terminál, s ktorým chcete rýchlo pracovať bez opustenia aktuálnej pracovnej plochy.

### Konzola Quake

Nakoniec je tu konzola Quake s polovičnou výškou, ktorá sa vysunie cez ktorúkoľvek pracovnú plochu, na ktorej práve ste. Prepnete ju pomocou `Super + Grave` a okno tam umiestnite pomocou `Super + Shift + Grave`.

Otvorí sa s vaším predvoleným agentom pripraveným na použitie. Kým konzola obsahuje jedno okno, vysunie sa ako vycentrovaný panel namiesto toho, aby zaberala celú šírku obrazovky. Umiestnite na ňu druhú aplikáciu a vráti sa na plnú šírku, aby mali obe miesto sedieť vedľa seba.

Ak chcete okno presunúť preč zo scratchpadu alebo z konzoly, pošlite ho priamo na inú pracovnú plochu napríklad pomocou `Super + Shift + 1`.

### Chvíľu trvá, kým si zvyknete!

Chvíľu trvá, kým si na takúto navigáciu po pracovnej ploche zvyknete, ale keď si zvyknete, bude ťažké vrátiť sa k tradičnému používaniu pracovnej plochy ovládanej myšou!
