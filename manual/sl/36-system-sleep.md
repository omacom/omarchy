# Spanje sistema

Omarchy privzeto omogoča Spanje in Mirovanje, če pa imate s katerim od njiju na vašem računalniku težave, ju lahko izklopite.

### Profili porabe energije

Na prenosniku si Omarchy zapomni vaš profil porabe energije posebej za priklopljenost na napajanje in delovanje na baterijo ter med njima preklaplja, ko priklopite in odklopite. Takoj po namestitvi to pomeni zmogljivost na AC in uravnoteženo na baterijo.

S `omarchy powerprofiles list` lahko vidite, kaj vaš računalnik ponuja, in s `omarchy powerprofiles set autodetect power-saver` nastavite tistega, ki ga želite za stanje, v katerem ste trenutno. Če želite nastaviti drugo stanje, ne da bi kaj odklopili, ga poimenujte neposredno: `omarchy powerprofiles set battery power-saver`. Kar koli izberete, to boste dobili nazaj naslednjič, ko boste v tem stanju.

### Preklopi Spanje

Spanje preklopite tako, da v terminalu zaženete `omarchy toggle suspend`. To samo prikaže/skrije možnost pod _Sistem_ (ali `Super + Esc`), nato pa lahko vidite, ali na vašem sistemu deluje dosledno. Če ne, jo lahko z istim ukazom spet skrijete.

### Preklopi Mirovanje

Mirovanje nastavite tako, da v terminalu zaženete `omarchy hibernation setup`. Mirovanje ustvari podvolumen /swap na vašem zagonskem pogonu v velikosti vaše dodeljene fizične pomnilniške kapacitete RAM, zato poskrbite, da imate dovolj prostora. Na računalniku z 32 GB boste za ta volumen vedno potrebovali več kot 32 GB prostega prostora. Mirovanje zahteva tudi privzeti zagonski nalagalnik Limine.

Ko je nastavljeno, boste možnost mirovanja videli pod _Sistem_ (ali `Super + Esc`) in nato lahko vidite, ali na vašem sistemu deluje dosledno. Če ne, jo lahko spet odstranite z `omarchy hibernation remove`.
