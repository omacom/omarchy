# Taustapildid

Iga teemaga on kaasas oma taustapiltide komplekt ja sa saad lisada enda omi kausta `~/.config/omarchy/backgrounds/[theme]`. Kui tahad lisada näiteks nord teemale täiendava taustapildi, pane fail lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsam on seda teha, kui lähed Omarchy Menus kohta _Paigalda > Stiil > Taust_. See avab kausta, kus selle teema taustapilte hoitakse. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taustapilt ja kopeeri see sinna. Nüüd on see valikus nende taustapiltide hulgas, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Taustad võivad olla nii videod kui ka liikumatud pildid. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildimootor. See dekodeerib video üks kord kõigi monitoride jaoks ja esitab selle heli vaikimisi heliväljundi kaudu ning peatab esituse alati, kui miski seda näha ei saa. Videotaustapilt kulutab ikkagi palju rohkem energiat kui liikumatu taustapilt.

Teemad võivad sisaldada liikumatu tausta jaoks lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub sobiv video kohas `backgrounds/intros/road.mp4`. See mängib automaatselt käivitamisel, selle taustaga valitud teemale lülitumisel ja selle tausta valimisel ning naaseb seejärel liikumatu pildi juurde. Sissejuhatavad videod ei ilmu taustavalijasse ega kordu kunagi.

_Välimus > Animatsioonid_ väljalülitamine lülitab välja ka tausta sissejuhatused. Omarchy teeb seda virtuaalmasinas vaikimisi. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine sissejuhatust ei mängi.

Liikumatul pildil võib olla ka silmus, sama pildi rahulik, pidevalt liikuv versioon kohas `backgrounds/loops/road.mp4`. Seda mängitakse liikumatu pildi asemel, pärast selle sissejuhatust, kui see on olemas, ja see peatub, kui animatsioonid välja lülitatakse. Akutoitel kuvatakse selle asemel liikumatu pilt ja silmus tuleb tagasi, kui toite ühendad. Silmused ei ilmu taustavalijasse.

Suure kogumiku lahedaid kureeritud taustapilte leiad kohast [dharmx/walls](https://github.com/dharmx/walls).

Lukustuskuva näitab videotausta liikumatut kaadrit samamoodi, nagu see näitab animeeritud GIF-i liikumatut kaadrit.
