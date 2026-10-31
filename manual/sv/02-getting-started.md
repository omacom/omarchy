# Kom igång

Omarchy installeras med en ISO. Du kan välja mellan en installation på hela disken, som tar över hela enheten, eller en installation i ledigt utrymme, som lägger Omarchy i det oallokerade utrymmet på en enhet — det är så du dual-bootar tillsammans med Windows eller ett annat OS (se [installation för dual boot](50-dual-boot-install.md) — observera att du först måste stänga av BitLocker i Windows). Oavsett vilket är full kryptering standard för installationen, och alternativet för hela disken kommer att rensa den valda enheten, så se till att ta en säkerhetskopia innan du använder en befintlig!

[Ladda ner Omarchy ISO:n](https://omarchy.org/) först, lägg den på ett USB-minne (använd [Rufus](https://rufus.ie/) på Windows, [balenaEtcher](https://etcher.balena.io/) på Mac eller [caligula](https://github.com/ifd3f/caligula) på Linux) och starta från minnet.

_Du måste stänga av Secure Boot och/eller TPM i BIOS. Du måste stänga av dem för att kunna installera Omarchy. De är säkerhetssystem från Microsoft avsedda för Windows och Microsoft-anslutna Linux-distributioner._

Besvara sedan konfigurationsfrågorna och bekräfta dem så här:

 ![install-config](images/install-config.webp)

Välj sedan en enhet för din installation och luta dig tillbaka och se installationsshowen rulla. Det kan vara klart på under en minut på de snabbaste moderna maskinerna, men det bör inte ta mer än 5 minuter ens på en äldre dator.

 ![install-done](images/install-done.webp)

Nu är du redo för Omarchy!

### Använd ett trådbundet tangentbord eller ett med 2.4ghz!

Fulldiskkrypteringen låter dig inte ange lösenordet från ett Bluetooth-tangentbord vid start. Precis som du inte kan använda ett Bluetooth-tangentbord för att komma in i BIOS på en PC. Du behöver ett tangentbord som antingen använder en 2.4ghz-dongel eller en kabel (vilket ändå är mycket trevligare för latensen!). Själv älskar jag [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installera för en annan ägare

Om du ställer in en maskin åt någon annan — en familjemedlem, en nyanställd, en köpare — ska du inte besvara de personliga frågorna åt dem. Tryck `Ctrl + C` på installerarens allra första skärm (tangentbordsvalet), så erbjuder Omarchy att förbereda maskinen för en annan ägare i stället. Systemet installeras direkt, men all personlig konfiguration — tangentbordslayout, användarnamn, lösenord — skjuts upp tills maskinen startar för första gången. Enheten är fortfarande krypterad som standard, och lösenordet som den nya ägaren väljer vid den första starten blir också krypteringslösenordet. (En maskin som du redan har använt kan också överlämnas utan ominstallation — se [återställa datorn](48-security.md).)

### Obevakade installationer

ISO:n kan också installera helt på egen hand — inget tangentbord, ingen guide — när den får sin konfiguration på en andra enhet. Det är sättet att behandla Omarchy som en basavbild för VMs och maskinparker. Se [obevakade installationer](51-unattended-installs.md).

### Installationer utan kryptering

Omarchy installeras med kryptering som standard. Det är det säkra, ansvarsfulla valet för alla datorer som överhuvudtaget kan tappas bort eller bli stulna. Du vill inte att någon med tillgång till din hårdvara ska kunna komma åt dina data!

Men under särskilda omständigheter, som fjärrinstallationer av Omarchy på skyddade datorer eller för engångsinstallationer utan känsliga data, kan du vilja installera utan kryptering. Du kan trycka `Ctrl + C` vid bekräftelsen för diskformatering för att växla till en installation utan kryptering.

### Språk

Omarchy talar 50 språk — samma uppsättning som omarchy.org — och engelska är standard. För att byta, öppna Omarchy-menyn och gå till _Inställningar > Språk_, eller kör `omarchy language <code>` i en terminal (`omarchy language list` visar koderna). Menyn, skrivbordet och Omarchys egna aviseringar byter språk omedelbart, och alla program du öppnar efteråt följer också med. Program som redan var öppna byter när du startar om dem.

### Hjälp om du kör fast

Om du kör fast kan du vanligtvis hitta någon som vill hjälpa till i kanalen _#omarchy-help_ på [communityts Discord](https://omarchy.org/discord).
