# Pogoste prilagoditve

To je zbirka pogostih prilagoditev nastavitve Omarchy. Vedite, da bo sistemskim posodobitvam občasno morda treba obnoviti določene konfiguracije v njihovo prvotno stanje. Če se to zgodi, vaše spremembe ne bodo izgubljene, ampak bodo postavljene v datoteko `.bak` v istem imeniku.

Če kaj pokvarite, lahko posamezne konfiguracije obnovite v njihovo prvotno nastavitev prek _Posodobi > Config_ v meniju Omarchy. Če _resnično_ vse pokvarite, lahko vse konfiguracije ponastavite prek `omarchy-reinstall`.

### Vedno razkrij vse ikone pladnja

Privzeto so ikone pladnja, kot so Dropbox, 1password ali Steam, skrite za puščico za razširitev pladnja, ki jih razkrije, ko miško premaknete nanjo. Če želite, da so vedno izpostavljene, z desno tipko miške kliknite puščico za razširitev, da odprete upravitelj ikon pladnja, nato pripnite ikone, ki jih želite ohraniti vidne (skrijete lahko tudi tiste, ki jih nikoli ne želite videti).

### Zaobljeni vogali oken

Privzeta zasnova Omarchyja je zasnova kvadratnih vogalov, če pa želite to nekoliko omiliti, lahko spremenite `~/.config/hypr/looknfeel.lua`, tako da zaobljenje ni več zakomentirano:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Odstrani razmike oken

Na zaslonih prenosnikov nekateri ljudje raje ne zapravljajo nobenih pikslov za razmike oken (ali celo vrstico, ki jo lahko izklopite s `Super + Shift + Space`). Vse razmike in robove lahko izklopite s `Super + Shift + Backspace` ali jih trajno odstranite tako, da odstranite komentarje v tem odseku `~/.config/hypr/looknfeel.lua`:

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
