# Odpravljanje težav

### Z posodobitvijo sem pokvaril sistem!

Najprej poskusite [povrniti sistem](47-system-snapshots.md) na različico pred zadnjo posodobitvijo. Če to ne deluje, uporabite `omarchy-debug` in svojo težavo delite na #omarchy-help v Discordu. Če pa tudi to odpove, lahko z `omarchy-reinstall` znova namestite privzete konfiguracije in pakete.

### Zakaj so nekatere aplikacije na mojem zaslonu tako velike?

Omarchy predvideva zaslon z visoko ločljivostjo 2x, zato `GDK_SCALE` nastavi na 2, dokler v panelu monitorja ne izberete merila. Če uporabljate zaslon 1x in so aplikacije GTK ali X11 prevelike, zanj v panelu monitorja izberite 1x ali v `~/.config/hypr/monitors.lua` dodajte `hl.env("GDK_SCALE", "1")` (in nato znova zaženite vse prevelike aplikacije). Glejte [priročnik o monitorjih](33-monitors.md).

Pri Spotifyju lahko z `Ctrl + Minus` pomanjšate uporabniški vmesnik (z `Ctrl + Plus` pa ga povečate).

### Zakaj so vse moje bližnjice s tipko Super prenehale delovati?

Pri nekaterih prenosnikih ASUS ROG in TUF je `Fn + Super` kombinacija, ki jo zlahka spregledate in ki preklopi zaklepanje tipke Windows v vdelani programski opremi (namenjeno igranju iger, da igre ne zapustite po pomoti). Na zaslonu ni ničesar, kar bi vas na to opozorilo. Ko je zaklepanje vklopljeno, Super ne oddaja prav ničesar — zato vsaka bližnjica v Omarchy, ki uporablja Super, preprosto preneha delovati in videti je, kot da se je pokvaril Hyprland.

Preden se začnete poglabljati v `~/.config/hypr/`, enkrat pritisnite `Fn + Super`, in če s tem Super ne začne znova delovati, pritisnite znova, da zaklepanja ne boste pustili vklopljenega. To ni Fn-lock, ki spreminja le delovanje vrste tipk F.

### Moj Wi-Fi, Bluetooth, zvok ali sledilna ploščica je pravkar prenehala delovati

Pred ponovnim zagonom poskusite znova zagnati samo problematični podsistem. _Posodobitev > Strojna oprema_ v meniju Omarchy vsebuje Wi-Fi, Bluetooth, Zvok in Sledilna ploščica, ponovni zagon enega od njih pa odpravi večino situacij tipa "pred petimi minutami je še delovalo" — slušalke Bluetooth, ki se nočejo znova povezati, sledilna ploščica, ki je po spanju prenehala delovati, zvok, ki je izginil, ko ste izklopili monitor.

### Zakaj moji zunanji zvočniki ne predvajajo zvoka?

Verjetno zato, ker niso nastavljeni kot primarni izhod. Kliknite ikono zvočnika na desni strani vrstice in odprl se bo pojavni okvir za glasnost, v katerem lahko izberete izhodno napravo (in nastavite tudi glasnost za posamezne aplikacije).

### Zvočniki mojega prenosnika zvenijo čudno

Pri nekaterih prenosnikih Omarchy samodejno uporabi uglasitev zvočnikov, ki popravi frekvenčni odziv vgrajenih zvočnikov. `omarchy audio tuning status` vam pove, ali je na vaši napravi aktivna katera od njih, `omarchy audio tuning off` pa jo izklopi, če želite zvočnike poslušati brez obdelave.

### Zakaj se ne morem prijaviti ali uporabiti sudo s svojim geslom?

Verjetno ste ga prevečkrat vnesli napačno in ste se zaklenili ven. Če se to dogaja na zaklenjenem zaslonu, lahko pritisnete `CTRL + ALT + F2`, da zaženete nov TTY, v katerem se lahko prijavite kot root, nato pa zaženete `faillock --reset --user [your-username]`. To bo ponastavilo zaklepanje in lahko nadaljujete.

### Zakaj se moji pozivi za pooblastitev 1Password za 1Password SSH Agent / CLI ne prikazujejo?

To se lahko zgodi iz dveh razlogov:

Da se prikaže bogati poziv za odobritev, mora biti vklopljena možnost Settings > Advanced > Use Hardware Acceleration. _Opomba: Da začne delovati, je potreben ponovni zagon._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ali če od zagona sistema še niste zagnali 1Password, se poziv ne bo prikazal.
