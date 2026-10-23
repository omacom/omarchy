# Foni

Katrai tēmai ir savs fonu komplekts, un savējos varat pievienot mapē `~/.config/omarchy/backgrounds/[theme]`. Ja vēlaties, piemēram, nord tēmai pievienot papildu fona attēlu, vienkārši ielieciet failu mapē `~/.config/omarchy/backgrounds/nord`.

Visvieglāk to izdarīt, Omarchy izvēlnē atverot _Instalēt > Stils > Fons_. Tas atvērs mapi, kur glabājas šīs tēmas foni. Nospiediet `Super + Shift + F`, lai palaistu vēl vienu failu pārvaldnieku, atrodiet savu fonu un iekopējiet to. Tagad tas būs iekļauts fonos, starp kuriem varat izvēlēties ar `Super + Ctrl + Space`.

Foni var būt tikpat labi video kā nekustīgi attēli. Ievietojiet `mp4`, `m4v`, `mov`, `webm`, `mkv` vai `avi` failu tajā pašā mapē, un tas parādīsies blakus attēliem. Video atskaņo OWE tapešu dzinējs. Tas dekodē video vienu reizi visiem monitoriem un atskaņo tā skaņu caur noklusējuma audio izvadi, un aptur atskaņošanu vienmēr, kad nekas to nevar redzēt. Bloķēšanas ekrāns zīmē to pašu dekodējumu, izslēgtu, caur OWE. Video tapete joprojām patērē daudz vairāk enerģijas nekā nekustīga.

Tēmās nekustīgam fonam var būt īss ievads. Failam `backgrounds/road.webp` atbilstošais video atrodas vietā `backgrounds/intros/road.mp4`. Tas automātiski atskaņojas sāknēšanas laikā un pārslēdzoties uz tēmu ar šo fonu, pēc tam atgriežas pie nekustīgā attēla. Ievada video neietilpst fonu atlasītājā un nekad neatkārtojas cilpā.

Izslēdzot _Palaist > Izskats > Animācijas_, tiek izslēgti arī fonu ievadi. Omarchy to pēc noklusējuma dara virtuālajā mašīnā. Komanda `omarchy theme bg intro toggle` var ievadus pārslēgt atsevišķi. Tēmas atsvaidzināšana vai cita fona izvēle tajā pašā tēmā ievadu neatskaņo.

Milzīgu foršu atlasītu fonu kolekciju atradīsiet vietnē https://github.com/dharmx/walls.

Video foni, kamēr atskaņošana ir apturēta vai nav pieejama, bloķēšanas ekrānā saglabā kešotu nekustīgu attēlu. Animēti GIF tiek atskaņoti uz darbvirsmas un bloķēšanas ekrānā rāda nekustīgu kadru.
