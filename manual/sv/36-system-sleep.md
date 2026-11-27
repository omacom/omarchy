# Systemvila

Omarchy aktiverar viloläge som standard, och dvala när det väl har konfigurerats, men om du har problem med något av dem på din dator kan du stänga av dem.

På datorer med NVIDIA GB10, som DGX Spark och ASUS Ascent GX10, är viloläge och dvala avstängda, precis som i NVIDIA:s DGX OS, eftersom viloläget ännu inte har visats fungera på den hårdvaran. Växlingen för viloläge och konfigurationen av dvala gäller inte där. För att slå på viloläget igen tar du bort `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; då återkommer Suspend till menyn, och dvala kan konfigureras som på andra datorer. Att köra `sudo omarchy apply hardware --install-user "$USER"` lägger tillbaka filen.

### Energiprofiler

På en bärbar dator kommer Omarchy ihåg din energiprofil separat för när datorn är ansluten till elnätet och när den körs på batteri, och växlar mellan de två när du ansluter och kopplar ur strömmen. Direkt från start innebär det prestanda med nätström och balanserat på batteri.

Du kan se vad din dator erbjuder med `omarchy powerprofiles list`, och ställa in den du vill ha för det läge du befinner dig i just nu med `omarchy powerprofiles set autodetect power-saver`. För att ställa in det andra läget utan att koppla ur något anger du det direkt: `omarchy powerprofiles set battery power-saver`. Vad du än väljer är det vad du får tillbaka nästa gång du befinner dig i det läget.

### Slå av/på viloläge

Du slår av/på viloläge genom att köra `omarchy toggle suspend` från terminalen. Det visar/döljer bara alternativet under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du dölja det igen med samma kommando.

### Slå av/på dvala

Du konfigurerar dvala genom att köra `omarchy hibernation setup` från terminalen (det är inte tillgängligt på Apple Silicon-Macar). Dvala skapar en /swap-undervolym på din startenhet i samma storlek som din fysiska RAM-tilldelning, så se till att du har gott om utrymme över. På en dator med 32GB behöver du alltid ha 32GB+ ledigt för den här volymen. Dvala kräver också standardbootloadern Limine.

När det är konfigurerat ser du alternativet för dvala under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du ta bort det igen genom att köra `omarchy hibernation remove`.
