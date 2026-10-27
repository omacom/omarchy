# Navigace

Všechno v Omarchy se děje přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když se systém poprvé spustí, jen myší doslova nic neuděláte. Můžete ale stisknout `Super + Space` a zobrazit nabídku Omarchy, odkud můžete dělat skoro všechno.

Ale nabídka Omarchy ani nemá být většinu času hlavním způsobem ovládání systému. Můžeme být rychlejší! Všechny nejdůležitější aplikace jsou navázané přímo na jednotlivé klávesové zkratky. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste jedno po druhém a uvidíte kouzlo dlaždicového uspořádání Hyprland v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžete stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Dalším stisknutím `Super + J` je vrátíte do pozice vedle sebe. Pak zkuste `Super + Shift + Arrow Right`, když jste v prohlížeči, a okna prohoďte.

Teď zkuste `Super + Shift + T` a spusťte monitor aktivity. Ten se objeví jako plovoucí okno. Můžete ho zařadit mezi dlaždice pomocí `Super + T` (a dalším stisknutím ho zase uděláte plovoucím). Teď stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít hezké uspořádání do čtyř stran:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která chcete mít aktivní, se pohybujete pomocí `Super + Arrow`. Tím se přepne zaměření a kurzor se přesune do středu nové aplikace. Na okraji obrazovky pokračuje na monitor na dané straně.

Pokud stisknete `Super + Shift + 2`, přesunete právě zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune právě zaměřenou aplikaci na druhou pracovní plochu, aniž by na ni přepnulo).

Při více než jednom monitoru má každý monitor své vlastní pracovní plochy 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jste, a horní lišta každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jste. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jste, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jste, na monitor v daném směru, kde získá stejné číslo, pokud je volné. Monitor si své pracovní plochy ponechá, když ho odpojíte: připojí se k jiné obrazovce, očíslované až za těmi, které už má, a když se monitor vrátí, vrátí se pod svá stará čísla.

Pokud podržíte `Super` a myší kliknete na okno, budete moct přeskládat, kde sedí. Pokud podržíte `Super` a použijete pravé tlačítko myši, můžete oknu volně měnit velikost.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřete pomocí `Ctrl + Alt + Delete`).

Můžete také přejít na celou obrazovku pomocí `Super + F`, nebo dokonce jen na plnou šířku (se zachováním horní lišty) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (dobré pro YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se nazývá dwindle. Udržuje všechna okna, která otevřete na jedné pracovní ploše, neustále viditelná, i kdyby je kvůli tomu muselo zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Můžete se ale také rozhodnout změnit pracovní plochu na rozložení scrolling, kde jsou okna seřazená vedle sebe za viditelným okrajem displeje. Jednu pracovní plochu na toto rozložení přepnete pomocí `Super + L`.

Další stisknutí `Super + L` změní pracovní plochu na plovoucí, kde se okna volně překrývají a umisťujete si je sami, a třetí stisknutí ji vrátí na dwindle. `Super + Alt + L` jimi prochází opačným směrem. Okno, které je stejně plovoucí — takové, které jste vyjmuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí k dlaždicím. Horní lišta označuje pracovní plochu, na které jste, jejím rozložením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutí na tuto značku také prochází rozložení.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a zůstává zachovaná. Můžete si tedy nechat pracovní plochu 1 na dwindle pro prohlížení a pracovní plochu 2 na scrolling pro kód a po restartu se vrátí právě tak.

Pokud chcete rozložení scrolling používat jako výchozí, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sami je přesouváte a měníte jim velikost. Každé okno dostane záhlaví v barvách vašeho motivu, s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` také minimalizuje zaměřené okno. Minimalizované okno čeká v docku; kliknutím na jeho aplikaci ho přivedete zpět. Kliknutím na okno ho přivedete dopředu. Velikost mu změníte z libovolného okraje nebo rohu. Dvojitým kliknutím na záhlaví okno maximalizujete, přičemž horní lišta zůstane viditelná, a dalším dvojitým kliknutím získáte zpět jeho starou velikost.

Plovoucí pracovní plocha také ukazuje dock, s vašimi připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, které otevírá také `Super + Alt + Space` a _Aplikace_ v nabídce Omarchy. Pravým kliknutím na aplikaci v mřížce, nebo stisknutím `Delete`, ji odinstalujete. Kliknutím na aplikaci ji otevřete, nebo přivedete její okno dopředu; dalším kliknutím procházíte její okna. Kliknutí prostředním tlačítkem otevře nové okno. Přetažením ikony podél docku ji přesunete; přetažením běžící aplikace mezi ostatní ji tam ponecháte. Pravým kliknutím aplikaci ponecháte v docku, vyjmete ji z něj, nebo ji ukončíte. Dock ustoupí z cesty oknu na celou obrazovku. Pravým kliknutím na tlačítko aplikací přesunete dock na jiný okraj, nebo ho necháte skrýt, dokud ukazatel nedosáhne jeho okraje. Pozice je také pod _Vzhled > Dock > Pozice docku_ a `omarchy dock position left` a `omarchy dock autohide on` nastavují obojí z terminálu. Aplikace, které si necháte v docku, jsou vybledlé, dokud neběží.

Nové pracovní plochy a všechny, kterým jste nedali vlastní rozložení pomocí `Super + L`, používají výchozí rozložení. Změna výchozího nastavení resetuje každou pracovní plochu bez oken na něj, zatímco ta s okny si zachová rozložení, které má. Okno minimalizované do docku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberte ho pod _Vzhled > Rozložení pracovní plochy_: Dlaždice, Scrolling, nebo Plovoucí. `omarchy-hyprland-workspace-layout-default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna lze seskupit pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, dokud je aktivní, bude patřit do skupiny. Mezi těmito seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo `Super + Alt + 1/2/3/4` a přejít přímo na seskupené okno v pořadí.

Okno můžete ze seskupení přesunout pomocí `Super + Alt + G`, nebo celou skupinu rozebrat dalším stisknutím `Super + G`. Nakonec můžete okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vyjímání oken

Okno můžete vyjmout z jeho přiřazení k pracovní ploše pomocí `Super + O`. Tím ho připnete jako plovoucí okno, které vás následuje, na kteroukoliv pracovní plochu přejdete. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která překrývá pracovní plochu, na které právě jste. K tomu, co na ní je, se dostanete pomocí `Super + S`, a okna tam umisťujete pomocí `Super + Alt + S`.

Dobře funguje pro ovládací prvky nebo terminál, se kterým chcete rychle pracovat, aniž byste opustili aktuální pracovní plochu.

### Konzole Quake

Nakonec je tu konzole Quake s poloviční výškou, která se vysune přes pracovní plochu, na které právě jste. Přepnete ji pomocí `Super + Grave` a okno tam umístíte pomocí `Super + Shift + Grave`.

Otevře se s vaším výchozím agentem připraveným k akci. Dokud konzole drží jediné okno, vysouvá se jako vycentrovaný panel, místo aby zabírala celou šířku obrazovky. Dejte na ni druhou aplikaci a vrátí se na plnou šířku, aby ty dvě měly místo sedět vedle sebe.

Chcete-li okno přesunout ze scratchpadu nebo z konzole, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu cviku!

Chvíli trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile si zvyknete, bude těžké vrátit se k tradičnímu desktopovému zážitku ovládanému myší!
