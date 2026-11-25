# Vanliga justeringar

Det här är en samling vanliga anpassningar av Omarchy-installationen. Tänk på att systemuppdateringar ibland kan behöva återställa vissa konfigurationer till deras ursprungliga skick. Om det händer försvinner inte dina ändringar, utan läggs i en `.bak.<timestamp>`-fil bredvid originalet.

Om du klantar till något kan du återställa enskilda konfigurationer till deras ursprungliga installation via _Uppdatera > Konfiguration_ i Omarchy-menyn. Om du *verkligen* klantar till allt kan du återställa alla konfigurationer via `omarchy reinstall configs`, eller installera om alla standardpaket och konfigurationer med `omarchy reinstall`.

### Visa alla ikoner i systembrickan hela tiden

Som standard är ikoner i systembrickan, som Dropbox, 1password eller Steam, dolda bakom pilen för att expandera brickan, som visar dem när du hovrar över den. Om du vill ha dem synliga hela tiden högerklickar du på expanderpilen för att öppna hanteraren för ikoner i systembrickan och fäster sedan de ikoner du vill ha kvar synliga (du kan också dölja dem du aldrig vill se).

### Rundade fönsterhörn

Omarchys standarddesign har fyrkantiga hörn, men om du vill mjuka upp det lite väljer du _Utseende > Fönster > Fönsterhörn > Rundade hörn_ i Omarchy-menyn, eller kör `omarchy hyprland corners rounded`. _Temahörn_ går tillbaka till det temat använder. För att välja din egen radie stannar du på _Temahörn_ (`omarchy hyprland corners theme`), eftersom Rundade och Skarpa läses in efter din konfiguration och åsidosätter den, och avkommenterar avrundningen i `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ta bort mellanrum mellan fönster

På bärbara datorers skärmar föredrar vissa att inte slösa några pixlar på mellanrum mellan fönster (eller ens en översta panel, som du kan slå av med `Super + Shift + Space`). Du kan slå av alla mellanrum och kanter med `Super + Shift + Backspace`, eller ta bort dem permanent genom att ta bort kommentarerna i det här avsnittet i `~/.config/hypr/looknfeel.lua`:

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
