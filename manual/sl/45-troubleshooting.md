# Odpravljanje težav

### Sistem sem pokvaril s posodobitvijo!

Najprej poskusite [povrniti sistem](47-system-snapshots.md) na različico pred nedavno posodobitvijo. Če to ne deluje, uporabite `omarchy-debug` in svojo težavo delite v kanalu #omarchy-help na Discordu. In če ne uspe niti to, lahko z `omarchy-reinstall` znova namestite privzete konfiguracije in pakete.

### Zakaj so nekatere aplikacije na mojem zaslonu tako velike?

Omarchy predvideva zaslon visoke ločljivosti 2x, zato nastavi `GDK_SCALE` na 2, dokler ne izberete merila v plošči monitorja. Če ste na zaslonu 1x in so aplikacije GTK ali X11 prevelike, zanj v plošči monitorja izberite 1x ali dodajte `hl.env("GDK_SCALE", "1")` v `~/.config/hypr/monitors.lua` (nato pa znova zaženite vsako preveliko aplikacijo). Oglejte si [priročnik o monitorjih](33-monitors.md).

Za Spotify lahko uporabite `Ctrl + Minus`, da pomanjšate vmesnik (in `Ctrl + Plus`, da ga povečate).

### Zakaj so vse moje bližnjice s tipko Super prenehale delovati?

Pri nekaterih prenosnikih ASUS ROG in TUF je `Fn + Super` kombinacija, ki jo zlahka spregledate in ki preklopi zaklep tipke Windows v vdelani programski opremi (namenjen igranju iger, da igre ne zapustite po nesreči). Na zaslonu ni ničesar, kar bi vam povedalo, da se je to zgodilo. Ko je zaklep vklopljen, Super ne odda ničesar — zato vsaka bližnjica v Omarchyju, ki uporablja Super, preprosto preneha delovati in videti je, kot da se je Hyprland pokvaril.

Enkrat pritisnite `Fn + Super`, preden začnete kopati po `~/.config/hypr/`, in če to tipke Super ne vrne, pritisnite znova, da zaklepa ne pustite vklopljenega. To ni Fn-lock, ki spremeni le delovanje vrstice tipk F.

### Moj Wi-Fi, Bluetooth, zvok ali sledilna ploščica je pravkar prenehala delovati

Preden znova zaženete sistem, poskusite znova zagnati samo okvarjeni podsistem. _Posodobitev > Strojna oprema_ v meniju Omarchy ima Wi-Fi, Bluetooth, Audio in Trackpad, ponovno nalaganje enega od njih pa odpravi večino položajev »pred petimi minutami je še delovalo« — slušalke Bluetooth, ki se nočejo znova povezati, sledilna ploščica, ki je prenehala delovati po stanju pripravljenosti, zvok, ki je izginil, ko ste izklopili monitor.

### Zakaj moji zunanji zvočniki ne predvajajo zvoka?

Verjetno zato, ker niso nastavljeni kot primarni izhod. Kliknite ikono zvočnika na desni strani vrstice in odprlo se bo pojavno okno za glasnost, kjer lahko izberete izhodno napravo (in mešate tudi glasnost za posamezne aplikacije).

### Zvočniki na mojem prenosniku zvenijo čudno

Pri nekaterih prenosnikih Omarchy samodejno uporabi uglasitev zvočnikov, ki popravi frekvenčni odziv vgrajenih zvočnikov. `omarchy audio tuning status` vam pove, ali je na vašem računalniku aktivna kakšna uglasitev, `omarchy audio tuning off` pa jo izklopi, če bi raje slišali zvočnike brez obdelave.

### Zakaj se s svojim geslom ne morem prijaviti ali uporabiti sudo?

Verjetno ste ga prevečkrat vnesli napačno in ste bili zaklenjeni. Če se to dogaja na zaklenjenem zaslonu, lahko pritisnete `CTRL + ALT + F2`, da zaženete nov TTY, kjer se lahko prijavite kot root, nato pa zaženete `faillock --reset --user [your-username]`. S tem boste ponastavili zaklep in lahko boste nadaljevali.

### Geslo je sprejeto, vendar se vrnem na prijavni zaslon

Pokvarjena datoteka z okoljem seje lahko prepreči zagon namizja, tudi če je vaše geslo pravilno. To je še posebej vredno preveriti po urejanju `~/.config/uwsm/env.d/`.

Pritisnite `Ctrl + Alt + F2`, prijavite se z običajnim uporabniškim imenom in geslom ter preglejte uporabniški dnevnik trenutnega zagona:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Poiščite napako, ki poimenuje eno od vaših datotek z okoljem, kot je `bad substitution`, tik pred sporočilom, da oznake izhoda okolja ni bilo mogoče najti. To datoteko premaknite iz `env.d`, preden se poskusite znova prijaviti. Če napaka na primer poimenuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM preskoči datoteko z napako v sintaksi, usodna napaka, ki se pokaže šele med izvajanjem datoteke, kot je `bad substitution`, pa še vedno lahko prepreči zagon namizja. Povrnitev posnetka sistema teh datotek ne popravi, ker `/home` ni povrnjen.

Ko se lahko prijavite, popravite shranjeno kopijo, preden jo premaknete nazaj. `sh -n` ujame napake v sintaksi, ne da bi datoteko zagnal, vendar ne more ujeti vsake napake, ki se pojavi, ko je datoteka vključena kot vir. Med preizkušanjem sprememb imejte odprt delujoč terminal.

### Zakaj se moji pozivi za avtorizacijo 1Password za 1Password SSH Agent / CLI ne prikažejo?

To se lahko zgodi iz 2 razlogov:

Da se prikaže obogateni poziv za odobritev, mora biti vklopljeno Settings > Advanced > Use Hardware Acceleration. _Opomba: Za začetek delovanja je potreben ponovni zagon._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ali pa se poziv ne bo prikazal, če od zagona sistema še niste zagnali 1Password.
