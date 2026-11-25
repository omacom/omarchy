# Taustad

Iga teema sisaldab oma taustade komplekti ja sa saad lisada oma lisasid kausta `~/.config/omarchy/backgrounds/[theme]`. Kui soovid lisada täiendava taustapildi näiteks nord teemale, pane fail lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsamalt saad seda teha, kui lähed Omarchy Menu menüüs valikuni _Install > Style > Background_. See avab kausta, kus selle teema taustu hoitakse. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taust üles ja kopeeri see sinna. Nüüd on see nende taustade hulgas, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Teema, millel ei ole ühtegi oma tausta, saab ühe, mis joonistatakse selle värvidest: Omarchy logo teema aktsendivärvis selle taustavärvil. Lisa oma, et see asendada.

Taustad võivad olla nii videod kui ka liikumatud pildid. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildimootor. See dekodeerib video üks kord kõigi monitoride jaoks ja esitab selle heli vaikeheliväljundi kaudu ning peatab esituse iga kord, kui seda ei ole näha. Videotaustapilt kulutab ikkagi palju rohkem energiat kui liikumatu pilt.

Teemad võivad sisaldada liikumatu tausta jaoks lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub sobiv video kohal `backgrounds/intros/road.mp4`. See esitatakse automaatselt käivitamisel, selle taustaga valitud teemale lülitumisel ja selle tausta valimisel, seejärel naaseb liikumatu pilt. Sissejuhatusvideod jäävad taustavalijast välja ja neid ei esitata kunagi korduvalt.

Valik _Appearance > Animations Off_ lülitab välja ka taustade sissejuhatused. Omarchy teeb seda virtuaalmasinas vaikimisi. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine sissejuhatust ei esita.

Liikumatul pildil võib olla ka silmus, sama pildi rahulik versioon, mis liigub pidevalt, kohal `backgrounds/loops/road.mp4`. Seda esitatakse liikumatu pildi asemel, pärast selle sissejuhatust, kui sellel see on, ja see peatub, kui animatsioonid välja lülitatakse. Aku peal näidatakse selle asemel liikumatut pilti ja silmus naaseb, kui toite ühendad. Silmused jäävad taustavalijast välja.

Suure kogumiku lahedaid kureeritud taustu leiad kogumikust [dharmx/walls](https://github.com/dharmx/walls).

Lukustuskuva näitab videotausta liikumatut kaadrit samamoodi, nagu see näitab animeeritud GIF-i liikumatut kaadrit.
