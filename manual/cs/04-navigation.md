# Navigace

Všechno v Omarchy se děje přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když se systém poprvé spustí, samotnou myší doslova nic nezmůžeš. Můžeš ale stisknout `Super + Space` a zobrazit Omarchy Menu, odkud zvládneš skoro všechno.

Nabídka Omarchy ale většinu času ani nemá být hlavním způsobem ovládání systému. Umíme to rychleji! Všechny nejdůležitější aplikace jsou navázané přímo na jednotlivé klávesové zkratky. Terminál spustíš pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkus jedno po druhém a uvidíš v akci kouzlo dlaždicového uspořádání v Hyprlandu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžeš stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskni `Super + J` znovu a vrátíš je zpět vedle sebe. Pak v prohlížeči zkus `Super + Shift + Arrow Right` a prohodíš okna.

Teď zkus `Super + Shift + T` a spustíš monitor Activity. Objeví se jako plovoucí okno. Můžeš ho uspořádat do dlaždic pomocí `Super + T` (a dalším stisknutím ho zase uděláš plovoucím). Teď stiskni `Super + Shift + F` a otevři správce souborů. Budeš mít pěkné uspořádání do čtyř oken:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která chceš mít aktivní, se pohybuješ pomocí `Super + Arrow`. Tím přepneš fokus a přesuneš kurzor do středu nové aplikace. Na okraji obrazovky pokračuje na monitor na dané straně.

Když stiskneš `Super + Shift + 2`, přesuneš právě zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune právě zaměřenou aplikaci na druhou pracovní plochu, aniž by na ni přepnulo).

S více než jedním monitorem má každý monitor svých vlastních pracovních ploch 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jsi, a horní lišta každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou právě zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jsi. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jsi, na monitor v daném směru, na pracovní plochu, kterou právě zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jsi, na monitor v daném směru, kde získá stejné číslo, pokud je volné. Monitor si své pracovní plochy ponechá, když ho odpojíš: připojí se k jiné obrazovce, očíslované až za těmi, které už má, a když se monitor vrátí, vrátí se pod svými starými čísly.

Když podržíš `Super` a myší klikneš na okno, budeš moct změnit, kde sedí. Když podržíš `Super` a použiješ pravé tlačítko myši, můžeš oknu volně měnit velikost.

Okno zavřeš pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřeš pomocí `Ctrl + Alt + Delete`).

Můžeš také přejít na celou obrazovku pomocí `Super + F`, nebo dokonce jen na celou šířku (s ponecháním horní lišty) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (skvělé pro YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se jmenuje dwindle. Všechna okna, která otevřeš na jedné pracovní ploše, udržuje neustále viditelná, i kdyby je muselo zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Můžeš se ale také rozhodnout změnit pracovní plochu na rozložení scrolling, kde jsou okna seřazená vedle sebe až za viditelný okraj displeje. Jednu pracovní plochu na toto rozložení přepneš pomocí `Super + L`.

Další stisknutí `Super + L` změní pracovní plochu na plovoucí, kde se okna volně překrývají a umisťuješ je sám, a třetí stisknutí ji vrátí na dwindle. `Super + Alt + L` jimi prochází opačným směrem. Okno, které je plovoucí tak jako tak — takové, které jsi vyndal pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, když se pracovní plocha vrátí k dlaždicím. Horní lišta označuje pracovní plochu, na které jsi, jejím rozložením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutí na tuto značku také prochází rozložení a totéž dělá klávesa displeje na laptopech, které ji mají.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a zůstává. Můžeš si tedy nechat pracovní plochu 1 na dwindle pro prohlížení a pracovní plochu 2 na scrolling pro kód a po restartu se vrátí přesně tak.

Pokud chceš rozložení scrolling používat jako výchozí, můžeš to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sám je přesouváš a měníš jejich velikost. Každé okno dostane záhlaví v barvách tvého motivu s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` také minimalizuje zaměřené okno. Minimalizované okno čeká v docku; kliknutím na jeho aplikaci ho vrátíš zpět. Kliknutím na okno ho přeneseš do popředí. Velikost mu změníš z kterékoli hrany nebo rohu. Dvojklikem na záhlaví okno maximalizuješ a přitom ponecháš horní lištu na očích a dalším dvojklikem mu vrátíš starou velikost. Chrome a další prohlížeče založené na Chromiu, Disks a Document Viewer záhlaví vynechávají a místo něj používají vlastní hlavičku; `Super + Alt + F` je maximalizuje a `Super + M` je minimalizuje.

Plovoucí pracovní plocha také ukazuje dock s tvými připnutými aplikacemi, vším, co právě běží, a mřížkou každé aplikace za tlačítkem aplikací, kterou otevírá také `Super + Alt + Space` a _Apps_ v nabídce Omarchy. Kliknutím pravým tlačítkem na aplikaci v mřížce, nebo stisknutím `Delete`, ji odinstaluješ. Kliknutím na aplikaci ji otevřeš, nebo její okno přeneseš do popředí; dalším kliknutím procházíš její okna. Files vrátí jen okno z pracovní plochy, na které jsi, a jinak otevře nové, a Terminal a Agent vždy spustí další, i když minimalizované okno se vrátí jako první. Kliknutí prostředním tlačítkem otevře nové okno. Přetažením ikony podél docku ji přesuneš; přetažením běžící aplikace mezi ostatní ji tam ponecháš. Kliknutím pravým tlačítkem aplikaci v docku ponecháš, odstraníš ji z něj, nebo ji ukončíš. Dock ustoupí oknu přes celou obrazovku. Kliknutím pravým tlačítkem na tlačítko aplikací dock přesuneš k jinému okraji, nebo ho necháš skrývat, dokud ukazatel nedosáhne jeho okraje. Pozice je také pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` obojí nastaví z terminálu. Aplikace, které si necháváš v docku, jsou vybledlé, když neběží.

Nové pracovní plochy a všechny, kterým jsi pomocí `Super + L` nedal vlastní rozložení, používají výchozí rozložení. Změna výchozího nastavení na něj resetuje každou pracovní plochu bez oken, zatímco plocha s okny si zachová rozložení, které má. Okno minimalizované do docku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vybereš ho pod _Appearance > Workspace Layout_: Tiling, Scrolling nebo Floating. Z terminálu ho nastaví `omarchy hyprland workspace layout default scrolling`.

### Seskupování oken

Okna lze seskupit pomocí `Super + G`. Jakmile jsi ve skupině, každé okno, které spustíš, když je aktivní, bude do skupiny patřit. Mezi těmito seskupenými okny se můžeš pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo přímo přejít na seskupená okna v pořadí pomocí `Super + Alt + 1/2/3/4`.

Okno můžeš ze seskupení vyjmout pomocí `Super + Alt + G`, nebo celou skupinu rozebrat dalším stisknutím `Super + G`. Nakonec můžeš okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vyndávání oken

Okno můžeš vyndat z jeho přiřazení k pracovní ploše pomocí `Super + O`. Tím ho připneš jako plovoucí okno, které tě následuje na kteroukoli pracovní plochu, na kterou přejdeš. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která překrývá pracovní plochu, na které právě jsi. K tomu, co na ní je, se dostaneš pomocí `Super + S` a okna tam umisťuješ pomocí `Super + Alt + S`.

Hodí se pro ovládací prvky nebo terminál, se kterými chceš rychle pracovat, aniž bys opustil aktuální pracovní plochu.

### Konzole Quake

Nakonec je tu konzole Quake o poloviční výšce, která sjede přes pracovní plochu, na které právě jsi. Přepínáš ji pomocí `Super + Grave` a okno tam umístíš pomocí `Super + Shift + Grave`.

Při prvním otevření spustí tvého výchozího agenta, nebo tě požádá, abys si jednoho vybral, pokud sis ještě žádného nezvolil. Dokud má konzole jediné okno, sjede jako vycentrovaný panel, místo aby se roztáhla přes obrazovku. Umísti na ni druhou aplikaci a vrátí se na celou šířku, aby obě měly místo sedět vedle sebe.

Chceš-li okno přesunout ze scratchpadu nebo z konzole, pošli ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíli trvá, než si na takovou navigaci po desktopu zvykneš, ale jakmile se to stane, bude těžké vrátit se k tradičnímu desktopovému zážitku ovládanému myší!
