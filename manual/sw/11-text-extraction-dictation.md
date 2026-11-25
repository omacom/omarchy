# Utoaji wa Maandishi na Kuamuru

### Utoaji wa Maandishi

Bonyeza `Super + Ctrl + PrtScr` kuchagua eneo kwenye skrini kwa ajili ya utoaji wa maandishi. Kisha modeli ya OCR ya chanzo huria ya tesseract itabadilisha uteuzi huo haraka kuwa maandishi na kuyaweka kwenye ubao wa kunakili. Kisha bonyeza tu `Super + V` kubandika.

Hii ni muhimu sana kwa kuchukua anwani kutoka kwenye vijachini vya picha au nambari za simu zilizopachikwa kwenye vichwa vya tovuti.

 ![text-extraction](images/text-extraction.webp)

### Kuamuru

Kwenye usakinishaji mpya, [Superwhisper](https://superwhisper.com/) ndio mfumo chaguo-msingi wa nyuma wa kuamuru, unaotumia uchakataji wa wingu bila upakuaji wa modeli za nje ya mtandao. Chagua Superwhisper, [Voxtype](https://voxtype.io/), au [Hex](https://anoma.ly/hex/) kupitia _Setup > Defaults > Dictation_ katika menyu ya Omarchy. Kuchagua mfumo wa nyuma huusakinisha ikiwa unahitajika na kuufanya kuwa chaguo-msingi cha kuamuru. Voxtype hupakia modeli ya msingi ya Kiingereza inayochukua 150MB; badilisha modeli kwa `voxtype setup model` na mipangilio mingine kupitia `~/.config/voxtype/config.toml`. Superwhisper hufungua mipangilio yake kuchagua uchakataji wa wingu au wa ndani, na OPR huweka programu ikiwa imesasishwa. Hex hupakua modeli yake ya usemi ya kwenye kifaa wakati wa usanidi na huendeshwa kama huduma ya mtumiaji ya `hex.service`; fungua dirisha lake kutoka kwenye ikoni ya trei ya upau au kwa kuendesha `hex` kubadilisha modeli na mipangilio mingine.

Unaamuru kwa kushikilia `Right Alt`, au kwa kuwasha/kuzima kwa `Alt + Space`, na maandishi yaliyoamriwa yataonekana katika eneo la kuingiza lililolengwa. Njia hizi za mkato hutumia mfumo wa nyuma uliochaguliwa. Right Alt pia huanzisha kuamuru inapotumiwa katika mchanganyiko wa virekebishaji; tumia Left Alt kwa michanganyiko hiyo. Kwenye mipangilio ya kibodi ambapo Right Alt ni AltGr, ikiwa ni pamoja na wakati mpangilio kama huo ni mmoja unaobadilisha kwenda kwake, ishikilie peke yake kwa muda kuamuru; AltGr ikibonyezwa pamoja na kitufe kingine bado huandika herufi yake. Usakinishaji wa kabla ya Alt + Space kuwa chaguo-msingi huhifadhi `F9` kwa push-to-talk na `Super + Ctrl + X` kwa kuwasha/kuzima, vilivyoongezwa kwenye `~/.config/hypr/bindings.lua`, ambapo `Super + Ctrl + X` hiyo huchukua nafasi ya paneli ya agents; ziondoe hapo kurudisha vitufe hivyo kwa programu na paneli.

Njia za mkato sawa hufanya kazi na kila mfumo wa nyuma. Chagua mfumo wako wa nyuma kupitia Setup > Defaults > Dictation. Kisakinishi cha mfumo wa nyuma huusanidi na kuhifadhi uteuzi. Endesha `omarchy default dictation` kuona ni upi uliochaguliwa. Uteuzi huhifadhiwa katika `~/.config/omarchy/defaults/dictation`. Usakinishaji mpya huchagua Superwhisper kiotomatiki.

Omarchy hupakia kiotomatiki ujumuishaji wa eneo-kazi wa mfumo wa nyuma uliochaguliwa. Hakuna usanidi wa Superwhisper unaohitajika katika `~/.config/hypr/`.

Vifungo maalum na hati zinaweza kutumia `omarchy dictation start`, `omarchy dictation stop`, na `omarchy dictation toggle`. Mfumo wa nyuma uliochaguliwa hushughulikia kurekodi na kunukuu. Kuchagua Superwhisper huzima njia yake ya asili ya mkato ya kushikilia na kuweka uwasishaji wake wa asili kuwa `Ctrl + Alt + Space`, ukiitenganisha na vitufe vya kurekodi vya Omarchy. Superwhisper huhitaji angalau njia moja ya asili ya mkato ya kurekodi, na njia yake ya mkato ya kughairi hubaki inapatikana.

Mifumo ya ziada ya nyuma inaweza kujumuika bila kubadilisha Omarchy. Toa inayotekelezeka iitwayo `omarchy-dictation-<backend>` kwenye PATH inayokubali `start`, `stop`, na `toggle` na kurudi mara moja, ikiwa na hali isiyo sifuri inaposhindwa. Kisakinishi chake husanidi mtoa huduma na kuita `omarchy-dictation-use <backend>` baada ya usanidi uliofaulu. Hii husimamisha mfumo wa nyuma uliopita na kuhifadhi uteuzi kwa ukamilifu; `stop` lazima ifaulu wakati mtoa huduma hayuko kazini au haipatikani. Majina ya mifumo ya nyuma hutumia herufi ndogo, tarakimu, na vihyphen. Toa `omarchy-install-dictation-<backend>` kwa ajili ya usanidi; `omarchy default dictation <backend>` huianzisha. Ongeza kiingilio cha menyu ya Defaults kupitia kiendelezi cha menyu ya Omarchy kuita kichaguzi hicho. Ujumuishaji wa hiari wa eneo-kazi unaweza kuwa katika `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
