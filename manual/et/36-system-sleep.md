# Süsteemi uni

Omarchy lubab peatamise ja talveune vaikimisi, aga kui sul on masinal kummagagi probleeme, saad need välja lülitada.

NVIDIA GB10 masinatel, nagu DGX Spark ja ASUS Ascent GX10, on peatamine ja talveuni välja lülitatud, nagu NVIDIA DGX OS-iski, sest une töötamist sellel riistvaral pole veel näidatud. Sama kehtib ASUS Zenbook A16 (UX3607OA) kohta, kus peatamine ei pane kiipi veel täielikult magama ja võib öö jooksul hanguda. Peatamise lüliti ja talveune seadistamine seal ei kehti. Une uuesti sisselülitamiseks eemalda `sudo rm` abil `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`; peatamine naaseb seejärel menüüsse ja talveune saab seadistada nagu teistel masinatel. `sudo omarchy apply hardware --install-user "$USER"` käivitamine paneb faili tagasi.

### Toiteprofiilid

Sülearvutil jätab Omarchy sinu toiteprofiili eraldi meelde vooluvõrku ühendatuna ja akutoitel töötades ning lülitub nende kahe vahel ümber, kui sa juhtme ühendad või lahti ühendad. Kohe karbist võttes tähendab see jõudlust AC korral ja tasakaalustatud režiimi akul.

Saad näha, mida sinu masin pakub, käsuga `omarchy powerprofiles list`, ja seada soovitud profiili olekule, milles parasjagu oled, käsuga `omarchy powerprofiles set autodetect power-saver`. Teise oleku seadmiseks ilma midagi lahti ühendamata nimeta see otse: `omarchy powerprofiles set battery power-saver`. Mida iganes valid, selle saad tagasi järgmisel korral, kui selles olekus oled.

### Peatamise lülitamine

Peatamise lülitad, käivitades terminalist `omarchy toggle suspend`. See lihtsalt näitab/peidab valiku jaotises _Süsteem_ (või `Super + Esc`) ja seejärel saad näha, kas see töötab sinu süsteemis järjepidevalt. Kui mitte, saad selle sama käsuga uuesti peita.

### Talveune lülitamine

Talveune seadistad, käivitades terminalist `omarchy hibernation setup`. Talveuni loob sinu alglaadimiskettale /swap alamköite, mille suurus vastab sinu füüsilise RAM-i mahule, nii et veendu, et sul on küllaga vaba ruumi varuks. 32GB masinal vajad selle köite jaoks alati 32GB+ vaba ruumi. Talveuni nõuab ka vaikimisi Limine alglaadurit.

Kui see on seadistatud, näed talveune valikut jaotises _Süsteem_ (või `Super + Esc`) ja seejärel saad näha, kas see töötab sinu süsteemis järjepidevalt. Kui mitte, saad selle uuesti eemaldada, käivitades `omarchy hibernation remove`.
