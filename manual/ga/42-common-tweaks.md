# Mionathruithe coitianta

Is bailiúchán é seo de shaincheapthaí coitianta ar shocrú Omarchy. Bíodh a fhios agat go mb'fhéidir go mbeidh sé riachtanach uaireanta do nuashonruithe córais cumraíochtaí áirithe a chur ar ais ina riocht bunaidh. Má tharlaíonn sé seo, ní chaillfear do chuid athruithe, ach cuirfear iad i gcomhad `.bak` sa chomhadlann chéanna.

Má scriosann tú rud éigin, is féidir leat cumraíochtaí aonair a chur ar ais ina socrú bunaidh trí _Nuashonraigh > Config_ sa roghchlár Omarchy. Má scriosann tú _i ndáiríre_ gach rud, is féidir leat na cumraíochtaí go léir a athshocrú trí `omarchy-reinstall`.

### Nocht deilbhíní an tréidire go léir an t-am ar fad

De réir réamhshocraithe, tá deilbhíní an tréidire, cosúil le Dropbox, 1password, nó Steam, i bhfolach taobh thiar de shaighead leathnóra an tréidire, a nochtann iad nuair a bhíonn tú os a chionn. Más mian leat iad a bheith nochta an t-am ar fad, cliceáil ar dheis ar shaighead an leathnóra chun bainisteoir deilbhíní an tréidire a oscailt, ansin pinnáil na deilbhíní is mian leat a choinneáil infheicthe (is féidir leat na cinn nach dteastaíonn uait a fheiceáil riamh a cheilt freisin).

### Cúinní fuinneoige cruinne

Is dearadh cúinní cearnacha é dearadh réamhshocraithe Omarchy, ach más maith leat é sin a mhaolú beagán, is féidir leat `~/.config/hypr/looknfeel.lua` a athrú ionas nach mbeidh an cruinniú tráchtaireachta as a thuilleadh:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Bain bearnaí fuinneoige

Ar thaispeántais ríomhaire glúine, is fearr le daoine áirithe gan picteilíní ar bith a chur amú ar bhearnaí fuinneoige (nó fiú barra barr, ar féidir leat é a scoránú as le `Super + Shift + Space`). Is féidir leat na bearnaí agus na teorainneacha go léir a scoránú as le `Super + Shift + Backspace`, nó iad a bhaint go buan trí na tráchtaireachtaí a bhaint sa chuid seo de `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
