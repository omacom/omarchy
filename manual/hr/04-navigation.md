# Navigacija

Sve se u Omarchyju događa putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možeš učiniti ništa samo mišem. Ali možeš pritisnuti `Super + Space` da otvoriš Omarchy Menu i odavde možeš učiniti gotovo sve.

Ali Omarchy izbornik većinu vremena uopće nije zamišljen kao glavni način upravljanja sustavom. Možemo i brže od toga! Sve najvažnije aplikacije izravno su vezane uz pojedinačne prečace. Terminal pokrećeš sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušaj jedno za drugim i vidjet ćeš čaroliju Hyprlandova slaganja prozora na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Možeš zatim pritisnuti `Super + J` da ih složiš jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Pritisni `Super + J` ponovno da ih vratiš u položaj jedan pokraj drugoga. Zatim u pregledniku pokušaj `Super + Shift + Arrow Right` da zamijeniš prozore.

Sada pokušaj `Super + Shift + T` da pokreneš monitor aktivnosti. Pojavit će se kao plutajući prozor, s naslovnom trakom za povlačenje i gumbima za minimiziranje, maksimiziranje i zatvaranje. Svaki plutajući prozor dobiva jednu, gdje god bio. Možeš ga postaviti u slaganje pomoću `Super + T` (i pritisnuti to ponovno da opet postane plutajući). Sada pritisni `Super + Shift + F` da otvoriš upravitelj datoteka. Imat ćeš uredan raspored od četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želiš da bude aktivan krećeš se sa `Super + Arrow`. Time se mijenja fokus i pokazivač se pomiče u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor na toj strani.

Ako pritisneš `Super + Shift + 2`, premjestit ćeš trenutačno fokusiranu aplikaciju na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutačno fokusiranu aplikaciju na drugi radni prostor bez prebacivanja na njega).

S više od jednog monitora, svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` ide na drugi radni prostor monitora na kojem se nalaziš, a gornja traka svakog monitora prikazuje njegove radne prostore i onaj koji prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalaziš. `Super + Shift + Ctrl + Arrows` premješta prozor na kojem se nalaziš na monitor u tom smjeru, na radni prostor koji taj monitor prikazuje, a `Super + Shift + Alt + Arrows` premješta radni prostor na kojem se nalaziš na monitor u tom smjeru, gdje preuzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga iskopčaš: pridružuju se drugom zaslonu, numerirani nakon onih koje taj već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držiš `Super` i mišem klikneš na prozor, moći ćeš preurediti gdje se nalazi. Ako držiš `Super` i koristiš desnu tipku miša, možeš slobodno mijenjati veličinu prozora.

Prozor zatvaraš sa `Super + W` ili `Super + Q` (a sve prozore zatvaraš sa `Ctrl + Alt + Delete`).

Također možeš prijeći na cijeli zaslon sa `Super + F` ili čak samo na punu širinu (zadržavajući gornju traku) sa `Super + Alt + F` ili na cijeli zaslon unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Raspored dwindle naspram pomičnog rasporeda

Zadani raspored u Omarchyju zove se dwindle. Sve prozore koje otvoriš na jednom radnom prostoru drži vidljivima u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali možeš odabrati i pretvoriti radni prostor u pomični raspored u kojem su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Jedan radni prostor u ovaj raspored pretvaraš pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, u kojem se prozori slobodno preklapaju i sam ih postavljaš, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih obrnutim redoslijedom. Prozor koji ionako pluta — onaj koji si izdvojio sa `Super + T` ili aplikacija koja se uvijek otvara kao plutajuća — ostaje plutajući kad se radni prostor vrati na slaganje. Gornja traka označava radni prostor na kojem se nalaziš njegovim rasporedom: kvadratom za dwindle, krugom za pomični i trokutom za plutajući. Klik na tu oznaku također kruži kroz raspored, kao i tipka za zaslon na prijenosnim računalima koja je imaju.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Odabir je po radnom prostoru i ostaje zapamćen. Tako radni prostor 1 možeš držati na dwindleu za pregledavanje, a radni prostor 2 na pomičnom za kod, i vratit će se tako nakon ponovnog pokretanja.

Ako pomični raspored želiš koristiti kao zadani, to možeš postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a ti ih sam pomičeš i određuješ im veličinu. Svaki prozor dobiva naslovnu traku u bojama tvoje teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; klikni njegovu aplikaciju da ga vratiš. Klikni prozor da ga izneseš u prvi plan. Mijenjaj mu veličinu s bilo kojeg ruba ili kuta. Dvoklikni naslovnu traku da maksimiziraš prozor uz zadržavanje gornje trake u vidokrugu, i ponovno da mu vratiš staru veličinu. Chrome i drugi preglednici temeljeni na Chromiumu, Disks i Document Viewer preskaču naslovnu traku i umjesto nje koriste vlastito zaglavlje; `Super + Alt + F` ih maksimizira, a `Super + M` ih minimizira.

Svaki radni prostor ima dock, s tvojim prikvačenim aplikacijama, svime što se izvodi i mrežom svih aplikacija iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u Omarchy izborniku. Desnom tipkom miša klikni aplikaciju na mreži ili pritisni `Delete` da je deinstaliraš. Klikni aplikaciju da je otvoriš ili da njezin prozor izneseš u prvi plan; klikni ponovno da kružiš kroz njezine prozore. Files vraća samo prozor s radnog prostora na kojem se nalaziš i inače otvara novi, a Terminal i Agent uvijek pokreću još jedan, iako se minimizirani prozor vraća prvi. Srednji klik otvara novi prozor. Povuci ikonu duž docka da je premjestiš; povlačenje pokrenute aplikacije među ostale zadržava je ondje. Desnom tipkom miša klikni da zadržiš aplikaciju u docku, ukloniš je ili je zatvoriš. Dock ostaje vidljiv dok je radni prostor prazan, a kad radni prostor ima prozor, skriva se dok pokazivač ne dođe do njegova ruba. Prozor preko cijelog zaslona skriva ga u potpunosti. Povuci gumb za aplikacije prema drugom rubu zaslona da dock premjestiš onamo. Desnom tipkom miša klikni ga za _Position_, da odabereš rub, _Layout_, da postaviš zadani raspored kao što to čini _Appearance > Workspace Layout_, i _Visibility_, da dock držiš uvijek uključenim, da ga prva aplikacija skriva ili da ga držiš uvijek skrivenim. `omarchy dock visibility always` postavlja to iz terminala. Položaj je također pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` postavlja ga iz terminala. Aplikacije koje držiš u docku izblijedjele su dok se ne izvode. Da dock zadržiš samo za plutajuće radne prostore, koristi _Appearance > Dock > Dock Only on Floating_ ili `omarchy dock tiling off`.

Novi radni prostori i svi kojima nisi dao vlastiti raspored sa `Super + L` koriste zadani raspored. Promjena zadanog vraća na njega svaki radni prostor bez prozora, dok onaj s prozorima na njemu zadržava raspored koji ima. Prozor minimiziran u dock i dalje se broji kao prozor na radnom prostoru koji je napustio. Odaberi ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy hyprland workspace layout default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozore možeš grupirati pomoću `Super + G`. Kad si u grupi, svaki prozor koji pokreneš dok je ona aktivna pripadat će grupi. Između tih grupiranih prozora možeš se kretati pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da izravno odeš na grupirane prozore po redu.

Prozor možeš izbaciti iz grupe sa `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Na kraju, prozore izvan grupe možeš premjestiti u nju sa `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možeš izdvojiti iz njegove dodjele radnom prostoru sa `Super + O`. Time ćeš ga prikvačiti kao plutajući prozor koji te prati na koji god radni prostor odeš. Odlično za reproduktore videozapisa i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Radni prostor scratchpad

Postoji poseban radni prostor scratchpad pune veličine koji prekriva koji god radni prostor trenutačno koristiš. Onome što je na njemu pristupaš pomoću `Super + S`, a prozore onamo postavljaš pomoću `Super + Alt + S`.

Dobro radi za kontrole ili terminal s kojim želiš brzo raditi bez napuštanja trenutačnog radnog prostora.

### Konzola Quake

Na kraju, tu je konzola Quake polovične visine koja se spušta preko kojeg god radnog prostora trenutačno koristiš. Uključuješ je i isključuješ sa `Super + the key above Tab` (grave na američkim rasporedima), a prozor onamo postavljaš pomoću `Super + Shift + the key above Tab`.

Kad se prvi put otvori, pokreće tvog zadanog agenta ili te pita da jednoga odabereš ako ga još nisi odabrao. Dok konzola drži jedan prozor, spušta se kao centrirana ploča umjesto da se proteže preko zaslona. Postavi drugu aplikaciju na nju i vraća se na punu širinu, tako da oboje imaju mjesta stajati jedan pokraj drugoga.

Da prozor makneš sa scratchpada ili s konzole, pošalji ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se navikneš ovako kretati radnom površinom, ali kad se navikneš, bit će ti teško vratiti se tradicionalnom iskustvu radne površine vođenom mišem!
