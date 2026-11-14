# Navigace

Všechno v Omarchy se děje přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když systém poprvé nastartuje, doslova neuděláte nic jen s myší. Ale můžete stisknout `Super + Space` a zobrazit Omarchy Menu a odtud uděláte skoro všechno.

Ale Omarchy menu ani nemá být většinu času hlavním způsobem ovládání systému. Umíme to rychleji! Všechny nejdůležitější aplikace jsou navázané přímo na jednotlivé klávesové zkratky. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste jedno po druhém a uvidíte kouzlo dlaždicového uspořádání v Hyprland v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžete stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskněte `Super + J` znovu a vrátíte je do pozic vedle sebe. Pak v prohlížeči zkuste `Super + Shift + Arrow Right` a okna prohoďte.

Teď zkuste `Super + Shift + T` a spusťte monitor aktivity. Ten se zobrazí jako plovoucí okno. Můžete ho přepnout do dlaždicového uspořádání pomocí `Super + T` (a dalším stisknutím ho zase vrátit do plovoucího). Teď stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít hezké uspořádání na čtyři části:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která chcete mít aktivní, se pohybujete pomocí `Super + Arrow`. Tím přepnete zaměření a přesunete kurzor do středu nové aplikace. Na okraji obrazovky to pokračuje na monitor na té straně.

Když stisknete `Super + Shift + 2`, přesunete právě zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune právě zaměřenou aplikaci na druhou pracovní plochu, aniž na ni přepne).

Při více než jednom monitoru má každý monitor svých vlastních pracovních ploch 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jste, a horní panel každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou právě zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jste. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jste, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jste, na monitor v daném směru, kde získá stejné číslo, pokud je volné. Monitor si své pracovní plochy zachová, když ho odpojíte: připojí se k plochám jiné obrazovky, očíslované až za těmi, které už má, a vrátí se pod svými původními čísly, když se monitor vrátí.

Když podržíte `Super` a myší kliknete na okno, budete moct změnit, kde okno sedí. Když podržíte `Super` a použijete pravé tlačítko myši, můžete oknu libovolně měnit velikost.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřete pomocí `Ctrl + Alt + Delete`).

Můžete také přejít na celou obrazovku pomocí `Super + F`, nebo dokonce jen na celou šířku (przy zachování horního panelu) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (hodí se pro YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení v Omarchy se nazývá dwindle. Udržuje všechna okna, která otevřete na jedné pracovní ploše, neustále viditelná, i kdyby je kvůli tomu muselo zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Můžete se ale také rozhodnout změnit pracovní plochu na rozložení scrolling, kde jsou okna seřazená vedle sebe až za viditelný okraj displeje. Jednu pracovní plochu na toto rozložení přepnete pomocí `Super + L`.

Další stisknutí `Super + L` přepne pracovní plochu na plovoucí, kde se okna volně překrývají a umisťujete si je sami, a třetí stisknutí ji vrátí na dwindle. `Super + Alt + L` jimi prochází opačným směrem. Okno, které je plovoucí tak jako tak — takové, které jste vysunuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí k dlaždicovému uspořádání. Horní panel označuje pracovní plochu, na které jste, podle jejího rozložení: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutí na tuto značku také rozložení přepíná.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a zůstává zachovaná. Takže pracovní plochu 1 si můžete nechat na dwindle na prohlížení a pracovní plochu 2 na scrolling na kód a po restartu se vrátí přesně takhle.

Pokud chcete rozložení scrolling používat jako výchozí, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sami je přesouváte a měníte jim velikost. Každé okno dostane titulkový pruh v barvách vašeho motivu, s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` také minimalizuje zaměřené okno. Minimalizované okno čeká v docku; klikněte na jeho aplikaci a vrátíte ho zpět. Klikněte na okno a přenesete ho dopředu. Velikost mu změníte z libovolné hrany nebo rohu. Dvojklikem na titulkový pruh okno maximalizujete a zároveň necháte horní panel na očích, dalším dvojklikem mu vrátíte původní velikost. Chrome a další prohlížeče založené na Chromiu, Disks a Document Viewer titulkový pruh vynechávají a místo něj používají vlastní záhlaví; `Super + Alt + F` je maximalizuje a `Super + M` je minimalizuje.

Plovoucí pracovní plocha také ukazuje dock s vašimi připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, kterou otevře také `Super + Alt + Space` a _Apps_ v Omarchy menu. Klikněte pravým tlačítkem na aplikaci v mřížce, nebo stiskněte `Delete`, a odinstalujete ji. Klikněte na aplikaci a otevřete ji, nebo přenesete její okno dopředu; dalším kliknutím procházíte její okna. Kliknutí prostředním tlačítkem otevře nové okno. Přetažením ikony podél docku ji přesunete; když běžící aplikaci přetáhnete mezi ostatní, zůstane tam. Klikněte pravým tlačítkem a aplikaci v docku necháte, odstraníte ji z něj, nebo ji ukončíte. Dock uhne oknu na celou obrazovku. Klikněte pravým tlačítkem na tlačítko aplikací a přesunete dock na jinou hranu, nebo ho necháte skrývat, dokud se ukazatel nedostane k jeho hraně. Pozice je také pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` a `omarchy dock autohide on` obojí nastaví z terminálu. Aplikace, které si v docku necháváte, jsou zeslabené, dokud neběží.

Nové pracovní plochy a všechny, kterým jste nedali vlastní rozložení pomocí `Super + L`, používají výchozí rozložení. Změna výchozího rozložení na něj resetuje každou pracovní plochu bez oken, zatímco plocha s okny si ponechá rozložení, které má. Okno minimalizované do docku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberete ho pod _Appearance > Workspace Layout_: Tiling, Scrolling, nebo Floating. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna lze seskupit pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, dokud je skupina aktivní, bude do skupiny patřit. Mezi takto seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo pomocí `Super + Alt + 1/2/3/4` přejít přímo na seskupená okna v pořadí.

Okno můžete ze seskupení vyjmout pomocí `Super + Alt + G` nebo celou skupinu rozložit dalším stisknutím `Super + G`. Nakonec můžete okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vysouvání oken

Okno můžete pomocí `Super + O` vysunout z jeho přiřazení k pracovní ploše. Tím ho připnete jako plovoucí okno, které vás následuje na každou pracovní plochu, na kterou přejdete. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která se překrývá přes pracovní plochu, na které právě jste. K tomu, co je na ní, se dostanete pomocí `Super + S` a okna tam umisťujete pomocí `Super + Alt + S`.

Hodí se na ovládací prvky nebo terminál, se kterými chcete rychle pracovat, aniž opustíte aktuální pracovní plochu.

### Konzole Quake

Nakonec je tu konzole Quake s poloviční výškou, která sjede dolů přes pracovní plochu, na které právě jste. Přepnete ji pomocí `Super + Grave` a okno tam umístíte pomocí `Super + Shift + Grave`.

Otevře se s vaším výchozím agentem připraveným k práci. Dokud konzole obsahuje jediné okno, sjede dolů jako panel na středu, místo aby zabírala celou šířku obrazovky. Dejte na ni druhou aplikaci a vrátí se na celou šířku, aby obě měly místo sedět vedle sebe.

Chcete-li okno přesunout pryč ze scratchpadu nebo z konzole, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíli trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile si zvyknete, bude těžké se vrátit k tradičnímu desktopu ovládanému myší!
