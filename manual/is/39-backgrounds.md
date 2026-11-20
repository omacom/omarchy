# Bakgrunnar

Hvert þema kemur með sitt eigið safn af bakgrunnum og þú getur bætt við aukabakgrunnum frá þér sjálfum í `~/.config/omarchy/backgrounds/[theme]`. Ef þú vilt til dæmis bæta aukabakgrunnsmynd við nord-þemað seturðu skrána einfaldlega í `~/.config/omarchy/backgrounds/nord`.

Þú getur gert þetta á auðveldastan hátt með því að fara í _Setja upp > Stíll > Bakgrunnur_ í Omarchy-valmyndinni. Þá opnast mappan þar sem bakgrunnar þess þema eru geymdir. Ýttu á `Super + Shift + F` til að opna annan skráastjóra, finndu bakgrunninn þinn og afritaðu hann yfir. Nú verður hann meðal þeirra bakgrunna sem þú getur valið á milli með `Super + Ctrl + W`.

Bakgrunnar geta verið myndbönd jafnt sem kyrrmyndir. Slepptu `mp4`, `m4v`, `mov`, `webm`, `mkv` eða `avi` skrá í sömu möppu og hún birtist við hlið myndanna. Myndbönd eru spiluð af OWE-bakgrunnsvélinni. Hún afkóðar myndbandið einu sinni fyrir alla skjái og spilar hljóð þess í gegnum sjálfgefið hljóðúttak og hún stöðvar spilun alltaf þegar ekkert getur séð það. Myndbandsbakgrunnur kostar samt mun meiri orku en kyrr bakgrunnur.

Þemu geta innihaldið stuttan inngang fyrir kyrran bakgrunn. Fyrir `backgrounds/road.webp` er samsvarandi myndband staðsett á `backgrounds/intros/road.mp4`. Það spilast sjálfkrafa við ræsingu, þegar skipt er yfir í þema með þann bakgrunn valinn og þegar sá bakgrunnur er valinn, og snýr svo aftur að kyrrmyndinni. Inngangsmyndbönd eru ekki í bakgrunnsveljaranum og endurtaka sig aldrei.

Ef slökkt er á _Útlit > Hreyfingar_ slokknar einnig á bakgrunnsinngöngum. Omarchy gerir þetta sjálfgefið í sýndarvél. Skipunin `omarchy theme bg intro toggle` getur kveikt og slökkt á inngöngum sérstaklega. Að endurnýja þema spilar ekki inngang.

Kyrrmynd getur einnig haft lykkju, hljóðláta útgáfu af sömu mynd sem heldur áfram að hreyfast, á `backgrounds/loops/road.mp4`. Hún spilast í stað kyrrmyndarinnar, á eftir inngangi hennar ef hún er með einn, og stöðvast þegar slökkt er á hreyfingum. Lykkjur eru ekki í bakgrunnsveljaranum og kosta, eins og allir myndbandsbakgrunnar, meiri orku en kyrrmynd.

Þú getur fundið gríðarstórt safn af flottum, vandlega völdum bakgrunnum í [dharmx/walls](https://github.com/dharmx/walls).

Lásskjárinn sýnir kyrran ramma úr myndbandsbakgrunni, á sama hátt og hann sýnir kyrran ramma úr hreyfðri GIF-mynd.
