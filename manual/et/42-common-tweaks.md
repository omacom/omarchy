# Levinud kohandused

See on kogu levinud kohandustest Omarchy seadistusele. Tea, et süsteemivärskendused võivad aeg-ajalt teatud seadistused nende algsele kujule taastada. Kui see juhtub, ei lähe sinu muudatused kaduma, vaid pannakse samasse kausta `.bak` faili.

Kui midagi ära rikud, saad üksikud seadistused nende algsele kujule taastada Omarchy menüüs jaotise _Uuenda > Seadistus_ kaudu. Kui rikud _tõesti_ kõik ära, saad kõik seadistused lähtestada käsuga `omarchy-reinstall`.

### Näita kõiki salveikoone kogu aeg

Vaikimisi on salveikoonid, nagu Dropbox, 1Password või Steam, peidetud salve laiendamise noole taha, mis need selle kohal hõljumisel välja toob. Kui tahad, et need oleksid kogu aeg nähtaval, tee laiendusnoolel paremklõps, et avada salveikoonide haldur, ja kinnita siis ikoonid, mida tahad nähtavana hoida (saad ka peita need, mida sa kunagi näha ei taha).

### Ümarad aknanurgad

Omarchy vaikimisi kujundus on kandiliste nurkadega, aga kui tahad seda veidi pehmendada, saad muuta faili `~/.config/hypr/looknfeel.lua` nii, et ümardamine pole enam välja kommenteeritud:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Eemalda aknavahed

Sülearvuti ekraanidel eelistavad mõned inimesed mitte ainsatki pikslit aknavahedele raisata (ega isegi menüüribale, mille saad välja lülitada klahvikombinatsiooniga `Super + Shift + Space`). Kõik vahed ja ääred saad välja lülitada klahvikombinatsiooniga `Super + Shift + Backspace` või need jäädavalt eemaldada, eemaldades kommentaarid sellest faili `~/.config/hypr/looknfeel.lua` osast:

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
