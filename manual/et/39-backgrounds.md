# Taustapildid

Iga teemaga on kaasas oma taustapiltide komplekt ja sa saad lisada enda omi kausta `~/.config/omarchy/backgrounds/[theme]`. Kui soovid lisada näiteks nord teemale täiendava taustapildi, pane fail lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsam on seda teha, kui lähed Omarchy menüüs jaotisse _Paigalda > Stiil > Taustapilt_. See avab kausta, kus selle teema taustapilte hoitakse. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taustapilt üles ja kopeeri see sinna. Nüüd on see nende taustapiltide valikus, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Taustapildid võivad olla nii videod kui ka liikumatud pildid. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildimootor. See dekodeerib video ühe korra kõigi monitoride jaoks, esitab selle heli vaikimisi heliväljundi kaudu ja peatab esituse iga kord, kui seda näha ei ole. Videotaustapilt kulutab siiski palju rohkem energiat kui liikumatu taustapilt.

Teemad võivad sisaldada liikumatule taustapildile lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub sobiv video asukohas `backgrounds/intros/road.mp4`. See esitatakse automaatselt käivitamisel, selle taustapildiga teemale vahetamisel ja selle taustapildi valimisel ning seejärel naasetakse liikumatu pildi juurde. Sissejuhatavad videod taustapiltide valijasse ei ilmu ja need ei lähe kunagi kordusele.

_Välimus > Animatsioonid_ väljalülitamine lülitab välja ka taustapiltide sissejuhatused. Omarchy teeb seda virtuaalmasinas vaikimisi. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine sissejuhatust ei esita.

Tohutu kogu lahedaid hoolikalt valitud taustapilte leiad hoidlast [dharmx/walls](https://github.com/dharmx/walls).

Lukustusekraan näitab videotaustapildist liikumatut kaadrit samamoodi nagu animeeritud GIF-ist liikumatut kaadrit.
