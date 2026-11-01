# Navigace

Všechno v Omarchy se děje přes klávesnici — _VŠECHNO!_ Když se systém poprvé spustí, doslova neuděláte nic jen s myší. Můžete ale stisknout `Super + Space` a zobrazí se nabídka Omarchy, odkud už zvládnete skoro všechno.

Nabídka Omarchy ale většinu času ani nemá být hlavním způsobem, jak systém ovládat. Umíme to rychleji! Všechny nejdůležitější aplikace jsou vázané přímo na jednotlivé klávesové zkratky. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste jedno po druhém a uvidíte kouzlo dlaždicového uspořádání Hyprland v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžete stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskněte `Super + J` znovu a vrátí se do pozic vedle sebe. Pak v prohlížeči zkuste `Super + Shift + Arrow Right` a okna prohoďte.

Teď zkuste `Super + Shift + T` a spusťte monitor aktivity. Zobrazí se jako plovoucí okno. Můžete ho zařadit do dlaždic pomocí `Super + T` (a dalším stisknutím ho zase uvolníte do plovoucího režimu). Teď stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít hezké čtyřdílné uspořádání:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která mají být aktivní, se pohybujete pomocí `Super + Arrow`. Tím přepnete fokus a přesunete kurzor do středu nové aplikace. Na kraji obrazovky pokračuje na monitor na dané straně.

Když stisknete `Super + Shift + 2`, přesunete právě aktivní aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune právě aktivní aplikaci na druhou pracovní plochu, aniž by na ni přepnulo.)

Máte-li více než jeden monitor, má každý monitor vlastní pracovní plochy 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jste, a horní lišta každého monitoru zobrazuje jeho vlastní pracovní plochy i tu, kterou právě zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jste. `Super + Shift + Ctrl + Arrows` přesune okno, ve kterém jste, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jste, na monitor v daném směru, kde získá stejné číslo, je-li volné. Monitor si své pracovní plochy zachová, i když ho odpojíte: připojí se k jiné obrazovce, očíslované za těmi, které už má, a až se monitor vrátí, vrátí se pod svými původními čísly.

Pokud podržíte `Super` a myší kliknete na okno, budete moci změnit, kde se nachází. Pokud podržíte `Super` a použijete pravé tlačítko myši, můžete oknu volně měnit velikost.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřete pomocí `Ctrl + Alt + Delete`).

Můžete také přejít na celou obrazovku pomocí `Super + F`, nebo jen na celou šířku (se zachováním horní lišty) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (ideální na YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se nazývá dwindle. Všechna okna, která otevřete na jedné pracovní ploše, udržuje neustále viditelná, i kdyby je muselo zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Můžete si ale také zvolit, že pracovní plochu přepnete do rozložení scrolling, kde jsou okna seřazená vedle sebe i za viditelným okrajem displeje. Jednu pracovní plochu do tohoto rozložení přepnete pomocí `Super + L`.

Dalším stisknutím `Super + L` pracovní plochu přepnete do plovoucího režimu, kde se okna volně překrývají a umisťujete je sami, a třetí stisknutí ji vrátí do dwindle. `Super + Alt + L` je prochází opačným směrem. Okno, které je plovoucí tak jako tak — takové, které jste vysunuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí k dlaždicím. Horní lišta označuje pracovní plochu, na které jste, jejím rozložením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutím na tuto značku rozložení také cyklicky přepnete.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a zůstává zachovaná. Můžete si tak nechat pracovní plochu 1 na dwindle pro prohlížení a pracovní plochu 2 na scrolling pro kód a po restartu se vrátí právě tak.

Pokud chcete rozložení scrolling používat jako výchozí, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sami je přesouváte a měníte jejich velikost. Každé okno dostane titulkový pruh v barvách vašeho motivu, s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` minimalizuje i aktivní okno. Minimalizované okno čeká v docku; kliknutím na jeho aplikaci ho přivedete zpět. Kliknutím okno přenesete do popředí. Velikost mu změníte z libovolného okraje nebo rohu. Dvojklikem na titulkový pruh okno maximalizujete, přičemž horní lišta zůstane viditelná, a dalším dvojklikem mu vrátíte původní velikost.

Plovoucí pracovní plocha zobrazuje také dock, s vašimi připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, kterou otevře také `Super + Alt + Space` a _Apps_ v nabídce Omarchy. Kliknutím pravým tlačítkem na aplikaci v mřížce, nebo stisknutím `Delete`, ji odinstalujete. Kliknutím na aplikaci ji otevřete, nebo přenesete její okno do popředí; dalším kliknutím procházíte její okna. Kliknutí prostředním tlačítkem otevře nové okno. Přetažením ikony podél docku ji přesunete; přetažením běžící aplikace mezi ostatní ji tam ponecháte. Kliknutím pravým tlačítkem aplikaci v docku ponecháte, odeberete ji z něj nebo ji ukončíte. Dock uhne oknu přes celou obrazovku. Kliknutím pravým tlačítkem na tlačítko aplikací dock přesunete k jinému okraji, nebo ho necháte skrývat, dokud ukazatel nedosáhne jeho okraje. Pozice je také pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` obojí nastaví z terminálu. Aplikace, které si v docku ponecháte, jsou vybledlé, dokud neběží.

Nové pracovní plochy, a všechny, kterým jste pomocí `Super + L` nedali vlastní rozložení, používají výchozí rozložení. Změna výchozího rozložení na něj přepne každou pracovní plochu bez oken, zatímco plocha, která na sobě okna má, si ponechá rozložení, které má. Okno minimalizované do docku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberete ho pod _Appearance > Workspace Layout_: Tiling, Scrolling, nebo Floating. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna lze seskupit pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, dokud je aktivní, bude do skupiny patřit. Mezi těmito seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo `Super + Alt + 1/2/3/4` a přejít přímo na seskupená okna v pořadí.

Okno můžete ze skupiny vyjmout pomocí `Super + Alt + G`, nebo celou skupinu rozložit dalším stisknutím `Super + G`. Nakonec můžete okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vysouvání oken

Okno můžete vysunout z jeho přiřazení k pracovní ploše pomocí `Super + O`. Tím ho připnete jako plovoucí okno, které vás následuje na každou pracovní plochu, na kterou přejdete. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která překrývá pracovní plochu, na které právě jste. K tomu, co je na ní, se dostanete pomocí `Super + S` a okna tam umisťujete pomocí `Super + Alt + S`.

Hodí se na ovládací prvky nebo terminál, se kterým chcete rychle pracovat, aniž byste opustili současnou pracovní plochu.

### Konzole Quake

Nakonec je tu konzole Quake v poloviční výšce, která se vysune přes pracovní plochu, na které právě jste. Přepnete ji pomocí `Super + Grave` a okno tam umístíte pomocí `Super + Shift + Grave`.

Otevře se s vaším výchozím agentem připraveným k práci. Dokud konzole obsahuje jediné okno, vysouvá se jako vycentrovaný panel, místo aby zabírala celou obrazovku. Přidejte na ni druhou aplikaci a vrátí se na plnou šířku, aby měly obě místo sedět vedle sebe.

Chcete-li okno přesunout pryč ze scratchpadu nebo z konzole, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíli trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile se to stane, bude těžké se vrátit k tradičnímu desktopovému prostředí ovládanému myší!
