# Foni

Katrai tēmai ir savs fonu komplekts, un jūs varat pievienot papildu fonus pēc savas izvēles mapē `~/.config/omarchy/backgrounds/[theme]`. Ja vēlaties pievienot papildu fona attēlu, piemēram, nord tēmai, vienkārši ievietojiet failu mapē `~/.config/omarchy/backgrounds/nord`.

Visvieglāk to izdarīt, Omarchy Menu atverot _Install > Style > Background_. Tiks atvērta mape, kurā tiek glabāti attiecīgās tēmas foni. Nospiediet `Super + Shift + F`, lai palaistu vēl vienu failu pārvaldnieku, atrodiet savu fonu un pārkopējiet to. Tagad tas būs iekļauts fonu izvēlē, starp kuriem varat izvēlēties ar `Super + Ctrl + W`.

Foni var būt gan video, gan nekustīgi attēli. Ievietojiet `mp4`, `m4v`, `mov`, `webm`, `mkv` vai `avi` failu tajā pašā mapē, un tas parādīsies līdzās attēliem. Video atskaņo OWE tapešu dzinējs. Tas dekodē video vienreiz visiem monitoriem, atskaņo tā skaņu caur noklusējuma audio izvadi un aptur atskaņošanu ikreiz, kad to nekas nevar redzēt. Video fons joprojām patērē daudz vairāk enerģijas nekā nekustīgs fons.

Tēmās nekustīgam fonam var būt īss ievads. Failam `backgrounds/road.webp` atbilstošais video atrodas vietā `backgrounds/intros/road.mp4`. Tas tiek automātiski atskaņots sāknēšanas laikā, pārslēdzoties uz tēmu ar atlasītu šo fonu un izvēloties šo fonu, un pēc tam atgriežas pie nekustīgā attēla. Ievadvideo netiek rādīti fonu atlasītājā un nekad netiek atkārtoti cilpā.

Izslēdzot _Appearance > Animations_, tiek izslēgti arī fonu ievadi. Virtuālajā mašīnā Omarchy to pēc noklusējuma dara automātiski. Ar komandu `omarchy theme bg intro toggle` ievadus var pārslēgt atsevišķi. Atsvaidzinot tēmu, ievads netiek atskaņots.

Nekustīgam attēlam var būt arī cilpa — klusa tā paša attēla versija, kas nepārtraukti kustas, — vietā `backgrounds/loops/road.mp4`. Tā tiek atskaņota nekustīgā attēla vietā, pēc tā ievada, ja tam tāds ir, un apstājas, kad animācijas ir izslēgtas. Darbojoties ar akumulatoru, tās vietā tiek rādīts nekustīgais attēls, un cilpa atgriežas, tiklīdz pievienojat strāvas padevi. Cilpas netiek rādītas fonu atlasītājā.

Milzīgu lielisku atlasītu fonu kolekciju varat atrast vietnē [dharmx/walls](https://github.com/dharmx/walls).

Bloķēšanas ekrānā tiek rādīts nekustīgs video fona kadrs, tāpat kā tas rāda nekustīgu animēta GIF kadru.
