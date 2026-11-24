# Chapa

Omarchy inakuruhusu kuweka nembo ya kampuni yako au picha yako binafsi kwa ajili ya kufungua wakati wa kuwasha, kiokoa skrini, na skrini ya kuhusu.

### Kufungua wakati wa kuwasha

Unaweza kutumia `omarchy plymouth preview` kuona jinsi nembo yako maalum na rangi zako zitakavyoonekana. Inachukua rangi ya mandharinyuma, rangi ya maandishi, png ya nembo, na njia ya picha ya onyesho la awali:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Kisha tumia mpangilio huo kwa `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, ambayo pia itaipa skrini ya kuingia ya SDDM rangi na nembo hizo hizo. Ikiwa unataka kurudisha, unaweza kutumia `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Kiokoa skrini

Unaweza kubadilisha nembo inayotumika kwa kiokoa skrini chini ya _Mwonekano > Chapa > Kiokoa Skrini_. Ni nembo ya ASCII, kwa hivyo unaweza kuhariri maandishi moja kwa moja, lakini pia unaweza kuipa picha ya png au svg, nasi tutaibadilisha kuwa ASCII. Inaonekana poa sana.

 ![branding-screensaver](images/branding-screensaver.webp)

Kuna vipengee vitatu katika menyu hiyo:

- **Hariri Maandishi** inafungua `~/.config/omarchy/branding/screensaver.txt` katika kihariri chako. Andika au bandika chochote unachotaka — sanaa ya ASCII, jina lako, neno chafu. Hifadhi na uondoke, na kiokoa skrini kitawaka mara moja ili uweze kukiona.
- **Weka Kutoka kwenye Picha** inafungua kichagua faili kwa ajili ya png au svg, inaibadilisha kuwa ASCII, na inakuonyesha matokeo. Nembo zenye umbo lililo wazi hufanya kazi vizuri zaidi kuliko picha zilizopigwa.
- **Rejesha Chaguo-msingi** inarudisha nembo ya Omarchy.

### Skrini ya kuhusu

Chaguo hizo hizo tatu ziko chini ya _Mwonekano > Chapa > Kuhusu_ kwa ajili ya skrini ya _Kuhusu_ unayoipata kutoka kwenye menyu ya Omarchy, na zinafanya kazi kwa njia ile ile — faili ni `~/.config/omarchy/branding/about.txt`, na dirisha la Kuhusu hujitokeza baada ya kila mabadiliko. Sanaa ya Kuhusu hubadilishwa kuwa ukubwa mdogo kuliko wa kiokoa skrini, kwani inabidi itoshee kwenye dirisha badala ya kujaza onyesho lako.

Wakati dirisha liko wazi, mkanda wa mwanga mweupe mkali huelekea kupita kwenye sanaa kila baada ya sekunde chache na kisha huiacha imetulia tena. Sanaa yako mwenyewe pia huipata, mradi kila herufi ndani yake ina upana wa safu wima moja — kila kitu kinachotengenezwa na _Weka Kutoka kwenye Picha_ kiko hivyo. Sanaa iliyotengenezwa kwa emoji au herufi zenye upana maradufu hubaki imetulia badala yake, na ndivyo ilivyo kwa skrini ukiweka usanidi wako mwenyewe wa fastfetch: nembo iliyotulia katika hali hizo ni uhuishaji ukijiepusha usiingilie badala ya kushindwa, kwani kutelezesha mwanga unaometa kupitia kwao kungeweka sehemu iliyobaki ya mstari mahali pasipofaa.

 ![branding-about](images/branding-about.webp)

### Kubadilisha picha mwenyewe

Chaguo zote mbili za _Weka Kutoka kwenye Picha_ zinaita tu `omarchy transcode ascii`, ambayo unaweza kuiendesha moja kwa moja ikiwa unataka udhibiti wa ubadilishaji:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Inachukua `--width` na `--height` katika safu wima na safu mlalo za terminal, `--mode` ya ama `braille` (chaguo-msingi, na yenye undani zaidi) au `block`, asilimia ya `--threshold` ya kuamua ni pikseli zipi zinahesabika kama sehemu ya nembo, na `--invert` kwa wakati nembo yako ni nyepesi kwenye mandharinyuma meusi. Ikiwa ubadilishaji unatokea kama donge, threshold ndiyo kitufe cha kugeuza kwa kawaida.

### Maneno badala ya nembo

`omarchy ascii` huchora maandishi katika Delta Corps Priest 1, fonti ya FIGlet ambayo neno la Omarchy lenyewe limechorwa kwayo, kwa hivyo kiokoa skrini kinaweza kusema kitu badala ya kuonyesha picha:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Inachukua maandishi kama hoja, au huyasoma kutoka kwenye pipe inapopewa hakuna. Fonti hubeba herufi na nafasi tu — ilichorwa bila tarakimu au alama za uakifishaji — kwa hivyo kitu kingine chochote huachwa na kutajwa kwenye stderr badala ya kumezwa kimya kimya.
