# Navigacija

Sve se u Omarchyju događa putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možeš učiniti ništa samo mišem. Ali možeš pritisnuti `Super + Space` da otkriješ Omarchy Menu i odavde možeš učiniti gotovo sve.

Ali Omarchy menu čak ni nije zamišljen kao glavni način upravljanja sustavom većinu vremena. Možemo i brže od toga! Sve najvažnije aplikacije izravno su vezane za pojedinačne tipkovničke prečace. Terminal pokrećeš sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušaj učiniti jedno za drugim i vidjet ćeš Hyprlandovu čaroliju slaganja prozora na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Zatim možeš pritisnuti `Super + J` da ih složiš jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Ponovno pritisni `Super + J` da ih vratiš u položaj jedan pokraj drugoga. Zatim, dok si u pregledniku, pokušaj `Super + Shift + Arrow Right` da zamijeniš prozore.

Sada pokušaj `Super + Shift + T` da pokreneš Activity monitor. Pojavit će se kao plutajući prozor. Možeš ga rasporediti bez preklapanja pomoću `Super + T` (i ponovno pritisnuti istu kombinaciju da opet postane plutajući). Sada pritisni `Super + Shift + F` da otvoriš upravitelj datoteka. Imat ćeš urednu postavu od četiri prozora:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora pomoću `Super + Arrow` prelaziš na onaj koji želiš da bude aktivan. Time se mijenja fokus i pokazivač se pomiče u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisneš `Super + Shift + 2`, trenutačno fokusiranu aplikaciju premjestit ćeš na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutačno fokusiranu aplikaciju na drugi radni prostor, a da ne prijeđeš na njega).

S više od jednog monitora, svaki monitor ima svoje radne prostore od 1 do 10. `Super + 2` ide na drugi radni prostor monitora na kojem se nalaziš, a gornja traka svakog monitora prikazuje njegove radne prostore i onaj koji trenutačno prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalaziš. `Super + Shift + Ctrl + Arrows` premješta prozor na kojem se nalaziš na monitor u tom smjeru, na radni prostor koji on prikazuje, a `Super + Shift + Alt + Arrows` premješta radni prostor na kojem se nalaziš na monitor u tom smjeru, gdje preuzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga isključiš: pridružuju se radnim prostorima drugog zaslona, numerirani nakon onih koje on već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držiš pritisnut `Super` i mišem klikneš na prozor, moći ćeš mu promijeniti položaj. Ako držiš `Super` i koristiš desnu tipku miša, možeš slobodno mijenjati veličinu prozora.

Prozor zatvaraš sa `Super + W` ili `Super + Q` (a sve prozore zatvaraš sa `Ctrl + Alt + Delete`).

Možeš i prijeći na cijeli zaslon sa `Super + F` ili čak samo na punu širinu (uz zadržavanje gornje trake) sa `Super + Alt + F` ili na cijeli zaslon unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle naspram scrolling rasporeda

Zadani raspored u Omarchyju zove se dwindle. Sve prozore koje otvoriš na jednom radnom prostoru drži vidljivima u svakom trenutku, čak i ako ih mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali također možeš odabrati pretvoriti radni prostor u scrolling raspored, u kojem su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Jedan radni prostor u taj raspored pretvaraš pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, u kojem se prozori slobodno preklapaju i sam ih postavljaš, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih obrnutim redoslijedom. Prozor koji ionako pluta — onaj koji si izdvojio sa `Super + T` ili aplikacija koja se uvijek otvara kao plutajuća — ostaje plutajući kad se radni prostor vrati na slaganje prozora bez preklapanja. Gornja traka označava radni prostor na kojem se nalaziš njegovim rasporedom: kvadrat za dwindle, krug za scrolling i trokut za plutajući. Klik na tu oznaku također kruži kroz rasporede, a isto čini i tipka za zaslon na prijenosnim računalima koja je imaju.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbor se odnosi na pojedini radni prostor i ostaje spremljen. Tako radni prostor 1 možeš držati na dwindleu za pregledavanje, a radni prostor 2 na scrollingu za kod, i vratit će se tako nakon ponovnog pokretanja.

Ako scrolling raspored želiš koristiti kao zadani, to možeš postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi poput tradicionalne radne površine: prozori se preklapaju, a ti ih sam pomičeš i određuješ im veličinu. Svaki prozor dobiva naslovnu traku u bojama tvoje teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; klikni njegovu aplikaciju da ga vratiš. Klikni prozor da ga dovedeš u prvi plan. Veličinu mu mijenjaj s bilo kojeg ruba ili kuta. Dvoklikni naslovnu traku da maksimiziraš prozor uz zadržavanje gornje trake u vidokrugu, i ponovno da mu vratiš staru veličinu. Chrome i drugi preglednici temeljeni na Chromiumu, Disks i Document Viewer preskaču naslovnu traku i umjesto nje koriste vlastito zaglavlje; `Super + Alt + F` ih maksimizira, a `Super + M` ih minimizira.

Plutajući radni prostor također prikazuje dock, s tvojim prikvačenim aplikacijama, svime što je trenutačno pokrenuto i mrežom svih aplikacija iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u Omarchy izborniku. Desnom tipkom miša klikni aplikaciju na mreži ili pritisni `Delete` da je deinstaliraš. Klikni aplikaciju da je otvoriš ili da njezin prozor dovedeš u prvi plan; klikni ponovno da kružiš kroz njezine prozore. Files vraća samo prozor s radnog prostora na kojem se nalaziš i u suprotnom otvara novi, a Terminal i Agent uvijek pokreću još jedan, iako se minimizirani prozor vraća prvi. Srednji klik otvara novi prozor. Povuci ikonu duž docka da je premjestiš; povlačenje pokrenute aplikacije među ostale zadržava je ondje. Desnom tipkom miša klikni da aplikaciju zadržiš u docku, ukloniš je iz docka ili je u potpunosti zatvoriš. Dock se pomiče s puta prozoru koji je preko cijelog zaslona. Desnom tipkom miša klikni gumb za aplikacije da dock premjestiš na drugi rub ili da se skriva dok pokazivač ne dosegne njegov rub. Položaj se nalazi i pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` oboje postavljaju iz terminala. Aplikacije koje držiš u docku izblijedjele su dok nisu pokrenute.

Novi radni prostori, i svi kojima nisi dao vlastiti raspored pomoću `Super + L`, koriste zadani raspored. Promjena zadanog rasporeda vraća svaki radni prostor bez prozora na njega, dok onaj s prozorima na sebi zadržava raspored koji ima. Prozor minimiziran u dock i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberi ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy hyprland workspace layout default scrolling` postavlja ga iz terminala.

### Grupiranje prozora

Prozore možeš grupirati pomoću `Super + G`. Kad se nađeš u grupi, svaki prozor koji pokreneš dok je ona aktivna pripadat će grupi. Između tih grupiranih prozora možeš se kretati pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da izravno prijeđeš na grupirane prozore po redu.

Prozor možeš izbaciti iz grupe pomoću `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Na kraju, prozore izvan grupe možeš premjestiti u nju pomoću `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možeš izdvojiti iz njegove dodjele radnom prostoru pomoću `Super + O`. Time ćeš ga prikvačiti kao plutajući prozor koji te prati na koji god radni prostor prijeđeš. Izvrsno za reproduktore videozapisa i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad radni prostor

Postoji poseban scratchpad radni prostor pune veličine koji prekriva radni prostor na kojem se trenutačno nalaziš. Sadržaju na njemu pristupaš pomoću `Super + S`, a prozore ondje postavljaš pomoću `Super + Alt + S`.

Dobro funkcionira za kontrole ili terminal s kojim želiš brzo komunicirati, a da ne napustiš trenutačni radni prostor.

### Quake konzola

Na kraju, tu je Quake konzola u pola visine koja se spušta preko radnog prostora na kojem se trenutačno nalaziš. Uključuješ je i isključuješ pomoću `Super + the key above Tab` (grave na US rasporedima), a prozor ondje postavljaš pomoću `Super + Shift + the key above Tab`.

Kad se prvi put otvori, pokreće tvog zadanog agenta ili te pita da ga odabereš ako ga još nisi odabrao. Dok konzola sadrži jedan prozor, spušta se kao centrirana ploča, umjesto da se proteže preko zaslona. Stavi drugu aplikaciju na nju i vraća se na punu širinu, pa dvije aplikacije imaju mjesta da stoje jedna pokraj druge.

Da prozor premjestiš sa scratchpada ili konzole, pošalji ga izravno na drugi radni prostor nečim poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se navikneš ovako kretati radnom površinom, ali kad se navikneš, teško će ti biti vratiti se tradicionalnom iskustvu radne površine upravljane mišem!
