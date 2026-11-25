# Brandáil

Ligeann Omarchy duit lógó do chuideachta nó d'íomhá phearsanta a shocrú don díghlasáil tosaithe, don spárálaí scáileáin, agus don scáileán eolais araon.

### Díghlasáil tosaithe

Is féidir leat `omarchy plymouth preview` a úsáid chun a fheiceáil cén chuma a bheadh ar do lógó agus ar do dhathanna saincheaptha. Glacann sé dath cúlra, dath téacs, png lógó, agus conair don íomhá réamhamhairc:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ansin cuir an socrú i bhfeidhm le `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, a thabharfaidh na dathanna agus an lógó céanna do scáileán logála isteach SDDM freisin. Más mian leat é a chur ar ceal, is féidir leat `omarchy plymouth reset` a úsáid.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Spárálaí scáileáin

Is féidir leat an lógó a úsáidtear don spárálaí scáileáin a athrú faoi _Cuma > Brandáil > Spárálaí Scáileáin_. Is lógó ASCII é, mar sin is féidir leat an téacs a chur in eagar go díreach, ach is féidir leat íomhá png nó svg a thabhairt dó freisin, agus tiontóimid sin go ASCII. Tá cuma an-fhionnuar air.

 ![branding-screensaver](images/branding-screensaver.webp)

Tá trí iontráil sa roghchlár sin:

- **Cuir Téacs in Eagar** osclaíonn sé `~/.config/omarchy/branding/screensaver.txt` i d'eagarthóir. Clóscríobh nó greamaigh cibé rud is mian leat — ealaín ASCII, d'ainm, focal gáirsiúil. Sábháil agus scoir, agus tosóidh an spárálaí scáileáin láithreach ionas gur féidir leat é a fheiceáil.
- **Socraigh Ó Íomhá** osclaíonn sé roghnóir comhad do png nó svg, tiontaíonn sé go ASCII é, agus taispeánann sé an toradh duit. Oibríonn lógónna le scáthchruth soiléir i bhfad níos fearr ná grianghraif.
- **Athchóirigh an Réamhshocrú** cuireann sé lógó Omarchy ar ais.

### Scáileán eolais

Tá na trí rogha chéanna faoi _Cuma > Brandáil > Eolas_ don scáileán _Eolas_ a fhaigheann tú ó roghchlár Omarchy, agus oibríonn siad ar an mbealach céanna — is é `~/.config/omarchy/branding/about.txt` an comhad, agus tagann fuinneog Eolas aníos tar éis gach athraithe. Déantar ealaín Eolas a thiontú go méid níos lú ná ealaín an spárálaí scáileáin, ós rud é go gcaithfidh sí luí isteach i bhfuinneog seachas do thaispeántas a líonadh.

Fad is atá an fhuinneog ar oscailt, claonann banda de sholas geal bán trasna na healaíne gach cúpla soicind agus ansin fágann sé socair arís í. Faigheann d'ealaín féin é freisin, chomh fada is a bhíonn gach carachtar inti aon cholún amháin ar leithead — bíonn gach rud a tháirgeann _Socraigh Ó Íomhá_ amhlaidh. Fanann ealaín a tógadh as emoji nó carachtair dhúbailte-leithead socair ina ionad sin, agus fanann an scáileán socair freisin má choinníonn tú cumraíocht fastfetch de do chuid féin: is é lógó socair sna cásanna sin an bheochan ag fanacht as an mbealach seachas ag teip, ós rud é go gcuirfeadh gliondar a shleamhnú trasna orthu an chuid eile den líne san áit mhícheart dá bharr.

 ![branding-about](images/branding-about.webp)

### Íomhánna a thiontú leat féin

Níl sa dá rogha _Socraigh Ó Íomhá_ ach `omarchy transcode ascii` a ghlaoch, ar féidir leat é a rith go díreach más mian leat smacht a bheith agat ar an tiontú:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Glacann sé `--width` agus `--height` i gcolúin agus i sraitheanna teirminéil, `--mode` de `braille` (an réamhshocrú, agus i bhfad níos míne) nó `block`, céatadán `--threshold` chun a chinneadh cé na picteilíní a áirítear mar chuid den lógó, agus `--invert` nuair a bhíonn do lógó geal ar chúlra dorcha. Má thagann tiontú amach mar bhall, is gnách gurb í an tairseach an socrú is cóir a choigeartú.

### Focail in ionad lógó

Tarraingíonn `omarchy ascii` téacs in Delta Corps Priest 1, an cló FIGlet ina bhfuil comhartha focal Omarchy féin tarraingthe, ionas gur féidir le spárálaí scáileáin rud éigin a rá seachas pictiúr a thaispeáint:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Glacann sé an téacs mar argóintí, nó léann sé ó phíopa é nuair nach dtugtar aon cheann dó. Níl sa chló ach litreacha agus spásanna — tarraingíodh gan digití ná poncaíocht é — mar sin scaoiltear aon rud eile agus ainmnítear é ar stderr seachas é a shlogadh go ciúin.
