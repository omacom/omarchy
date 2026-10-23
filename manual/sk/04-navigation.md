# Navigácia

Všetko v Omarchy sa deje cez klávesnicu — _VŠETKO!_ Keď sa systém prvýkrát spustí, len s myšou doslova neurobíte nič. Môžete však stlačiť `Super + Space` a zobraziť tak Omarchy Menu a odtiaľ dokážete robiť takmer všetko.

Ale Omarchy menu ani nemá byť hlavným spôsobom ovládania systému po väčšinu času. Vieme to robiť rýchlejšie! Všetky najdôležitejšie aplikácie sú naviazané priamo na jednotlivé klávesové skratky. Terminál spustíte skratkou `Super + Return` a prehliadač skratkou `Super + Shift + Return`. Skúste ich spustiť jednu po druhej a uvidíte kúzlo dlaždicového usporiadania v Hyprland v akcii:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom môžete stlačiť `Super + J` a naskladať ich na seba namiesto vedľa seba:

 ![navigation-stacked](images/navigation-stacked.webp)

Opätovným stlačením `Super + J` ich vrátite do polohy vedľa seba. Potom skúste v prehliadači stlačiť `Super + Shift + Arrow Right` a okná sa vymenia.

Teraz skúste `Super + Ctrl + T` a spustite monitor aktivity. Ten sa zobrazí ako plávajúce okno. Môžete ho usporiadať do dlaždíc skratkou `Super + T` (a opätovným stlačením z neho znova urobiť plávajúce okno). Teraz stlačte `Super + Shift + F` a otvorte správcu súborov. Získate prehľadné usporiadanie do štyroch okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Medzi oknami, ktoré chcete mať aktívne, sa presúvate skratkou `Super + Arrow`. Tá prepne zameranie a presunie kurzor do stredu novej aplikácie.

Ak stlačíte `Super + Shift + 2`, presuniete aktuálne zameranú aplikáciu na druhú pracovnú plochu. Skratkou `Super + Shift + 1` ju presuniete späť. (A `Super + Shift + Alt + 2` presunie aktuálne zameranú aplikáciu na druhú pracovnú plochu bez toho, aby na ňu prešlo).

Ak podržíte `Super` a myšou kliknete na okno, budete môcť zmeniť jeho umiestnenie. Ak podržíte `Super` a použijete pravé tlačidlo myši, môžete voľne meniť veľkosť okna.

Okno zatvoríte skratkou `Super + W` alebo `Super + Q` (a všetky okná zatvoríte skratkou `Ctrl + Alt + Delete`).

Môžete tiež prejsť na celú obrazovku skratkou `Super + F`, alebo dokonca len na celú šírku (pri zachovaní horného panela) skratkou `Super + Alt + F`, prípadne na celú obrazovku v rámci okna skratkou `Super + Ctrl + F` (vhodné pre YouTube!).

### Rozloženie dwindle vs. rolujúce rozloženie

Predvolené rozloženie v Omarchy sa nazýva dwindle. Všetky okná, ktoré otvoríte na jednej pracovnej ploche, zostávajú neustále viditeľné, aj keď ich musí zmenšiť.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Môžete sa však rozhodnúť zmeniť pracovnú plochu na rolujúce rozloženie, v ktorom sú okná zoradené vedľa seba až za viditeľný okraj displeja. Jednu pracovnú plochu do tohto rozloženia prepnete skratkou `Super + L`.

Opätovným stlačením `Super + L` sa pracovná plocha zmení na plávajúcu, kde sa okná voľne prekrývajú a umiestňujete ich sami, a tretím stlačením sa vráti do rozloženia dwindle. Skratka `Super + Alt + L` nimi prechádza opačným smerom. Okno, ktoré je aj tak plávajúce — také, ktoré ste vytiahli skratkou `Super + T`, alebo aplikácia, ktorá sa vždy otvára ako plávajúca — zostane plávajúce aj vtedy, keď sa pracovná plocha vráti do dlaždicového usporiadania. Horný panel označuje pracovnú plochu, na ktorej sa nachádzate, jej rozložením: štvorcom pre dwindle, kruhom pre rolujúce a trojuholníkom pre plávajúce. Kliknutím na túto značku sa rozloženie tiež prepína.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Voľba platí pre každú pracovnú plochu osobitne a zostáva zachovaná. Takže pracovnú plochu 1 môžete mať v rozložení dwindle na prehliadanie a pracovnú plochu 2 v rolujúcom rozložení na kód a po reštarte sa vrátia presne tak.

Ak chcete rolujúce rozloženie používať ako predvolené, môžete to nastaviť v súbore `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plávajúce pracovné plochy

Plávajúca pracovná plocha funguje ako tradičná pracovná plocha: okná sa prekrývajú a sami ich presúvate a meníte ich veľkosť. Každé okno dostane záhlavie vo farbách vašej témy s tlačidlami na minimalizáciu, maximalizáciu a zatvorenie. Skratkou `Super + M` minimalizujete aj zamerané okno. Minimalizované okno čaká v docku; kliknutím na jeho aplikáciu ho privediete späť. Kliknutím na okno ho prenesiete do popredia. Jeho veľkosť zmeníte z ktoréhokoľvek okraja alebo rohu. Dvojitým kliknutím na záhlavie okno maximalizujete, pričom horný panel zostane viditeľný, a opätovným dvojitým kliknutím mu vrátite pôvodnú veľkosť.

Plávajúca pracovná plocha zobrazuje aj dock s pripnutými aplikáciami, so všetkým, čo práve beží, a s mriežkou všetkých aplikácií za tlačidlom aplikácií, ktorú otvára aj skratka `Super + Alt + Space` a položka _Apps_ v Omarchy menu. Kliknutím pravým tlačidlom myši na aplikáciu v mriežke, alebo stlačením `Delete`, ju odinštalujete. Kliknutím na aplikáciu ju otvoríte, alebo prenesiete jej okno do popredia; opätovným kliknutím prechádzate jej oknami. Kliknutím stredným tlačidlom otvoríte nové okno. Potiahnutím ikony pozdĺž docku ju presuniete; potiahnutím bežiacej aplikácie medzi ostatné ju tam ponecháte. Kliknutím pravým tlačidlom myši môžete aplikáciu ponechať v docku, odstrániť ju z neho alebo ju ukončiť. Dock ustúpi oknu na celú obrazovku. Kliknutím pravým tlačidlom myši na tlačidlo aplikácií presuniete dock na iný okraj, alebo ho necháte skrývať, kým ukazovateľ nedosiahne jeho okraj. Pozícia sa nachádza aj pod položkou _Trigger > Appearance > Dock > Dock Position_ a príkazy `omarchy dock position left` a `omarchy dock autohide on` nastavia obe možnosti z terminálu. Aplikácie, ktoré ponecháte v docku, sú vyblednuté, kým nebežia.

Nové pracovné plochy, a všetky, ktorým ste skratkou `Super + L` nedali vlastné rozloženie, používajú predvolené rozloženie. Zmenou predvoleného rozloženia sa naň nastavia všetky pracovné plochy bez okien, zatiaľ čo pracovná plocha s oknami si ponechá rozloženie, ktoré má. Okno minimalizované do docku sa stále počíta ako okno na pracovnej ploche, z ktorej odišlo. Vyberte si ho pod položkou _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling alebo Floating. Z terminálu ho nastaví príkaz `omarchy-hyprland-workspace-layout-default scrolling`.

### Zoskupovanie okien

Okná môžete zoskupovať skratkou `Super + G`. Keď ste v skupine, každé okno, ktoré počas jej aktívnosti spustíte, bude patriť do tejto skupiny. Medzi týmito zoskupenými oknami sa môžete presúvať skratkami `Super + Ctrl + Arrow Left/Right` alebo `Super + Alt + 1/2/3/4`, čím prejdete priamo na zoskupené okno v poradí.

Okno môžete zo skupiny vybrať skratkou `Super + Alt + G` alebo celú skupinu rozobrať opätovným stlačením `Super + G`. Napokon môžete okná mimo skupiny presunúť do nej skratkou `Super + Alt + Arrows`.

### Vyťahovanie okien

Okno môžete vytiahnuť z jeho pridelenia na pracovnej ploche skratkou `Super + O`. Tým ho pripnete ako plávajúce okno, ktoré vás nasleduje na ktorúkoľvek pracovnú plochu, na ktorú prejdete. Skvelé pre prehrávače videa a podobne.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovná plocha scratchpad

Napokon je tu špeciálna pracovná plocha scratchpad, ktorá sa vysunie cez ktorúkoľvek pracovnú plochu, na ktorej sa práve nachádzate, veľmi podobne ako konzola v hre Quake. Prepínate ju skratkou `Super + Grave` alebo `Super + S` a okno tam umiestnite skratkou `Super + Shift + Grave` alebo `Super + Alt + S`.

Obzvlášť dobre sa hodí pre terminál, v ktorom beží agent, alebo pre ovládacie prvky, s ktorými chcete rýchlo pracovať bez opustenia aktuálnej pracovnej plochy. Ak chcete okno zo scratchpadu presunúť preč, pošlite ho priamo na inú pracovnú plochu napríklad skratkou `Super + Shift + 1`.

Kým scratchpad obsahuje jediné okno, vysunie sa ako vycentrovaný panel namiesto toho, aby sa roztiahol cez celú obrazovku. Ak naň umiestnite druhú aplikáciu, vráti sa na celú šírku, aby mali obe miesto vedľa seba.

### Treba si na to zvyknúť!

Chvíľu trvá, kým si zvyknete takto sa pohybovať po svojej pracovnej ploche, ale keď si zvyknete, bude ťažké vrátiť sa k tradičnej pracovnej ploche ovládanej myšou!
