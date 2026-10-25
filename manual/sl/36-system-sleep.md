# Spanje sistema

Omarchy privzeto omogoča mirovanje in hibernacijo, če pa imaš na svojem računalniku težave s katerim od njiju, ju lahko izklopiš.

Na računalnikih z NVIDIA GB10, kot sta DGX Spark in ASUS Ascent GX10, sta mirovanje in hibernacija izklopljena, enako kot v NVIDIA DGX OS, ker spanje na tej strojni opremi še ni dokazano delovalo. Preklop mirovanja in nastavitev hibernacije tam ne veljata. Če želiš spanje znova vklopiti, s `sudo rm` odstrani `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`; možnost Mirovanje se nato vrne v meni, hibernacijo pa lahko nastaviš kot na drugih računalnikih. Z ukazom `sudo omarchy apply hardware --install-user "$USER"` datoteko vrneš nazaj.

### Profili napajanja

Na prenosniku si Omarchy zapomni tvoj profil napajanja ločeno za delovanje na napajanje iz omrežja in delovanje na baterijo ter med njima preklaplja, ko vklopiš ali izklopiš napajanje. Privzeto to pomeni zmogljivost na izmeničnem napajanju in uravnoteženo delovanje na baterijo.

Kaj tvoj računalnik ponuja, lahko vidiš z `omarchy powerprofiles list`, želeni profil za stanje, v katerem si trenutno, pa nastaviš z `omarchy powerprofiles set autodetect power-saver`. Če želiš nastaviti drugo stanje, ne da bi karkoli izklopil, ga poimenuj neposredno: `omarchy powerprofiles set battery power-saver`. Kar izbereš, dobiš nazaj ob naslednjem prehodu v to stanje.

### Vklop/izklop mirovanja

Mirovanje vklopiš ali izklopiš z ukazom `omarchy toggle suspend` v terminalu. To samo prikaže/skrije možnost pod _System_ (ali `Super + Esc`), nato pa lahko vidiš, ali na tvojem sistemu deluje zanesljivo. Če ne, jo z istim ukazom znova skriješ.

### Vklop/izklop hibernacije

Hibernacijo nastaviš z ukazom `omarchy hibernation setup` v terminalu. Hibernacija na tvojem zagonskem pogonu ustvari podzvezek /swap v velikosti tvojega fizičnega pomnilnika RAM, zato poskrbi, da imaš dovolj prostega prostora. Na računalniku z 32GB boš za ta zvezek vedno potreboval 32GB+ prostega prostora. Hibernacija zahteva tudi privzeti zagonski nalagalnik Limine.

Ko je nastavljena, boš pod _System_ (ali `Super + Esc`) videl možnost hibernacije, nato pa lahko vidiš, ali na tvojem sistemu deluje zanesljivo. Če ne, jo lahko znova odstraniš z ukazom `omarchy hibernation remove`.
