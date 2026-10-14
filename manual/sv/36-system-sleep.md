# Systemvila

Omarchy aktiverar viloläge och dvala som standard, men om du har problem med någon av dem på din dator kan du stänga av dem.

### Effektprofiler

På en bärbar dator minns Omarchy din effektprofil separat för inkopplad och för batteridrift, och växlar mellan de två när du kopplar i och ur. Direkt ur lådan betyder det prestanda på nätström och balanserat på batteri.

Du kan se vad din dator erbjuder med `omarchy powerprofiles list`, och ställa in den du vill ha för det tillstånd du för närvarande befinner dig i med `omarchy powerprofiles set autodetect power-saver`. För att ställa in det andra tillståndet utan att koppla ur något namnger du det direkt: `omarchy powerprofiles set battery power-saver`. Vad du än väljer är det du får tillbaka nästa gång du befinner dig i det tillståndet.

### Växla viloläge

Du växlar viloläge genom att köra `omarchy toggle suspend` från terminalen. Det visar/döljer bara alternativet under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du dölja det igen med samma kommando.

### Växla dvala

Du konfigurerar dvala genom att köra `omarchy hibernation setup` från terminalen. Dvala skapar en /swap-undervolym på din startenhet i storlek med din fysiska RAM-allokering, så se till att du har gott om utrymme över. På en 32GB-dator behöver du alltid 32GB+ ledigt för denna volym. Dvala kräver också den standardmässiga Limine-bootloadern.

När det är konfigurerat ser du dvala-alternativet under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du ta bort det igen genom att köra `omarchy hibernation remove`.
