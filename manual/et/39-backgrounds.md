# Taustapildid

Iga teemaga on kaasas oma taustapiltide komplekt ja sa saad enda omi lisada kausta `~/.config/omarchy/backgrounds/[theme]`. Kui tahad lisada täiendava taustapildi näiteks nord teemale, pane fail lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsam on seda teha, kui lähed Omarchy menüüs valikuni _Paigalda > Stiil > Taust_. See avab kausta, kus selle teema taustapildid asuvad. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taustapilt ja kopeeri see sinna. Nüüd on see valikute hulgas, mille vahel saad valida klahvidega `Super + Ctrl + W`.

Taustapildid võivad olla nii videod kui ka liikumatud pildid. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildimootor. See dekodeerib video üks kord kõigi monitoride jaoks ja esitab selle heli vaikimisi heliväljundi kaudu ning peatab esituse iga kord, kui seda pole näha. Videotaustapilt kulutab siiski palju rohkem energiat kui liikumatu taustapilt.

Teemad võivad sisaldada liikumatu taustapildi jaoks lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub sobiv video failis `backgrounds/intros/road.mp4`. See esitatakse automaatselt käivitamisel ja selle valitud taustapildiga teemale lülitumisel, seejärel naaseb see liikumatu pildi juurde. Sissejuhatavad videod ei ilmu taustapildi valijasse ega kordu kunagi.

Valiku _Välimus > Animatsioonid_ väljalülitamine lülitab välja ka taustapiltide sissejuhatused. Omarchy teeb seda vaikimisi virtuaalmasinas. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine või teise taustapildi valimine sama teema piires sissejuhatust ei esita.

Suure kogumiku lahedaid, hoolikalt valitud taustapilte leiad kogumikust [dharmx/walls](https://github.com/dharmx/walls).

Lukustuskuva näitab videotaustapildist liikumatut kaadrit, samamoodi nagu see näitab animeeritud GIF-ist liikumatut kaadrit.
