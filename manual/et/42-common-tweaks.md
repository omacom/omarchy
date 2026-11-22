# Levinud kohandused

See on kogu Omarchy seadistuse levinud kohandustest. Tea, et süsteemiuuendustel võib mõnikord olla vaja teatud konfiguratsioone algsele kujule taastada. Kui see juhtub, ei lähe sinu muudatused kaotsi, vaid pannakse originaali kõrvale `.bak.<timestamp>` faili.

Kui midagi vussi keerad, saad üksikud konfiguratsioonid algsele seadistusele taastada Omarchy menüüs _Uuendamine > Konfiguratsioon_ kaudu. Kui keerad _tõesti_ kõik vussi, saad kõik konfiguratsioonid lähtestada käsuga `omarchy reinstall configs` või installida iga vaikepaketi ja konfiguratsiooni uuesti käsuga `omarchy reinstall`.

### Näita kõiki salveikoone kogu aeg

Vaikimisi on salveikoonid, näiteks Dropbox, 1password või Steam, peidetud salve laiendaja noole taha, mis näitab neid, kui hiirega selle kohale liigud. Kui soovid, et need oleksid kogu aeg nähtaval, paremklõpsa laiendaja noolt, et avada salveikoonide haldur, seejärel kinnista ikoonid, mida soovid nähtaval hoida (saad peita ka need, mida sa kunagi näha ei taha).

### Ümarad aknanurgad

Omarchy vaikekujundus on kandiliste nurkadega, aga kui soovid seda veidi pehmendada, vali Omarchy menüüs _Välimus > Aknad > Aknanurgad > Ümarad nurgad_ või käivita `omarchy hyprland corners rounded`. _Teema nurgad_ läheb tagasi selle juurde, mida teema kasutab. Oma raadiuse valimiseks püsi valikul _Teema nurgad_ (`omarchy hyprland corners theme`), kuna Ümarad ja Teravad laetakse pärast sinu konfiguratsiooni ja kirjutavad selle üle, ning eemalda ümaruse juurest kommentaarimärgid failis `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Aknavahede eemaldamine

Sülearvuti ekraanil eelistavad mõned inimesed mitte raisata ühtegi pikslit aknavahedele (või isegi ülaribale, mille saab välja lülitada kombinatsiooniga `Super + Shift + Space`). Saad kõik vahed ja äärised välja lülitada kombinatsiooniga `Super + Shift + Backspace` või need püsivalt eemaldada, eemaldades kommentaarimärgid sellest faili `~/.config/hypr/looknfeel.lua` jaotisest:

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
