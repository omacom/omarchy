# Foni

Katra tēma tiek piegādāta ar savu fonu kopu, un jūs varat pievienot savus papildu fonus mapē `~/.config/omarchy/backgrounds/[theme]`. Ja vēlaties pievienot papildu fona attēlu, piemēram, nord tēmai, vienkārši ievietojiet failu mapē `~/.config/omarchy/backgrounds/nord`.

Vienkāršākais veids, kā to izdarīt, ir Omarchy izvēlnē atvērt _Instalēšana > Stils > Fons_. Tiks atvērta mape, kurā tiek glabāti šīs tēmas foni. Nospiediet `Super + Shift + F`, lai palaistu vēl vienu failu pārvaldnieku, atrodiet savu fonu un pārkopējiet to. Tagad tas būs iekļauts fonu izvēlē, starp kuriem varat izvēlēties, izmantojot `Super + Ctrl + W`.

Foni var būt arī video, ne tikai nekustīgi attēli. Ievietojiet `mp4`, `m4v`, `mov`, `webm`, `mkv` vai `avi` failu tajā pašā mapē, un tas parādīsies līdzās attēliem. Video atskaņo OWE tapešu dzinējs. Tas dekodē video vienreiz visiem monitoriem un atskaņo tā skaņu caur noklusējuma audio izvadi, un tas pārtrauc atskaņošanu ikreiz, kad nekas to nevar redzēt. Video fons joprojām patērē daudz vairāk enerģijas nekā nekustīgs fons.

Tēmas var ietvert īsu ievadu nekustīgam fonam. Fonam `backgrounds/road.webp` atbilstošais video atrodas `backgrounds/intros/road.mp4`. Tas tiek atskaņots automātiski palaišanas laikā, pārslēdzoties uz tēmu ar atlasītu šo fonu un izvēloties šo fonu, un pēc tam atgriežas pie nekustīgā attēla. Ievada video netiek rādīti fonu izvēlnē un nekad netiek atkārtoti cilpā.

Izslēdzot _Izskats > Animācijas_, tiek izslēgti arī fonu ievadi. Omarchy to pēc noklusējuma dara virtuālajā mašīnā. Komanda `omarchy theme bg intro toggle` var pārslēgt ievadus atsevišķi. Tēmas atsvaidzināšana ievadu neatskaņo.

Nekustīgam attēlam var būt arī cilpa, klusa tā paša attēla versija, kas turpina kustēties, vietā `backgrounds/loops/road.mp4`. Tā tiek atskaņota nekustīgā attēla vietā, pēc tā ievada, ja tāds ir, un apstājas, kad animācijas ir izslēgtas. Cilpas netiek rādītas fonu izvēlnē un, tāpat kā jebkurš video fons, patērē vairāk enerģijas nekā nekustīgs attēls.

Milzīgu foršu, rūpīgi atlasītu fonu kolekciju varat atrast [dharmx/walls](https://github.com/dharmx/walls).

Bloķēšanas ekrānā tiek rādīts video fona nekustīgs kadrs, tāpat kā tas rāda animēta GIF nekustīgu kadru.
