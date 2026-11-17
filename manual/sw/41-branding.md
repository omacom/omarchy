# Chapa

Omarchy inakuruhusu kuweka nembo ya kampuni yako au picha yako binafsi kwa ajili ya kufungua wakati wa kuwasha, kiokoa skrini, na skrini ya kuhusu.

### Kufungua wakati wa kuwasha

Unaweza kutumia `omarchy plymouth preview` kuona jinsi nembo na rangi zako maalum zitakavyoonekana. Inachukua rangi ya mandharinyuma, rangi ya maandishi, png ya nembo, na njia ya picha ya onyesho la kukagua:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Kisha tumia usanidi huo kwa `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, ambayo pia itaipa skrini ya kuingia ya SDDM rangi na nembo hizo hizo. Ukitaka kurudisha, unaweza kutumia `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Kiokoa skrini

Unaweza kubadilisha nembo inayotumika kwa kiokoa skrini chini ya _Muonekano > Chapa > Kiokoa Skrini_. Ni nembo ya ASCII, kwa hivyo unaweza kuhariri maandishi moja kwa moja, lakini pia unaweza kuipa picha ya png au svg, nasi tutaibadilisha kuwa ASCII. Inaonekana nzuri sana kabisa.

 ![branding-screensaver](images/branding-screensaver.webp)

Kuna vipengee vitatu katika menyu hiyo:

- **Hariri Maandishi** hufungua `~/.config/omarchy/branding/screensaver.txt` katika kihariri chako. Andika au bandika chochote unachotaka — sanaa ya ASCII, jina lako, neno chafu. Hifadhi na uondoke, na kiokoa skrini kitawaka mara moja ili uweze kukiona.
- **Weka Kutoka kwenye Picha** hufungua kiteua faili kwa ajili ya png au svg, huibadilisha kuwa ASCII, na kukuonyesha matokeo. Nembo zenye umbo lililo wazi hufanya kazi vizuri zaidi kuliko picha.
- **Rejesha Chaguo-msingi** hurudisha nembo ya Omarchy.

### Skrini ya kuhusu

Chaguo hizo hizo tatu ziko chini ya _Muonekano > Chapa > Kuhusu_ kwa ajili ya skrini ya _Kuhusu_ unayoipata kutoka kwenye menyu ya Omarchy, na zinafanya kazi kwa njia ile ile kabisa — faili ni `~/.config/omarchy/branding/about.txt`, na dirisha la Kuhusu hujitokeza baada ya kila mabadiliko. Sanaa ya Kuhusu hubadilishwa kuwa ukubwa mdogo zaidi kuliko wa kiokoa skrini, kwa kuwa inapaswa kutoshea ndani ya dirisha badala ya kujaza onyesho lako.

Dirisha likiwa wazi, mwangaza wa kijani hupita juu ya sanaa kila baada ya sekunde chache kisha huiacha tuli tena. Sanaa yako mwenyewe pia huupata, ilmradi kila herufi ndani yake ina upana wa safu wima moja — kila kitu kinachotolewa na _Weka Kutoka kwenye Picha_ kina sifa hiyo. Sanaa iliyotengenezwa kwa emoji au herufi za upana maradufu hubaki tuli badala yake, na ndivyo pia ilivyo kwa skrini ukiwa na usanidi wako mwenyewe wa fastfetch: nembo tuli katika hali hizo ni uhuishaji ukijiepusha usiingilie njia badala ya kushindwa, kwa kuwa kusogeza mwangaza juu yake kungeiweka sehemu iliyobaki ya mstari mahali pasipofaa.

 ![branding-about](images/branding-about.webp)

### Kubadilisha picha mwenyewe

Chaguo zote mbili za _Weka Kutoka kwenye Picha_ zinaita tu `omarchy transcode ascii`, ambayo unaweza kuiendesha moja kwa moja ukitaka udhibiti wa ubadilishaji:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Inachukua `--width` na `--height` katika safu wima na safu mlalo za terminal, `--mode` ya ama `braille` (chaguo-msingi, na laini zaidi) au `block`, asilimia ya `--threshold` ya kuamua ni pikseli zipi zinazohesabika kuwa sehemu ya nembo, na `--invert` kwa wakati nembo yako ni nyepesi kwenye mandharinyuma meusi. Ubadilishaji ukitoka kama donge, threshold ndiyo kitu cha kugeuza kwa kawaida.

### Maneno badala ya nembo

`omarchy ascii` huchora maandishi kwa Delta Corps Priest 1, fonti ya FIGlet ambayo alama ya neno la Omarchy yenyewe imechorwa kwayo, kwa hivyo kiokoa skrini kinaweza kusema kitu badala ya kuonyesha picha:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Inachukua maandishi kama hoja, au kuyasoma kutoka kwenye pipe isipopewa yoyote. Fonti hubeba herufi na nafasi pekee — ilichorwa bila tarakimu wala alama za uakifishaji — kwa hivyo kitu kingine chochote huondolewa na kutajwa kwenye stderr badala ya kumezwa kimya kimya.
