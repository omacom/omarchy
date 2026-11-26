# Foni

Katrai tēmai ir savs fonu komplekts, un jūs varat pievienot savus papildu fonus mapē `~/.config/omarchy/backgrounds/[theme]`. Ja vēlaties pievienot papildu fona attēlu, piemēram, nord tēmai, vienkārši ievietojiet failu mapē `~/.config/omarchy/backgrounds/nord`.

Visvieglāk to izdarīt, Omarchy izvēlnē dodoties uz _Instalēšana > Stils > Fons_. Tas atvērs mapi, kurā glabājas šīs tēmas foni. Nospiediet `Super + Shift + F`, lai palaistu citu failu pārvaldnieku, atrodiet savu fonu un pārkopējiet to. Tagad tas būs iekļauts fonu izvēlē, starp kuriem varat izvēlēties, izmantojot `Super + Ctrl + W`.

Tēma, kurai nav savu fonu, saņem vienu, kas uzzīmēts no tās krāsām: Omarchy logotipu tēmas akcenta krāsā uz tās fona krāsas. Pievienojiet savus, lai to aizstātu.

Foni var būt arī video, ne tikai nekustīgi attēli. Ievietojiet `mp4`, `m4v`, `mov`, `webm`, `mkv` vai `avi` failu tajā pašā mapē, un tas parādīsies līdzās attēliem. Video atskaņo OWE tapešu dzinējs. Tas dekodē video vienu reizi visiem monitoriem un atskaņo tā skaņu caur noklusējuma audio izvadi, un tas aptur atskaņošanu ikreiz, kad nekas to nevar redzēt. Video fons joprojām patērē daudz vairāk enerģijas nekā nekustīgs fons.

Tēmas var ietvert īsu intro nekustīgam fonam. Fonam `backgrounds/road.webp` atbilstošais video atrodas `backgrounds/intros/road.mp4`. Tas automātiski atskaņojas, sistēmai palaižoties, pārslēdzoties uz tēmu ar izvēlētu šo fonu un izvēloties šo fonu, pēc tam atgriežas pie nekustīgā attēla. Intro video neparādās fonu izvēlnē un nekad neatkārtojas ciklā.

Izvēloties _Izskats > Animācijas izslēgtas_, tiek izslēgti arī fonu intro. Omarchy to pēc noklusējuma dara virtuālajā mašīnā. Komanda `omarchy theme bg intro toggle` var pārslēgt intro atsevišķi. Tēmas atsvaidzināšana intro neatskaņo.

Nekustīgam attēlam var būt arī cikls, klusa tā paša attēla versija, kas turpina kustēties, `backgrounds/loops/road.mp4`. Tas atskaņojas nekustīgā attēla vietā, pēc tā intro, ja tāds ir, un apstājas, kad animācijas tiek izslēgtas. Darbojoties ar akumulatoru, tā vietā tiek rādīts nekustīgais attēls, un cikls atgriežas, tiklīdz pieslēdzat strāvu. Cikli neparādās fonu izvēlnē.

Milzīgu stilīgu, rūpīgi atlasītu fonu kolekciju varat atrast [dharmx/walls](https://github.com/dharmx/walls).

Bloķēšanas ekrānā tiek rādīts video fona nekustīgs kadrs, tāpat kā tajā tiek rādīts animēta GIF nekustīgs kadrs.
