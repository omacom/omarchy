# Taustad

Iga teemaga on kaasas oma taustade komplekt ja sa saad lisada enda omi kataloogi `~/.config/omarchy/backgrounds/[theme]`. Kui tahad lisada näiteks nord teemale täiendava taustapildi, paned faili lihtsalt kataloogi `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsamalt saad seda teha, kui lähed Omarchy menüüs valikuni _Paigalda > Stiil > Taust_. See avab kausta, kus selle teema taustu hoitakse. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taust üles ja kopeeri see sinna. Nüüd on see nende taustade valikus, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Taustad võivad olla nii videod kui ka liikumatud pildid. Pudista `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail samasse kausta ja see ilmub piltide kõrvale. Videoid taasesitab OWE taustapildimootor. See dekodeerib video üks kord kõigi monitoride jaoks ja esitab selle heli vaikeheliväljundi kaudu ning peatab taasesituse alati, kui miski seda näha ei saa. Videotaust kulutab ikkagi palju rohkem energiat kui liikumatust pildist taust.

Teemad võivad sisaldada liikumatule taustale lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub vastav video kohas `backgrounds/intros/road.mp4`. Seda esitatakse automaatselt käivitamisel, selle taustaga valitud teemale lülitumisel ja sama tausta valimisel ning seejärel naaseb see liikumatu pildi juurde. Sissejuhatuse videod jäävad taustavalijast välja ega kordu kunagi.

Valik _Välimus > Animatsioonid välja_ lülitab välja ka taustade sissejuhatused. Omarchy teeb seda vaikimisi virtuaalmasinas. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine sissejuhatust ei esita.

Liikumatul pildil võib olla ka tsükkel, sama pildi vaikne, pidevalt liikuv versioon, kohas `backgrounds/loops/road.mp4`. See esitatakse liikumatu pildi asemel, selle sissejuhatuse järel, kui sel see on, ja see peatub, kui animatsioonid välja lülitatakse. Aku peal näidatakse selle asemel liikumatut pilti ja tsükkel tuleb tagasi niipea, kui toite ühendad. Tsüklid jäävad taustavalijast välja.

Suure kogu lahedaid kureeritud taustu leiad siit: [dharmx/walls](https://github.com/dharmx/walls).

Lukustuskuva näitab videotausta liikumatut kaadrit samamoodi, nagu see näitab animeeritud GIF-i liikumatut kaadrit.
