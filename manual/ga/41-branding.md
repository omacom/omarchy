# Brandáil

Ligeann Omarchy duit lógó do chuideachta nó íomhá phearsanta a shocrú don sábhálaí scáileáin agus don scáileán eolais araon.

### Sábhálaí scáileáin

Is féidir leat an lógó a úsáidtear don sábhálaí scáileáin a athrú faoi _Cuma > Brandáil > Sábhálaí Scáileáin_. Is lógó ASCII é, mar sin is féidir leat an téacs a chur in eagar go díreach, ach is féidir leat íomhá png nó svg a thabhairt dó freisin, agus tiontóimid sin go ASCII. Tá cuma an-deas air.

 ![branding-screensaver](images/branding-screensaver.webp)

Tá trí iontráil sa roghchlár sin:

- **Cuir Téacs in Eagar** osclaíonn sé `~/.config/omarchy/branding/screensaver.txt` i d'eagarthóir. Clóscríobh nó greamaigh cibé rud is mian leat — ealaín ASCII, d'ainm, focal rúnta. Sábháil agus scoir, agus lasann an sábhálaí scáileáin suas láithreach ionas gur féidir leat é a fheiceáil.
- **Socraigh ó Íomhá** osclaíonn sé roghnóir comhad do png nó svg, tiontaíonn sé go ASCII é, agus taispeánann sé an toradh duit. Oibríonn lógónna le scáthchruth soiléir i bhfad níos fearr ná grianghraif.
- **Athchóirigh an Réamhshocrú** cuireann sé lógó Omarchy ar ais.

### Scáileán eolais

Tá na trí rogha chéanna faoi _Cuma > Brandáil > Eolas_ don scáileán _Eolas_ a fhaigheann tú ó roghchlár Omarchy, agus oibríonn siad ar an mbealach céanna — is é `~/.config/omarchy/branding/about.txt` an comhad, agus preabann fuinneog an Eolais aníos tar éis gach athraithe. Tiontaítear ealaín an Eolais go méid níos lú ná ealaín an tsábhálaí scáileáin, óir caithfidh sí luí isteach i bhfuinneog seachas do scáileán a líonadh.

Fad atá an fhuinneog ar oscailt, claonann banda de sholas geal bán trasna na healaíne gach cúpla soicind agus ansin fágann sé socair arís í. Faigheann d'ealaín féin é freisin, fad is atá gach carachtar inti aon cholún ar leithead — tá gach rud a tháirgeann _Socraigh ó Íomhá_ mar sin. Fanann ealaín a tógadh as emoji nó carachtair dhúbailte-leithead socair ina ionad sin, agus fanann an scáileán socair freisin má choinníonn tú cumraíocht fastfetch de do chuid féin: is é atá i lógó socair sna cásanna sin ná an bheochan ag coinneáil as an mbealach seachas ag teip, óir dá sleamhnófaí lonrú trasna orthu, thiocfadh an chuid eile den líne i dtír san áit mhícheart.

 ![branding-about](images/branding-about.webp)

### Íomhánna a thiontú tú féin

Níl sa dá rogha _Socraigh ó Íomhá_ ach `omarchy transcode ascii` a ghlaoch, ar féidir leat é a rith go díreach más mian leat smacht a bheith agat ar an tiontú:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Glacann sé `--width` agus `--height` i gcolúin agus i rónna teirminéil, `--mode` de `braille` (an réamhshocrú, agus i bhfad níos míne) nó `block`, céatadán `--threshold` chun a chinneadh cé na picteilíní a áirítear mar chuid den lógó, agus `--invert` nuair atá do lógó éadrom ar chúlra dorcha. Má thagann tiontú amach mar bhall, is gnách gurb í an tairseach an rud is cóir a athrú.

### Focail in ionad lógó

Tarraingíonn `omarchy ascii` téacs in Delta Corps Priest 1, an cló FIGlet ina bhfuil an focalmharc Omarchy féin tarraingthe, ionas gur féidir leis an sábhálaí scáileáin rud éigin a rá seachas pictiúr a thaispeáint:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Glacann sé an téacs mar argóintí, nó léann sé ó phíopa é nuair nach dtugtar aon cheann dó. Níl sa chló ach litreacha agus spásanna — tarraingíodh gan digití ná poncaíocht é — mar sin scaoiltear aon rud eile agus ainmnítear ar stderr é seachas é a shlogadh go ciúin.
