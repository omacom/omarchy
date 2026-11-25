# Coigeartuithe coitianta

Is bailiúchán é seo de shaincheapadh coitianta ar shuiteáil Omarchy. Bí ar an eolas go mb’fhéidir go mbeidh sé riachtanach ó am go chéile do nuashonruithe córais cumraíochtaí áirithe a chur ar ais ina mbunriocht. Má tharlaíonn sé sin, ní chaillfear do chuid athruithe, ach cuirfear iad i gcomhad `.bak.<timestamp>` in aice leis an mbunchomhad.

Má dhéanann tú praiseach de rud éigin, is féidir leat cumraíochtaí aonair a chur ar ais ina mbunsuiteáil trí _Update > Config_ sa roghchlár Omarchy. Má dhéanann tú praiseach _i ndáiríre_ de gach rud, is féidir leat na cumraíochtaí go léir a athshocrú trí `omarchy reinstall configs`, nó gach pacáiste agus cumraíocht réamhshocraithe a athshuiteáil le `omarchy reinstall`.

### Taispeáin gach deilbhín tráidire an t-am ar fad

De réir réamhshocraithe, bíonn deilbhíní tráidire, cosúil le Dropbox, 1password, nó Steam, i bhfolach taobh thiar den tsaighead leathnaithe tráidire, a thaispeánann iad nuair a luíonn tú os a chionn. Más mian leat iad a bheith nochta an t-am ar fad, deaschliceáil ar an tsaighead leathnaithe chun bainisteoir na ndeilbhíní tráidire a oscailt, ansin pinnigh na deilbhíní ar mian leat a choinneáil infheicthe (is féidir leat na cinn nach mian leat a fheiceáil choíche a chur i bhfolach freisin).

### Coirnéil chruinne fuinneoige

Is é dearadh réamhshocraithe Omarchy coirnéil chearnacha, ach más maith leat é sin a mhaolú beagán, roghnaigh _Appearance > Windows > Window Corners > Rounded Corners_ sa roghchlár Omarchy, nó rith `omarchy hyprland corners rounded`. Téann _Theme Corners_ ar ais go dtí cibé rud a úsáideann an téama. Chun do gha féin a roghnú, fan ar _Theme Corners_ (`omarchy hyprland corners theme`), mar lódálann Rounded agus Sharp tar éis do chumraíochta agus sáraíonn siad í, agus bain na marcanna tráchta ón gcruinniú i `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Bain bearnaí fuinneoige

Ar thaispeántais ríomhairí glúine, is fearr le roinnt daoine gan aon phicteilín a chur amú ar bhearnaí fuinneoige (nó fiú ar bharra barr, ar féidir leat é a scoránú as le `Super + Shift + Space`). Is féidir leat na bearnaí agus na himill go léir a scoránú as le `Super + Shift + Backspace`, nó iad a bhaint go buan trí na nótaí tráchta a bhaint sa chuid seo de `~/.config/hypr/looknfeel.lua`:

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
