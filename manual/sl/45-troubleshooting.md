# Odpravljanje težav

### Z posodobitvijo sem pokvaril sistem!

Najprej poskusite [povrniti sistem](47-system-snapshots.md) na različico pred nedavno posodobitvijo. Če to ne deluje, uporabite `omarchy-debug`, da svojo težavo delite v #omarchy-help na Discordu. In če vse to odpove, lahko z `omarchy-reinstall` znova namestite privzete konfiguracije in pakete.

### Zakaj so nekatere aplikacije na mojem zaslonu tako velike?

Omarchy predpostavlja zaslon z visoko ločljivostjo 2x, zato nastavi `GDK_SCALE` na 2, dokler v plošči za monitor ne izberete merila. Če ste na zaslonu 1x in so aplikacije GTK ali X11 prevelike, v plošči za monitor zanj izberite 1x ali dodajte `hl.env("GDK_SCALE", "1")` v `~/.config/hypr/monitors.lua` (in nato znova zaženite vsako preveliko aplikacijo). Glejte [priročnik o monitorjih](33-monitors.md).

Pri Spotifyju lahko z `Ctrl + Minus` pomanjšate uporabniški vmesnik (in z `Ctrl + Plus` ga povečate).

### Zakaj so vse moje bližnjice s tipko Super prenehale delovati?

Na nekaterih prenosnikih ASUS ROG in TUF je `Fn + Super` zlahka spregledljiva kombinacija tipk, ki preklopi zaklep tipke Windows v vdelani programski opremi (namenjen igranju iger, da igre ne zapustite po nesreči). Nič na zaslonu vam ne pove, da se je to zgodilo. Medtem ko je zaklep vklopljen, Super ne oddaja ničesar — zato vsaka bližnjica Omarchy, ki uporablja Super, preprosto preneha delovati in zdi se, kot da se je Hyprland pokvaril.

Enkrat pritisnite `Fn + Super`, preden začnete brskati po `~/.config/hypr/`, in če to ne vrne tipke Super, jo pritisnite znova, da zaklepa ne pustite vklopljenega. To ni Fn-lock, ki spremeni le delovanje vrstice tipk F.

### Moj Wi-Fi, Bluetooth, zvok ali sledilna ploščica je kar prenehal delovati

Pred ponovnim zagonom poskusite znova zagnati samo problematični podsistem. _Update > Hardware_ v meniju Omarchy ima Wi-Fi, Bluetooth, Audio in Trackpad, in ponovna naložitev enega od teh odpravi večino situacij »pred petimi minutami je delovalo« — slušalke Bluetooth, ki se nočejo znova povezati, sledilno ploščico, ki je po prebujanju iz mirovanja obmrla, zvok, ki je izginil, ko ste odklopili monitor.

### Zakaj moji zunanji zvočniki ne predvajajo zvoka?

Verjetno zato, ker niso nastavljeni kot primarni izhod. Kliknite ikono zvočnika na desni strani vrstice in odprl se bo pojavni element za glasnost, kjer lahko izberete izhodno napravo (in mešate tudi glasnost za posamezne aplikacije).

### Zvočniki mojega prenosnika zvenijo čudno

Na nekaterih prenosnikih Omarchy samodejno uporabi uglasitev zvočnikov, ki popravi frekvenčni odziv vgrajenih zvočnikov. `omarchy audio tuning status` vam pove, ali je na vašem računalniku katera aktivna, `omarchy audio tuning off` pa jo izklopi, če raje poslušate zvočnike brez obdelave.

### Zakaj se ne morem prijaviti ali uporabiti sudo s svojim geslom?

Verjetno ste ga desetkrat vnesli narobe in ste bili zaklenjeni. Zaklep se sam počisti po dveh minutah. Če ne morete čakati in se to dogaja na zaklenjenem zaslonu, lahko pritisnete `CTRL + ALT + F2`, da zaženete nov TTY, kjer se lahko prijavite kot root, nato pa zaženete `faillock --reset --user [your-username]`. To bo ponastavilo zaklep in lahko nadaljujete.

### Moje geslo je sprejeto, vendar se vrnem na prijavni zaslon

Pokvarjena datoteka okolja seje lahko prepreči zagon namizja, tudi ko je vaše geslo pravilno. To je še posebej vredno preveriti po urejanju `~/.config/uwsm/env.d/`.

Pritisnite `Ctrl + Alt + F2`, prijavite se z običajnim uporabniškim imenom in geslom ter preglejte dnevnik uporabnika za trenutni zagon:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Poiščite napako, ki imenuje eno od vaših datotek okolja, na primer `bad substitution`, tik pred sporočilom, da oznaka izhoda okolja ni bila najdena. Preden se poskusite znova prijaviti, premaknite to datoteko iz `env.d`. Na primer, če napaka imenuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM preskoči datoteko s sintaktično napako, vendar lahko usodna napaka, ki se pokaže šele med izvajanjem datoteke, kot je `bad substitution`, še vedno prepreči zagon namizja. Povrnitev sistemskega posnetka teh datotek ne popravi, ker `/home` ni povrnjen.

Ko se lahko prijavite, popravite shranjeno kopijo, preden jo premaknete nazaj. `sh -n` ujame sintaktične napake, ne da bi datoteko zagnal, vendar ne more ujeti vsake napake, ki se pojavi, ko se datoteka naloži kot vir. Med preizkušanjem sprememb imejte odprt delujoč terminal.

### Zakaj se mi ne prikažejo pozivi za avtorizacijo 1Password za 1Password SSH Agent / CLI?

To se lahko zgodi iz 2 razlogov:

Da se prikaže bogati poziv za odobritev, mora biti vklopljena možnost Settings > Advanced > Use Hardware Acceleration. _Opomba: Za začetek delovanja je potreben ponovni zagon._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ali če od zagona še niste zagnali 1Password, se poziv ne bo prikazal.
