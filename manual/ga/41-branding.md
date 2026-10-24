# Brandáil

Ceadaíonn Omarchy duit lógó do chuideachta nó íomhá phearsanta a shocrú don díghlasáil tosaithe, don choigilteoir scáileáin, agus don scáileán faisnéise araon.

### Díghlasáil tosaithe

Is féidir leat `omarchy plymouth preview` a úsáid chun a fheiceáil cad a bheadh cuma do lógó saincheaptha agus do dhathanna. Glacann sé dath cúlra, dath téacs, png lógó, agus cosán don íomhá réamhamhairc:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ansin cuir an socrú i bhfeidhm le `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, a thabharfaidh na dathanna agus an lógó céanna don scáileán logála isteach SDDM freisin. Más mian leat filleadh air, is féidir leat `omarchy plymouth reset` a úsáid.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Coigilteoir scáileáin

Is féidir leat an lógó a úsáidtear don choigilteoir scáileáin a athrú faoi _Stíl > Coigilteoir scáileáin_. Is lógó ASCII é, mar sin is féidir leat an téacs a chur in eagar go díreach, ach is féidir leat íomhá png nó svg a thabhairt dó freisin, agus tiontóimid é sin go ASCII. Breathnaíonn sé sách fionnuar.

 ![branding-screensaver](images/branding-screensaver.webp)

Tá trí iontráil sa roghchlár sin:

- Osclaíonn **Edit Text** `~/.config/omarchy/branding/screensaver.txt` i d'eagarthóir. Clóscríobh nó greamaigh cibé rud is mian leat — ealaín ASCII, d'ainm, focal drochmhúinte. Sábháil agus scoir, agus lastar an coigilteoir scáileáin suas láithreach ionas gur féidir leat é a fheiceáil.
- Osclaíonn **Set From Image** roghnóir comhad le haghaidh png nó svg, tiontaíonn sé go ASCII é, agus taispeánann sé an toradh duit. Oibríonn lógónna le scáthchruth soiléir i bhfad níos fearr ná grianghraif.
- Cuireann **Restore Default** lógó Omarchy ar ais.

### Scáileán faisnéise

Tá na trí rogha chéanna faoi _Stíl > Faisnéis_ don scáileán _Faisnéis_ a fhaigheann tú ón roghchlár Omarchy, agus oibríonn siad ar an mbealach céanna — is é an comhad `~/.config/omarchy/branding/about.txt`, agus preabann an fhuinneog Faisnéise suas tar éis gach athraithe. Tiontaítear an ealaín Faisnéise go méid níos lú ná ealaín an choigilteora scáileáin, óir caithfidh sí luí i bhfuinneog seachas do thaispeáint a líonadh.

Fad is atá an fhuinneog ar oscailt, claonaíonn glioscarnach glas trasna na healaíne gach cúpla soicind agus ansin fágann sé socair arís í. Faigheann d'ealaín féin é freisin, chomh fada is go bhfuil gach carachtar inti colún amháin ar leithead — is amhlaidh atá aon rud a tháirgeann _Set From Image_. Fanann ealaín a tógadh as emoji nó carachtair dhúbailte-leithid socair ina áit sin, agus fanann an scáileán amhlaidh freisin má choinníonn tú cumraíocht fastfetch de do chuid féin: is é lógó socair sna cásanna sin an beochan ag coinneáil as an mbealach seachas ag teip, óir chuirfeadh glioscarnach a shleamhnú trasna orthu an chuid eile den líne sa áit mhícheart.

 ![branding-about](images/branding-about.webp)

### Íomhánna a thiontú tú féin

Ní dhéanann an dá rogha _Set From Image_ ach `omarchy transcode ascii` a ghlaoch, ar féidir leat é a rith go díreach más mian leat smacht a bheith agat ar an tiontú:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Glacann sé `--width` agus `--height` i gcolúin agus sraitheanna teirminéil, `--mode` de `braille` (an réamhshocrú, agus i bhfad níos míne) nó `block`, céatadán `--threshold` chun cinneadh a dhéanamh cé na picteilíní a chomhaireann mar chuid den lógó, agus `--invert` nuair atá do lógó solas ar chúlra dorcha. Má thagann tiontú amach mar bhloba, is gnách gurb é an tairseach an cnaipe le casadh.

### Focail in áit lógó

Tarraingíonn `omarchy ascii` téacs in Delta Corps Priest 1, an cló FIGlet ina bhfuil an marc focal Omarchy féin tarraingthe, mar sin is féidir le coigilteoir scáileáin rud éigin a rá seachas pictiúr a thaispeáint:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Glacann sé an téacs mar argóintí, nó léann sé ó phíopa é nuair nach dtugtar aon cheann. Ní iompraíonn an cló ach litreacha agus spásanna — tarraingíodh é gan digití ná poncaíocht — mar sin scaoiltear aon rud eile agus ainmnítear é ar stderr seachas é a shlogadh go ciúin.
