# Bakgrunnar

Sérhvert þema fylgir sitt eigið safn bakgrunna, og þú getur bætt við aukabakgrunnum í `~/.config/omarchy/backgrounds/[theme]`. Ef þú vilt bæta við aukabakgrunnsmynd við, segjum, nord þemað, setur þú einfaldlega skrána í `~/.config/omarchy/backgrounds/nord`.

Þú getur gert þetta á auðveldastan hátt með því að fara í _Install > Style > Background_ í Omarchy Menu. Það opnar möppuna þar sem bakgrunnar fyrir það þema eru geymdir. Ýttu á `Super + Shift + F` til að opna annan skráastjóra, finndu bakgrunninn þinn og afritaðu hann yfir. Nú verður hann meðal þeirra bakgrunna sem þú getur valið á milli með `Super + Ctrl + W`.

Bakgrunnar geta verið myndbönd jafnt sem kyrrmyndir. Slepptu `mp4`, `m4v`, `mov`, `webm`, `mkv` eða `avi` skrá í sömu möppu og hún birtist við hlið myndanna. Myndbönd eru spiluð af OWE veggfóðursvélinni. Hún afkóðar myndbandið einu sinni fyrir alla skjái og spilar hljóð þess í gegnum sjálfgefna hljóðútganginn, og hún stöðvar spilun þegar ekkert getur séð það. Myndbandsbakgrunnur eyðir samt mun meiri orku en kyrr bakgrunnur.

Þemu geta innihaldið stutta kynningu fyrir kyrran bakgrunn. Fyrir `backgrounds/road.webp` er samsvarandi myndband á `backgrounds/intros/road.mp4`. Það spilast sjálfkrafa við ræsingu, þegar skipt er yfir í þema með þann bakgrunn valinn, og þegar sá bakgrunnur er valinn, og skilar síðan aftur í kyrrmyndina. Kynningarmyndbönd eru ekki í bakgrunnsveljaranum og endurtaka sig aldrei.

Að velja _Appearance > Animations Off_ slökkur einnig á kynningum bakgrunna. Omarchy gerir þetta sjálfgefið í sýndarvél. Skipunin `omarchy theme bg intro toggle` getur skipt kynningum af og á sérstaklega. Að endurnýja þema spilar ekki kynningu.

Kyrrmynd getur einnig haft lykkju, hljóðláta útgáfu af sömu mynd sem heldur áfram að hreyfast, á `backgrounds/loops/road.mp4`. Hún spilast í stað kyrrmyndarinnar, á eftir kynningu hennar ef hún er til staðar, og stöðvast þegar slökkt er á hreyfimyndum. Á rafhlöðu birtist kyrrmyndin í staðinn, og lykkjan kemur aftur um leið og þú tengir við rafmagn. Lykkjur eru ekki í bakgrunnsveljaranum.

Þú getur fundið gríðarlegt safn af flottum, vandlega völdum bakgrunnum í [dharmx/walls](https://github.com/dharmx/walls).

Lásskjárinn sýnir kyrrmynd úr myndbandsbakgrunni, á sama hátt og hann sýnir kyrrmynd úr hreyfanlegri GIF-mynd.
