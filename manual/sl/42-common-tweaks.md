# Pogoste prilagoditve

To je zbirka pogostih prilagoditev namestitve Omarchy. Vedi, da bo pri posodobitvah sistema občasno morda treba nekatere konfiguracije povrniti v prvotno stanje. Če se to zgodi, tvoje spremembe ne bodo izgubljene, ampak bodo shranjene v datoteki `.bak.<timestamp>` poleg izvirnika.

Če kaj zamočiš, lahko posamezne konfiguracije povrneš v prvotno namestitev prek _Posodobitev > Konfiguracija_ v meniju Omarchy. Če _res_ zamočiš vse, lahko vse konfiguracije ponastaviš z `omarchy reinstall configs` ali pa z `omarchy reinstall` znova namestiš vse privzete pakete in konfiguracije.

### Vedno prikaži vse ikone sistemskega pladnja

Ikone sistemskega pladnja, kot so Dropbox, 1password ali Steam, so privzeto skrite za puščico za razširitev pladnja, ki jih prikaže, ko nanjo zadržiš kazalec. Če jih želiš imeti ves čas izpostavljene, z desno tipko klikni puščico za razširitev, da odpreš upravitelja ikon pladnja, nato pripni ikone, ki jih želiš obdržati vidne (lahko tudi skriješ tiste, ki jih nočeš nikoli videti).

### Zaobljeni vogali oken

Privzeta zasnova Omarchy ima oglate vogale, če pa jo želiš nekoliko zmehčati, v meniju Omarchy izberi _Videz > Okna > Vogali oken > Zaobljeni vogali_ ali zaženi `omarchy hyprland corners rounded`. _Vogali teme_ se vrne na tisto, kar uporablja tema. Če želiš izbrati lasten polmer, ostani na _Vogali teme_ (`omarchy hyprland corners theme`), saj se Zaobljeni in Ostri naložita za tvojo konfiguracijo in jo prepišeta, ter odkomentiraj zaobljenje v `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Odstrani razmike med okni

Na zaslonih prenosnikov nekateri raje ne zapravljajo nobenih slikovnih pik za razmike med okni (ali celo za zgornjo vrstico, ki jo lahko preklopiš s `Super + Shift + Space`). Vse razmike in obrobe lahko preklopiš s `Super + Shift + Backspace` ali pa jih trajno odstraniš tako, da odstraniš komentarje v tem razdelku datoteke `~/.config/hypr/looknfeel.lua`:

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
