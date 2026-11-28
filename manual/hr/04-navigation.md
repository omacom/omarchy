# Navigacija

Sve se u Omarchyju događa putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možete učiniti ništa samo mišem. Ali možete pritisnuti `Super + Space` da biste otkrili Omarchy Menu i odavde možete učiniti gotovo sve.

Ali Omarchy izbornik većinu vremena uopće nije zamišljen kao glavni način upravljanja sustavom. Možemo brže od toga! Sve najvažnije aplikacije izravno su vezane uz pojedinačne prečace. Terminal pokrećete sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušajte učiniti jedno za drugim i vidjet ćete čaroliju Hyprlandova slaganja prozora na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Zatim možete pritisnuti `Super + J` da biste ih složili jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Ponovno pritisnite `Super + J` da biste ih vratili u položaj jedan pokraj drugoga. Zatim u pregledniku pokušajte `Super + Shift + Arrow Right` da biste zamijenili prozore.

Sada pokušajte `Super + Shift + T` da biste pokrenuli Activity monitor. Pojavit će se kao plutajući prozor, s naslovnom trakom za povlačenje i gumbima za minimiziranje, maksimiziranje i zatvaranje. Svaki plutajući prozor dobiva jednu, gdje god se nalazio. Možete ga postaviti u slaganje prozora pomoću `Super + T` (i ponovno pritisnite to da bi opet postao plutajući). Sada pritisnite `Super + Shift + F` da biste otvorili upravitelj datoteka. Imat ćete uredan raspored od četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želite učiniti aktivnim krećete se pomoću `Super + Arrow`. Time se mijenja fokus i pokazivač se pomiče u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisnete `Super + Shift + 2`, premjestit ćete trenutačno fokusiranu aplikaciju na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutačno fokusiranu aplikaciju na drugi radni prostor bez prebacivanja na njega).

S više od jednog monitora svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` odlazi na drugi radni prostor monitora na kojem se nalazite, a gornja traka svakog monitora prikazuje njegove radne prostore i onaj koji prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalazite. `Super + Shift + Ctrl + Arrows` premješta prozor na kojem se nalazite na monitor u tom smjeru, na radni prostor koji on prikazuje, a `Super + Shift + Alt + Arrows` premješta radni prostor na kojem se nalazite na monitor u tom smjeru, gdje zauzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga isključite: pridružuju se radnim prostorima drugog zaslona, numerirani nakon onih koje on već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držite `Super` i mišem kliknete na prozor, moći ćete promijeniti gdje se nalazi. Ako držite `Super` i upotrijebite desnu tipku miša, možete slobodno mijenjati veličinu prozora.

Prozor zatvarate sa `Super + W` ili `Super + Q` (a sve prozore zatvarate sa `Ctrl + Alt + Delete`).

Također možete prijeći na cijeli zaslon sa `Super + F` ili čak samo na punu širinu (uz zadržavanje gornje trake) sa `Super + Alt + F` ili na cijeli zaslon unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle naspram rasporeda s pomicanjem

Zadani raspored u Omarchyju zove se dwindle. Sve prozore koje otvorite na jednom radnom prostoru drži vidljivima u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali također možete odabrati pretvoriti radni prostor u raspored s pomicanjem, gdje su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Jedan radni prostor u taj raspored pretvarate pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, gdje se prozori slobodno preklapaju i sami ih postavljate, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih obrnutim redoslijedom. Prozor koji ionako pluta — onaj koji ste izdvojili pomoću `Super + T` ili aplikacija koja se uvijek otvara kao plutajuća — ostaje plutajući kad se radni prostor vrati na slaganje prozora. Gornja traka označava radni prostor na kojem se nalazite njegovim rasporedom: kvadrat za dwindle, krug za pomicanje i trokut za plutajući. Klik na tu oznaku također kruži kroz rasporede, kao i tipka za zaslon na prijenosnim računalima koja je imaju.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbor se odnosi na svaki radni prostor zasebno i ostaje spremljen. Tako radni prostor 1 možete držati na dwindleu za pregledavanje, a radni prostor 2 na pomicanju za kod, i vratit će se tako nakon ponovnog pokretanja.

Ako želite koristiti raspored s pomicanjem kao zadani, to možete postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a sami ih pomičete i mijenjate im veličinu. Svaki prozor dobiva naslovnu traku u bojama vaše teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; kliknite njegovu aplikaciju da biste ga vratili. Kliknite prozor da biste ga doveli u prvi plan. Mijenjajte mu veličinu s bilo kojeg ruba ili kuta. Dvaput kliknite naslovnu traku da biste maksimizirali prozor uz zadržavanje gornje trake u vidiku, i ponovno da biste vratili njegovu staru veličinu. Chrome i drugi preglednici temeljeni na Chromiumu, Disks i Document Viewer preskaču naslovnu traku i umjesto nje koriste vlastito zaglavlje; `Super + Alt + F` ih maksimizira, a `Super + M` ih minimizira.

Svaki radni prostor ima dock, s vašim prikvačenim aplikacijama, svime što je pokrenuto i mrežom svih aplikacija iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u Omarchy izborniku. Desnom tipkom miša kliknite aplikaciju na mreži ili pritisnite `Delete` da biste je deinstalirali. Kliknite aplikaciju da biste je otvorili ili doveli njezin prozor u prvi plan; kliknite ponovno da biste kružili kroz njezine prozore. Files vraća samo prozor s radnog prostora na kojem se nalazite i u suprotnom otvara novi, a Terminal i Agent uvijek pokreću još jedan, iako se minimizirani prozor prvo vraća. Srednji klik otvara novi prozor. Povucite ikonu duž docka da biste je premjestili; povlačenje pokrenute aplikacije među ostale zadržava je ondje. Kliknite desnom tipkom miša da biste aplikaciju zadržali u docku, izvadili je iz njega ili je zatvorili. Dock ostaje vani dok je radni prostor prazan, a kad radni prostor dobije prozor, skriva se dok pokazivač ne dosegne njegov rub. Prozor na cijelom zaslonu skriva ga u potpunosti. Povucite gumb za aplikacije prema drugom rubu zaslona da biste dock premjestili onamo. Kliknite ga desnom tipkom miša za _Position_, da biste odabrali rub, i _Layout_, da biste postavili zadani raspored kao što to čini _Appearance > Workspace Layout_. Položaj se također nalazi pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` postavlja ga iz terminala. Aplikacije koje držite u docku izblijedjele su dok nisu pokrenute. Da biste dock zadržali samo na plutajućim radnim prostorima, koristite _Appearance > Dock > Dock Only on Floating_ ili `omarchy dock tiling off`.

Novi radni prostori i svi kojima niste dali vlastiti raspored pomoću `Super + L` koriste zadani raspored. Promjena zadanog rasporeda vraća na njega svaki radni prostor bez prozora, dok onaj s prozorima zadržava raspored koji ima. Prozor minimiziran u dock i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberite ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy hyprland workspace layout default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozori se mogu grupirati pomoću `Super + G`. Kad ste u grupi, svaki prozor koji pokrenete dok je ona aktivna pripadat će grupi. Između tih grupiranih prozora možete se kretati pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da biste izravno otišli na grupirane prozore redom.

Prozor možete izbaciti iz grupe pomoću `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Naposljetku, prozore izvan grupe možete premjestiti u nju pomoću `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možete izdvojiti iz dodjele njegova radnog prostora pomoću `Super + O`. Time ćete ga prikvačiti kao plutajući prozor koji vas prati na koji god radni prostor odete. Odlično za videoreproduktore i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad radni prostor

Postoji poseban scratchpad radni prostor pune veličine koji prekriva radni prostor na kojem se trenutačno nalazite. Onome što je na njemu pristupate pomoću `Super + S`, a prozore onamo postavljate pomoću `Super + Alt + S`.

Dobro funkcionira za kontrole ili terminal s kojim želite brzo raditi bez napuštanja trenutačnog radnog prostora.

### Quake konzola

Naposljetku, postoji Quake konzola polovične visine koja se spušta preko radnog prostora na kojem se trenutačno nalazite. Uključujete i isključujete je pomoću `Super + the key above Tab` (grave na američkim rasporedima), a prozor onamo postavljate pomoću `Super + Shift + the key above Tab`.

Kad se prvi put otvori, pokreće vašeg zadanog agenta ili vas pita da odaberete jednoga ako ga još niste odabrali. Dok konzola sadrži jedan prozor, spušta se kao centrirana ploča umjesto da se proteže preko zaslona. Postavite drugu aplikaciju na nju i vraća se na punu širinu, tako da obje imaju mjesta stajati jedna pokraj druge.

Da biste prozor premjestili sa scratchpada ili konzole, pošaljite ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se naviknete ovako kretati svojom radnom površinom, ali kad se naviknete, bit će vam teško vratiti se tradicionalnom iskustvu radne površine upravljane mišem!
