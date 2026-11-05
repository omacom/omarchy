# Navigacija

Sve u Omarchyju događa se putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možete učiniti ništa samo mišem. Ali možete pritisnuti `Super + Space` da biste otkrili izbornik Omarchy i odavde možete učiniti gotovo sve.

Ali izbornik Omarchy nije ni zamišljen kao glavni način upravljanja sustavom većinu vremena. Možemo i brže od toga! Sve najvažnije aplikacije izravno su vezane uz pojedinačne tipkovničke prečace. Terminal pokrećete sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušajte učiniti jedno za drugim i vidjet ćete čaroliju Hyprlandova popločavanja na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Zatim možete pritisnuti `Super + J` da biste ih složili jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Pritisnite `Super + J` ponovno da biste ih vratili u položaj jedan pokraj drugoga. Zatim pokušajte sa `Super + Shift + Arrow Right` dok ste u pregledniku da biste zamijenili prozore.

Sada pokušajte sa `Super + Shift + T` da biste pokrenuli monitor aktivnosti. Pojavit će se kao plutajući prozor. Možete ga popločiti pomoću `Super + T` (i pritisnite to ponovno da bi opet postao plutajući). Sada pritisnite `Super + Shift + F` da biste otvorili upravitelj datoteka. Imat ćete uredan raspored s četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želite aktivirati krećete se pomoću `Super + Arrow`. To će prebaciti fokus i pomaknuti pokazivač u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisnete `Super + Shift + 2`, premjestit ćete trenutačno fokusiranu aplikaciju na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutačno fokusiranu aplikaciju na drugi radni prostor bez prebacivanja na njega).

S više od jednog monitora svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` vodi na drugi radni prostor monitora na kojem se nalazite, a gornja traka svakog monitora prikazuje njegove vlastite radne prostore i onaj koji prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalazite. `Super + Shift + Ctrl + Arrows` premješta prozor na kojem se nalazite na monitor u tom smjeru, na radni prostor koji on prikazuje, a `Super + Shift + Alt + Arrows` premješta radni prostor na kojem se nalazite na monitor u tom smjeru, gdje preuzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga isključite: pridružuju se onima drugog zaslona, numerirani nakon onih koje on već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držite `Super` i mišem kliknete na prozor, moći ćete promijeniti gdje se nalazi. Ako držite `Super` i upotrijebite desnu tipku miša, možete slobodno mijenjati veličinu prozora.

Prozor zatvarate sa `Super + W` ili `Super + Q` (a sve prozore zatvarate sa `Ctrl + Alt + Delete`).

Također možete prijeći na cijeli zaslon sa `Super + F` ili čak samo na punu širinu (zadržavajući gornju traku) sa `Super + Alt + F` ili na cijeli zaslon unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle naspram pomičnog rasporeda

Zadani raspored u Omarchyju zove se dwindle. Sve prozore koje otvorite na jednom radnom prostoru drži vidljivima u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali također možete odabrati pretvoriti radni prostor u pomični raspored, u kojem su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Jedan radni prostor u taj raspored pretvarate pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, u kojem se prozori slobodno preklapaju i sami ih postavljate, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih u suprotnom smjeru. Prozor koji ionako pluta — onaj koji ste izdvojili pomoću `Super + T` ili aplikacija koja se uvijek otvara kao plutajuća — ostaje plutajući kad se radni prostor vrati na popločavanje. Gornja traka označava radni prostor na kojem se nalazite njegovim rasporedom: kvadrat za dwindle, krug za pomični i trokut za plutajući. Klik na tu oznaku također kruži kroz rasporede.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbor vrijedi po radnom prostoru i ostaje zapamćen. Tako radni prostor 1 možete držati na dwindleu za pregledavanje, a radni prostor 2 na pomičnom rasporedu za kod, i vratit će se takvi nakon ponovnog pokretanja.

Ako pomični raspored želite koristiti kao zadani, to možete postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a vi ih sami premještate i mijenjate im veličinu. Svaki prozor dobiva naslovnu traku u bojama vaše teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; kliknite njegovu aplikaciju da biste ga vratili. Kliknite prozor da biste ga iznijeli u prvi plan. Mijenjajte mu veličinu s bilo kojeg ruba ili kuta. Dvokliknite naslovnu traku da biste maksimizirali prozor, a da gornja traka ostane vidljiva, i ponovno da biste mu vratili staru veličinu.

Plutajući radni prostor također prikazuje dock, s vašim prikvačenim aplikacijama, svime što se izvodi i mrežom svih aplikacija iza gumba za aplikacije, koju također otvaraju `Super + Alt + Space` i _Apps_ u izborniku Omarchy. Desnom tipkom miša kliknite aplikaciju na mreži ili pritisnite `Delete` da biste je deinstalirali. Kliknite aplikaciju da biste je otvorili ili da biste njezin prozor iznijeli u prvi plan; kliknite ponovno da biste kružili kroz njezine prozore. Srednji klik otvara novi prozor. Povucite ikonu duž docka da biste je premjestili; povlačenjem pokrenute aplikacije među ostale zadržavate je ondje. Desnom tipkom miša kliknite da biste aplikaciju zadržali u docku, uklonili je iz njega ili je zatvorili. Dock se miče s puta prozoru preko cijelog zaslona. Desnom tipkom miša kliknite gumb za aplikacije da biste dock premjestili na drugi rub ili da biste ga sakrili dok pokazivač ne dosegne njegov rub. Položaj se nalazi i pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` postavljaju oboje iz terminala. Aplikacije koje držite u docku izblijedjele su dok se ne izvode.

Novi radni prostori, i svi kojima niste dodijelili vlastiti raspored pomoću `Super + L`, koriste zadani raspored. Promjena zadanog rasporeda vraća na njega svaki radni prostor bez prozora, dok onaj s prozorima zadržava raspored koji ima. Prozor minimiziran u dock i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberite ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy-hyprland-workspace-layout-default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozore možete grupirati pomoću `Super + G`. Kad ste u grupi, svaki prozor koji pokrenete dok je ona aktivna pripadat će grupi. Između tih grupiranih prozora možete se kretati pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da biste izravno otišli na grupirane prozore redom.

Prozor možete premjestiti izvan grupiranja pomoću `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Na kraju, prozore izvan grupe možete premjestiti u nju pomoću `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možete izdvojiti iz njegove dodjele radnom prostoru pomoću `Super + O`. To će ga prikvačiti kao plutajući prozor koji vas prati na koji god radni prostor odete. Odlično za videoreproduktore i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Radni prostor scratchpad

Postoji poseban radni prostor scratchpad pune veličine koji se preklapa preko radnog prostora na kojem se trenutačno nalazite. Onome što je na njemu pristupate pomoću `Super + S`, a prozore ondje postavljate pomoću `Super + Alt + S`.

Dobro funkcionira za kontrole ili terminal s kojim želite brzo raditi bez napuštanja trenutačnog radnog prostora.

### Konzola Quake

Na kraju, tu je konzola Quake polovične visine koja se spušta preko radnog prostora na kojem se trenutačno nalazite. Uključujete je i isključujete pomoću `Super + Grave`, a prozor ondje postavljate pomoću `Super + Shift + Grave`.

Otvara se s vašim zadanim agentom spremnim za rad. Dok konzola sadrži jedan prozor, spušta se kao središnja ploča umjesto da se proteže preko zaslona. Stavite drugu aplikaciju na nju i vraća se na punu širinu, pa obje imaju mjesta da stoje jedna pokraj druge.

Da biste prozor premjestili s scratchpada ili konzole, pošaljite ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se naviknete ovako kretati po svojoj radnoj površini, ali kad se naviknete, bit će vam teško vratiti se tradicionalnom iskustvu radne površine vođenom mišem!
