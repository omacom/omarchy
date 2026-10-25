# Taustad

Igal teemal on oma taustapiltide komplekt ja sa saad lisada enda omasid kausta `~/.config/omarchy/backgrounds/[theme]`. Kui soovid lisada näiteks nord-teemale täiendava taustapildi, pane fail lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsam on seda teha Omarchy menüüs valiku _Install > Style > Background_ kaudu. See avab kausta, kus selle teema taustapilte hoitakse. Vajuta `Super + Shift + F`, et avada teine failihaldur, leia oma taustapilt ja kopeeri see sinna. Nüüd on see valikus taustapiltide hulgas, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Taustad võivad olla nii videod kui ka liikumatud pildid. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildimootor. See dekodeerib video üks kord kõigi monitoride jaoks ja esitab selle heli vaikimisi heliväljundi kaudu ning peatab taasesituse alati, kui seda pole näha. Videotaustapilt tarbib endiselt palju rohkem energiat kui liikumatu taustapilt.

Teemad võivad sisaldada liikumatule taustapildile lühikest sissejuhatust. Faili `backgrounds/road.webp` puhul asub sobiv video aadressil `backgrounds/intros/road.mp4`. See esitatakse automaatselt käivitamisel ja selle taustapildiga valitud teemale lülitumisel ning naaseb seejärel liikumatu pildi juurde. Sissejuhatavad videod ei ilmu taustapiltide valijasse ega kordu kunagi.

Valiku _Appearance > Animations_ väljalülitamine lülitab välja ka taustade sissejuhatused. Omarchy teeb seda virtuaalmasinas vaikimisi. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi sisse ja välja lülitada. Teema värskendamine või teise tausta valimine sama teema sees sissejuhatust ei esita.

Suure valiku lahedaid, hoolikalt valitud taustapilte leiad aadressilt https://github.com/dharmx/walls.

Lukustuskuva näitab videotaustast liikumatut kaadrit samamoodi, nagu see näitab animeeritud GIF-ist liikumatut kaadrit.
