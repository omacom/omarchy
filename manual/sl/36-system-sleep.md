# Spanje sistema

Omarchy privzeto omogoči zaustavitev, mirovanje pa, ko je nastavljeno, a če imate na svojem računalniku težave s katerim koli od njiju, ju lahko izklopite.

Na računalnikih z NVIDIA GB10, kot sta DGX Spark in ASUS Ascent GX10, sta zaustavitev in mirovanje izklopljena, tako kot v sistemu NVIDIA DGX OS, ker za spanje na tej strojni opremi še ni bilo dokazano, da deluje. Isto velja za ASUS Zenbook A16 (UX3607OA), kjer zaustavitev čipa še ne uspava v celoti in lahko čez noč obtiči. Preklop zaustavitve in nastavitev mirovanja tam ne veljata. Če želite spanje znova vklopiti, odstranite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` z `sudo rm`; Zaustavitev se nato vrne v meni, mirovanje pa je mogoče nastaviti kot na drugih računalnikih. Zagon `sudo omarchy apply hardware --install-user "$USER"` datoteko vrne nazaj.

### Profili napajanja

Na prenosniku si Omarchy vaš profil napajanja zapomni ločeno za priklopljeno napajanje in za delovanje na baterijo ter preklaplja med njima, ko napajalnik priklopite in izklopite. Takoj po namestitvi to pomeni zmogljivost na AC in uravnotežen način na baterijo.

Kaj vaš računalnik ponuja, lahko vidite z `omarchy powerprofiles list`, profil, ki ga želite za stanje, v katerem ste trenutno, pa nastavite z `omarchy powerprofiles set autodetect power-saver`. Če želite nastaviti drugo stanje, ne da bi karkoli izklopili, ga poimenujte neposredno: `omarchy powerprofiles set battery power-saver`. Kar koli izberete, boste dobili nazaj naslednjič, ko boste v tem stanju.

### Preklop zaustavitve

Zaustavitev preklopite tako, da v terminalu zaženete `omarchy toggle suspend`. To samo pokaže/skrije možnost pod _System_ (ali `Super + Esc`), nato pa lahko preverite, ali na vašem sistemu deluje dosledno. Če ne, jo lahko z istim ukazom znova skrijete.

### Preklop mirovanja

Mirovanje nastavite tako, da v terminalu zaženete `omarchy hibernation setup` (na računalnikih Apple Silicon Mac ni na voljo). Mirovanje na vašem zagonskem pogonu ustvari podzvezek /swap v velikosti vaše dodelitve fizičnega RAM, zato poskrbite, da imate na voljo dovolj prostora. Na računalniku z 32GB boste za ta zvezek vedno potrebovali 32GB+ prostega prostora. Mirovanje zahteva tudi privzeti zagonski nalagalnik Limine.

Ko je nastavljeno, boste možnost mirovanja videli pod _System_ (ali `Super + Esc`), nato pa lahko preverite, ali na vašem sistemu deluje dosledno. Če ne, jo lahko znova odstranite tako, da zaženete `omarchy hibernation remove`.
