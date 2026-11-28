# Windows VM

Omarchy ponuja preprost način za poganjanje sistema Windows prek Docker VM na računalnikih x86_64. Namestite ga lahko z možnostjo _Install > Windows_ v meniju Omarchy (`Super + Space`).

Vaš računalnik za to potrebuje virtualizacijo KVM, kar večina podpira — včasih pa je v BIOS izklopljena in namestitveni program vas bo na to opozoril. Potrebovali boste tudi prostor na disku: toliko, kolikor ga namenite sistemu Windows, plus približno 10GB za samo sliko.

Namestitveni program vpraša, koliko RAM, koliko jeder CPU in koliko prostora na disku želite nameniti (64GB ali več je smiselna spodnja meja), nato pa še za uporabniško ime in geslo za Windows. Če ju pustite prazna, dobite `docker` / `admin`. Prenos traja nekaj časa — 10-15 minut je normalno — napredek pa lahko spremljate v brskalniku na `http://127.0.0.1:8006`. Brskalnik pred odpiranjem konzole zahteva isto uporabniško ime in geslo.

 ![windows-vm](images/windows-vm.webp)

## Uporaba

Ko je nameščen, zaženite _Windows_ iz zaganjalnika aplikacij. To zažene VM, če še ne teče, in vas poveže prek RDP, v celozaslonskem načinu. Pri hladnem zagonu mu dajte 15-30 sekund.

Seja RDP prenaša zvok, vaš mikrofon in skupno odložišče, zato kopiranje besedila med Linux in Windows preprosto deluje. Ločljivost sledi vašemu oknu, Omarchy pa posreduje skaliranje vašega zaslona, zato na zaslonu HiDPI ni zamegljena zmešnjava.

Ko zaprete okno RDP, se VM samodejno zaustavi. Če ga raje pustite teči — recimo, da v njem nekaj dela — ga namesto tega zaženite z `omarchy windows vm launch --keep-alive`.

Preostali ukazi za upravljanje so na istem ukazu:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Souporaba datotek

Imenik `~/Windows` v vašem domačem imeniku je samodejno v souporabi z VM. Tja dajte datoteke, če želite, da so dostopne sistemu Windows. VM nima dostopa do nobenega drugega dela vašega datotečnega sistema, zato ste varni pred čimerkoli zlonamernim na strani Windows. Njegov lastni navidezni disk je na voljo na `~/.windows`.

Te znane domače poti ostanejo na svojih datotečnih sistemih. Lahko so tudi simbolne povezave do imenikov v vaši lasti, kar je uporabno, ko je navidezni disk na večjem pogonu. Namestitveni program meri prosti prostor na datotečnem sistemu, ki dejansko vsebuje `~/.windows`, ne nujno na datotečnem sistemu, ki vsebuje vaš domači imenik.

Pot diska in pot v souporabi ohranite kot ločena, neprekrivajoča se imenika. Odstranitev namerno izprazni imenik diska, imenik v souporabi pa ohrani. Neposredno pred brisanjem Omarchy izvede omejeno preverjanje vsebovanosti in zavrne odstranitev česarkoli, če preverjanje poteče ali ne more dokazati, da sta drevesi ločeni.

Pred zagonom VM Omarchy odpre in pripne ta dva imenika, nato pa točna inoda imenikov veže z bind-mount na zasebna sidra za posameznega uporabnika pod `/var/lib/omarchy/windows/mounts`. Docker vidi samo ta sidra, zaščitena z root. To ohrani lokacije diska po meri, hkrati pa prepreči, da bi drug proces, ki teče kot vi, zamenjal preverjeno pot, preden jo porabi privilegirani vsebnik. Obstoječa imenika diska in souporabe se med migracijo poostrita na način `0700`, da drugi lokalni računi ne morejo brskati po njuni vsebini.

Vrata VM so vezana samo na localhost, zato nič na vašem omrežju ne more doseči računalnika Windows. Spletna konzola zahteva tudi nastavljeno uporabniško ime in geslo za Windows, kar prepreči, da bi drug lokalni račun upravljal VM prek vrat 8006.

## Omejitve in licenciranje

Pri tej nastavitvi ni prehoda GPU, zato ni primerna za igranje iger ali urejanje videa. Je pa odličen način za poganjanje Microsoft Office ali česarkoli drugega, kar nujno morate imeti.

Nameščena različica je Windows 11 Pro, neaktivirana. Za uporabo zaklenjenih funkcij boste potrebovali svojo licenčno kodo.

Če je bil ta računalnik dobavljen z Windows, je ključ OEM še vedno v strojni programski opremi, tudi po namestitvi Omarchy. Izpišite ga z `omarchy windows key`. Ta ključ je vezan na ta računalnik — aktiviral bo Windows, znova nameščen na tej strojni opremi, običajno pa ne bo aktiviral VM.

Dodelitev virov lahko pozneje spremenite tako, da v terminalu zaženete `omarchy windows vm install`, kar znova zapiše konfiguracijo VM iz vaših odgovorov. Datoteka compose zdaj živi na `/var/lib/omarchy/windows/docker-compose.yml` in je v lasti root — to je namerno, da proces, ki teče kot vi, ne more prepisati je in doseči, da bi privilegirani zagon v vsebnik pripel ves vaš disk. Če jo morate ročno urediti (na primer za priklop naprave USB), jo uredite s `sudo` in si oglejte vse možnosti v [projektu Dockur Windows](https://github.com/dockur/windows).

Da se znebite vsega, uporabite _Remove > Windows_ v meniju Omarchy. To izbriše disk VM v `~/.windows` in vse, kar je nameščeno znotraj Windows, zato prej iz VM skopirajte vse, kar potrebujete. Vaša mapa v souporabi `~/Windows` ostane nedotaknjena.
