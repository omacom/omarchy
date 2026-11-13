# Navigacija

Sve u Omarchyju događa se putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možete učiniti ništa samo mišem. Ali možete pritisnuti `Super + Space` da biste otkrili Omarchy Menu i odavde možete učiniti gotovo sve.

Ali Omarchy menu čak nije ni zamišljen kao glavni način upravljanja sustavom većinu vremena. Možemo i brže od toga! Sve najvažnije aplikacije izravno su vezane uz pojedinačne tipkovničke prečace. Terminal pokrećete sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušajte učiniti jedno za drugim i vidjet ćete čaroliju Hyprlandova slaganja prozora na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Možete zatim pritisnuti `Super + J` da biste ih složili jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Ponovno pritisnite `Super + J` da biste ih vratili u položaj jedan pokraj drugoga. Zatim pokušajte `Super + Shift + Arrow Right` dok ste u pregledniku da biste zamijenili prozore.

Sada pokušajte `Super + Shift + T` da biste pokrenuli Activity monitor. On će se pojaviti kao plutajući prozor. Možete ga postaviti u raspored pločica pomoću `Super + T` (i ponovno pritisnite to da bi opet postao plutajući). Sada pritisnite `Super + Shift + F` da biste otvorili upravitelj datoteka. Imat ćete uredan raspored od četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želite da bude aktivan krećete se pomoću `Super + Arrow`. Time ćete prebaciti fokus i pomaknuti pokazivač u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisnete `Super + Shift + 2`, premjestit ćete trenutačno fokusiranu aplikaciju na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutačno fokusiranu aplikaciju na drugi radni prostor, a da se ne prebacite na njega).

Kad imate više od jednog monitora, svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` ide na drugi radni prostor monitora na kojem se nalazite, a gornja traka svakog monitora prikazuje njegove vlastite radne prostore i onaj koji trenutačno prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalazite. `Super + Shift + Ctrl + Arrows` premješta prozor na kojem se nalazite na monitor u tom smjeru, na radni prostor koji on prikazuje, a `Super + Shift + Alt + Arrows` premješta radni prostor na kojem se nalazite na monitor u tom smjeru, gdje preuzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga iskopčate: oni se pridružuju radnim prostorima drugog zaslona, numerirani iza onih koje on već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držite `Super` i mišem kliknete na prozor, moći ćete preurediti gdje se nalazi. Ako držite `Super` i koristite desnu tipku miša, možete slobodno mijenjati veličinu prozora.

Prozor zatvarate sa `Super + W` ili `Super + Q` (a sve prozore zatvarate sa `Ctrl + Alt + Delete`).

Možete i prijeći na cijeli zaslon sa `Super + F` ili čak samo na punu širinu (zadržavajući gornju traku) sa `Super + Alt + F` ili na cijeli zaslon unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Raspored dwindle naspram pomičnog rasporeda

Omarchyjev zadani raspored zove se dwindle. On drži sve prozore koje otvorite na jednom radnom prostoru vidljivima u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali možete odabrati i pretvoriti radni prostor u pomični raspored u kojem su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Pojedinačni radni prostor pretvarate u ovaj raspored pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, u kojem se prozori slobodno preklapaju i sami ih postavljate, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih u suprotnom smjeru. Prozor koji ionako pluta — onaj koji ste izbacili pomoću `Super + T` ili aplikacija koja se uvijek otvara plutajuća — ostaje plutajući kad se radni prostor vrati na slaganje u pločice. Gornja traka označava radni prostor na kojem se nalazite njegovim rasporedom: kvadrat za dwindle, krug za pomični i trokut za plutajući. Klik na tu oznaku također kruži kroz rasporede.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbor je po radnom prostoru i ostaje zapamćen. Tako možete zadržati radni prostor 1 na dwindleu za pregledavanje, a radni prostor 2 na pomičnom za kod, i vratit će se takvi nakon ponovnog pokretanja.

Ako želite koristiti pomični raspored kao zadani, to možete postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a vi ih sami premještate i mijenjate im veličinu. Svaki prozor dobiva naslovnu traku u bojama vaše teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; kliknite njegovu aplikaciju da biste ga vratili. Kliknite prozor da biste ga doveli u prvi plan. Mijenjajte mu veličinu s bilo kojeg ruba ili kuta. Dvaput kliknite naslovnu traku da biste maksimizirali prozor, a da gornja traka ostane vidljiva, i ponovno da biste mu vratili staru veličinu. Chrome i drugi preglednici temeljeni na Chromiumu, Disks i Document Viewer preskaču naslovnu traku i umjesto nje koriste vlastito zaglavlje; `Super + Alt + F` ih maksimizira, a `Super + M` ih minimizira.

Plutajući radni prostor također prikazuje dock, s vašim prikvačenim aplikacijama, svime što je pokrenuto i mrežom svih aplikacija iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u Omarchy menuu. Desnom tipkom miša kliknite aplikaciju na mreži ili pritisnite `Delete` da biste je deinstalirali. Kliknite aplikaciju da biste je otvorili ili da biste doveli njezin prozor u prvi plan; kliknite ponovno da biste kružili kroz njezine prozore. Srednji klik otvara novi prozor. Povucite ikonu duž docka da biste je premjestili; povlačenje pokrenute aplikacije među ostale zadržava je ondje. Kliknite desnom tipkom da biste zadržali aplikaciju u docku, izvadili je iz njega ili je zatvorili. Dock se sklanja s puta prozoru preko cijelog zaslona. Kliknite desnom tipkom gumb za aplikacije da biste premjestili dock na drugi rub ili da biste ga sakrili dok pokazivač ne dosegne njegov rub. Položaj je također pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` oboje postavljaju iz terminala. Aplikacije koje držite u docku izblijedjele su dok nisu pokrenute.

Novi radni prostori, i svi kojima niste dali vlastiti raspored pomoću `Super + L`, koriste zadani raspored. Promjena zadanog rasporeda vraća svaki radni prostor bez prozora na njega, dok onaj s prozorima na njemu zadržava raspored koji ima. Prozor minimiziran u dock i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberite ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy-hyprland-workspace-layout-default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozori se mogu grupirati pomoću `Super + G`. Kad ste u grupi, svaki prozor koji pokrenete dok je ona aktivna pripadat će grupi. Između ovih grupiranih prozora možete se kretati pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da biste izravno otišli na grupirane prozore po redu.

Možete premjestiti prozor izvan grupiranja pomoću `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Konačno, prozore izvan grupe možete premjestiti u nju pomoću `Super + Alt + Arrows`.

### Iskočni prozori

Prozor možete izbaciti iz njegove dodjele radnom prostoru pomoću `Super + O`. Time ćete ga prikvačiti kao plutajući prozor koji vas prati na koji god radni prostor odete. Odlično za videoreproduktore i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad radni prostor

Postoji poseban scratchpad radni prostor pune veličine koji prekriva radni prostor na kojem se trenutačno nalazite. Onome što je na njemu pristupate pomoću `Super + S`, a prozore ondje postavljate pomoću `Super + Alt + S`.

Dobro radi za kontrole ili terminal s kojim želite brzo komunicirati, a da ne napustite trenutačni radni prostor.

### Quake konzola

Konačno, postoji Quake konzola polovične visine koja se spušta preko radnog prostora na kojem se trenutačno nalazite. Uključujete je i isključujete pomoću `Super + Grave`, a prozor ondje postavljate pomoću `Super + Shift + Grave`.

Otvara se s vašim zadanim agentom spremnim za rad. Dok konzola drži jedan prozor, spušta se kao središnja ploča umjesto da se proteže preko zaslona. Stavite drugu aplikaciju na nju i vraća se na punu širinu, tako da dvije imaju mjesta sjediti jedna pokraj druge.

Da biste premjestili prozor sa scratchpada ili s konzole, pošaljite ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti na to!

Treba malo vremena da se naviknete kretati radnom površinom na ovaj način, ali kad se naviknete, bit će vam teško vratiti se tradicionalnom iskustvu radne površine kojom se upravlja mišem!
