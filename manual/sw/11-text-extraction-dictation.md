# Uchimbaji wa Maandishi na Kuandika kwa Sauti

### Uchimbaji wa Maandishi

Bonyeza `Super + Ctrl + PrtScr` ili kuchagua eneo kwenye skrini kwa ajili ya uchimbaji wa maandishi. Kisha modeli ya OCR ya huria ya tesseract itabadilisha uteuzi huo kwa haraka kuwa maandishi na kuyaweka kwenye ubao wa kunakili. Kisha unabonyeza tu `Super + V` ili kubandika.

Hii ni muhimu sana kwa kuchukua anwani kutoka kwenye vijachini vya picha au nambari za simu zilizopachikwa kwenye vichwa vya habari vya tovuti.

 ![text-extraction](images/text-extraction.webp)

### Kuandika kwa Sauti

Kwenye usakinishaji mpya, [Superwhisper](https://superwhisper.com/) ndiye mtoa huduma chaguo-msingi wa kuandika kwa sauti, akitumia uchakataji wa wingu bila kupakua modeli za nje ya mtandao. Chagua Superwhisper, [Voxtype](https://voxtype.io/), au [Hex](https://anoma.ly/hex/) kupitia _Setup > Defaults > Dictation_ katika menyu ya Omarchy. Kuchagua mtoa huduma humsakinisha ikihitajika na kumfanya kuwa chaguo-msingi wa kuandika kwa sauti. Voxtype hupakia modeli ya msingi ya Kiingereza inayochukua 150MB; badilisha modeli kwa `voxtype setup model` na mipangilio mingine kupitia `~/.config/voxtype/config.toml`. Superwhisper hufungua mipangilio yake ili kuchagua uchakataji wa wingu au wa ndani, na OPR huweka programu hiyo ikisasishwa. Hex hupakua modeli yake ya usemi ya kwenye kifaa wakati wa usanidi na huendesha kama huduma ya mtumiaji ya `hex.service`; fungua dirisha lake kutoka kwenye ikoni ya trei ya upau au kwa kuendesha `hex` ili kubadilisha modeli na mipangilio mingine.

Unaandika kwa sauti kwa kushikilia `Right Alt`, au kwa kubadilisha kwa `Alt + Space`, na maandishi yaliyoandikwa kwa sauti yataonekana katika eneo lililolengwa la kuingiza. Njia hizi za mkato hutumia mtoa huduma aliyechaguliwa. Alt ya Kulia pia huanzisha uandikaji kwa sauti inapotumika katika mchanganyiko wa virekebishaji; tumia Alt ya Kushoto kwa mchanganyiko huo. Kwenye miundo ya kibodi ambapo Alt ya Kulia ni AltGr, tumia `Alt + Space` ili kuweka AltGr ipatikane kwa kuandika. Usakinishaji wa kabla ya Alt + Space kuwa chaguo-msingi huhifadhi `F9` kwa bonyeza-ili-kuzungumza na `Super + Ctrl + X` kwa kubadilisha, iliyoongezwa kwenye `~/.config/hypr/bindings.lua`, ambapo hiyo `Super + Ctrl + X` huchukua nafasi ya paneli ya mawakala; ziondoe hapo ili kurudisha vitufe hivyo kwa programu na paneli.

Njia hizo hizo za mkato hufanya kazi na kila mtoa huduma. Chagua mtoa huduma wako kupitia Setup > Defaults > Dictation. Kisakinishi cha mtoa huduma humsanidi na kuhifadhi uteuzi. Endesha `omarchy default dictation` ili kuona ni yupi aliyechaguliwa. Uteuzi huhifadhiwa katika `~/.config/omarchy/defaults/dictation`. Usakinishaji mpya huchagua Superwhisper kiotomatiki.

Omarchy hupakia kiotomatiki muunganiko wa eneo-kazi wa mtoa huduma aliyechaguliwa. Hakuna usanidi wa Superwhisper unaohitajika katika `~/.config/hypr/`.

Vifungo maalum na hati zinaweza kutumia `omarchy dictation start`, `omarchy dictation stop`, na `omarchy dictation toggle`. Mtoa huduma aliyechaguliwa hushughulikia kurekodi na unukuzi. Kuchagua Superwhisper huzima njia yake ya mkato ya asili ya kushikilia na kuweka ubadilishaji wake wa asili kuwa `Ctrl + Alt + Space`, ikiiweka tofauti na vitufe vya kurekodi vya Omarchy. Superwhisper inahitaji angalau njia moja ya mkato ya asili ya kurekodi, na njia yake ya mkato ya kughairi hubaki ipatikana.

Watoa huduma wa ziada wanaweza kuunganishwa bila kubadilisha Omarchy. Toa faili inayoweza kutekelezwa iitwayo `omarchy-dictation-<backend>` kwenye PATH inayokubali `start`, `stop`, na `toggle` na kurudi mara moja, ikiwa na hali ya kutoka isiyo sifuri inaposhindwa. Kisakinishi chake humsanidi mtoa huduma na kuita `omarchy-dictation-use <backend>` baada ya usanidi uliofaulu. Hii husimamisha mtoa huduma aliyepita na kuhifadhi uteuzi kiatomiki; `stop` lazima ifaulu wakati mtoa huduma yuko bila kazi au haapatikani. Majina ya watoa huduma hutumia herufi ndogo, tarakimu, na vistariungio. Toa `omarchy-install-dictation-<backend>` kwa usanidi; `omarchy default dictation <backend>` huianzisha. Ongeza ingizo la menyu ya Defaults kupitia kiendelezi cha menyu ya Omarchy ili kuita kiteuzi hicho. Muunganiko wa hiari wa eneo-kazi unaweza kuishi katika `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
