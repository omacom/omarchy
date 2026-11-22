# Navigacija

Sve se u Omarchyju događa putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možete učiniti ništa samo mišem. Ali možete pritisnuti `Super + Space` da biste otkrili Omarchy izbornik i odavde možete učiniti gotovo sve.

Ali Omarchy izbornik većinu vremena čak nije ni zamišljen kao glavni način upravljanja sustavom. Možemo i brže od toga! Sve najvažnije aplikacije izravno su vezane uz pojedinačne prečace. Terminal pokrećete s `Super + Return`, a preglednik s `Super + Shift + Return`. Pokušajte učiniti jedno za drugim i vidjet ćete čaroliju Hyprlandova popločavanja na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Zatim možete pritisnuti `Super + J` da ih složite jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Pritisnite `Super + J` ponovno da ih vratite u položaj jedan pokraj drugoga. Zatim, dok ste u pregledniku, isprobajte `Super + Shift + Arrow Right` da zamijenite prozore.

Sada isprobajte `Super + Shift + T` da pokrenete Activity monitor. Pojavit će se kao plutajući prozor. Možete ga popločiti s pomoću `Super + T` (i pritisnite to ponovno da opet postane plutajući). Sada pritisnite `Super + Shift + F` da otvorite upravitelj datoteka. Dobit ćete uredan raspored s četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želite da bude aktivan krećete se s `Super + Arrow`. To će prebaciti fokus i pomaknuti pokazivač u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisnete `Super + Shift + 2`, premjestit ćete trenutačno fokusiranu aplikaciju na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutačno fokusiranu aplikaciju na drugi radni prostor bez prebacivanja na njega).

S više od jednog monitora, svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` ide na drugi radni prostor monitora na kojem se nalazite, a gornja traka svakog monitora prikazuje njegove radne prostore i onaj koji prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalazite. `Super + Shift + Ctrl + Arrows` pomiče prozor na kojem se nalazite na monitor u tom smjeru, na radni prostor koji on prikazuje, a `Super + Shift + Alt + Arrows` pomiče radni prostor na kojem se nalazite na monitor u tom smjeru, gdje zauzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga isključite: pridružuju se drugom zaslonu, numerirani nakon onih koje on već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držite `Super` i mišem kliknete na prozor, moći ćete preurediti gdje se nalazi. Ako držite `Super` i koristite desnu tipku miša, možete slobodno mijenjati veličinu prozora.

Prozor zatvarate s `Super + W` ili `Super + Q` (a sve prozore zatvarate s `Ctrl + Alt + Delete`).

Također možete prijeći na cijeli zaslon s `Super + F` ili čak samo na punu širinu (uz zadržavanje gornje trake) s `Super + Alt + F` ili na cijeli zaslon unutar prozora s `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle naspram scrolling rasporeda

Omarchyjev zadani raspored naziva se dwindle. Svi prozori koje otvorite na jednom radnom prostoru ostaju vidljivi u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali također možete odabrati pretvoriti radni prostor u scrolling raspored, gdje su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Jedan radni prostor u ovaj raspored pretvarate s pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, gdje se prozori slobodno preklapaju i sami ih postavljate, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih u suprotnom smjeru. Prozor koji ionako pluta — onaj koji ste izdvojili s `Super + T` ili aplikacija koja se uvijek otvara plutajuća — ostaje plutajući kad se radni prostor vrati na popločavanje. Gornja traka označava radni prostor na kojem se nalazite njegovim rasporedom: kvadrat za dwindle, krug za scrolling i trokut za plutajući. Klik na tu oznaku također kruži kroz rasporede, a to čini i tipka za zaslon na prijenosnim računalima koja je imaju.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbor se odnosi na svaki radni prostor zasebno i ostaje zapamćen. Tako radni prostor 1 možete držati na dwindleu za pregledavanje, a radni prostor 2 na scrollingu za kod, i vratit će se takvi nakon ponovnog pokretanja.

Ako želite koristiti scrolling raspored kao zadani, to možete postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a sami ih pomičete i mijenjate im veličinu. Svaki prozor dobiva naslovnu traku u bojama vaše teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; kliknite njegovu aplikaciju da ga vratite. Kliknite prozor da ga iznesete u prvi plan. Mijenjajte mu veličinu s bilo kojeg ruba ili kuta. Dvaput kliknite naslovnu traku da maksimizirate prozor uz zadržavanje gornje trake u vidnom polju, i ponovno da mu vratite staru veličinu. Chrome i drugi preglednici temeljeni na Chromiumu, Disks i Document Viewer preskaču naslovnu traku i umjesto nje koriste vlastito zaglavlje; `Super + Alt + F` ih maksimizira, a `Super + M` ih minimizira.

Plutajući radni prostor također prikazuje dock, s vašim prikvačenim aplikacijama, svime što je pokrenuto i mrežom svih aplikacija iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u Omarchy izborniku. Desnom tipkom miša kliknite aplikaciju na mreži, ili pritisnite `Delete`, da je deinstalirate. Kliknite aplikaciju da je otvorite, ili da iznesete njezin prozor u prvi plan; kliknite ponovno da kružite kroz njezine prozore. Files vraća samo prozor s radnog prostora na kojem se nalazite i inače otvara novi, a Terminal i Agent uvijek pokreću još jedan, iako se minimizirani prozor najprije vraća. Srednji klik otvara novi prozor. Povucite ikonu duž docka da je premjestite; povlačenje pokrenute aplikacije među ostale zadržava je ondje. Kliknite desnom tipkom miša da zadržite aplikaciju u docku, izvadite je ili je zatvorite. Dock se sklanja s puta prozoru preko cijelog zaslona. Desnom tipkom miša kliknite gumb za aplikacije da premjestite dock na drugi rub ili da se skriva dok pokazivač ne dođe do njegova ruba. Položaj je također pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` postavljaju oboje iz terminala. Aplikacije koje držite u docku izblijedjele su dok nisu pokrenute.

Novi radni prostori, i svi kojima niste dali vlastiti raspored s `Super + L`, koriste zadani raspored. Promjena zadanoga svaki radni prostor bez prozora vraća na njega, dok onaj s prozorima na sebi zadržava raspored koji ima. Minimizirani prozor u docku i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberite ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy hyprland workspace layout default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozori se mogu grupirati s pomoću `Super + G`. Kad ste u grupi, svaki prozor koji pokrenete dok je ona aktivna pripadat će grupi. Između tih grupiranih prozora možete se kretati s pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da izravno odete na grupirane prozore redom.

Prozor možete izbaciti iz grupiranja s `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Konačno, prozore izvan grupe možete u nju premjestiti s `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možete izdvojiti iz njegove dodjele radnom prostoru s `Super + O`. To će ga prikvačiti kao plutajući prozor koji vas prati na koji god radni prostor odete. Izvrsno za reproduktore videozapisa i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad radni prostor

Postoji poseban scratchpad radni prostor pune veličine koji prekriva radni prostor na kojem se trenutačno nalazite. Onome što je na njemu pristupate s pomoću `Super + S`, a prozore ondje postavljate s pomoću `Super + Alt + S`.

Dobro radi za kontrole ili terminal s kojim želite brzo raditi bez napuštanja trenutačnog radnog prostora.

### Quake konzola

Konačno, postoji Quake konzola polovične visine koja se spušta preko radnog prostora na kojem se trenutačno nalazite. Uključujete je i isključujete s `Super + Grave`, a prozor ondje postavljate s pomoću `Super + Shift + Grave`.

Prvi put kad se otvori, pokreće vašeg zadanog agenta, ili traži da odaberete jednoga ako ga još niste odabrali. Dok konzola sadrži jedan prozor, spušta se kao središnja ploča, a ne proteže se preko zaslona. Stavite drugu aplikaciju na nju i vraća se na punu širinu, tako da njih dvije imaju mjesta stajati jedna pokraj druge.

Da biste prozor premjestili sa scratchpada ili s konzole, pošaljite ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se naviknete ovako kretati radnom površinom, ali kad se naviknete, bit će vam teško vratiti se tradicionalnom iskustvu radne površine vođenom mišem!
