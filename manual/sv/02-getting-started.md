# Kom igång

Omarchy installeras med hjälp av en ISO. Du kan välja mellan en fullständig diskinstallation, som tar över hela disken, eller en installation på ledigt utrymme, som placerar Omarchy i det oallokerade utrymmet på en disk — det är så du kör dual boot tillsammans med Windows eller ett annat operativsystem (se [installation med dual boot](50-dual-boot-install.md) — observera att du först måste stänga av BitLocker i Windows). Oavsett vilket du väljer använder installationen som standard full kryptering, och alternativet för fullständig disk raderar den valda disken, så se till att ta en säkerhetskopia innan du använder en befintlig disk!

[Ladda ner Omarchy ISO:n](https://omarchy.org/) först, lägg den på ett USB-minne (använd [balenaEtcher](https://etcher.balena.io/) på Mac/Windows eller [caligula](https://github.com/ifd3f/caligula) på Linux) och boota från minnet.

_Du måste stänga av Secure Boot och/eller TPM i BIOS. Du måste stänga av dem för att kunna installera Omarchy. De är Microsofts säkerhetssystem avsedda för Windows och Linux-distributioner anslutna till Microsoft._

Svara sedan på konfigurationsfrågorna och bekräfta dem så här:

 ![install-config](images/install-config.webp)

Välj sedan en disk för din installation, luta dig tillbaka och se installationsshowen rulla. Det kan vara klart på under en minut på de snabbaste moderna maskinerna, men det bör inte ta mer än 5 minuter ens på en äldre dator.

 ![install-done](images/install-done.webp)

Nu är du redo att Omarchy!

### Använd ett trådbundet tangentbord eller ett med 2.4ghz!

Den fullständiga diskkrypteringen låter dig inte ange lösenordet från ett Bluetooth-tangentbord vid start. Precis som du inte kan använda ett Bluetooth-tangentbord för att gå in i BIOS på en PC. Du behöver ett tangentbord som antingen använder en 2.4ghz-dongel eller en kabel (vilket ändå är mycket trevligare för latensen!). Själv älskar jag [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installera för en annan ägare

Om du sätter upp en maskin åt någon annan — en familjemedlem, en ny anställd, en köpare — ska du inte svara på de personliga frågorna åt dem. Tryck på `Ctrl + C` på installerarens allra första skärm (valet av tangentbord), så erbjuder Omarchy sig att i stället förbereda maskinen för en annan ägare. Systemet installeras direkt, men all personlig konfiguration — tangentbordslayout, användarnamn, lösenord — skjuts upp tills maskinen bootar för första gången. Disken är fortfarande krypterad som standard, och lösenordet som den nya ägaren väljer vid den första booten blir också krypteringslösenordet. (En maskin som du redan har använt kan också lämnas över utan ominstallation — se [återställa datorn](48-security.md).)

### Obevakade installationer

ISO:n kan också installera helt på egen hand — inget tangentbord, ingen guide — när den får sin konfiguration på en andra disk. Det är sättet att behandla Omarchy som en basavbildning för VMs och maskinparker. Se [obevakade installationer](51-unattended-installs.md).

### Installationer utan kryptering

Omarchy installeras med kryptering som standard. Det är det säkra, ansvarsfulla valet för varje dator som över huvud taget kan tappas bort eller stjälas. Du vill inte att någon med tillgång till din hårdvara ska kunna komma åt dina data!

Men under särskilda omständigheter, som fjärrinstallationer av Omarchy på skyddade datorer eller för engångsinstallationer utan känsliga data, vill du kanske installera utan kryptering. Du kan trycka på `Ctrl + C` vid bekräftelsen av diskformateringen för att växla till en installation utan kryptering.

### Språk

Omarchy talar 50 språk — samma uppsättning som omarchy.org — och engelska är standard. För att byta öppnar du Omarchy-menyn och går till _Setup > Language_, eller kör `omarchy language <code>` i en terminal (`omarchy language list` visar koderna). Menyn, skrivbordet och Omarchys egna notiser byter språk omedelbart, och varje applikation du öppnar efteråt följer också med. Appar som redan var öppna byter så snart du startar om dem.

### Hjälp om du kör fast

Om du kör fast kan du vanligtvis hitta någon som vill hjälpa till i kanalen _#omarchy-help_ på [gemenskapens Discord](https://omarchy.org/discord).
