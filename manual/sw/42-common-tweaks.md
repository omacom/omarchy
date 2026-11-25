# Marekebisho ya kawaida

Hii ni mkusanyiko wa marekebisho ya kawaida kwa usanidi wa Omarchy. Fahamu kwamba mara kwa mara inaweza kuwa muhimu kwa masasisho ya mfumo kurejesha mipangilio fulani katika hali yake ya asili. Hili likitokea, mabadiliko yako hayatapotea, bali yatawekwa kwenye faili ya `.bak.<timestamp>` karibu na ile ya asili.

Ukikosea kitu, unaweza kurejesha mipangilio ya kila mmoja katika usanidi wake wa asili kupitia _Update > Config_ katika menyu ya Omarchy. Ukikosea kila kitu *kweli*, unaweza kuweka upya mipangilio yote kupitia `omarchy reinstall configs`, au kusakinisha upya kila kifurushi na mipangilio chaguo-msingi kwa `omarchy reinstall`.

### Fichua aikoni zote za trei wakati wote

Kwa chaguo-msingi, aikoni za trei, kama Dropbox, 1password, au Steam, zimefichwa nyuma ya mshale wa kipanua trei, ambao huzifichua unapouelemea. Ikiwa ungependa ziwe wazi wakati wote, bofya kulia mshale wa kipanua ili kufungua kidhibiti cha aikoni za trei, kisha bandika aikoni unazotaka ziendelee kuonekana (unaweza pia kuficha zile ambazo hutaki kuziona kamwe).

### Pembe za mviringo za dirisha

Muundo chaguo-msingi wa Omarchy ni wa pembe kali mraba, lakini ikiwa ungependa kuupunguza ukali kidogo, chagua _Appearance > Windows > Window Corners > Rounded Corners_ katika menyu ya Omarchy, au endesha `omarchy hyprland corners rounded`. _Theme Corners_ hurudi kwenye chochote kinachotumiwa na mandhari. Ili kuchagua kipenyo chako mwenyewe, baki kwenye _Theme Corners_ (`omarchy hyprland corners theme`), kwa kuwa Rounded na Sharp hupakia baada ya mipangilio yako na kuibatilisha, na uondoe alama ya maoni kwenye rounding katika `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ondoa nafasi kati ya madirisha

Kwenye skrini za laptop, baadhi ya watu hupendelea kutopoteza pikseli hata moja kwenye nafasi kati ya madirisha (au hata upau wa juu, ambao unaweza kuuzima kwa `Super + Shift + Space`). Unaweza kuwasha na kuzima nafasi zote na mipaka kwa `Super + Shift + Backspace`, au kuziondoa kabisa kwa kuondoa alama za maoni katika sehemu hii ya `~/.config/hypr/looknfeel.lua`:

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
