# Navigacija

Sve u Omarchyju događa se putem tipkovnice — _SVE!_ Kad se sustav prvi put pokrene, doslovno ne možete učiniti ništa samo mišem. Ali možete pritisnuti `Super + Space` da otkrijete Omarchy Menu i odavde možete učiniti gotovo sve.

Ali izbornik Omarchy čak ni nije zamišljen kao glavni način upravljanja sustavom većinu vremena. Možemo brže od toga! Sve najvažnije aplikacije izravno su povezane s pojedinačnim tipkovničkim prečacima. Terminal pokrećete sa `Super + Return`, a preglednik sa `Super + Shift + Return`. Pokušajte učiniti jedno za drugim i vidjet ćete čaroliju Hyprlandova pločastog slaganja prozora na djelu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Zatim možete pritisnuti `Super + J` da ih složite jedan na drugi umjesto jedan pokraj drugoga:

 ![navigation-stacked](images/navigation-stacked.webp)

Ponovno pritisnite `Super + J` da ih vratite u položaj jedan pokraj drugoga. Zatim, dok ste u pregledniku, pokušajte sa `Super + Shift + Arrow Right` da zamijenite prozore.

Sada pokušajte sa `Super + Shift + T` da pokrenete Activity monitor. On će se pojaviti kao plutajući prozor. Možete ga postaviti u pločasti raspored pomoću `Super + T` (i ponovno pritisnuti isto da opet postane plutajući). Sada pritisnite `Super + Shift + F` da otvorite upravitelj datoteka. Imat ćete uredan četverostruki raspored:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Između prozora koji želite da bude aktivan krećete se pomoću `Super + Arrow`. To će prebaciti fokus i pomaknuti pokazivač u središte nove aplikacije. Na rubu zaslona nastavlja se na monitor s te strane.

Ako pritisnete `Super + Shift + 2`, trenutno fokusiranu aplikaciju premjestit ćete na drugi radni prostor. `Super + Shift + 1` vraća je natrag. (A `Super + Shift + Alt + 2` premjestit će trenutno fokusiranu aplikaciju na drugi radni prostor, a da se ne prebacite na njega).

S više od jednog monitora, svaki monitor ima vlastite radne prostore od 1 do 10. `Super + 2` odlazi na drugi radni prostor monitora na kojem se nalazite, a gornja traka svakog monitora prikazuje njegove radne prostore i onaj koji trenutačno prikazuje. `Super + Tab` kruži kroz radne prostore na monitoru na kojem se nalazite. `Super + Shift + Ctrl + Arrows` premješta prozor na kojem se nalazite na monitor u tom smjeru, na radni prostor koji taj monitor prikazuje, a `Super + Shift + Alt + Arrows` premješta radni prostor na kojem se nalazite na monitor u tom smjeru, gdje preuzima isti broj ako je slobodan. Monitor zadržava svoje radne prostore kad ga isključite: pridružuju se drugome zaslonu, numerirani nakon onih koje taj već ima, i vraćaju se pod svoje stare brojeve kad se monitor vrati.

Ako držite `Super` i mišem kliknete na prozor, moći ćete promijeniti gdje se nalazi. Ako držite `Super` i koristite desnu tipku miša, možete slobodno mijenjati veličinu prozora.

Prozor zatvarate sa `Super + W` ili `Super + Q` (a sve prozore zatvarate sa `Ctrl + Alt + Delete`).

Također možete prijeći u prikaz preko cijelog zaslona sa `Super + F` ili čak samo u punu širinu (uz zadržavanje gornje trake) sa `Super + Alt + F` ili u prikaz preko cijelog zaslona unutar prozora sa `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle naspram scrolling rasporeda

Omarchyjev zadani raspored zove se dwindle. Sve prozore koje otvorite na jednom radnom prostoru održava vidljivima u svakom trenutku, čak i ako ih za to mora smanjiti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ali također možete odabrati radni prostor pretvoriti u scrolling raspored, u kojem su prozori poredani jedan pokraj drugoga, izvan vidljivog ruba zaslona. Pojedini radni prostor u ovaj raspored pretvarate pomoću `Super + L`.

Ponovnim pritiskom na `Super + L` radni prostor postaje plutajući, u kojem se prozori slobodno preklapaju i sami ih postavljate, a treći pritisak vraća ga na dwindle. `Super + Alt + L` prolazi kroz njih u suprotnom smjeru. Prozor koji ionako pluta — onaj koji ste izbacili pomoću `Super + T` ili aplikacija koja se uvijek otvara plutajuća — nastavlja plutati kad se radni prostor vrati na pločasti raspored. Gornja traka označava radni prostor na kojem se nalazite njegovim rasporedom: kvadratom za dwindle, krugom za scrolling i trokutom za plutajući. Klik na tu oznaku također kruži kroz rasporede.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbor vrijedi po radnom prostoru i ostaje spremljen. Tako možete radni prostor 1 držati na dwindleu za pregledavanje, a radni prostor 2 na scrollingu za kod, i vratit će se takvi nakon ponovnog pokretanja.

Ako želite koristiti scrolling raspored kao zadani, to možete postaviti u `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plutajući radni prostori

Plutajući radni prostor radi kao tradicionalna radna površina: prozori se preklapaju, a sami ih pomičete i mijenjate im veličinu. Svaki prozor dobiva naslovnu traku u bojama vaše teme, s gumbima za minimiziranje, maksimiziranje i zatvaranje. `Super + M` također minimizira fokusirani prozor. Minimizirani prozor čeka u docku; kliknite njegovu aplikaciju da ga vratite. Kliknite prozor da ga iznesete u prvi plan. Mijenjajte mu veličinu s bilo kojeg ruba ili kuta. Dvokliknite naslovnu traku da maksimizirate prozor uz zadržavanje gornje trake u vidljivom polju, i ponovno da mu vratite staru veličinu. Chrome i drugi preglednici temeljeni na Chromiumu, Disks i Document Viewer preskaču naslovnu traku i umjesto nje koriste vlastito zaglavlje; `Super + Alt + F` ih maksimizira, a `Super + M` ih minimizira.

Plutajući radni prostor također prikazuje dock, s vašim prikvačenim aplikacijama, svime što se izvodi i mrežom svake aplikacije iza gumba za aplikacije, koji također otvaraju `Super + Alt + Space` i _Apps_ u izborniku Omarchy. Desnom tipkom miša kliknite aplikaciju na mreži, ili pritisnite `Delete`, da je deinstalirate. Kliknite aplikaciju da je otvorite ili da njezin prozor iznesete u prvi plan; kliknite ponovno da kružite kroz njezine prozore. Files vraća samo prozor s radnog prostora na kojem se nalazite i u suprotnom otvara novi, a Terminal i Agent uvijek pokreću još jedan, iako se minimizirani prozor vraća prvi. Srednji klik otvara novi prozor. Povucite ikonu duž docka da je premjestite; povlačenjem pokrenute aplikacije među ostale ona tamo ostaje. Kliknite desnom tipkom da aplikaciju zadržite u docku, izvadite je ili je zatvorite. Dock se uklanja s puta prozoru preko cijelog zaslona. Desnom tipkom kliknite gumb za aplikacije da dock premjestite na drugi rub ili da se skriva dok pokazivač ne dosegne njegov rub. Položaj je također pod _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` oboje postavljaju s terminala. Aplikacije koje držite u docku izblijeđene su dok se ne izvode.

Novi radni prostori, i svi kojima niste dali vlastiti raspored pomoću `Super + L`, koriste zadani raspored. Promjena zadanoga vraća svaki radni prostor bez prozora na njega, dok onaj s prozorima na sebi zadržava raspored koji ima. Prozor minimiziran u dock i dalje se računa kao prozor na radnom prostoru koji je napustio. Odaberite ga pod _Appearance > Workspace Layout_: Tiling, Scrolling ili Floating. `omarchy-hyprland-workspace-layout-default scrolling` postavlja ga s terminala.

### Grupiranje prozora

Prozori se mogu grupirati pomoću `Super + G`. Kad se nađete u grupi, svaki prozor koji pokrenete dok je to aktivno pripadat će grupi. Između tih grupiranih prozora možete se kretati pomoću `Super + Ctrl + Arrow Left/Right` ili `Super + Alt + 1/2/3/4` da odete izravno na grupirane prozore po redu.

Prozor možete izvesti iz grupe pomoću `Super + Alt + G` ili rastaviti cijelu grupu ponovnim pritiskom na `Super + G`. Naposljetku, prozore izvan grupe možete u nju premjestiti pomoću `Super + Alt + Arrows`.

### Izdvajanje prozora

Prozor možete izdvojiti iz njegove dodjele radnom prostoru pomoću `Super + O`. To će ga prikvačiti kao plutajući prozor koji vas prati na koji god radni prostor odete. Izvrsno za reproduktore videozapisa i slično.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Radni prostor scratchpad

Postoji poseban radni prostor scratchpad pune veličine koji prekriva radni prostor na kojem se trenutačno nalazite. Onome što je na njemu pristupate pomoću `Super + S`, a prozore na njega postavljate pomoću `Super + Alt + S`.

Dobro funkcionira za kontrole ili terminal s kojim želite brzo raditi, a da ne napustite trenutačni radni prostor.

### Konzola Quake

Naposljetku, postoji konzola Quake upola visine koja se spušta preko radnog prostora na kojem se trenutačno nalazite. Uključujete je i isključujete pomoću `Super + Grave`, a prozor na nju postavljate pomoću `Super + Shift + Grave`.

Otvara se s vašim zadanim agentom spremnim za rad. Dok konzola drži jedan prozor, spušta se kao centrirana ploča, umjesto da se proteže preko zaslona. Stavite na nju drugu aplikaciju i vraća se na punu širinu, tako da oboje imaju mjesta da sjede jedan pokraj drugoga.

Da prozor uklonite sa scratchpada ili konzole, pošaljite ga izravno na drugi radni prostor nečime poput `Super + Shift + 1`.

### Treba se malo naviknuti!

Treba malo vremena da se naviknete na ovakvo kretanje po radnoj površini, ali kad se naviknete, teško ćete se vratiti na tradicionalno iskustvo radne površine upravljane mišem!
