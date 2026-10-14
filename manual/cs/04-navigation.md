# Navigace

Vše v Omarchy se děje přes klávesnici — _VŠECHNO!_ Když systém poprvé nastartuje, doslova neuděláte nic jen s myší. Ale můžete stisknout `Super + Space` a odhalit menu Omarchy a odtud dělat skoro všechno.

Ale menu Omarchy většinu času ani nemá být hlavním způsobem ovládání systému. Umíme to rychleji! Všechny nejdůležitější aplikace jsou navázané přímo na jednotlivé klávesové zkratky. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste to jedno po druhém a uvidíte kouzlo dlaždicování Hyprland v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžete stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskněte `Super + J` znovu a vrátíte je zpět do pozic vedle sebe. Pak zkuste `Super + Shift + Arrow Right`, zatímco jste na prohlížeči, a prohoďte okna.

Teď zkuste `Super + Ctrl + T` a spusťte monitor aktivity. Ten se objeví jako plovoucí okno. Můžete ho vydláždit pomocí `Super + T` (a stisknout to znovu, aby bylo zase plovoucí). Teď stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít pěkné čtyřdílné uspořádání:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která chcete mít aktivní, se pohybujete pomocí `Super + Arrow`. Tím přepnete zaměření a přesunete kurzor do středu nové aplikace.

Pokud stisknete `Super + Shift + 2`, přesunete právě zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune právě zaměřenou aplikaci na druhou pracovní plochu, aniž by na ni přepnulo).

Pokud podržíte `Super` a myší kliknete na okno, budete moct přeuspořádat, kde sedí. Pokud podržíte `Super` a použijete pravé tlačítko myši, můžete oknu libovolně měnit velikost.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřete pomocí `Ctrl + Alt + Delete`).

Můžete také přejít na celou obrazovku pomocí `Super + F` nebo dokonce jen na celou šířku (při zachování horní lišty) pomocí `Super + Alt + F` nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (dobré pro YouTube!).

### Rozvržení dwindle vs. scrolling

Výchozí rozvržení Omarchy se jmenuje dwindle. Udržuje všechna okna, která otevřete na jediné pracovní ploše, neustále viditelná, i když je kvůli tomu musí zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale můžete se také rozhodnout změnit pracovní plochu na rozvržení scrolling, kde jsou okna seřazená vedle sebe, za viditelným okrajem displeje. Jednotlivou pracovní plochu do tohoto rozvržení přepnete pomocí `Super + L`.

Opětovné stisknutí `Super + L` změní pracovní plochu na plovoucí, kde se okna volně překrývají a umisťujete je sami, a třetí stisknutí ji vrátí zpět na dwindle. `Super + Alt + L` jimi prochází opačným směrem. Okno, které je stejně plovoucí — takové, které jste vysunuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí zpět k dlaždicování. Horní lišta označuje pracovní plochu, na které jste, jejím rozvržením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutí na tuto značku rozvržení také přepíná.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a drží. Takže si můžete nechat pracovní plochu 1 na dwindle pro prohlížení a pracovní plochu 2 na scrolling pro kód a po restartu se tak vrátí.

Pokud si přejete používat rozvržení scrolling jako výchozí, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sami je přesouváte a měníte jejich velikost. Každé okno dostane titulkový pruh v barvách vašeho motivu s tlačítky pro minimalizaci, maximalizaci a zavření. Zaměřené okno minimalizuje také `Super + M`. Minimalizované okno čeká v docku; klikněte na jeho aplikaci a přivedete ho zpět. Klikněte na okno a přivedete ho dopředu. Změňte jeho velikost z kteréhokoli okraje nebo rohu. Poklepejte na titulkový pruh a maximalizujete okno při zachování horní lišty na očích, a znovu a dostanete zpět jeho starou velikost.

Plovoucí pracovní plocha také ukazuje dock s vašimi připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, které otevírá také `Super + Alt + Space` a _Apps_ v menu Omarchy. Klikněte na aplikaci v mřížce pravým tlačítkem, nebo stiskněte `Delete`, a odinstalujete ji. Klikněte na aplikaci a otevřete ji, nebo přivedete její okno dopředu; klikněte znovu a procházíte jejími okny. Kliknutí prostředním tlačítkem otevře nové okno. Táhněte ikonu podél docku a přesunete ji; přetažení běžící aplikace mezi ostatní ji tam nechá. Klikněte pravým tlačítkem a ponecháte aplikaci v docku, odstraníte ji z něj, nebo ji ukončíte. Dock se klidí z cesty oknu na celou obrazovku. Klikněte pravým tlačítkem na tlačítko aplikací a přesunete dock na jiný okraj, nebo ho necháte skrývat, dokud ukazatel nedosáhne jeho okraje. Pozice je také pod _Trigger > Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` nastaví obojí z terminálu. Aplikace, které si necháte v docku, jsou vybledlé, zatímco neběží.

Nové pracovní plochy a všechny, kterým jste nedali vlastní rozvržení pomocí `Super + L`, používají výchozí rozvržení. Změna výchozího nastavení na něj resetuje každou pracovní plochu bez oken, zatímco ta, která na sobě okna má, si ponechá rozvržení, které má. Okno minimalizované do docku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberte ho pod _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling, nebo Floating. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna můžete seskupovat pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, zatímco je to aktivní, bude patřit do skupiny. Mezi těmito seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo `Super + Alt + 1/2/3/4` a přejít přímo na seskupené okno v pořadí.

Okno můžete ze seskupení přesunout ven pomocí `Super + Alt + G` nebo rozebrat celou skupinu opětovným stisknutím `Super + G`. Nakonec můžete okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vysouvání oken

Okno můžete vysunout z jeho přidělení na pracovní plochu pomocí `Super + O`. Tím ho připnete jako plovoucí okno, které vás následuje na kteroukoli pracovní plochu, na kterou přejdete. Skvělé pro přehrávače videa a podobné.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Nakonec je tu speciální pracovní plocha scratchpad, která se vysune dolů přes kteroukoli pracovní plochu, na které jste právě teď, hodně podobně jako konzole Quake. Přepínáte ji pomocí `Super + Grave` nebo `Super + S` a okno tam umístíte pomocí `Super + Shift + Grave` nebo `Super + Alt + S`.

Zvlášť dobře funguje pro terminál, ve kterém běží agent, nebo pro ovládací prvky, se kterými chcete rychle pracovat, aniž byste opouštěli aktuální pracovní plochu. Chcete-li okno ze scratchpadu přesunout pryč, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

Zatímco scratchpad drží jediné okno, vysune se dolů jako vycentrovaný panel, namísto aby přesahoval celou obrazovku. Dejte na něj druhou aplikaci a vrátí se zpět na celou šířku, aby ty dvě měly místo sedět vedle sebe.

### Chce to chvíli zvyku!

Chvíli trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile si zvyknete, bude těžké vrátit se zpět k tradičnímu zážitku z desktopu ovládaného myší!
