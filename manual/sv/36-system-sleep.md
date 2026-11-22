# Viloläge för systemet

Omarchy aktiverar vila som standard, och hibernering när den väl är konfigurerad, men om du har problem med någon av dem på din maskin kan du stänga av dem.

På NVIDIA GB10-maskiner, som DGX Spark och ASUS Ascent GX10, är vila och hibernering avstängda, precis som i NVIDIA:s DGX OS, eftersom viloläge ännu inte har visat sig fungera på den hårdvaran. Samma sak gäller ASUS Zenbook A16 (UX3607OA), där vila ännu inte försätter chippet helt i viloläge och kan hänga sig över natten. Växlingen för vila och konfigurationen av hibernering gäller inte där. För att slå på viloläge igen tar du bort `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; Suspend återkommer då i menyn, och hibernering kan konfigureras som på andra maskiner. Att köra `sudo omarchy apply hardware --install-user "$USER"` lägger tillbaka filen.

### Strömprofiler

På en bärbar dator kommer Omarchy ihåg din strömprofil separat för ansluten till ström och för batteridrift, och växlar mellan de två när du ansluter och kopplar från strömmen. Direkt från start innebär det prestanda vid nätanslutning och balanserat vid batteridrift.

Du kan se vad din maskin erbjuder med `omarchy powerprofiles list`, och ställa in den du vill ha för det läge du befinner dig i just nu med `omarchy powerprofiles set autodetect power-saver`. För att ställa in det andra läget utan att koppla från något namnger du det direkt: `omarchy powerprofiles set battery power-saver`. Vad du än väljer är det du får tillbaka nästa gång du befinner dig i det läget.

### Växla vila

Du växlar vila genom att köra `omarchy toggle suspend` från terminalen. Det visar/döljer bara alternativet under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du dölja det igen med samma kommando.

### Växla hibernering

Du konfigurerar hibernering genom att köra `omarchy hibernation setup` från terminalen (den är inte tillgänglig på Apple Silicon-Macar). Hibernering skapar en /swap-undervolym på din startenhet med storleken på din fysiska RAM-tilldelning, så se till att du har gott om utrymme över. På en 32GB-maskin behöver du alltid 32GB+ ledigt för den här volymen. Hibernering kräver också standardbootloadern Limine.

När den är konfigurerad ser du alternativet för hibernering under _System_ (eller `Super + Esc`), och sedan kan du se om det fungerar konsekvent på ditt system. Om inte kan du ta bort det igen genom att köra `omarchy hibernation remove`.
