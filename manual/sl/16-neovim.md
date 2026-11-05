# Neovim

[Neovim](https://neovim.io/) je sodobna izvedba [urejevalnika vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), ki ga je že leta 1976 ustvaril Bill Joy. Je modalni urejevalnik, v katerem sta način vstavljanja in ukazni način ločena, in je nekakšna supermoc, ko se naučite tudi samo podmnožico neverjetno globokega nabora tipkovnih ukazov. Ampak gre tudi za precejšnjo učno krivuljo!

Če ste z urejanjem v slogu vima povsem novi, priporočam, da si na YouTubu ogledate [serijo ThePrimeagena Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R). Ta vas bo naučila osnov. Samo vedite, da vam bo za razliko od bolj podobnih uveljavljenih urejevalnikov za osnovno spretnost z vimom vzelo več časa. Ko pa vam bo uspelo, bo tudi izkupiček večji.

Zdaj, Neovim je v bistvu neskončno konfigurabilen. Če res želite podivjati, lahko ustvarite lastno konfiguracijo Neovima od nič. Obstaja odličen tečaj Typecrafta o [nastavitvi Neovima od nič](https://www.youtube.com/watch?v=zHTeCSVAFNY). In [ThePrimeagen ga ima tudi](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ampak Omarchy je dobavljen s celovito namestitvijo Neovima — paketom `omarchy-nvim` — ki je bila z ljubeznijo uglašena, da pokaže najboljše, kar je mogoče že takoj po namestitvi. Brez da bi vam bilo treba napisati eno samo vrstico konfiguracije! Zgrajena je na [LazyVimu](https://www.lazyvim.org/), distribuciji vtičnikov in konfiguracij Neovima. Je izvrstna.

## Osnove LazyVima

Kot omenjeno, vas v tem kratkem uvodu ne bom učil vima, lahko pa vam pokažem nekaj osnov LazyVima in kako se premikati.

Prvič, Neovim pozna pojem vodilne tipke (leader). Ta je v bistvu vrata do vseh ukazov. LazyVim jo je nastavil na `Space`. Samo pritisnite to, počakajte sekundo in videli boste kup možnosti, razloženih vdelano takole:

Tukaj je nekaj osnovnih ukazov, ki jih ves čas uporabljam:

- `Space Space` - Nejasno iskanje katere koli datoteke v trenutnem imeniku.
- `Space S G` - Iskanje po vseh datotekah z grepom s predogledom.
- `Space E` - Preklop datotečnega drevesa vklop/izklop.
- `Ctrl + W W` - Skok iz datotečnega drevesa v urejevalnik in nazaj.
- `Shift + H` - Pomik levo med odprtimi zavihki (vim jim pravi medpomnilniki).
- `Shift + L` - Pomik desno med odprtimi zavihki.
- `Space B D` - Zapiranje zavihka.
- `Space B O` - Zapiranje vseh drugih zavihkov razen trenutnega.
- `Space G G` - Zagon LazyGita v lebdečem podoknu iz trenutnega imenika.
- `Space U W` - Preklop mehkega preloma.

Medtem ko ste v datotečnem drevesu (`Space E` za razkritje, `Ctrl + W W` za skok tja), lahko novo datoteko dodate z `a`, nov imenik pa z `A`. V drevesu pritisnite `?`, da vidite vse ukaze.

Če želite pobrati osnovni jezik vima, sem pisal o [tridelni sintaksi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) in o tem, kako izvesti tiste bolne kombinirane poteze!

Vse možne ukaze si lahko ogledate na [strani LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Zagon Neovima

Neovim lahko zaženete s `Super + Shift + N` (vezava zažene vaš privzeti urejevalnik, kar je takoj po namestitvi Neovim), običajno pa ga je lažje voditi iz terminala tako, da se pomaknete v imenik, v katerem želite delati, in vtipkate `n`. `n` je vzdevek za `nvim`, ki bo privzeto odprl sedanji imenik. Posamezno datoteko lahko odprete z `n myfile.txt`.

## Uporaba Neovima za urejanje s sudo

Če morate urejati datoteke, ki jih lahko spreminjate samo kot superuporabnik, lahko Neovim z vsemi svojimi vtičniki uporabite tako, da zaženete `sudoedit /etc/sudoers.d/00-sudo-only-file`.
