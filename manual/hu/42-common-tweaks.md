# Gyakori módosítások

Ez az Omarchy-beállítás gyakori, személyre szabott módosításainak gyűjteménye. Tudd, hogy a rendszerfrissítések miatt időnként szükség lehet bizonyos konfigurációk eredeti állapotának visszaállítására. Ha ez történik, a módosításaid nem vesznek el, hanem az eredeti mellett egy `.bak.<timestamp>` fájlba kerülnek.

Ha elrontasz valamit, az egyes konfigurációkat visszaállíthatod az eredeti beállításukra az Omarchy menü _Update > Config_ pontján keresztül. Ha _igazán_ elrontasz mindent, az összes konfigurációt visszaállíthatod az `omarchy reinstall configs` paranccsal, vagy minden alapértelmezett csomagot és konfigurációt újratelepíthetsz az `omarchy reinstall` paranccsal.

### Minden tálcaikon folyamatos megjelenítése

Alapértelmezés szerint a tálcaikonok, mint a Dropbox, az 1password vagy a Steam, a tálcakibontó nyíl mögött rejtve vannak, amely akkor fedi fel őket, amikor fölé viszed az egeret. Ha szeretnéd, hogy mindig láthatók legyenek, kattints jobb gombbal a kibontó nyílra a tálcaikon-kezelő megnyitásához, majd tűzd ki azokat az ikonokat, amelyeket láthatóan akarsz tartani (azokat is elrejtheted, amelyeket soha nem akarsz látni).

### Lekerekített ablaksarkok

Az Omarchy alapértelmezett kialakítása szögletes sarkokat használ, de ha szeretnéd ezt egy kicsit lágyítani, válaszd az _Appearance > Windows > Window Corners > Rounded Corners_ lehetőséget az Omarchy menüben, vagy futtasd az `omarchy hyprland corners rounded` parancsot. A _Theme Corners_ visszatér ahhoz, amit a téma használ. Saját sugár kiválasztásához maradj a _Theme Corners_ beállításnál (`omarchy hyprland corners theme`), mivel a Rounded és a Sharp a konfigurációd után töltődik be, és felülírja azt, és vedd ki a kommentből a lekerekítést a `~/.config/hypr/looknfeel.lua` fájlban:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ablakrések eltávolítása

Laptopkijelzőkön egyesek inkább nem pazarolnak egyetlen pixelt sem ablakrésekre (vagy akár egy felső sávra sem, amelyet a `Super + Shift + Space` billentyűkombinációval kapcsolhatsz ki). Az összes rést és szegélyt a `Super + Shift + Backspace` billentyűkombinációval kapcsolhatod ki, vagy véglegesen eltávolíthatod őket, ha eltávolítod a kommenteket a `~/.config/hypr/looknfeel.lua` fájl ezen szakaszából:

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
