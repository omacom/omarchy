# Mac-stöd

Omarchy har inbyggt stöd för **Intel-Macs**. Det finns ett par kända begränsningar just nu, men så länge du är medveten om dem och är okej med dem kan du blåsa nytt liv i dina gamla Macs genom att installera Omarchy.

Observera att installation på en Mac med M-serien inte stöds direkt för närvarande. Du kan läsa mer om läget för detta i #omarchy-on-other i vår [Discord](https://discord.gg/tXFUdasqhY).

I ett enkelt test lyckades vi uppnå 36% högre prestanda på en MacBook Pro från 2019 bara genom att installera Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installera Omarchy på Mac

Omarchy stöder för närvarande bara att vara det **enda** operativsystemet installerat. Under installationen rensas enheten och MacOS kommer inte längre att gå att starta.

Du kan fortfarande återställa det senare via Internet Recovery om du vill.

För den här delen antar vi att du redan har gått igenom [Kom igång](02-getting-started.md) och har din USB-enhet redo. Om du inte har gjort det, gör det nu.

#### Inaktivera Secure Boot

Du måste inaktivera Apples Secure Boot för att kunna starta från det startbara USB-minnet, liksom operativsystemet. För att inaktivera det gör du följande:

1. Stäng av din Mac
2. Starta den och tryck _omedelbart_ ned och håll Command-R intryckt tills du ser laddningsskärmen visas
3. Välj din användare och ange ditt lösenord om du blir ombedd att göra det
4. När du är på återställningsskärmen väljer du **Utilities > Startup Security Utility** i menyraden
5. Ange ditt lösenord när du blir ombedd att autentisera dig
6. Välj "No Security" bland alternativen för Secure Boot
7. Välj "Allow booting from external or removable media" bland alternativen för External Boot

#### Starta installationen

1. Sätt i USB-enheten
2. Starta om din Mac och tryck _omedelbart_ ned och håll Option intryckt tills du ser en skärm med startenheter
3. Välj den orangea EFI Boot-enheten
4. Fortsätt med [installationen som vanligt](02-getting-started.md)

Installationsprogrammet upptäcker Mac-hårdvara och tillämpar de nödvändiga åtgärderna automatiskt: Broadcom Wi-Fi-drivrutiner och firmware, SPI-tangentbordsdrivrutinen på de MacBook-modeller som behöver den, och en NVMe-åtgärd för viloläge på samma modeller.

### Kända begränsningar

Medlemmar i communityn arbetar ständigt på lösningar på dessa utmaningar, så om dessa är problematiska för dig, gå med i #omarchy-on-other i vår [Discord](https://discord.gg/tXFUdasqhY) och se om det finns några aktuella metoder för att lösa dem.

#### Enheter med T1-chip

Apple T1-chippet introducerades i slutet av 2016 och användes uteslutande i första generationens MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-tums (2016, två Thunderbolt 3-portar) – Modell: A1706
- MacBook Pro 13-tums (2016, fyra Thunderbolt 3-portar) – Modell: A1708
- MacBook Pro 15-tums (2016) – Modell: A1707

#### Kända problem

- Touch Bar fungerar inte
- Ljudet fungerar inte

#### Enheter med T2-chip

Apple T2 Security Chip introducerades 2017. T2-chippet lades ned i samband med övergången till Apple silicon (M-seriechip) med start 2020.

- iMac Pro (2017) – Modell: A1862
- MacBook Pro 13-tums (2018, fyra Thunderbolt 3-portar) – Modell: A1989
- MacBook Pro 15-tums (2018) – Modell: A1990
- MacBook Air (Retina, 13-tums, 2018) – Modell: A1932
- Mac mini (2018) – Modell: A1998
- MacBook Pro 13-tums (2019, två Thunderbolt 3-portar) – Modell: A2159
- MacBook Pro 13-tums (2019, fyra Thunderbolt 3-portar) – Modell: A2178
- MacBook Pro 15-tums (2019) – Modell: A1990
- iMac (Retina 5K, 27-tums, 2020) – Modell: A2115 (iMac20,1 och iMac20,2)
- MacBook Pro 13-tums (2020, två Thunderbolt 3-portar) – Modell: A2265
- MacBook Pro 15-tums (2020) – Modell: A1990

På dessa modeller konfigurerar installationsprogrammet automatiskt den patchade `linux-t2`-kärnan, T2-ljudkonfigurationen, Apples Broadcom Wi-Fi/Bluetooth-firmware och fläktstyrning via `t2fanrd`. Touch Bar körs med kärnans inbyggda stöd i Boot Camp-stil.

#### iMac Retina 5K (2017)

27-tums iMac från 2017 har inget T2-chip, så installationsprogrammet konfigurerar den som de andra Intel-Macarna.

- iMac (Retina 5K, 27-tums, 2017) – Modell: A1419

#### Kända problem

- Skärmen körs inte i sin ursprungliga upplösning på 5120×2880: panelen består av två plattor, och standarddrivrutinen tänder bara den ena
- Ljudet fungerar inte
- Ljusstyrkeregleringen har ingen effekt
- Viloläge får maskinen att hänga sig; endast en strömavstängning och påslagning återställer den

En community-patch för den här modellen åtgärdar skärmen, ljudet och ljusstyrkan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
