# Navigacija

Sve u Omarchyju događa se putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možete učiniti ništa samo mišem. Ali možete pritisnuti `Super + Space` da otkrijete Omarchy Menu i odavde možete učiniti gotovo sve.

Ali Omarchy izbornik čak nije ni zamišljen kao glavni način upravljanja sustavom većinu vremena. Možemo i brže od toga! Sve najvažnije aplikacije izravno su vezane uz pojedinačne tipkovničke prečace. Terminal pokrećete sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušajte učiniti jedno za drugim i vidjet ćete magiju Hyprlandova slaganja pločica na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Zatim možete pritisnuti `Super + J` da ih složite jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Ponovno pritisnite `Super + J` da ih vratite u položaj jedan pokraj drugoga. Zatim pokušajte sa `Super + Shift + Arrow Right` dok ste na pregledniku da zamijenite prozore.

Sada pokušajte sa `Super + Shift + T` da pokrenete monitor aktivnosti. On će se pojaviti kao plutajući prozor. Možete ga posložiti kao pločicu koristeći `Super + T` (i ponovno pritisnuti isto da opet postane plutajući). Sada pritisnite `Super + Shift + F` da otvorite upravitelj datoteka. Imat ćete uredan raspored s četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želite da bude aktivan krećete se sa `Super + Arrow`. Time ćete prebaciti fokus i pomaknuti pokazivač u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisnete `Super + Shift + 2`, premjestit ćete trenutno fokusiranu aplikaciju na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutno fokusiranu aplikaciju na drugi radni prostor bez prebacivanja na njega).

S više od jednog monitora svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` odlazi na drugi radni prostor monitora na kojem se nalazite, a gornja traka svakog monitora prikazuje njegove radne prostore i onaj koji prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalazite. `Super + Shift + Ctrl + Arrows` pomiče prozor na kojem se nalazite na monitor u tom smjeru, na radni prostor koji on prikazuje, a `Super + Shift + Alt + Arrows` pomiče radni prostor na kojem se nalazite na monitor u tom smjeru, gdje zauzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga iskopčate: oni se pridružuju drugom zaslonu, numerirani iza onih koje on već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držite `Super` i mišem kliknete na prozor, moći ćete preurediti gdje se nalazi. Ako držite `Super` i koristite desnu tipku miša, možete slobodno mijenjati veličinu prozora.

Prozor zatvarate sa `Super + W` ili `Super + Q` (a sve prozore zatvarate sa `Ctrl + Alt + Delete`).

Također možete prijeći na cijeli zaslon sa `Super + F` ili čak samo na punu širinu (zadržavajući gornju traku) sa `Super + Alt + F` ili na cijeli zaslon unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle naspram kliznog rasporeda

Zadani raspored u Omarchyju zove se dwindle. On sve prozore koje otvorite na jednom radnom prostoru drži vidljivima u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali također možete odabrati pretvoriti radni prostor u klizni raspored, gdje su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Pojedinačni radni prostor u ovaj raspored pretvarate putem `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, gdje se prozori slobodno preklapaju i sami ih postavljate, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih u drugom smjeru. Prozor koji ionako pluta — onaj koji ste izdvojili sa `Super + T` ili aplikacija koja se uvijek otvara plutajuća — ostaje plutajući kad se radni prostor vrati na slaganje pločica. Gornja traka označava radni prostor na kojem se nalazite njegovim rasporedom: kvadrat za dwindle, krug za klizni i trokut za plutajući. Klik na tu oznaku također kruži kroz rasporede.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Odabir vrijedi po radnom prostoru i ostaje zapamćen. Tako možete radni prostor 1 držati na dwindleu za pregledavanje, a radni prostor 2 na kliznom za kod, i vratit će se takvi nakon ponovnog pokretanja.

Ako želite koristiti klizni raspored kao zadani, to možete postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a vi ih sami pomišete i mijenjate im veličinu. Svaki prozor dobiva naslovnu traku u bojama vaše teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. I `Super + M` minimizira fokusirani prozor. Minimizirani prozor čeka u docku; kliknite njegovu aplikaciju da ga vratite. Kliknite prozor da ga iznesete u prvi plan. Mijenjajte mu veličinu s bilo kojeg ruba ili kuta. Dvaput kliknite naslovnu traku da maksimizirate prozor uz zadržavanje gornje trake u vidokrugu, i ponovno da mu vratite staru veličinu.

Plutajući radni prostor također prikazuje dock, s vašim prikvačenim aplikacijama, svime što se izvodi i mrežom svake aplikacije iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u Omarchy izborniku. Desnom tipkom miša kliknite aplikaciju na mreži, ili pritisnite `Delete`, da je deinstalirate. Kliknite aplikaciju da je otvorite, ili da njezin prozor iznesete u prvi plan; kliknite ponovno da kružite kroz njezine prozore. Srednji klik otvara novi prozor. Povucite ikonu duž docka da je premjestite; povlačenje pokrenute aplikacije među ostale zadržava je ondje. Kliknite desnom tipkom da zadržite aplikaciju u docku, izvadite je iz njega ili je zatvorite. Dock se miče s puta prozoru na cijelom zaslonu. Desnom tipkom kliknite gumb za aplikacije da premjestite dock na drugi rub ili da se skriva dok pokazivač ne dosegne njegov rub. Položaj se također nalazi pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` postavljaju oboje iz terminala. Aplikacije koje držite u docku izblijedjele su dok se ne izvode.

Novi radni prostori, i svi kojima niste dali vlastiti raspored sa `Super + L`, koriste zadani raspored. Promjena zadanog vraća svaki radni prostor bez prozora na njega, dok onaj s prozorima na njemu zadržava raspored koji ima. Prozor minimiziran u dock i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberite ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy-hyprland-workspace-layout-default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozori se mogu grupirati koristeći `Super + G`. Kad ste u grupi, svaki prozor koji pokrenete dok je ona aktivna pripadat će grupi. Između tih grupiranih prozora možete se kretati koristeći `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da izravno odete na grupirani prozor po redu.

Prozor možete izbaciti iz grupe sa `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Na kraju, prozore izvan grupe možete u nju premjestiti sa `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možete izdvojiti iz njegove dodjele radnom prostoru sa `Super + O`. Time ćete ga prikvačiti kao plutajući prozor koji vas prati na koji god radni prostor odete. Izvrsno za videoplayere i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad radni prostor

Postoji poseban scratchpad radni prostor pune veličine koji se preklapa preko radnog prostora na kojem se trenutno nalazite. Onome što je na njemu pristupate koristeći `Super + S`, a prozore onamo postavljate koristeći `Super + Alt + S`.

Dobro funkcionira za kontrole ili terminal s kojim želite brzo raditi bez napuštanja trenutnog radnog prostora.

### Quake konzola

Na kraju, tu je Quake konzola polovične visine koja se spušta preko radnog prostora na kojem se trenutno nalazite. Uključujete je i isključujete sa `Super + Grave`, a prozor onamo postavljate koristeći `Super + Shift + Grave`.

Otvara se s vašim zadanim agentom spremnim za rad. Dok konzola drži jedan prozor, spušta se kao centrirana ploča umjesto da se proteže preko zaslona. Stavite na nju drugu aplikaciju i vraća se na punu širinu, tako da obje imaju mjesta sjediti jedna pokraj druge.

Da prozor maknete bilo sa scratchpada ili s konzole, pošaljite ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se naviknete ovako kretati svojom radnom površinom, ali kad se naviknete, bit će vam teško vratiti se tradicionalnom iskustvu radne površine upravljane mišem!
