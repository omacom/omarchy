# Programu-jalizi za Shell

Eneo-kazi la Omarchy huendeshwa kama mchakato mmoja wa Quickshell wa muda mrefu unaoitwa `omarchy-shell`, na karibu kila kitu unachokiona kwenye skrini ni programu-jalizi ndani yake. Upau ni programu-jalizi. Vivyo hivyo paneli zinazodondoka kutoka kwake, vifuniko vya skrini nzima kama kiteuzi cha emoji na meneja wa ubao wa kunakili, menyu ya Omarchy yenyewe, skrini ya kufuli, kisogezi cha polkit, na huduma zisizo na kichwa zinazofuatilia betri yako na kupasha skrini yako moto usiku.

Hiyo si maelezo tu ya utekelezaji. Ina maana unaweza kuzima vipande vya eneo-kazi, kuvibadilisha, au kuandika vyako mwenyewe bila kugusa mstari wa chanzo cha Omarchy.

Programu-jalizi za mtu wa kwanza huja na Omarchy na kukaa katika `$OMARCHY_PATH/shell/plugins/`. Chochote unachoongeza mwenyewe — majaribio yako mwenyewe, au kitu ulichopata kwenye GitHub — hukaa katika `~/.config/omarchy/plugins/`. Zote mbili hugunduliwa kwa njia ile ile wakati wa kuanza, lakini zilizo za ndani hupokea violesura vinavyoaminika vya shell wakati programu-jalizi za wahusika wengine hupokea kiolesura kidogo kilichowekewa wigo kwa huduma na mzunguko wa maisha wao wenyewe. Nakala za zilizo za ndani huhifadhi tu usanidi maalum wa chanzo na miito ya UI inayohitajika kwa tabia ya asili.

## Kuona ulivyonavyo

```
omarchy plugin list
```

Hiyo huchapisha kila programu-jalizi iliyogunduliwa yenye kitambulisho chake, kama imewashwa, kama ni ya mtu wa kwanza au ya wahusika wengine, aina zake, na jina lake la onyesho. Ongeza `--json` kama unailisha kwa kitu kingine.

Vitambulisho vya programu-jalizi vimewekewa nafasi ya jina. Zilizo za ndani zote huanza na `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — na nafasi hiyo ya jina imehifadhiwa, hivyo programu-jalizi ya wahusika wengine haiwezi kamwe kuidai.

## Kuziwasha na kuzizima

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Au tumia menyu: _Sanidi > Programu-jalizi_ ina Washa, Zima, Ongeza, Nakili, na Ondoa, kila moja na kiteuzi kinachotoa tu programu-jalizi zenye maana kwa kitendo hicho.

Hali ya kuwashwa huhifadhiwa katika `~/.config/omarchy/shell.json`, na kanuni hutofautiana kidogo kwa aina mbili za programu-jalizi. Programu-jalizi ya wahusika wengine huwashwa kabisa wakati kitambulisho chake kinapoonekana mahali fulani katika faili hiyo — kama kiingilio cha mpangilio wa upau, kama kiingilio katika `plugins[]`, au kama `bar.id`. Programu-jalizi za mtu wa kwanza ambazo si wijeti za upau ni vinginevyo: zimewashwa kwa chaguomsingi na huzimwa tu kwa kuorodheshwa katika `disabledPlugins[]`.

Programu-jalizi kamili ya upau haina hali ya kuzimwa kabisa. Daima kuna upau mmoja tu hasa, hivyo unaubadilisha kwa kuwasha mwingine. Uwekaji wa wijeti ya upau umefunikwa katika [upau wa juu](05-the-top-bar.md).

## Kuongeza programu-jalizi kutoka git

Programu-jalizi ya wahusika wengine ni hazina tu ya git yenye `manifest.json` katika mzizi wake.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Kabla haijafanya chochote, inakuambia wazi kwamba programu-jalizi huendeshwa kama msimbo wa kiholela, usio na sanduku ndani ya mchakato wako wa shell wa muda mrefu, inakuonyesha URL, na inakuomba uthibitishe. Chukua hilo kwa uzito. Kiolesura cha programu-jalizi ya wahusika wengine hakionyeshi huduma za uthibitishaji moja kwa moja, na upau mbadala hupokea tu uwezo mdogo kwa UI isiyo ya uthibitishaji iliyosanidiwa. Programu-jalizi za kuona bado hushiriki eneo la QML la shell na zinaweza kutembea vitu vya kawaida vya mzazi, wakati msimbo wote wa programu-jalizi huendeshwa na kila kitu ambacho akaunti yako ya mtumiaji inaweza kufikia. Hali ya uthibitishaji hulindwa kando kwa kuweka huduma hizo nje ya grafu ya kitu mwenyeji inayofikiwa. Ongeza tu hazina ambazo uko tayari kuziendesha, na uzisome kabla huja-ziwasha.

Upau mbadala unaweza kutoa wijeti zilizosakinishwa, lakini wijeti za wahusika wengine zinazotegemea huduma zinaweza kuwa na utendakazi uliopunguzwa hapo kwa sababu upau hauruhusiwi kuomba kitu cha huduma hai cha programu-jalizi nyingine. Rudi kwenye `omarchy.bar` iliyojengewa ndani kama wijeti kama hiyo inahitaji huduma yake rafiki.

Kisha hunakili hazina kwenye saraka ya awamu, huthibitisha manifesti, hukataa usakinishaji kama programu-jalizi nyingine tayari inadai kitambulisho hicho, na kuihamishia katika `~/.config/omarchy/plugins/<id>/`. Bila `--enable` huuliza kama unataka iwake sasa, na unaweza kusema hapana na kwenda kusoma msimbo kwanza. Haendeshi kitu chochote kutoka programu-jalizi, kamwe haitekelezi ndoano ya usakinishaji, na kamwe haiaulizi sudo — hunakili faili, huangalia manifesti, na hugeuza biti kupitia IPC.

Kusasisha ni kuvuta haraka-mbele (fast-forward pull) kwa nakala ile ile:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Bila kitambulisho husasisha kila programu-jalizi inayosimamiwa na git uliyonayo. Inakuonyesha tofauti kabla ya kuitumia, hukataa kusasisha kama una mabadiliko ya ndani ambayo haiwezi kusogeza haraka-mbele kupita, na hurudi nyuma kama marekebisho mapya yatashindwa uthibitishaji.

```
omarchy plugin remove acme.weather
```

Uondoaji huzima programu-jalizi kwanza, kisha huifuta kama ni nakala ya git (hazina bado iko juu) au huiondoa kiungo kama ni kiungo cha kiishara. Folda ya programu-jalizi iliyotengenezwa kwa mkono bila hazina ya git huhamishiwa kwenye nakala rudufu yenye muhuri wa muda ndani ya saraka ya programu-jalizi badala ya kufutwa moja kwa moja.

## Kunakili iliyojengewa ndani kuibadilisha

Hii ndiyo sehemu ninayoipenda zaidi. Kama unataka kubadilisha jinsi wijeti iliyojengewa ndani inavyofanya kazi, usihariri faili chini ya `$OMARCHY_PATH` — hizo ni za kifurushi na sasisho linalofuata litaandika juu yake. Inakili badala yake:

```
omarchy plugin clone omarchy.clock
```

Hiyo hunakili programu-jalizi nzima katika `~/.config/omarchy/plugins/dhh.clock` (jina lako la mtumiaji, si langu), huibadilisha jina kuwa "Saa Yangu", huiwasha, na kubadilisha shell kutoka iliyojengewa ndani hadi nakala yako — ikiweka nafasi na mipangilio ya wijeti ya upau iliyopo. Ongeza `--edit` kufungua saraka mpya katika `$EDITOR` yako mara moja, ambayo ndiyo menyu ya _Sanidi > Programu-jalizi > Nakili Programu-jalizi_ hukufanyia.

Kiambishi awali cha jina la mtumiaji huweka kitambulisho cha nakala yako kuwa chako, hivyo kuishiriki hakuigongi ya mtu mwingine yeyote. Miito inayofanywa kwa kitambulisho cha asili kilichojengewa ndani huelekezwa kwenye nakala yako, hivyo hakuna kilichorejelea `omarchy.clock` kinachohitaji kusasishwa. Na kama utafanya fujo nayo, `omarchy plugin remove dhh.clock` hurudisha iliyojengewa ndani.

Kuhifadhi faili popote chini ya `~/.config/omarchy/plugins/` hupakia upya msimbo wa programu-jalizi kiotomatiki, hivyo unaweza kuacha kihariri wazi na kutazama mabadiliko yako yakitia.

## Kuandika yako mwenyewe

Programu-jalizi ni saraka yenye `manifest.json` na QML fulani. Manifesti hutangaza `schemaVersion: 1`, `id`, `name`, `version`, `kinds` moja au zaidi, na kitu cha `entryPoints` kinachoelekeza kwenye faili ya QML kwa kila aina:

| Aina | Ni nini |
|------|------------|
| `bar-widget` | Kipengele ambacho upau hai unaweza kukidondosha kwenye sehemu |
| `panel` | Dirisha linaloelea la kudumu au lililoitwa |
| `overlay` | Kifuniko cha skrini nzima |
| `menu` | Uso wa menyu ulioitwa |
| `service` | Kitu kimoja kisicho na kichwa bila UI |
| `bar` | Upau kamili unaochukua nafasi ya uliojengewa ndani |

Programu-jalizi inaweza kutangaza aina kadhaa mara moja — programu-jalizi ya media ni `service` na `bar-widget`. Wijeti za upau hupata kitalu cha ziada cha `barWidget` chenye jina la onyesho, kategoria, `defaultSection` ya hiari, na `allowMultiple`, ambayo husema kama ina maana kuwa na zaidi ya moja kwenye upau. Wijeti nyingi huiweka kuwa `false`; vitenganishi na viashiria huiweka kuwa `true`.

Kabla hujachapisha kitu chochote, kiangalie:

```
omarchy plugin validate ./my-plugin
```

Hiyo huendesha ukaguzi ule ule ambao shell hufanya wakati wa kupakia: toleo la schema, sehemu zinazohitajika, kitambulisho kisichohifadhiwa, pointi za kuingia ambazo ni njia salama za uhusiano na kwa kweli zipo, pointi ya kuingia kwa kila aina uliyodai, na hakuna viungo vya kiishara popote ndani ya folda.

Kwa uendelezaji wa programu-jalizi, tazama [rejeleo la shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) na [orodha ya programu-jalizi za mtu wa kwanza](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Kushiriki yako na dunia

Mara umetengeneza kitu unachokipenda, kiweke katika hazina ya git ya umma. Hiyo ndiyo utaratibu mzima wa usambazaji — yeyote anaweza kisha kuendesha `omarchy plugin add` dhidi ya URL yako na kuifanya ifanye kazi katika sekunde chache.

Ili kuwasaidia watu kuipata kwa kweli, iorodheshe katika [plugins.omarchy.org](https://plugins.omarchy.org). Hilo ndilo soko la programu-jalizi za shell za Omarchy, na ni mahali pa kwanza pa kutazama unapojiuliza kama mtu tayari amejenga wijeti unayotaka kuiandika. Ivinjari kabla hujaanza!
