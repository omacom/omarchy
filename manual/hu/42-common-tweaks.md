# Gyakori finomhangolások

Ez az Omarchy-beállítás gyakori testreszabásainak gyűjteménye. Tudd, hogy rendszerfrissítések miatt időnként szükségessé válhat bizonyos konfigurációk eredeti állapotukra való visszaállítása. Ha ez történik, a változtatásaid nem vesznek el, hanem egy `.bak` fájlba kerülnek ugyanabban a könyvtárban.

Ha valamit elrontasz, az Omarchy menü _Frissítés > Konfiguráció_ pontjából visszaállíthatod az egyes konfigurációkat eredeti beállításukra. Ha _igazán_ mindent elrontasz, az `omarchy-reinstall` paranccsal minden konfigurációt visszaállíthatsz.

### Minden tálcaikon folyamatos megmutatása

Alapértelmezetten a tálcaikonok, mint a Dropbox, az 1password vagy a Steam, a tálcakibontó nyíl mögött vannak rejtve, amely megmutatja őket, amikor fölé viszed az egeret. Ha szeretnéd, hogy folyamatosan láthatóak legyenek, kattints jobb gombbal a kibontó nyílra a tálcaikon-kezelő megnyitásához, majd rögzítsd azokat az ikonokat, amelyeket láthatóan akarsz tartani (azokat is elrejtheted, amelyeket soha nem akarsz látni).

### Lekerekített ablaksarkok

Az Omarchy alapértelmezett dizájnja szögletes sarkokra épül, de ha szeretnéd egy kicsit lágyítani, megváltoztathatod a `~/.config/hypr/looknfeel.lua` fájlt úgy, hogy a lekerekítés ne legyen többé kikommentezve:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ablakközök eltávolítása

Laptopkijelzőkön egyesek inkább nem pazarolnak pixeleket ablakközökre (vagy akár egy felső sávra, amelyet a `Super + Shift + Space` kombinációval kikapcsolhatsz). Minden közt és szegélyt kikapcsolhatsz a `Super + Shift + Backspace` kombinációval, vagy végleg eltávolíthatod őket a `~/.config/hypr/looknfeel.lua` ezen szakaszában a kommentek eltávolításával:

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
