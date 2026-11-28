# Navigace

Všechno v Omarchy se děje přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když se systém poprvé spustí, samotnou myší doslova nic nezmůžete. Můžete ale stisknout `Super + Space`, čímž zobrazíte Omarchy Menu, a odtud můžete dělat skoro všechno.

Omarchy menu ale většinu času ani nemá být hlavním způsobem ovládání systému. Zvládneme to rychleji! Všechny nejdůležitější aplikace jsou svázané přímo s jednotlivými klávesovými zkratkami. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste to jedno po druhém a uvidíte kouzlo dlaždic v Hyprland v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžete stisknout `Super + J` a poskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskněte `Super + J` znovu a vrátíte je zpět do pozic vedle sebe. Poté zkuste v prohlížeči `Super + Shift + Arrow Right`, čímž okna prohodíte.

Teď zkuste `Super + Shift + T` pro spuštění monitoru Activity. Ten se objeví jako plovoucí okno. Můžete ho převést na dlaždici pomocí `Super + T` (a dalším stisknutím ho zase uděláte plovoucím). Teď stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít úhledné rozložení na čtyři části:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, které chcete mít aktivní, se pohybujete pomocí `Super + Arrow`. Tím se přepne aktivní okno a kurzor se přesune do středu nové aplikace. Na okraji obrazovky pokračuje na monitor na dané straně.

Když stisknete `Super + Shift + 2`, přesunete aktuálně aktivní aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune aktuálně aktivní aplikaci na druhou pracovní plochu, aniž byste na ni přepnuli).

Při více než jednom monitoru má každý monitor své vlastní pracovní plochy 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jste, a horní lišta každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou právě zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jste. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jste, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jste, na monitor v daném směru, kde převezme stejné číslo, pokud je volné. Monitor si své pracovní plochy zachová, když ho odpojíte: připojí se k jiné obrazovce, očíslované za těmi, které už tato obrazovka má, a po návratu monitoru se vrátí pod svá původní čísla.

Když podržíte `Super` a myší kliknete na okno, budete moci změnit, kde se nachází. Když podržíte `Super` a použijete pravé tlačítko myši, můžete volně měnit velikost okna.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna pomocí `Ctrl + Alt + Delete`).

Můžete také přejít na celou obrazovku pomocí `Super + F` nebo jen na celou šířku (se zachováním horní lišty) pomocí `Super + Alt + F` nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (hodí se na YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se jmenuje dwindle. Všechna okna, která otevřete na jedné pracovní ploše, nechává po celou dobu viditelná, i kdyby je kvůli tomu muselo zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pracovní plochu ale můžete přepnout i do posuvného rozložení scrolling, kde jsou okna seřazená vedle sebe až za viditelný okraj displeje. Jednu pracovní plochu do tohoto rozložení přepnete pomocí `Super + L`.

Dalším stisknutím `Super + L` pracovní plochu přepnete na plovoucí, kde se okna volně překrývají a umisťujete si je sami, a třetím stisknutím ji vrátíte do dwindle. `Super + Alt + L` je prochází opačným směrem. Okno, které je plovoucí tak jako tak — takové, které jste vysunuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí k dlaždicím. Horní lišta označuje pracovní plochu, na které jste, jejím rozložením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutím na tuto značku rozložení také přepnete, a stejně tak klávesou pro displej na notebooku, pokud takovou má.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Tato volba je pro každou pracovní plochu zvlášť a zůstává zachovaná. Můžete si tak nechat pracovní plochu 1 na dwindle pro prohlížení webu a pracovní plochu 2 na scrolling pro kód a po restartu se vrátí přesně tak.

Pokud chcete jako výchozí používat posuvné rozložení scrolling, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sami si je přesouváte a měníte jejich velikost. Každé okno dostane záhlaví v barvách vašeho motivu s tlačítky pro minimalizaci, maximalizaci a zavření. Pomocí `Super + M` také minimalizujete aktivní okno. Minimalizované okno čeká v doku; kliknutím na jeho aplikaci ho přivedete zpět. Kliknutím na okno ho přenesete do popředí. Jeho velikost změníte z libovolné hrany nebo rohu. Dvojklikem na záhlaví okno maximalizujete tak, aby horní lišta zůstala vidět, a dalším dvojklikem mu vrátíte původní velikost. Chrome a další prohlížeče založené na Chromium, Disks a Document Viewer záhlaví vynechávají a místo něj používají vlastní hlavičku; `Super + Alt + F` je maximalizuje a `Super + M` je minimalizuje.

Plovoucí pracovní plocha také zobrazuje dok s vašimi připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, kterou otevírá také `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknutím pravým tlačítkem na aplikaci v mřížce, nebo stisknutím `Delete`, ji odinstalujete. Kliknutím na aplikaci ji otevřete nebo přenesete její okno do popředí; dalším kliknutím procházíte její okna. Files přivede zpět pouze okno z pracovní plochy, na které jste, a jinak otevře nové, a Terminal a Agent vždy spustí další, i když se nejprve vrátí minimalizované okno. Kliknutím prostředním tlačítkem se otevře nové okno. Přetažením ikony podél doku ji přesunete; přetažením běžící aplikace mezi ostatní ji tam ponecháte. Kliknutím pravým tlačítkem aplikaci v doku ponecháte, odeberete ji z něj nebo ji ukončíte. Dok uhne z cesty oknu na celou obrazovku. Kliknutím pravým tlačítkem na tlačítko aplikací dok přesunete k jiné hraně nebo ho necháte skrývat, dokud ukazatel nedorazí k jeho hraně. Pozice je také pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` obě nastavení provedou z terminálu. Aplikace, které si v doku necháte, jsou vybledlé, když neběží.

Nové pracovní plochy a všechny, kterým jste pomocí `Super + L` nedali vlastní rozložení, používají výchozí rozložení. Změna výchozího rozložení na něj resetuje každou pracovní plochu bez oken, zatímco ta s okny si zachová rozložení, které má. Okno minimalizované do doku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberete ho pod _Appearance > Workspace Layout_: Tiling, Scrolling nebo Floating. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna můžete seskupit pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, když je aktivní, bude patřit do skupiny. Mezi těmito seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo přímo přejít na seskupená okna v pořadí pomocí `Super + Alt + 1/2/3/4`.

Okno můžete ze seskupení vyjmout pomocí `Super + Alt + G` nebo celou skupinu rozložit dalším stisknutím `Super + G`. Nakonec můžete okna mimo skupinu do ní přesunout pomocí `Super + Alt + Arrows`.

### Vysouvání oken

Okno můžete vysunout z jeho přiřazení k pracovní ploše pomocí `Super + O`. Tím ho připnete jako plovoucí okno, které vás následuje na jakoukoli pracovní plochu, na kterou přejdete. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která překryje jakoukoli pracovní plochu, na které právě jste. K tomu, co je na ní, se dostanete pomocí `Super + S` a okna tam umisťujete pomocí `Super + Alt + S`.

Dobře se hodí pro ovládací prvky nebo terminál, se kterým chcete rychle pracovat, aniž byste opustili aktuální pracovní plochu.

### Konzole Quake

Nakonec tu je konzole Quake o poloviční výšce, která se vysune přes jakoukoli pracovní plochu, na které právě jste. Přepnete ji pomocí `Super + the key above Tab` (na americkém rozložení grave) a okno tam umístíte pomocí `Super + Shift + the key above Tab`.

Při prvním otevření spustí vašeho výchozího agenta, nebo vás vyzve, abyste si jednoho vybrali, pokud jste si ještě žádného nezvolili. Dokud konzole obsahuje jediné okno, vysouvá se jako vycentrovaný panel, místo aby zabírala celou šířku obrazovky. Dejte na ni druhou aplikaci a vrátí se do plné šířky, aby obě měly místo vedle sebe.

Chcete-li okno přesunout ze scratchpadu nebo z konzole, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíli trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile si zvyknete, bude těžké se vracet k tradičnímu desktopu ovládanému myší!
