# Süsteemi unerežiim

Omarchy lülitab vaikimisi sisse peatamise ja pärast selle seadistamist ka talveune, aga kui kummagagi on su masinal probleeme, saad need välja lülitada.

NVIDIA GB10 masinatel, näiteks DGX Sparkil ja ASUS Ascent GX10-l, on peatamine ja talveuni välja lülitatud, nagu ka NVIDIA DGX OS-is, sest unerežiim ei ole sellel riistvaral veel tõestatult tööle hakanud. Peatamise lüliti ja talveune seadistamine seal ei kehti. Unerežiimi uuesti sisselülitamiseks eemalda `sudo rm`-iga `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`; peatamine naaseb seejärel menüüsse ja talveune saab seadistada nagu teistel masinatel. Käsu `sudo omarchy apply hardware --install-user "$USER"` käivitamine paneb faili tagasi.

### Toiteprofiilid

Sülearvutil jätab Omarchy su toiteprofiili eraldi meelde vooluvõrku ühendatuna ja akutoitel töötades ning vahetab nende kahe vahel, kui toite ühendad või lahti ühendad. Karbist võttes tähendab see AC korral jõudlust ja akutoitel tasakaalustatud režiimi.

Näed, mida su masin pakub, käsuga `omarchy powerprofiles list`, ja saad seada soovitu oma praeguse oleku jaoks käsuga `omarchy powerprofiles set autodetect power-saver`. Teise oleku seadmiseks ilma midagi lahti ühendamata nimeta see otse: `omarchy powerprofiles set battery power-saver`. Mida iganes valid, selle saad tagasi järgmisel korral, kui selles olekus oled.

### Peatamise lülitamine

Peatamist lülitad terminalist käsku `omarchy toggle suspend` käivitades. See lihtsalt näitab/peidab valiku jaotuse _System_ all (või `Super + Esc`) ja seejärel näed, kas see töötab su süsteemis järjepidevalt. Kui ei, saad selle sama käsuga uuesti peita.

### Talveune lülitamine

Talveune seadistad terminalist käsku `omarchy hibernation setup` käivitades (see pole Apple Silicon Macidel saadaval). Talveuni loob su alglaadimiskettale /swap alamköite, mille suurus vastab su füüsilise RAM-i mahule, nii et veendu, et sul on piisavalt vaba ruumi. 32GB masinal vajad selle köite jaoks alati 32GB+ vaba ruumi. Talveuni nõuab ka vaikimisi Limine alglaadurit.

Kui see on seadistatud, näed talveune valikut jaotuse _System_ all (või `Super + Esc`) ja seejärel näed, kas see töötab su süsteemis järjepidevalt. Kui ei, saad selle uuesti eemaldada käsuga `omarchy hibernation remove`.
