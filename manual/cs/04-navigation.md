# Navigace

Všechno v Omarchy se děje přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když systém poprvé nastartuje, myší samotnou doslova nic nezmůžeš. Můžeš ale stisknout `Super + Space`, čímž odkryješ Omarchy Menu, a odsud už zvládneš skoro všechno.

Omarchy menu ale většinu času ani nemá být hlavním způsobem, jak systém ovládat. Umíme to rychleji! Všechny nejdůležitější aplikace jsou navázané přímo na jednotlivé klávesové zkratky. Terminál spustíš pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkus jedno po druhém a uvidíš kouzlo dlaždicového uspořádání Hyprland v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžeš stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskni `Super + J` znovu a vrátíš je zpět do pozic vedle sebe. Pak v prohlížeči zkus `Super + Shift + Arrow Right` a okna prohoď.

Teď zkus `Super + Shift + T` a spusť monitor aktivity. Ten se objeví jako plovoucí okno. Můžeš ho uspořádat do dlaždic pomocí `Super + T` (a dalším stisknutím ho zase uděláš plovoucím). Teď stiskni `Super + Shift + F` a otevři správce souborů. Budeš mít pěkné uspořádání do čtyř částí:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která chceš mít aktivní, se pohybuješ pomocí `Super + Arrow`. Tím přepneš zaměření a přesuneš kurzor do středu nové aplikace. Na kraji obrazovky to pokračuje na monitor na dané straně.

Když stiskneš `Super + Shift + 2`, přesuneš právě zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune právě zaměřenou aplikaci na druhou pracovní plochu, aniž by na ni přepnulo.)

S více než jedním monitorem má každý monitor své vlastní pracovní plochy 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jsi, a horní lišta každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou právě zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jsi. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jsi, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jsi, na monitor v daném směru, kde získá stejné číslo, pokud je volné. Monitor si své pracovní plochy ponechá, i když ho odpojíš: připojí se k jiné obrazovce, očíslované za těmi, které už má, a když se monitor vrátí, vrátí se pod svými starými čísly.

Když podržíš `Super` a myší klikneš na okno, budeš moct přeuspořádat, kde sedí. Když podržíš `Super` a použiješ pravé tlačítko myši, můžeš oknu volně měnit velikost.

Okno zavřeš pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřeš pomocí `Ctrl + Alt + Delete`).

Můžeš taky přejít na celou obrazovku pomocí `Super + F`, nebo jen na celou šířku (s ponecháním horní lišty) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (skvělé pro YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se jmenuje dwindle. Všechna okna, která otevřeš na jedné pracovní ploše, udržuje neustále viditelná, i když je kvůli tomu musí zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Můžeš se ale taky rozhodnout změnit pracovní plochu na rozložení scrolling, kde jsou okna seřazená vedle sebe až za viditelný okraj displeje. Jednu pracovní plochu na tohle rozložení přepneš pomocí `Super + L`.

Dalším stisknutím `Super + L` se pracovní plocha změní na plovoucí, kde se okna volně překrývají a umisťuješ je sám, a třetí stisknutí ji vrátí na dwindle. `Super + Alt + L` jimi prochází opačným směrem. Okno, které je plovoucí tak jako tak — takové, které jsi vyjmul pomocí `Super + T`, nebo aplikace, která se vždy otevírá plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí k dlaždicovému uspořádání. Horní lišta označuje pracovní plochu, na které jsi, podle jejího rozložení: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutím na tuhle značku rozložení taky přepneš.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a drží. Můžeš si tak nechat pracovní plochu 1 na dwindle na prohlížení a pracovní plochu 2 na scrolling na kód a po restartu se vrátí přesně takhle.

Pokud chceš jako výchozí používat rozložení scrolling, můžeš to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sám je přesouváš a měníš jim velikost. Každé okno dostane titulkový pruh v barvách tvého motivu s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` minimalizuje i zaměřené okno. Minimalizované okno čeká v docku; kliknutím na jeho aplikaci ho přivedeš zpět. Kliknutím na okno ho přivedeš dopředu. Velikost mu změníš z kterékoli hrany nebo rohu. Dvojitým kliknutím na titulkový pruh okno maximalizuješ a přitom ponecháš horní lištu na očích a dalším dvojitým kliknutím získáš zpět jeho starou velikost. Chrome a další prohlížeče založené na Chromium, Disks a Document Viewer titulkový pruh vynechávají a místo něj používají vlastní záhlaví; `Super + Alt + F` je maximalizuje a `Super + M` je minimalizuje.

Plovoucí pracovní plocha taky ukazuje dock s tvými připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, kterou otevře i `Super + Alt + Space` a _Aplikace_ v Omarchy menu. Kliknutím pravým tlačítkem na aplikaci v mřížce, nebo stisknutím `Delete`, ji odinstaluješ. Kliknutím na aplikaci ji otevřeš, nebo přivedeš její okno dopředu; dalším kliknutím procházíš její okna. Files přivede zpět jen okno z pracovní plochy, na které jsi, a jinak otevře nové, a Terminal a Agent vždy spustí další, i když minimalizované okno se vrátí jako první. Kliknutím prostředním tlačítkem otevřeš nové okno. Přetažením ikony podél docku ji přesuneš; přetažením běžící aplikace mezi ostatní ji tam ponecháš. Kliknutím pravým tlačítkem aplikaci v docku ponecháš, vyndáš ji z něj, nebo ji ukončíš. Dock uhne oknu na celou obrazovku. Kliknutím pravým tlačítkem na tlačítko aplikací dock přesuneš na jinou hranu, nebo ho necháš skrývat, dokud ukazatel nedosáhne jeho hrany. Umístění je taky pod _Vzhled > Dock > Umístění docku_ a `omarchy dock position left` a `omarchy dock autohide on` obojí nastaví z terminálu. Aplikace, které si v docku ponecháš, jsou vybledlé, dokud neběží.

Nové pracovní plochy a každá, které jsi pomocí `Super + L` nedal její vlastní rozložení, používají výchozí rozložení. Změna výchozího rozložení na něj resetuje každou pracovní plochu bez oken, zatímco ta s okny si ponechá rozložení, které má. Okno minimalizované do docku se pořád počítá jako okno na pracovní ploše, kterou opustilo. Vyber ho pod _Vzhled > Rozložení pracovní plochy_: Dlaždicové, Posuvné, nebo Plovoucí. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna lze seskupit pomocí `Super + G`. Jakmile jsi ve skupině, každé okno, které spustíš, dokud je aktivní, bude do skupiny patřit. Mezi těmihle seskupenými okny se můžeš pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo `Super + Alt + 1/2/3/4` a přejít přímo na seskupená okna v pořadí.

Okno můžeš ze seskupení vyjmout pomocí `Super + Alt + G`, nebo celou skupinu rozebrat dalším stisknutím `Super + G`. Nakonec můžeš okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vyjímání oken

Okno můžeš vyjmout z jeho přiřazení k pracovní ploše pomocí `Super + O`. Tím ho připneš jako plovoucí okno, které tě následuje na kteroukoli pracovní plochu, na kterou přejdeš. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která překrývá kteroukoli pracovní plochu, na které právě jsi. K tomu, co je na ní, se dostaneš pomocí `Super + S` a okna tam umisťuješ pomocí `Super + Alt + S`.

Hodí se na ovládací prvky nebo terminál, se kterým chceš rychle pracovat, aniž bys opouštěl aktuální pracovní plochu.

### Konzole Quake

Nakonec je tu konzole Quake v poloviční výšce, která se vysune přes kteroukoli pracovní plochu, na které právě jsi. Přepneš ji pomocí `Super + Grave` a okno tam umístíš pomocí `Super + Shift + Grave`.

Otevře se s tvým výchozím agentem připraveným k akci. Dokud konzole drží jediné okno, vysouvá se jako vycentrovaný panel, místo aby se roztáhla přes celou obrazovku. Dej na ni druhou aplikaci a vrátí se na plnou šířku, aby obě měly místo sedět vedle sebe.

Chceš-li okno přesunout pryč ze scratchpadu nebo z konzole, pošli ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to si trochu zvyknout!

Chvilku trvá, než si na takovouhle navigaci po desktopu zvykneš, ale jakmile si zvykneš, bude těžké se vracet k tradičnímu zážitku z desktopu ovládaného myší!
