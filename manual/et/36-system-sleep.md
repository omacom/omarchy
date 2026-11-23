# Süsteemi unerežiim

Omarchy lubab vaikimisi peatamise ja pärast selle seadistamist ka talveune, kuid kui sul on oma masinas kummagagi probleeme, saad need välja lülitada.

NVIDIA GB10 masinatel, nagu DGX Spark ja ASUS Ascent GX10, on peatamine ja talveuni välja lülitatud, nagu ka NVIDIA DGX OS-is, sest unerežiimi toimimine sellel riistvaral pole veel kinnitust leidnud. Sama kehtib ASUS Zenbook A16 (UX3607OA) kohta, kus peatamine ei pane kiipi veel täielikult magama ja see võib öösel hanguda. Peatamise lülitamine ja talveune seadistamine seal ei kehti. Une uuesti sisselülitamiseks eemalda `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` käsuga `sudo rm`; seejärel naaseb Suspend menüüsse ja talveune saab seadistada nagu teistel masinatel. Käsu `sudo omarchy apply hardware --install-user "$USER"` käitamine paneb faili tagasi.

### Toiteprofiilid

Sülearvutil jätab Omarchy sinu toiteprofiili meelde eraldi vooluvõrku ühendatud ja akul töötamise korral ning vahetab nende kahe vahel, kui voolu ühendad või lahti ühendad. Vaikimisi tähendab see AC korral jõudlusrežiimi ja akul tasakaalustatud režiimi.

Saad vaadata, mida sinu masin pakub, käsuga `omarchy powerprofiles list`, ja määrata soovitud profiili oleku jaoks, milles parasjagu oled, käsuga `omarchy powerprofiles set autodetect power-saver`. Teise oleku määramiseks ilma midagi lahti ühendamata nimeta see otse: `omarchy powerprofiles set battery power-saver`. Mida iganes sa valid, selle saadki tagasi järgmine kord, kui selles olekus oled.

### Peatamise lülitamine

Peatamist lülitad terminalist käsu `omarchy toggle suspend` käitamisega. See lihtsalt näitab/peidab valikut jaotuse _System_ all (või `Super + Esc`) ja seejärel saad vaadata, kas see töötab sinu süsteemis järjepidevalt. Kui mitte, saad selle sama käsuga uuesti peita.

### Talveune lülitamine

Talveune seadistad terminalist käsu `omarchy hibernation setup` käitamisega (see pole Apple Silicon Macidel saadaval). Talveuni loob sinu käivitusdraivile /swap alamköite, mille suurus on võrdne sinu füüsilise RAM-i mahuga, nii et veendu, et sul on piisavalt vaba ruumi. 32GB masinal vajad selle köite jaoks alati 32GB+ vaba ruumi. Talveuni nõuab ka vaikimisi Limine alglaadurit.

Kui see on seadistatud, näed talveune valikut jaotuse _System_ all (või `Super + Esc`) ja seejärel saad vaadata, kas see töötab sinu süsteemis järjepidevalt. Kui mitte, saad selle uuesti eemaldada käsu `omarchy hibernation remove` käitamisega.
