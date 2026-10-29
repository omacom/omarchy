# Odpravljanje težav

### S posodobitvijo sem pokvaril sistem!

Najprej poskusite [povrniti sistem](47-system-snapshots.md) na različico pred nedavno posodobitvijo. Če to ne deluje, uporabite `omarchy-debug`, da svojo težavo delite na #omarchy-help v Discordu. In če ne uspe nič od tega, lahko s pomočjo `omarchy-reinstall` znova namestite privzete konfiguracije in pakete.

### Zakaj so nekatere aplikacije na mojem zaslonu tako velike?

Omarchy predvideva zaslon z visoko ločljivostjo 2x, kar zahteva nastavitev `GDK_SCALE` na 2 v `~/.config/hypr/monitors.lua`. Če pa imate zaslon 1x, lahko `local omarchy_gdk_scale = 2` spremenite v 1 (in nato znova zaženete vse prevelike aplikacije). Glejte [priročnik o monitorjih](33-monitors.md).

Pri Spotifyju lahko z `Ctrl + Minus` pomanjšate uporabniški vmesnik (z `Ctrl + Plus` pa ga povečate).

### Zakaj so vse moje bližnjice s tipko Super prenehale delovati?

Pri nekaterih prenosnikih ASUS ROG in TUF je `Fn + Super` kombinacija, ki jo zlahka spregledate, saj preklopi zaklepanje tipke Windows v vdelani programski opremi (namenjeno igranju iger, da igre ne zapustite po nesreči). Na zaslonu vas nič ne opozori, da se je to zgodilo. Dokler je zaklepanje vklopljeno, Super ne odda ničesar — zato vse bližnjice v Omarchyju, ki uporabljajo Super, preprosto prenehajo delovati in videti je, kot da se je pokvaril Hyprland.

Enkrat pritisnite `Fn + Super`, preden se lotite brskanja po `~/.config/hypr/`, in če s tem Super ne začnete znova delovati, jo pritisnite še enkrat, da zaklepanja ne pustite vklopljenega. To ni Fn-lock, ki spremeni le delovanje vrstice tipk F.

### Wi-Fi, Bluetooth, zvok ali sledilna ploščica so mi kar prenehali delovati

Preden znova zaženete računalnik, poskusite posebej znova zagnati problematični podsistem. _Update > Hardware_ v meniju Omarchy vsebuje Wi-Fi, Bluetooth, Audio in Trackpad, ponovni zagon enega od njih pa odpravi večino situacij tipa »pred petimi minutami je še delovalo« — slušalke Bluetooth, ki se nočejo znova povezati, sledilno ploščico, ki po zaustavitvi ne deluje več, zvok, ki je izginil, ko ste izklopili monitor.

### Zakaj moji zunanji zvočniki ne predvajajo zvoka?

Verjetno zato, ker niso nastavljeni kot primarni izhod. Kliknite ikono zvočnika na desni strani vrstice in odprlo se bo pojavno okno za glasnost, v katerem lahko izberete izhodno napravo (in nastavite tudi glasnost za posamezne aplikacije).

### Zvočniki na mojem prenosniku zvenijo čudno

Na nekaterih prenosnikih Omarchy samodejno uporabi uglasitev zvočnikov, ki popravi frekvenčni odziv vgrajenih zvočnikov. `omarchy audio tuning status` vam pove, ali je na vašem računalniku katera aktivna, `omarchy audio tuning off` pa jo izklopi, če želite zvočnike raje slišati brez obdelave.

### Zakaj se ne morem prijaviti ali uporabiti sudo s svojim geslom?

Verjetno ste ga prevečkrat vnesli narobe in ste ostali zaklenjeni zunaj. Če se to dogaja na zaklenjenem zaslonu, lahko pritisnete `CTRL + ALT + F2`, da zaženete nov TTY, v katerem se lahko prijavite kot root, nato pa zaženete `faillock --reset --user [your-username]`. S tem boste ponastavili zaklepanje in lahko nadaljujete.

### Zakaj se mi ne prikažejo pozivi za avtorizacijo 1Password za 1Password SSH Agent / CLI?

Do tega lahko pride iz 2 razlogov:

Da se prikaže obogateni poziv za odobritev, mora biti vklopljena možnost Settings > Advanced > Use Hardware Acceleration. _Opomba: Da začne delovati, je potreben ponovni zagon._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ali pa poziv ne bo prikazan, če od zagona računalnika še niste zagnali aplikacije 1Password.
