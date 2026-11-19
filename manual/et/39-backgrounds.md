# Taustapildid

Iga teemaga on kaasas oma taustapiltide komplekt ja sa saad lisada enda omi kausta `~/.config/omarchy/backgrounds/[theme]`. Kui sa tahad lisada näiteks nord teemale täiendava taustapildi, paned faili lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsam on seda teha, kui lähed Omarchy Menu's valikule _Install > Style > Background_. See avab kausta, kus selle teema taustapildid asuvad. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taustapilt ja kopeeri see sinna. Nüüd on see valikute hulgas, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Taustad võivad olla nii videod kui ka liikumatud pildid. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildimootor. See dekodeerib video ühe korra kõigi monitoride jaoks ja esitab selle heli vaikeheliväljundi kaudu ning peatab esituse alati, kui miski seda näha ei saa. Videotaustapilt kulutab ikkagi palju rohkem energiat kui liikumatu pilt.

Teemad võivad sisaldada liikumatu tausta jaoks lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub sobiv video asukohas `backgrounds/intros/road.mp4`. See esitatakse automaatselt käivitamisel, selle taustaga valitud teemale lülitumisel ja selle tausta valimisel ning seejärel naaseb liikumatu pildi juurde. Sissejuhatavad videod ei ilmu taustapiltide valijasse ja neid ei korrata kunagi.

_Appearance > Animations_ väljalülitamine lülitab välja ka taustade sissejuhatused. Omarchy teeb seda vaikimisi virtuaalmasinas. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine sissejuhatust ei esita.

Liikumatul pildil võib olla ka tsükkel, sama pildi vaikne versioon, mis liigub pidevalt, asukohas `backgrounds/loops/road.mp4`. Seda esitatakse liikumatu pildi asemel, pärast selle sissejuhatust, kui sel see on, ja see peatub, kui animatsioonid välja lülitatakse. Tsüklid ei ilmu taustapiltide valijasse ja kulutavad nagu iga videotaustapilt rohkem energiat kui liikumatu pilt.

Suure valiku lahedaid, hoolikalt valitud taustapilte leiad kogust [dharmx/walls](https://github.com/dharmx/walls).

Lukustuskuva näitab videotaustapildist liikumatut kaadrit samamoodi, nagu see näitab liikumatut kaadrit animeeritud GIF-ist.
