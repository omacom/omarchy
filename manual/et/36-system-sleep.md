# Süsteemi unerežiim

Omarchy lubab peatamise ja talveune vaikimisi, kuid kui sul on masinas kummagagi probleeme, saad need välja lülitada.

NVIDIA GB10 masinatel, nagu DGX Spark ja ASUS Ascent GX10, on peatamine ja talveuni välja lülitatud, nagu ka NVIDIA DGX OS-is, sest unerežiim pole sellel riistvaral veel tõestatult töötanud. Peatamise lüliti ja talveune seadistus seal ei kehti. Unerežiimi uuesti sisselülitamiseks eemalda `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` käsuga `sudo rm`; seejärel naaseb peatamine menüüsse ja talveune saab seadistada nagu teistel masinatel. Käsu `sudo omarchy apply hardware --install-user "$USER"` käivitamine paneb faili tagasi.

### Toiteprofiilid

Sülearvutil jätab Omarchy sinu toiteprofiili eraldi meelde vooluvõrku ühendatuna ja akutoitel töötades ning vahetab nende kahe vahel, kui ühendad voolu sisse ja välja. Vaikimisi tähendab see vooluvõrgus jõudlust ja akutoitel tasakaalustatud režiimi.

Näed, mida su masin pakub, käsuga `omarchy powerprofiles list` ja saad seada soovitud profiili oleku jaoks, milles parasjagu oled, käsuga `omarchy powerprofiles set autodetect power-saver`. Teise oleku seadmiseks ilma midagi lahti ühendamata nimeta see otse: `omarchy powerprofiles set battery power-saver`. Mida iganes valid, selle saadki tagasi järgmisel korral, kui selles olekus oled.

### Peatamise lülitamine

Peatamist lülitad terminalist käsku `omarchy toggle suspend` käivitades. See lihtsalt näitab/peidab valiku _Süsteem_ all (või `Super + Esc`) ja seejärel saad näha, kas see töötab sinu süsteemis järjepidevalt. Kui ei tööta, saad selle sama käsuga uuesti peita.

### Talveune lülitamine

Talveune seadistad terminalist käsku `omarchy hibernation setup` käivitades. Talveuni loob sinu alglaadimiskettale /swap alamköite, mille suurus vastab sinu füüsilise RAM-i mahule, seega veendu, et sul on piisavalt vaba ruumi varuks. 32GB masinal vajad selle köite jaoks alati 32GB+ vaba ruumi. Talveuni nõuab ka vaikimisi Limine alglaadurit.

Kui see on seadistatud, näed talveune valikut _Süsteem_ all (või `Super + Esc`) ja seejärel saad näha, kas see töötab sinu süsteemis järjepidevalt. Kui ei tööta, saad selle uuesti eemaldada käsku `omarchy hibernation remove` käivitades.
