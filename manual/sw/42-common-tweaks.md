# Marekebisho ya kawaida

Huu ni mkusanyiko wa urekebishaji wa kawaida kwenye usanidi wa Omarchy. Jua kuwa wakati mwingine inaweza kuwa muhimu kwa masasisho ya mfumo kurejesha usanidi fulani kwenye hali yao ya asili. Kama hii inatokea, mabadiliko yako hayatapotea, lakini yatawekwa katika faili ya `.bak` katika saraka hiyo hiyo.

Kama unaharibu kitu, unaweza kurejesha usanidi mmojammoja kwenye usanidi wao wa asili kupitia _Sasisha > Usanidi_ katika menyu ya Omarchy. Kama _kweli_ unaharibu kila kitu, unaweza kuweka upya usanidi wote kupitia `omarchy-reinstall`.

### Fichua aikoni zote za trei wakati wote

Kwa chaguomsingi, aikoni za trei, kama Dropbox, 1password, au Steam, zimefichwa nyuma ya mshale wa kupanua trei, ambao huzifichua unapouelekeza. Kama ungependa ziwe wazi wakati wote, bofya kulia mshale wa kupanua ili kufungua kidhibiti cha aikoni za trei, kisha bandika aikoni unazotaka kubaki zinaonekana (unaweza pia kuficha zile usizotaka kuona kamwe).

### Pembeni za madirisha za mviringo

Ubunifu chaguomsingi wa Omarchy ni ule wa pembeni za mraba, lakini kama unapenda kuilainisha kidogo, unaweza kubadilisha `~/.config/hypr/looknfeel.lua` ili umviringo usiwe umetolewa maoni tena:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ondoa mapengo ya madirisha

Kwenye skrini za kompyuta mpakato, watu wengine hupendelea kutopoteza pikseli zozote kwa mapengo ya madirisha (au hata upau wa juu, ambao unaweza kuuzima kwa `Super + Shift + Space`). Unaweza kuzima mapengo na mipaka yote kwa `Super + Shift + Backspace`, au kuziondoa kabisa kwa kuondoa maoni katika sehemu hii ya `~/.config/hypr/looknfeel.lua`:

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
