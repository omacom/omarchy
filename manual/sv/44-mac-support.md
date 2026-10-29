# Mac-stöd

Omarchy har inbyggt stöd för **Intel-Macar**. Det finns ett par kända begränsningar för tillfället, men så länge du är medveten om och OK med dem kan du blåsa nytt liv i dina gamla Macar genom att ladda Omarchy.

Observera att installation på en Mac med M-serien inte stöds direkt för tillfället. Du kan ta reda på mer om läget för detta i #omarchy-on-other i vår [Discord](https://discord.gg/tXFUdasqhY).

I ett enkelt test kunde vi uppnå 36% prestandavinster på en MacBook Pro från 2019 bara genom att installera Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installera Omarchy på Mac

Omarchy stöder bara att vara det **enda** installerade operativsystemet för tillfället. Under installationen kommer enheten att raderas och MacOS kommer inte längre att vara startbart.

Du kan fortfarande återställa det senare via Internet Recovery om du vill.

För denna dels skull antar vi att du redan har granskat [Komma igång](02-getting-started.md) och har din USB-enhet redo. Om inte, gå och gör det nu.

#### Inaktivera Secure Boot

Det är nödvändigt att inaktivera Apples Secure Boot för att starta den startbara USB-enheten, såväl som operativsystemet. För att inaktivera den gör du följande:

1. Stäng av din Mac
2. Slå på den och tryck och håll _omedelbart_ ned Command-R tills du ser laddningsskärmen visas
3. Välj din användare och mata in ditt lösenord om du blir ombedd
4. När du är i återställningsskärmen väljer du **Utilities > Startup Security Utility** från menyfältet
5. Mata in ditt lösenord när du blir ombedd att autentisera
6. Välj "No Security" från Secure Boot-alternativen
7. Välj "Allow booting from external or removable media" från External Boot-alternativen

#### Starta installationen

1. Sätt i USB-enheten
2. Starta om din Mac och tryck och håll _omedelbart_ ned Option tills du ser en skärm med startenheter
3. Välj den orangea EFI Boot-enheten
4. Fortsätt med [installationen som vanligt](02-getting-started.md)

Installationsprogrammet upptäcker Mac-hårdvara och tillämpar de fixar som behövs automatiskt: Broadcom Wi-Fi-drivrutiner och firmware, SPI-tangentbordsdrivrutinen på de MacBook-modeller som behöver den, och en NVMe-vilolägesfix för samma modeller.

### Kända begränsningar

Medlemmar i gemenskapen arbetar ständigt på lösningar på dessa utmaningar, så om dessa är problematiska för dig, gå med i #omarchy-on-other i vår [Discord](https://discord.gg/tXFUdasqhY) och se om det finns några aktuella metoder för att lösa dem.

#### Enheter med T1-chip

Apple T1-chippet introducerades i slutet av 2016 och användes uteslutande i första generationens MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Kända problem

- Touch Bar är icke-funktionell
- Ljudet fungerar inte

#### Enheter med T2-chip

Apple T2 Security Chip introducerades 2017. T2-chippet avvecklades i och med övergången till Apple Silicon (M-seriens chip) från och med 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

På dessa modeller konfigurerar installationsprogrammet automatiskt den patchade `linux-t2`-kärnan, T2-ljudkonfigurationen, Apples Broadcom Wi-Fi/Bluetooth-firmware och fläktkontroll via `t2fanrd`. Touch Bar körs på kärnans inbyggda Boot Camp-liknande stöd.
