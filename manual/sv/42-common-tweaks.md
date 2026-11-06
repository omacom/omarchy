# Vanliga justeringar

Detta är en samling vanliga anpassningar av Omarchy-konfigurationen. Vet att det ibland kan vara nödvändigt för systemuppdateringar att återställa vissa konfigurationer till deras ursprungliga skick. Om detta händer förloras inte dina ändringar, utan läggs i en `.bak`-fil i samma katalog.

Om du förstör något kan du återställa enskilda konfigurationer till deras ursprungliga konfiguration via _Uppdatera > Config_ i Omarchy-menyn. Om du _verkligen_ förstör allting kan du återställa alla konfigurationer via `omarchy-reinstall`.

### Visa alla brickikoner hela tiden

Som standard döljs brickikoner, som Dropbox, 1password eller Steam, bakom brickutfällarens pil, som visar dem när du hovrar över den. Om du vill ha dem exponerade hela tiden högerklickar du på utfallningspilen för att öppna brickikonhanteraren, och fäster sedan de ikoner du vill hålla synliga (du kan också dölja dem du aldrig vill se).

### Rundade fönsterhörn

Omarchys standarddesign är en av fyrkantiga hörn, men om du vill mjuka upp det lite kan du ändra `~/.config/hypr/looknfeel.lua` så att rundning inte längre är bortkommenterad:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ta bort fönstermellanrum

På bärbara skärmar föredrar vissa att inte slösa några pixlar på fönstermellanrum (eller ens ett menyfält, som du kan växla av med `Super + Shift + Space`). Du kan växla av alla mellanrum och kanter med `Super + Shift + Backspace`, eller ta bort dem permanent genom att ta bort kommentarerna i detta avsnitt av `~/.config/hypr/looknfeel.lua`:

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
