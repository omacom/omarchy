# Brandáil

Ligeann Omarchy duit lógó do chuideachta nó íomhá phearsanta a shocrú don díghlasáil tosaithe, don spárálaí scáileáin, agus don scáileán maidir araon.

### Díghlasáil tosaithe

Is féidir leat `omarchy plymouth preview` a úsáid chun a fheiceáil cén chuma a bheadh ar do lógó saincheaptha agus ar do dhathanna. Glacann sé dath cúlra, dath téacs, png lógó, agus conair don íomhá réamhamhairc:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ansin cuir an socrú i bhfeidhm le `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, a thabharfaidh na dathanna agus an lógó céanna don scáileán logála isteach SDDM freisin. Más mian leat dul ar ais, is féidir leat `omarchy plymouth reset` a úsáid.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Spárálaí scáileáin

Is féidir leat an lógó a úsáidtear don spárálaí scáileáin a athrú faoi _Dealramh > Brandáil > Spárálaí Scáileáin_. Lógó ASCII atá ann, mar sin is féidir leat an téacs a chur in eagar go díreach, ach is féidir leat íomhá png nó svg a thabhairt dó freisin, agus tiontóimid sin go ASCII. Breathnaíonn sé an-deas ar fad.

 ![branding-screensaver](images/branding-screensaver.webp)

Tá trí iontráil sa roghchlár sin:

- **Cuir Téacs in Eagar** osclaíonn sé `~/.config/omarchy/branding/screensaver.txt` i d'eagarthóir. Clóscríobh nó greamaigh cibé rud is mian leat — ealaín ASCII, d'ainm, focal drochmhúinte. Sábháil agus scoir, agus tosóidh an spárálaí scáileáin láithreach ionas go bhfeicfidh tú é.
- **Socraigh ó Íomhá** osclaíonn sé roghnóir comhad do png nó svg, tiontaíonn sé go ASCII é, agus taispeánann sé an toradh duit. Oibríonn lógónna le scáthchruth soiléir i bhfad níos fearr ná grianghraif.
- **Athchóirigh an Réamhshocrú** cuireann sé lógó Omarchy ar ais.

### Scáileán Maidir

Tá na trí rogha chéanna faoi _Dealramh > Brandáil > Maidir_ don scáileán _Maidir_ a fhaigheann tú ó roghchlár Omarchy, agus oibríonn siad ar an mbealach céanna — is é `~/.config/omarchy/branding/about.txt` an comhad, agus tagann fuinneog Maidir aníos tar éis gach athraithe. Tiontaítear ealaín Maidir go méid níos lú ná méid an spárálaí scáileáin, mar go gcaithfidh sí luí isteach i bhfuinneog seachas do scáileán a líonadh.

Agus an fhuinneog ar oscailt, claonann glioscarnach glas trasna na healaíne gach cúpla soicind agus ansin fágann sé socair arís í. Faigheann d'ealaín féin é freisin, chomh fada is go bhfuil gach carachtar inti colún amháin ar leithead — mar atá aon rud a tháirgeann _Socraigh ó Íomhá_. Fanann ealaín atá déanta as emoji nó carachtair dhúbailte-leithid socair ina ionad sin, agus fanann an scáileán socair freisin má choinníonn tú cumraíocht fastfetch de do chuid féin: is é atá i lógó socair sna cásanna sin ná an bheochan ag fanacht as an mbealach seachas ag teip, mar go gcuirfeadh glioscarnach a shleamhnú trasna orthu an chuid eile den líne san áit mícheart.

 ![branding-about](images/branding-about.webp)

### Íomhánna a thiontú tú féin

Níl sa dá rogha _Socraigh ó Íomhá_ ach `omarchy transcode ascii` a ghlaoch, ar féidir leat a rith go díreach más mian leat smacht a bheith agat ar an tiontú:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Glacann sé `--width` agus `--height` i gcolúin agus i rónna teirminéil, `--mode` de `braille` (an réamhshocrú, agus i bhfad níos míne) nó `block`, céatadán `--threshold` chun a chinneadh cé na picteilíní a áirítear mar chuid den lógó, agus `--invert` nuair atá do lógó éadrom ar chúlra dorcha. Má thagann tiontú amach mar bhloba, is gnách gurb é an tairseach an cnaipe le casadh.

### Focail in ionad lógó

Tarraingíonn `omarchy ascii` téacs in Delta Corps Priest 1, an cló FIGlet ina bhfuil comhartha focal Omarchy féin tarraingthe, ionas gur féidir le spárálaí scáileáin rud a rá seachas pictiúr a thaispeáint:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Glacann sé an téacs mar argóintí, nó léann sé ó phíopa é nuair nach dtugtar aon cheann dó. Níl sa chló ach litreacha agus spásanna — tarraingíodh gan digití ná poncaíocht é — mar sin scaoiltear aon rud eile agus ainmnítear ar stderr é seachas é a shlogadh go ciúin.
