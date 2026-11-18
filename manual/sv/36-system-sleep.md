# Systemvila

Omarchy aktiverar vänteläge och viloläge som standard, men om du har problem med något av dem på din maskin kan du stänga av dem.

På NVIDIA GB10-maskiner, som DGX Spark och ASUS Ascent GX10, är vänteläge och viloläge avstängda, precis som i NVIDIA:s DGX OS, eftersom vila ännu inte har visat sig fungera på den hårdvaran. Samma sak gäller ASUS Zenbook A16 (UX3607OA), där vänteläget ännu inte försätter chippet helt i vila och kan hänga sig över natten. Växlingen för vänteläge och konfigurationen av viloläge gäller inte där. För att slå på vila igen tar du bort `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; då kommer Suspend tillbaka till menyn, och viloläge kan konfigureras som på andra maskiner. Att köra `sudo omarchy apply hardware --install-user "$USER"` lägger tillbaka filen.

### Effektprofiler

På en bärbar dator kommer Omarchy ihåg din effektprofil separat för när du är ansluten till ström och när du kör på batteri, och växlar mellan de två när du kopplar in och ur. Direkt ur lådan betyder det prestanda på AC och balanserat på batteri.

Du kan se vad din maskin erbjuder med `omarchy powerprofiles list`, och ställa in den du vill ha för läget du befinner dig i just nu med `omarchy powerprofiles set autodetect power-saver`. För att ställa in det andra läget utan att koppla ur något anger du det direkt: `omarchy powerprofiles set battery power-saver`. Vad du än väljer är det du får tillbaka nästa gång du är i det läget.

### Växla vänteläge

Du växlar vänteläge genom att köra `omarchy toggle suspend` från terminalen. Det visar/döljer bara alternativet under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du dölja det igen med samma kommando.

### Växla viloläge

Du konfigurerar viloläge genom att köra `omarchy hibernation setup` från terminalen. Viloläge skapar en /swap-undervolym på din startenhet med samma storlek som ditt fysiska RAM-minne, så se till att du har gott om utrymme över. På en 32GB-maskin behöver du alltid 32GB+ ledigt för den här volymen. Viloläge kräver också den förvalda Limine-bootloadern.

När det är konfigurerat ser du alternativet för viloläge under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du ta bort det igen genom att köra `omarchy hibernation remove`.
