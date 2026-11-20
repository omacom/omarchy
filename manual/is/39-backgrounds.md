# Bakgrunnar

Hvert þema kemur með sitt eigið safn bakgrunna og þú getur bætt þínum eigin við í `~/.config/omarchy/backgrounds/[theme]`. Ef þú vilt bæta auka bakgrunnsmynd við, segjum, nord-þemað, setur þú skrána einfaldlega í `~/.config/omarchy/backgrounds/nord`.

Þú gerir þetta auðveldast með því að fara í _Install > Style > Background_ í Omarchy Menu. Það opnar möppuna þar sem bakgrunnar þess þema eru geymdir. Ýttu á `Super + Shift + F` til að opna annan skráastjóra, finndu bakgrunninn þinn og afritaðu hann yfir. Nú verður hann meðal þeirra bakgrunna sem þú getur valið á milli með `Super + Ctrl + W`.

Bakgrunnar geta verið myndbönd jafnt sem kyrrmyndir. Slepptu `mp4`, `m4v`, `mov`, `webm`, `mkv` eða `avi` skrá í sömu möppu og hún birtist við hlið myndanna. Myndbönd eru spiluð af OWE-bakgrunnsvélinni. Hún afkóðar myndbandið einu sinni fyrir alla skjái og spilar hljóð þess í gegnum sjálfgefna hljóðútganginn og hún stöðvar spilun hvenær sem ekkert getur séð það. Myndbandsbakgrunnur kostar samt mun meira afl en kyrr bakgrunnur.

Þemu geta innihaldið stuttan inngang fyrir kyrran bakgrunn. Fyrir `backgrounds/road.webp` er samsvarandi myndband að finna í `backgrounds/intros/road.mp4`. Það spilast sjálfkrafa við ræsingu, þegar skipt er yfir í þema með þann bakgrunn valinn og þegar sá bakgrunnur er valinn, og snýr svo aftur að kyrrmyndinni. Inngangsmyndbönd eru ekki í bakgrunnsveljaranum og eru aldrei spiluð í lykkju.

Að slökkva á _Appearance > Animations_ slekkur einnig á inngöngum bakgrunna. Omarchy gerir þetta sjálfgefið í VM. Skipunin `omarchy theme bg intro toggle` getur kveikt og slökkt á inngöngum sérstaklega. Að endurnýja þema spilar ekki inngang.

Kyrrmynd getur líka haft lykkju, hljóðláta útgáfu af sömu mynd sem heldur áfram að hreyfast, í `backgrounds/loops/road.mp4`. Hún spilast í stað kyrrmyndarinnar, á eftir inngangi hennar ef hún hefur slíkan, og stöðvast þegar slökkt er á hreyfimyndum. Á rafhlöðu birtist kyrrmyndin í staðinn og lykkjan kemur aftur um leið og þú stingur í samband. Lykkjur eru ekki í bakgrunnsveljaranum.

Þú getur fundið gríðarstórt safn af flottum, vandlega völdum bakgrunnum í [dharmx/walls](https://github.com/dharmx/walls).

Lásskjárinn sýnir kyrran ramma úr myndbandsbakgrunni, á sama hátt og hann sýnir kyrran ramma úr hreyfðu GIF.
