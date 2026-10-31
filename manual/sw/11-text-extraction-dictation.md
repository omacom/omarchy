# Utoaji wa Maandishi & Kuandika kwa Sauti

### Utoaji wa Maandishi

Bonyeza `Super + Ctrl + PrtScr` kuchagua eneo kwenye skrini kwa ajili ya utoaji wa maandishi. Kisha modeli huria ya OCR ya tesseract itabadilisha uteuzi huo haraka kuwa maandishi na kuyaweka kwenye ubao wa kunakili. Kisha bonyeza tu `Super + V` kubandika.

Hii ni muhimu sana kwa kuchukua anwani kutoka kwenye vijachini vya picha au nambari za simu zilizopachikwa kwenye vichwa vya habari vya tovuti.

 ![text-extraction](images/text-extraction.webp)

### Kuandika kwa Sauti

Kwenye usakinishaji mpya, [Superwhisper](https://superwhisper.com/) ndiyo injini chaguo-msingi ya kuandika kwa sauti, inayotumia uchakataji wa wingu bila kupakua modeli za nje ya mtandao. Chagua Superwhisper au [Voxtype](https://voxtype.io/) kupitia _Setup > Defaults > Dictation_ kwenye menyu ya Omarchy. Kuchagua injini huisakinisha ikihitajika na kuifanya kuwa chaguo-msingi cha kuandika kwa sauti. Voxtype hupakia modeli ya msingi ya Kiingereza inayochukua 150MB; badilisha modeli kwa `voxtype setup model` na mipangilio mingine kupitia `~/.config/voxtype/config.toml`. Superwhisper hufungua mipangilio yake kuchagua uchakataji wa wingu au wa ndani, na OPR huweka programu hiyo ikiwa imesasishwa.

Unaandika kwa sauti kwa kushikilia `Right Alt`, au kwa kuwasha/kuzima kwa `Alt + Space`, na maandishi yaliyoandikwa yataonekana katika eneo la kuingiza lililolengwa. Njia hizi za mkato hutumia injini iliyochaguliwa. Right Alt pia huanzisha uandikaji kwa sauti inapotumika katika mchanganyiko wa virekebishaji; tumia Left Alt kwa michanganyiko hiyo. Kwenye mipangilio ya kibodi ambapo Right Alt ni AltGr, tumia `Alt + Space` ili AltGr iendelee kupatikana kwa kuandika. Usakinishaji wa kabla ya Alt + Space kuwa chaguo-msingi huhifadhi `F9` kwa bonyeza-kuzungumza na `Super + Ctrl + X` kuwasha/kuzima, vilivyoongezwa kwenye `~/.config/hypr/bindings.lua`; viondoe hapo ili kuzirudisha funguo hizo kwa programu.

Njia hizo hizo za mkato hufanya kazi na injini yoyote kati ya hizo mbili. Chagua injini yako kupitia Setup > Defaults > Dictation. Kisakinishi cha injini huisanidi na kuhifadhi uteuzi. Endesha `omarchy default dictation` kuona ni ipi iliyochaguliwa. Uteuzi huhifadhiwa katika `~/.config/omarchy/defaults/dictation`. Usakinishaji mpya huchagua Superwhisper kiotomatiki.

Omarchy hupakia kiotomatiki muunganiko wa eneo-kazi wa injini iliyochaguliwa. Hakuna usanidi wa Superwhisper unaohitajika katika `~/.config/hypr/`.

Vifungo maalum na hati zinaweza kutumia `omarchy dictation start`, `omarchy dictation stop`, na `omarchy dictation toggle`. Injini iliyochaguliwa hushughulikia kurekodi na kunukuu. Kuchagua Superwhisper huzima njia yake ya asili ya mkato ya kushikilia na kuweka uwasishaji wake wa asili kuwa `Ctrl + Alt + Space`, ikiuitenga na funguo za kurekodi za Omarchy. Superwhisper inahitaji angalau njia moja ya asili ya mkato ya kurekodi, na njia yake ya mkato ya kughairi hubaki kupatikana.

Injini za ziada zinaweza kuunganishwa bila kubadilisha Omarchy. Toa faili linaloweza kutekelezwa lenye jina `omarchy-dictation-<backend>` kwenye PATH linalokubali `start`, `stop`, na `toggle` na kurudi haraka, likiwa na hali isiyo sifuri linaposhindwa. Kisakinishi chake husanidi mtoa huduma na kuita `omarchy-dictation-use <backend>` baada ya usanidi uliofanikiwa. Hii husimamisha injini iliyotangulia na kuhifadhi uteuzi kwa atomiki; `stop` lazima ifanikiwe wakati mtoa huduma hajafanya kazi au hapatikani. Majina ya injini hutumia herufi ndogo, tarakimu, na vistari. Toa `omarchy-install-dictation-<backend>` kwa usanidi; `omarchy default dictation <backend>` huianzisha. Ongeza kiingilio cha menyu ya Defaults kupitia kiendelezi cha menyu ya Omarchy kuita kiteuzi hicho. Muunganiko wa hiari wa eneo-kazi unaweza kuishi katika `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
