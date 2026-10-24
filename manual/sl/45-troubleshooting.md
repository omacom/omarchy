# Odpravljanje težav

### Pokvaril sem sistem s posodobitvijo!

Najprej poskusite [vrniti sistem](47-system-snapshots.md) na različico pred vašo nedavno posodobitvijo. Če to ne deluje, uporabite `omarchy-debug`, da svojo težavo delite na #omarchy-help v Discordu. In če vse to odpove, lahko privzete konfiguracije in pakete znova namestite z `omarchy-reinstall`.

### Zakaj so nekatere aplikacije tako velike na mojem zaslonu?

Omarchy predpostavlja zaslon visoke ločljivosti 2x, ki zahteva nastavitev `GDK_SCALE` na 2 v `~/.config/hypr/monitors.lua`. Če pa ste na zaslonu 1x, lahko spremenite `local omarchy_gdk_scale = 2` na 1 (in nato znova zaženete vsako aplikacijo, ki je prevelika). Glejte [priročnik o zaslonih](33-monitors.md).

Za Spotify lahko uporabite `Ctrl + Minus`, da skrčite vmesnik (in `Ctrl + Plus`, da ga povečate).

### Moj Wi-Fi, Bluetooth, zvok ali sledilna ploščica je ravno prenehal delovati

Preden znova zaženete, poskusite znova zagnati sam problematični podsistem. _Posodobi > Hardware_ v meniju Omarchy ima Wi-Fi, Bluetooth, Audio in Sledilna ploščica, ponovno nalaganje enega od teh odpravi večino situacij tipa »pet minut nazaj je delovalo« — slušalke Bluetooth, ki se nočejo znova povezati, sledilno ploščico, ki je odpovedala po Spanju, zvok, ki je izginil, ko ste odklopili zaslon.

### Zakaj moji zunanji zvočniki ne predvajajo?

Verjetno zato, ker niso nastavljeni kot primarni izhod. Kliknite ikono zvočnika na desni strani vrstice in odprlo se bo pojavno okno za glasnost, kjer lahko izberete izhodno napravo (in tudi mešate glasnosti po aplikacijah).

### Zvočniki mojega prenosnika zvenijo narobe

Na nekaterih prenosnikih Omarchy samodejno uporabi uglaševanje zvočnikov, ki popravi frekvenčni odziv vgrajenih zvočnikov. `omarchy audio tuning status` vam pove, ali je eno dejavno na vašem računalniku, `omarchy audio tuning off` pa ga izklopi, če raje poslušate zvočnike surove.

### Zakaj se ne morem prijaviti ali uporabiti sudo s svojim geslom?

Verjetno ste ga prevečkrat vnesli napačno in se zaklenili. Če se to dogaja na zaklepanju zaslona, lahko pritisnete `CTRL + ALT + F2`, da zaženete nov TTY, kjer se lahko prijavite kot root, nato zaženete `faillock --reset --user [your-username]`. S tem ponastavite zaklepanje in ste pripravljeni.

### Zakaj se moji pozivi za avtorizacijo 1Password za 1Password SSH Agent / CLI ne prikažejo?

To se lahko zgodi iz 2 razlogov:

Da se prikaže bogat poziv za odobritev, mora biti Settings > Advanced > Use Hardware Acceleration vklopljeno. _Opomba: To zahteva ponovni zagon, da začne delovati._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ali če od zagona niste zagnali 1Password, se poziv ne bo prikazal.
