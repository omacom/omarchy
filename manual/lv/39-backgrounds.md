# Foni

Katrai tēmai ir savs fonu komplekts, un jūs varat pievienot savus papildu fonus mapē `~/.config/omarchy/backgrounds/[theme]`. Ja vēlaties pievienot papildu fona attēlu, piemēram, nord tēmai, vienkārši ielieciet failu mapē `~/.config/omarchy/backgrounds/nord`.

Visvienkāršāk to var izdarīt, Omarchy Menu dodoties uz _Install > Style > Background_. Tiks atvērta mape, kurā tiek glabāti attiecīgās tēmas foni. Nospiediet `Super + Shift + F`, lai palaistu vēl vienu failu pārvaldnieku, atrodiet savu fonu un pārkopējiet to. Tagad tas būs iekļauts fonu izvēlē, starp kuriem varat izvēlēties, izmantojot `Super + Ctrl + W`.

Foni var būt arī video, ne tikai nekustīgi attēli. Iemetiet `mp4`, `m4v`, `mov`, `webm`, `mkv` vai `avi` failu tajā pašā mapē, un tas parādīsies līdzās attēliem. Video atskaņo OWE tapešu dzinis. Tas dekodē video vienreiz visiem monitoriem un atskaņo tā skaņu caur noklusējuma audio izvadi, un tas aptur atskaņošanu ikreiz, kad nekas to nevar redzēt. Video fons joprojām patērē daudz vairāk enerģijas nekā nekustīgs fons.

Tēmas var ietvert īsu ievadu nekustīgam fonam. Failam `backgrounds/road.webp` atbilstošais video atrodas `backgrounds/intros/road.mp4`. Tas tiek atskaņots automātiski sāknēšanas laikā, pārslēdzoties uz tēmu ar izvēlētu šo fonu un izvēloties šo fonu, un pēc tam atgriežas pie nekustīgā attēla. Ievada video neparādās fonu atlasītājā un nekad netiek cilpoti.

Izvēloties _Appearance > Animations Off_, tiek izslēgti arī fonu ievadi. Omarchy virtuālajā mašīnā (VM) to pēc noklusējuma dara. Ar komandu `omarchy theme bg intro toggle` ievadus var pārslēgt atsevišķi. Atsvaidzinot tēmu, ievads netiek atskaņots.

Nekustīgam attēlam var būt arī cilpa — klusa tās pašas bildes versija, kas turpina kustēties — `backgrounds/loops/road.mp4`. Tā tiek atskaņota nekustīgā attēla vietā, pēc tā ievada, ja tam tāds ir, un apstājas, kad animācijas ir izslēgtas. Darbojoties ar akumulatoru, tā vietā tiek rādīts nekustīgais attēls, un cilpa atgriežas, tiklīdz pievienojaties strāvas padevei. Cilpas neparādās fonu atlasītājā.

Lielu kolekciju ar foršiem atlasītiem foniem varat atrast [dharmx/walls](https://github.com/dharmx/walls).

Bloķēšanas ekrāns rāda video fona nekustīgu kadru, tāpat kā tas rāda animēta GIF nekustīgu kadru.
