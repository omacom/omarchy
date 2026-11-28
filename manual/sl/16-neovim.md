# Neovim

[Neovim](https://neovim.io/) je sodobna izvedba [urejevalnika vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), ki ga je Bill Joy ustvaril že davnega leta 1976. Je modalni urejevalnik, pri katerem sta način vstavljanja in ukazni način ločena, in ko se naučite vsaj del neverjetno obsežnega nabora tipkovnih ukazov, je to prava supermoc. Toda krivulja učenja je tudi precej strma!

Če ste pri urejanju v slogu vim popolni začetnik, vam priporočam, da si na YouTube ogledate [serijo ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R). Ta vas bo naučila osnov. Le vedite, da vam bo v primerjavi z bolj podobnimi množičnimi urejevalniki trajalo dlje, da boste z vim dosegli osnovno usposobljenost. Ko pa vam to uspe, je tudi nagrada večja.

Neovim je v bistvu neskončno nastavljiv. Če želite res ponoreti, lahko lastno konfiguracijo za Neovim ustvarite od nič. Obstaja odličen tečaj avtorja [Typecraft o postavitvi Neovima od nič](https://www.youtube.com/watch?v=zHTeCSVAFNY). In [enega ima tudi ThePrimeagen](https://www.youtube.com/watch?v=w7i4amO_zaE).

Toda Omarchy je dobavljen s popolno nastavitvijo za Neovim — paketom `omarchy-nvim` — ki je bila z ljubeznijo uglašena, da takoj po namestitvi pokaže najboljše, kar je mogoče. Ne da bi vam bilo treba napisati eno samo vrstico konfiguracije! Zgrajena je na [LazyVim](https://www.lazyvim.org/), distribuciji vtičnikov in konfiguracij za Neovim. Odlična je.

## Osnove LazyVim

Kot sem omenil, vas v tem kratkem uvodu ne bom učil vim, lahko pa vam pokažem nekaj osnov LazyVim in kako se znajti.

Neovim ima najprej pojem vodilne tipke. Ta je v bistvu prehod do vseh ukazov. LazyVim jo je nastavil na `Space`. Zato jo samo pritisnite, počakajte sekundo in videli boste kup možnosti, razloženih v vrstici, takole:

Tukaj je nekaj osnovnih ukazov, ki jih ves čas uporabljam:

- `Space Space` - Z neostrim iskanjem poiščite katero koli datoteko v trenutnem imeniku.
- `Space S G` - Preiščite vse datoteke z grep s predogledom.
- `Space E` - Vklopite/izklopite datotečno drevo.
- `Ctrl + W W` - Skočite iz datotečnega drevesa v urejevalnik in nazaj.
- `Shift + H` - Pomaknite se v levo med odprtimi zavihki (vim jih imenuje buffers).
- `Shift + L` - Pomaknite se v desno med odprtimi zavihki.
- `Space B D` - Zaprite zavihek.
- `Space B O` - Zaprite vse druge zavihke razen trenutnega.
- `Space G G` - Zaženite LazyGit v plavajočem podoknu iz trenutnega imenika.
- `Space U W` - Preklopite mehko prelamljanje.

Ko ste v datotečnem drevesu (`Space E`, da ga prikažete, `Ctrl + W W`, da skočite tja), lahko dodate novo datoteko z `a` ali nov imenik z `A`. Medtem ko ste v drevesu, pritisnite `?`, da vidite vse ukaze.

Če želite osvojiti osnovni jezik vim, sem pisal o [tridelni sintaksi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) in kako izvesti tiste hude kombinacijske poteze!

Vse možne ukaze si lahko ogledate na [strani LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Zagon Neovima

`Super + Shift + N` zažene vaš privzeti urejevalnik, ki je pri novih namestitvah Plain; pod _Setup > Defaults > Editor_ izberite Neovim, da se namesto njega zažene Neovim. Toda običajno ga je lažje poganjati iz terminala tako, da se pomaknete v imenik, v katerem želite delati, in vtipkate `n`. `n` je vzdevek za `nvim`, ki bo privzeto odprl trenutni imenik. Posamezno datoteko lahko odprete z `n myfile.txt`.

## Uporaba Neovima za urejanje s sudo

Če morate urejati datoteke, ki jih lahko spremenite le kot super uporabnik, zaženite `sudoedit /etc/sudoers.d/00-sudo-only-file`. Odpre vaš privzeti urejevalnik, zato pod _Setup > Defaults > Editor_ nastavite Neovim, če ga želite tam z vsemi svojimi vtičniki.
