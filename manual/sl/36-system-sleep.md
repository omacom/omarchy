# Spanje sistema

Omarchy privzeto omogoča mirovanje in hibernacijo, če pa imate na svojem računalniku težave s katero od njiju, ju lahko izklopite.

Na računalnikih NVIDIA GB10, kot sta DGX Spark in ASUS Ascent GX10, sta mirovanje in hibernacija izklopljena, tako kot sta v sistemu NVIDIA DGX OS, ker za spanje na tej strojni opremi še ni bilo dokazano, da deluje. Enako velja za ASUS Zenbook A16 (UX3607OA), pri katerem mirovanje čipa še ne uspava v celoti in lahko čez noč zamrzne. Preklop mirovanja in nastavitev hibernacije tam ne veljata. Če želite spanje znova vklopiti, odstranite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` z `sudo rm`; mirovanje se nato vrne v meni, hibernacijo pa lahko nastavite kot na drugih računalnikih. Zagon `sudo omarchy apply hardware --install-user "$USER"` datoteko vrne nazaj.

### Profili napajanja

Na prenosniku si Omarchy zapomni vaš profil napajanja ločeno za delovanje ob priklopu na napajanje in delovanje na baterijo ter med njima preklaplja, ko napravo priklopite in odklopite. Takoj po namestitvi to pomeni performance na AC in balanced na bateriji.

Kaj vaš računalnik ponuja, lahko vidite z `omarchy powerprofiles list`, profil, ki ga želite za stanje, v katerem ste trenutno, pa nastavite z `omarchy powerprofiles set autodetect power-saver`. Če želite nastaviti drugo stanje, ne da bi karkoli odklopili, ga neposredno poimenujte: `omarchy powerprofiles set battery power-saver`. Kar koli izberete, boste dobili nazaj ob naslednjem prehodu v to stanje.

### Preklop mirovanja

Mirovanje preklopite tako, da iz terminala zaženete `omarchy toggle suspend`. To samo razkrije/skrije možnost pod _System_ (ali `Super + Esc`), nato pa lahko preverite, ali na vašem sistemu deluje zanesljivo. Če ne, jo lahko z istim ukazom znova skrijete.

### Preklop hibernacije

Hibernacijo nastavite tako, da iz terminala zaženete `omarchy hibernation setup`. Hibernacija na vašem zagonskem pogonu ustvari podzvezek /swap v velikosti dodeljenega fizičnega pomnilnika RAM, zato poskrbite, da imate na voljo dovolj prostora. Na računalniku z 32GB boste za ta zvezek vedno potrebovali 32GB+ prostega prostora. Hibernacija zahteva tudi privzeti zagonski nalagalnik Limine.

Ko bo nastavljena, boste možnost hibernacije videli pod _System_ (ali `Super + Esc`), nato pa lahko preverite, ali na vašem sistemu deluje zanesljivo. Če ne, jo lahko znova odstranite z zagonom `omarchy hibernation remove`.
