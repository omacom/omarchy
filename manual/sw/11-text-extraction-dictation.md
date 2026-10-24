# Uchimbaji wa Maandishi na Imla

### Uchimbaji wa Maandishi

Bonyeza `Super + Ctrl + PrtScr` kuchagua eneo kwenye skrini kwa uchimbaji wa maandishi. Mtindo huria wa OCR wa tesseract kisha utabadilisha haraka uteuzi huo kuwa maandishi na kuyaweka kwenye ubao wa kunakili. Kisha bonyeza tu `Super + V` kubandika.

Hii inasaidia sana kunyakua anwani kutoka vijichini vya picha au nambari za simu zilizopachikwa katika vichwa vya tovuti.

 ![text-extraction](images/text-extraction.webp)

### Imla

Katika usakinishaji mpya, [Superwhisper](https://superwhisper.com/) ndiyo nyuma ya imla chaguomsingi, ikitumia usindikaji wa wingu bila upakuaji wa mtindo wa nje ya mtandao. Chagua Superwhisper au [Voxtype](https://voxtype.io/) kupitia _Sanidi > Chaguomsingi > Imla_ katika menyu ya Omarchy. Kuchagua nyuma huusakinisha ikihitajika na kuufanya kuwa chaguomsingi kwa imla. Voxtype hupakia mtindo wa msingi wa Kiingereza unaochukua 150MB; badilisha mtindo kwa `voxtype setup model` na mipangilio mingine kupitia `~/.config/voxtype/config.toml`. Superwhisper hufungua mipangilio yake kuchagua usindikaji wa wingu au wa ndani, na OPR huweka programu hiyo ikisasishwa.

Unaandika kwa imla kwa kushikilia `Right Alt` au `F9`, au kwa kubadilisha kwa `Super + Ctrl + X`, na maandishi yaliyoamriwa yataonekana katika eneo la ingizo lililozingatiwa. Mikato hii hutumia nyuma iliyochaguliwa. Right Alt pia huanzisha imla inapotumiwa katika mchanganyiko wa kirekebishaji; tumia Left Alt kwa michanganyiko hiyo. Kwenye miumbo ya kibodi ambapo Right Alt ni AltGr, tumia `F9` kuiweka AltGr ipatikane kwa kuandika.

Mikato hiyo hiyo hufanya kazi na nyuma yoyote. Chagua nyuma yako kupitia Sanidi > Chaguomsingi > Imla. Kisakinishi cha nyuma huusanidi na kuhifadhi uteuzi. Endesha `omarchy default dictation` kuona ni gani imechaguliwa. Uteuzi umehifadhiwa katika `~/.config/omarchy/defaults/dictation`. Usakinishaji mpya huchagua Superwhisper kiotomatiki.

Omarchy hupakia muunganiko wa eneo-kazi wa nyuma iliyochaguliwa kiotomatiki. Hakuna usanidi wa Superwhisper unaohitajika katika `~/.config/hypr/`.

Ufungaji wa kubinafsisha na hati zinaweza kutumia `omarchy dictation start`, `omarchy dictation stop`, na `omarchy dictation toggle`. Nyuma iliyochaguliwa hushughulikia kurekodi na unukuu. Kuchagua Superwhisper huzima mkato wake wa asili wa kushikilia na kuweka kibadili chake cha asili kuwa `Alt + Space`, kuiweka tofauti na vitufe vya kurekodi vya Omarchy. Superwhisper huhitaji angalau mkato mmoja wa asili wa kurekodi, na mkato wake wa kughairi hubaki unapatikana.

Nyumba za ziada zinaweza kuunganishwa bila kubadilisha Omarchy. Toa inayoweza kutekelezwa inayoitwa `omarchy-dictation-<backend>` kwenye PATH inayokubali `start`, `stop`, na `toggle` na kurudi haraka, na hali isiyo sifuri ikishindwa. Kisakinishi chake husanidi mtoa huduma na kuita `omarchy-dictation-use <backend>` baada ya usanidi wenye mafanikio. Hii husimamisha nyuma iliyotangulia na kuhifadhi uteuzi kimatomu; `stop` lazima ifanikiwe wakati mtoa huduma hana kazi au hapatikani. Majina ya nyuma hutumia herufi ndogo, tarakimu, na deshi. Toa `omarchy-install-dictation-<backend>` kwa usanidi; `omarchy default dictation <backend>` huizindua. Ongeza ingizo la menyu ya Chaguomsingi kupitia kiendelezi cha menyu ya Omarchy kuita kichaguzi hicho. Muunganiko wa hiari wa eneo-kazi unaweza kuishi katika `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
