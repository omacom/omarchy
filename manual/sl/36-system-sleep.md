# Spanje sistema

Omarchy privzeto omogoča spanje, po nastavitvi pa tudi hibernacijo, če pa imate na svojem računalniku težave s katerim koli od njiju, ju lahko izklopite.

Na računalnikih z NVIDIA GB10, kot sta DGX Spark in ASUS Ascent GX10, sta spanje in hibernacija izklopljena, tako kot v operacijskem sistemu NVIDIA DGX OS, ker še ni dokazano, da spanje na tej strojni opremi deluje. Preklop spanja in nastavitev hibernacije tam ne veljata. Če želite spanje znova vklopiti, odstranite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` z `sudo rm`; Suspend se nato vrne v meni, hibernacijo pa je mogoče nastaviti kot na drugih računalnikih. Zagon `sudo omarchy apply hardware --install-user "$USER"` datoteko vrne nazaj.

### Profili napajanja

Na prenosniku si Omarchy zapomni vaš profil napajanja ločeno za priklopljenost na napajanje in za delovanje na baterijo ter preklaplja med njima, ko napajanje priklopite in odklopite. Privzeto to pomeni performance na AC in balanced na bateriji.

Kaj vaš računalnik ponuja, lahko vidite z `omarchy powerprofiles list`, želeni profil za stanje, v katerem ste trenutno, pa nastavite z `omarchy powerprofiles set autodetect power-saver`. Če želite nastaviti drugo stanje, ne da bi karkoli odklopili, ga poimenujte neposredno: `omarchy powerprofiles set battery power-saver`. Karkoli izberete, boste dobili nazaj naslednjič, ko boste v tem stanju.

### Preklop spanja

Spanje preklopite tako, da v terminalu zaženete `omarchy toggle suspend`. To samo pokaže/skrije možnost pod _System_ (ali `Super + Esc`), nato pa lahko preverite, ali na vašem sistemu deluje dosledno. Če ne, jo lahko z istim ukazom znova skrijete.

### Preklop hibernacije

Hibernacijo nastavite tako, da v terminalu zaženete `omarchy hibernation setup` (na računalnikih Mac z Apple Silicon ni na voljo). Hibernacija na vašem zagonskem pogonu ustvari podzvezek /swap v velikosti vaše dodelitve fizičnega pomnilnika RAM, zato poskrbite, da imate na voljo dovolj prostora. Na računalniku z 32GB boste za ta zvezek vedno potrebovali 32GB+ prostega prostora. Hibernacija zahteva tudi privzeti zagonski nalagalnik Limine.

Ko je nastavljena, boste pod _System_ (ali `Super + Esc`) videli možnost hibernacije, nato pa lahko preverite, ali na vašem sistemu deluje dosledno. Če ne, jo lahko znova odstranite z zagonom `omarchy hibernation remove`.
