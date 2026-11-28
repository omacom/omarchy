# Navigace

Všechno v Omarchy probíhá přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když systém poprvé nastartuje, myší samotnou doslova nic nezmůžete. Můžete ale stisknout `Super + Space` a zobrazit Omarchy Menu a odtud uděláte skoro všechno.

Ale Omarchy menu ani nemá být většinu času hlavním způsobem ovládání systému. Umíme to rychleji! Všechny nejdůležitější aplikace jsou navázané přímo na jednotlivé klávesové zkratky. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste jedno po druhém a uvidíte kouzlo dlaždicového uspořádání Hyprlandu v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Potom můžete stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskněte `Super + J` znovu a vrátíte je do pozic vedle sebe. Potom v prohlížeči zkuste `Super + Shift + Arrow Right` a okna prohodíte.

Nyní zkuste `Super + Shift + T` a spustíte monitor aktivity. Ten se objeví jako plovoucí okno s titulkovým pruhem, za který ho můžete přetahovat, a s tlačítky pro minimalizaci, maximalizaci a zavření. Každé plovoucí okno ho dostane, ať je kdekoli. Můžete ho převést na dlaždici pomocí `Super + T` (a opětným stisknutím z něj znovu udělat plovoucí). Nyní stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít hezké uspořádání do čtyř stran:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, které chcete mít aktivní, se pohybujete pomocí `Super + Arrow`. Tím přepnete zaměření a přesunete kurzor do středu nové aplikace. Na okraji obrazovky pokračuje na monitor na dané straně.

Když stisknete `Super + Shift + 2`, přesunete aktuálně zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune aktuálně zaměřenou aplikaci na druhou pracovní plochu, aniž na ni přepne).

S více než jedním monitorem má každý monitor svých vlastních pracovních ploch 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jste, a horní lišta každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou právě zobrazuje. `Super + Tab` prochází pracovní plochy na monitoru, na kterém jste. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jste, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jste, na monitor v daném směru, kde získá stejné číslo, pokud je volné. Monitor si své pracovní plochy ponechá, když ho odpojíte: připojí se k jiné obrazovce, očíslované až za těmi, které už má, a když se monitor vrátí, vrátí se pod svými starými čísly.

Když podržíte `Super` a myší kliknete na okno, budete moci přeskupit, kde se nachází. Když podržíte `Super` a použijete pravé tlačítko myši, můžete libovolně měnit velikost okna.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřete pomocí `Ctrl + Alt + Delete`).

Můžete také přejít na celou obrazovku pomocí `Super + F`, nebo dokonce jen na celou šířku (przy zachování horní lišty) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (skvělé pro YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se nazývá dwindle. Všechna okna, která otevřete na jedné pracovní ploše, udržuje neustále viditelná, i když je kvůli tomu musí zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Můžete ale také zvolit převod pracovní plochy do rozložení scrolling, kde jsou okna seřazená vedle sebe až za viditelný okraj displeje. Jednu pracovní plochu do tohoto rozložení převedete pomocí `Super + L`.

Opětné stisknutí `Super + L` změní pracovní plochu na plovoucí, kde se okna volně překrývají a umisťujete je sami, a třetí stisknutí ji vrátí do dwindle. `Super + Alt + L` jimi prochází opačným směrem. Okno, které je plovoucí tak jako tak — takové, které jste vysunuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, když se pracovní plocha vrátí do dlaždicového režimu. Horní lišta označuje pracovní plochu, na které jste, jejím rozložením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutí na tuto značku také cyklicky přepíná rozložení a stejně tak klávesa displeje na noteboocích, které ji mají.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Volba je pro každou pracovní plochu zvlášť a zůstává zachovaná. Můžete si tedy ponechat pracovní plochu 1 na dwindle pro prohlížení a pracovní plochu 2 na scrolling pro kód a po restartu se vrátí právě takto.

Pokud chcete rozložení scrolling používat jako výchozí, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a sami je přesouváte a měníte jejich velikost. Každé okno dostane titulkový pruh v barvách vašeho motivu s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` také minimalizuje zaměřené okno. Minimalizované okno čeká v doku; kliknutím na jeho aplikaci ho přivedete zpět. Kliknutím na okno ho přenesete do popředí. Jeho velikost změníte z libovolné hrany nebo rohu. Poklepáním na titulkový pruh okno maximalizujete a přitom ponecháte horní lištu na očích a opětovným poklepáním získáte zpět jeho starou velikost. Chrome a další prohlížeče založené na Chromiu, Disks a Document Viewer titulkový pruh přeskakují a místo něj používají vlastní záhlaví; `Super + Alt + F` je maximalizuje a `Super + M` je minimalizuje.

Každá pracovní plocha má dok s vašimi připnutými aplikacemi, vším, co právě běží, a mřížkou všech aplikací za tlačítkem aplikací, kterou otevírá také `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknutím pravým tlačítkem na aplikaci v mřížce, nebo stisknutím `Delete`, ji odinstalujete. Kliknutím na aplikaci ji otevřete, nebo přenesete její okno do popředí; opětovným kliknutím procházíte její okna. Files přivede zpět pouze okno z pracovní plochy, na které jste, a jinak otevře nové, a Terminal a Agent vždy spustí další, i když se minimalizované okno vrátí jako první. Kliknutí prostředním tlačítkem otevře nové okno. Přetažením ikony podél doku ji přesunete; přetažení běžící aplikace mezi ostatní ji tam ponechá. Kliknutím pravým tlačítkem aplikaci v doku ponecháte, vyjmete ji z něj, nebo ji ukončíte. Dok zůstává venku, dokud je pracovní plocha prázdná, a jakmile má pracovní plocha okno, skryje se, dokud ukazatel nedosáhne její hrany. Okno na celé obrazovce ho skryje úplně. Přetažením tlačítka aplikací k jiné hraně obrazovky tam dok přesunete. Klikněte na něj pravým tlačítkem pro _Position_, kde vyberete hranu, _Layout_, kde nastavíte výchozí rozložení stejně jako v _Appearance > Workspace Layout_, a _Visibility_, kde dok ponecháte vždy zapnutý, necháte ho skrýt první aplikací, nebo ho ponecháte vždy skrytý. `omarchy dock visibility always` to nastaví z terminálu. Pozice se nachází také pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` ji nastaví z terminálu. Aplikace, které si ponecháte v doku, jsou vybledlé, dokud neběží. Chcete-li dok omezit na plovoucí pracovní plochy, použijte _Appearance > Dock > Dock Only on Floating_ nebo `omarchy dock tiling off`.

Nové pracovní plochy a všechny, kterým jste pomocí `Super + L` nedali vlastní rozložení, používají výchozí rozložení. Změna výchozího rozložení na něj resetuje každou pracovní plochu bez oken, zatímco ta, která na sobě okna má, si ponechá rozložení, které má. Okno minimalizované do doku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberte si ho pod _Appearance > Workspace Layout_: Tiling, Scrolling, nebo Floating. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna lze seskupovat pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, dokud je aktivní, bude do skupiny patřit. Mezi těmito seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo `Super + Alt + 1/2/3/4` a přejít přímo na seskupená okna v pořadí.

Okno můžete ze seskupení přesunout ven pomocí `Super + Alt + G`, nebo celou skupinu rozebrat opětovným stisknutím `Super + G`. Nakonec můžete okna mimo skupinu přesunout do ní pomocí `Super + Alt + Arrows`.

### Vysouvání oken

Okno můžete vysunout z jeho přiřazení pracovní ploše pomocí `Super + O`. Tím ho připnete jako plovoucí okno, které vás následuje na jakoukoli pracovní plochu, kam přejdete. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje zvláštní pracovní plocha scratchpad v plné velikosti, která se překrývá přes jakoukoli pracovní plochu, na které právě jste. K tomu, co je na ní, se dostanete pomocí `Super + S` a okna tam umisťujete pomocí `Super + Alt + S`.

Dobře se hodí pro ovládací prvky nebo terminál, se kterým chcete rychle pracovat, aniž byste opustili aktuální pracovní plochu.

### Konzole Quake

Nakonec je tu konzole Quake s poloviční výškou, která se sune dolů přes jakoukoli pracovní plochu, na které právě jste. Přepnete ji pomocí `Super + the key above Tab` (na rozloženích US znak grave) a okno tam umístíte pomocí `Super + Shift + the key above Tab`.

Když se poprvé otevře, spustí vašeho výchozího agenta, nebo vás požádá, abyste si jednoho vybrali, pokud jste si ještě žádného nezvolili. Dokud konzole obsahuje jediné okno, sune se dolů jako vycentrovaný panel, místo aby se roztáhla přes obrazovku. Umístěte na ni druhou aplikaci a vrátí se na plnou šířku, aby ty dvě měly místo vedle sebe.

Chcete-li okno přesunout pryč ze scratchpadu nebo z konzole, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu zvyku!

Chvíli trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile to uděláte, bude těžké vrátit se k tradičnímu desktopovému prostředí ovládanému myší!
