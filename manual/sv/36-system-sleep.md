# Systemvila

Omarchy aktiverar vänteläge och viloläge som standard, men om du har problem med något av dem på din maskin kan du stänga av dem.

På NVIDIA GB10-maskiner, som DGX Spark och ASUS Ascent GX10, är vänteläge och viloläge avstängda, precis som i NVIDIA:s DGX OS, eftersom vila ännu inte har visats fungera på den hårdvaran. Växlingen för vänteläge och inställningen av viloläge gäller inte där. För att slå på vila igen tar du bort `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; då kommer Vänteläge tillbaka till menyn, och viloläge kan ställas in som på andra maskiner. Att köra `sudo omarchy apply hardware --install-user "$USER"` lägger tillbaka filen.

### Effektprofiler

På en bärbar dator kommer Omarchy ihåg din effektprofil separat för när den är inkopplad och när den körs på batteri, och växlar mellan de två när du kopplar in och kopplar ur. Direkt från start innebär det prestanda på nätström och balanserat på batteri.

Du kan se vad din maskin erbjuder med `omarchy powerprofiles list`, och ställa in den du vill ha för det läge du befinner dig i just nu med `omarchy powerprofiles set autodetect power-saver`. För att ställa in det andra läget utan att koppla ur något anger du det direkt: `omarchy powerprofiles set battery power-saver`. Vad du än väljer är det du får tillbaka nästa gång du befinner dig i det läget.

### Slå på/av vänteläge

Du slår på/av vänteläge genom att köra `omarchy toggle suspend` från terminalen. Det visar/döljer bara alternativet under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du dölja det igen med samma kommando.

### Slå på/av viloläge

Du ställer in viloläge genom att köra `omarchy hibernation setup` från terminalen. Viloläge skapar en /swap-undervolym på din startenhet med samma storlek som din fysiska RAM-tilldelning, så se till att du har gott om utrymme över. På en maskin med 32GB behöver du alltid ha 32GB+ ledigt för den här volymen. Viloläge kräver också den förvalda Limine-bootladdaren.

När det är inställt ser du alternativet för viloläge under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du ta bort det igen genom att köra `omarchy hibernation remove`.
