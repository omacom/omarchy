# Navigace

Všechno v Omarchy se děje přes klávesnici — _ÚPLNĚ VŠECHNO!_ Když systém poprvé nastartuje, doslova nemůžete udělat nic jen myší. Ale můžete stisknout `Super + Space` a zobrazí se Omarchy Menu a odtud můžete dělat skoro všechno.

Ale Omarchy menu ani nemá být většinu času hlavním způsobem ovládání systému. Umíme to rychleji! Všechny nejdůležitější aplikace jsou vázané přímo na jednotlivé klávesové zkratky. Terminál spustíte pomocí `Super + Return` a prohlížeč pomocí `Super + Shift + Return`. Zkuste jedno po druhém a uvidíte kouzlo dlaždicového uspořádání Hyprlandu v akci:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pak můžete stisknout `Super + J` a naskládat je na sebe místo vedle sebe:

 ![navigation-stacked](images/navigation-stacked.webp)

Stiskněte `Super + J` znovu a vrátíte je zpět vedle sebe. Pak zkuste `Super + Shift + Arrow Right` v prohlížeči a prohoďte okna.

Teď zkuste `Super + Shift + T` a spusťte monitor aktivity. Zobrazí se jako plovoucí okno s titulkovým pruhem, za který ho můžete přetahovat, a s tlačítky pro minimalizaci, maximalizaci a zavření. Každé plovoucí okno ho dostane, ať je kdekoliv. Můžete ho uspořádat do dlaždic pomocí `Super + T` (a dalším stisknutím ho vrátíte zpět do plovoucího režimu). Teď stiskněte `Super + Shift + F` a otevřete správce souborů. Budete mít hezké uspořádání do čtveřice:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Mezi okny, která chcete mít aktivní, se pohybujete pomocí `Super + Arrow`. Tím přepnete fokus a přesunete kurzor do středu nové aplikace. Na okraji obrazovky pokračuje na monitor v daném směru.

Pokud stisknete `Super + Shift + 2`, přesunete aktuálně zaměřenou aplikaci na druhou pracovní plochu. `Super + Shift + 1` ji přesune zpět. (A `Super + Shift + Alt + 2` přesune aktuálně zaměřenou aplikaci na druhou pracovní plochu, aniž na ni přepnete).

S více než jedním monitorem má každý monitor svých vlastních pracovních ploch 1 až 10. `Super + 2` přejde na druhou pracovní plochu monitoru, na kterém jste, a horní lišta každého monitoru ukazuje jeho vlastní pracovní plochy a tu, kterou právě zobrazuje. `Super + Tab` cykluje pracovní plochy na monitoru, na kterém jste. `Super + Shift + Ctrl + Arrows` přesune okno, na kterém jste, na monitor v daném směru, na pracovní plochu, kterou zobrazuje, a `Super + Shift + Alt + Arrows` přesune pracovní plochu, na které jste, na monitor v daném směru, kde získá stejné číslo, pokud je volné. Monitor si své pracovní plochy podrží, když ho odpojíte: připojí se k jiné obrazovce, očíslované až za těmi, které už má, a když se monitor vrátí, vrátí se pod svými starými čísly.

Pokud podržíte `Super` a myší kliknete na okno, budete moci přeskupit, kde sedí. Pokud podržíte `Super` a použijete pravé tlačítko myši, můžete okno volně měnit na velikosti.

Okno zavřete pomocí `Super + W` nebo `Super + Q` (a všechna okna zavřete pomocí `Ctrl + Alt + Delete`).

Také můžete přejít na celou obrazovku pomocí `Super + F`, nebo jen na celou šířku (przy zachování horní lišty) pomocí `Super + Alt + F`, nebo na celou obrazovku uvnitř okna pomocí `Super + Ctrl + F` (dobré pro YouTube!).

### Rozložení dwindle vs. scrolling

Výchozí rozložení Omarchy se nazývá dwindle. Všechna okna, která otevřete na jedné pracovní ploše, nechává po celou dobu viditelná, i kdyby je kvůli tomu měla zmenšit.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale můžete si pracovní plochu přepnout do rozložení scrolling, kde jsou okna seřazená vedle sebe až za viditelný okraj displeje. Jednu pracovní plochu do tohoto rozložení přepnete pomocí `Super + L`.

Dalším stisknutím `Super + L` přepnete pracovní plochu na plovoucí, kde se okna volně překrývají a umisťujete si je sami, a třetím stisknutím ji vrátíte zpět na dwindle. `Super + Alt + L` nimi prochází opačným směrem. Okno, které plave tak jako tak — takové, které jste vyjmuli pomocí `Super + T`, nebo aplikace, která se vždy otevírá jako plovoucí — zůstane plovoucí, i když se pracovní plocha vrátí k dlaždicovému uspořádání. Horní lišta označuje pracovní plochu, na které jste, jejím rozložením: čtverec pro dwindle, kruh pro scrolling a trojúhelník pro plovoucí. Kliknutí na tuto značku také cykluje rozložení, stejně jako klávesa displeje na laptopech, které ji mají.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Tato volba je pro každou pracovní plochu zvlášť a drží. Klidně si můžete pracovní plochu 1 nechat na dwindle pro prohlížení a pracovní plochu 2 na scrolling pro kód a po restartu se vám vrátí přesně takhle.

Pokud chcete rozložení scrolling používat jako výchozí, můžete to nastavit v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plovoucí pracovní plochy

Plovoucí pracovní plocha funguje jako tradiční desktop: okna se překrývají a vy sami je přesouváte a měníte jejich velikost. Každé okno dostane titulkový pruh v barvách vašeho motivu s tlačítky pro minimalizaci, maximalizaci a zavření. `Super + M` minimalizuje i zaměřené okno. Minimalizované okno čeká v doku; kliknutím na jeho aplikaci ho přivedete zpět. Kliknutím na okno ho přivedete do popředí. Velikost měníte z kteréhokoliv okraje nebo rohu. Dvojklikem na titulkový pruh okno maximalizujete, přičemž horní lištu necháte na dohled, a dalším dvojklikem mu vrátíte starou velikost. Chrome a další prohlížeče založené na Chromiu, Disks a Document Viewer titulkový pruh vynechávají a místo něj používají vlastní hlavičku; `Super + Alt + F` je maximalizuje a `Super + M` je minimalizuje.

Každá pracovní plocha má dok s vašimi připnutými aplikacemi, se vším, co právě běží, a s mřížkou všech aplikací za tlačítkem aplikací, které otevírá také `Super + Alt + Space` a _Apps_ v Omarchy menu. Kliknutím pravým tlačítkem na aplikaci na mřížce, nebo stisknutím `Delete`, ji odinstalujete. Kliknutím na aplikaci ji otevřete, nebo přivedete její okno do popředí; dalším kliknutím cyklicky procházíte její okna. Files přivede zpět jen okno z pracovní plochy, na které jste, a jinak otevře nové, a Terminal a Agent vždy spustí další, i když minimalizované okno se vrátí jako první. Kliknutí prostředním tlačítkem otevře nové okno. Přetažením ikony podél doku ji přesunete; přetažením běžící aplikace mezi ostatní ji tam podrží. Kliknutím pravým tlačítkem aplikaci v doku podržíte, odstraníte ji z něj, nebo ji ukončíte. Dok zůstává vidět, dokud je pracovní plocha prázdná, a jakmile pracovní plocha dostane okno, skryje se, dokud ukazatel nedosáhne jejího okraje. Okno na celé obrazovce ho skryje úplně. Přetažením tlačítka aplikací k jinému okraji obrazovky tam dok přesunete. Kliknutím pravým tlačítkem na něj otevřete _Position_ pro výběr okraje a _Layout_ pro nastavení výchozího rozložení, stejně jako to dělá _Appearance > Workspace Layout_. Pozice je také pod _Appearance > Dock > Dock Position_ a `omarchy dock position left` ji nastaví z terminálu. Aplikace, které si necháváte v doku, jsou ztlumené, dokud neběží. Pokud chcete dok omezit na plovoucí pracovní plochy, použijte _Appearance > Dock > Dock Only on Floating_ nebo `omarchy dock tiling off`.

Nové pracovní plochy a všechny, kterým jste pomocí `Super + L` nedali vlastní rozložení, používají výchozí rozložení. Změna výchozího rozložení resetuje každou pracovní plochu bez oken na toto rozložení, zatímco ta s okny si ponechá rozložení, které má. Okno minimalizované do doku se stále počítá jako okno na pracovní ploše, kterou opustilo. Vyberte ho pod _Appearance > Workspace Layout_: Tiling, Scrolling, nebo Floating. `omarchy hyprland workspace layout default scrolling` ho nastaví z terminálu.

### Seskupování oken

Okna můžete seskupit pomocí `Super + G`. Jakmile jste ve skupině, každé okno, které spustíte, když je aktivní, bude patřit do skupiny. Mezi těmito seskupenými okny se můžete pohybovat pomocí `Super + Ctrl + Arrow Left/Right` nebo `Super + Alt + 1/2/3/4` a přejít přímo na seskupená okna v pořadí.

Okno můžete ze seskupení vyjmout pomocí `Super + Alt + G`, nebo celou skupinu rozebrat opětovným stisknutím `Super + G`. Nakonec můžete okna mimo skupinu do ní přesunout pomocí `Super + Alt + Arrows`.

### Vyjímání oken

Okno můžete vyjmout z jeho přiřazení pracovní plochy pomocí `Super + O`. Tím ho připnete jako plovoucí okno, které vás následuje, na kteroukoliv pracovní plochu přejdete. Skvělé pro přehrávače videa a podobně.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Pracovní plocha scratchpad

Existuje speciální pracovní plocha scratchpad v plné velikosti, která se překrývá přes kteroukoliv pracovní plochu, na které právě jste. K tomu, co na ní je, se dostanete pomocí `Super + S` a okna tam umisťujete pomocí `Super + Alt + S`.

Dobře funguje pro ovládací prvky nebo terminál, se kterými chcete rychle interagovat, aniž byste opustili aktuální pracovní plochu.

### Konzole Quake

Nakonec tu je konzole Quake v poloviční výšce, která spadne přes kteroukoliv pracovní plochu, na které právě jste. Přepnete ji pomocí `Super + the key above Tab` (grave na amerických rozloženích) a okno tam umístíte pomocí `Super + Shift + the key above Tab`.

Při prvním otevření spustí vašeho výchozího agenta, nebo vás požádá o výběr jednoho, pokud jste si ještě žádného nevybrali. Když konzole drží jediné okno, spadne jako vystředěný panel, místo aby se táhla přes celou obrazovku. Přidejte na ni druhou aplikaci a vrátí se na celou šířku, aby ty dvě měly prostor sedět vedle sebe.

Pokud chcete okno pryč ze scratchpadu nebo konzole, pošlete ho přímo na jinou pracovní plochu něčím jako `Super + Shift + 1`.

### Chce to trochu cviku!

Chvilku trvá, než si na takovou navigaci po desktopu zvyknete, ale jakmile se to stane, bude těžké vrátit se k tradičnímu desktopu ovládanému myší!
