# Taustad

Iga teemaga tuleb kaasa oma taustade komplekt ja sa saad omi juurde lisada kausta `~/.config/omarchy/backgrounds/[teema]`. Kui tahad lisada lisatausta näiteks nord teemale, pane fail lihtsalt kausta `~/.config/omarchy/backgrounds/nord`.

Kõige lihtsam on seda teha Omarchy menüüs jaotise _Paigalda > Stiil > Taust_ kaudu. See avab kausta, kus selle teema taustad asuvad. Vajuta `Super + Shift + F`, et käivitada teine failihaldur, leia oma taust ja kopeeri see üle. Nüüd on see taustade valikus, mille hulgast saad valida klahvikombinatsiooniga `Super + Ctrl + Space`.

Taustad võivad olla lisaks piltidele ka videod. Pane samasse kausta `mp4`, `m4v`, `mov`, `webm`, `mkv` või `avi` fail ja see ilmub piltide kõrvale. Videoid esitab OWE taustapildi mootor. See dekodeerib video üks kord kõigi kuvarite jaoks ja esitab selle heli vaikimisi heliväljundi kaudu ning peatab taasesituse alati, kui miski seda näha ei saa. Lukuekraan joonistab sama dekoodi vaigistatult läbi OWE. Videotaust kulutab ikka tunduvalt rohkem energiat kui liikumatult taust.

Teemad võivad liikumatule taustale lisada lühikese sissejuhatuse. Faili `backgrounds/road.webp` puhul asub vastav video aadressil `backgrounds/intros/road.mp4`. See esitatakse automaatselt alglaadimisel ja selle taustaga teemale lülitumisel ning pöördub siis tagasi liikumatu pildi juurde. Sissejuhatavad videod jäävad taustavalikust välja ega kordu kunagi.

Valiku _Käivita > Välimus > Animatsioonid_ väljalülitamine lülitab välja ka tausta sissejuhatused. Virtuaalmasinas teeb Omarchy seda vaikimisi. Käsk `omarchy theme bg intro toggle` saab sissejuhatusi eraldi lülitada. Teema värskendamine või teise tausta valimine sama teema sees sissejuhatust ei esita.

Suure koguse lahedaid kureeritud taustu leiad aadressilt https://github.com/dharmx/walls.

Videotaustad hoiavad lukuekraanil vahemällu salvestatud liikumatut pilti, kui taasesitus on peatatud või kättesaamatu. Animeeritud GIF-id esitatakse töölaual ja näitavad lukuekraanil liikumatut kaadrit.
