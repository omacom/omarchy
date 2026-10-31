# Gleusadh cumanta

Seo cruinneachadh de dh'atharrachaidhean cumanta air suidheachadh Omarchy. Bi mothachail gum faod e tachairt bho àm gu àm gum feum ùrachaidhean an t-siostaim cuid a rèiteachaidhean a thilleadh gun staid thùsail. Ma thachras seo, cha chaill thu na h-atharrachaidhean agad, ach thèid an cur ann am faidhle `.bak` san aon phasgan.

Ma nì thu praiseach de rudeigin, 's urrainn dhut rèiteachaidhean fa leth aiseag gun suidheachadh tùsail le _Ùraich > Rèiteachadh_ ann an clàr-taice Omarchy. Ma nì thu praiseach _cheart_ dhen a h-uile rud, 's urrainn dhut na rèiteachaidhean uile ath-shuidheachadh le `omarchy-reinstall`.

### Seall gach ìomhaigheag na treidhe fad na h-ùine

A thaobh bun-roghainn, tha ìomhaigheagan na treidhe, mar Dropbox, 1password no Steam, falaichte air cùlaibh saighead leudachadh na treidhe, a nochdas iad nuair a chumas tu an luchag os a cionn. Ma tha thu airson 's gum bi iad ri am faicinn fad na h-ùine, dèan briogadh deas air an t-saighead gus manaidsear ìomhaigheagan na treidhe fhosgladh, agus prìnich na h-ìomhaigheagan a tha thu airson cumail ri am faicinn (is 's urrainn dhut an fheadhainn nach eil thu ag iarraidh fhaicinn idir fhalach cuideachd).

### Oiseanan cruinn air uinneagan

'S e oiseanan ceàrnagach a th' ann an dealbhadh bunaiteach Omarchy, ach mas toil leat a dhèanamh beagan nas buige, 's urrainn dhut `~/.config/hypr/looknfeel.lua` atharrachadh gus nach bi an cruinneachadh air a chur à gnìomh le comharra beachd tuilleadh:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Thoir air falbh beàrnan nan uinneagan

Air sgrìnichean laptop, b' fheàrr le cuid gun piogsail sam bith a chosg air beàrnan eadar uinneagan (no fiù 's air bàr gu h-àrd, agus 's urrainn dhut sin a chur dheth le `Super + Shift + Space`). 'S urrainn dhut na beàrnan is na h-iomaill uile a chur dheth le `Super + Shift + Backspace`, no an toirt air falbh gu buan le bhith a' toirt air falbh nam beachdan san earrann seo de `~/.config/hypr/looknfeel.lua`:

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
