# Süsteemi uni

Omarchy lubab vaikimisi uinaku ja talveune, aga kui sul on oma masinal kummagagi probleeme, saad need välja lülitada.

### Toiteprofiilid

Sülearvutil jätab Omarchy sinu toiteprofiili eraldi meelde nii võrku ühendatuna kui ka akutoitel ja vahetab neid, kui ühendad toite külge või lahti. Karbist võttes tähendab see võrgutoitel jõudlust ja akutoitel tasakaalustatud režiimi.

Sa saad vaadata, mida sinu masin pakub, käsuga `omarchy powerprofiles list` ja seada soovitud profiili olekule, milles parasjagu oled, käsuga `omarchy powerprofiles set autodetect power-saver`. Et seada teine olek ilma midagi lahti ühendamata, nimeta see otse: `omarchy powerprofiles set battery power-saver`. Mida iganes valid, saad selle ka tagasi, kui järgmine kord samas olekus oled.

### Uinaku lülitamine

Uinakut saad lülitada terminalis käsuga `omarchy toggle suspend`. See lihtsalt näitab/peidab valikut jaotise _Süsteem_ all (või `Super + Esc`) ja siis saad vaadata, kas see sinu süsteemis järjepidevalt töötab. Kui ei tööta, saad selle sama käsuga uuesti peita.

### Talveune lülitamine

Talveune seadistad terminalis käsuga `omarchy hibernation setup`. Talveuni loob sinu alglaadimiskettale /swap alamahtumi sinu füüsilise muutmälu suuruses, nii et veendu, et sul oleks piisavalt ruumi. 32GB masinal vajad selle mahu jaoks alati 32GB+ vaba ruumi. Talveuni nõuab ka vaikimisi Limine alglaadurit.

Kui see on seadistatud, näed talveune valikut jaotise _Süsteem_ all (või `Super + Esc`) ja siis saad vaadata, kas see sinu süsteemis järjepidevalt töötab. Kui ei tööta, saad selle käsuga `omarchy hibernation remove` uuesti eemaldada.
