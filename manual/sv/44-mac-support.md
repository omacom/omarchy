# Mac-stöd

## Omarchy för Apple Silicon

Omarchy för Apple Silicon är en officiell lösning från Omacom, först släppt med Omarchy 4.5. Det installeras bredvid macOS, och du väljer mellan de två när din Mac startar.

Fick du ett meddelande om Omarchy Mac? Gå till [Kommer du från Omarchy Mac](#coming-from-omarchy-mac).

Det körs på dessa Macar:

| Mac | Chip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macar med M4 och nyare stöds inte ännu. Stöd för M4 testas på edge-kanalen och kommer härnäst. Installationsprogrammet kontrollerar din Mac innan det ändrar något.

På alla Apple Silicon-Macar, inklusive M4 och nyare, kan du köra Omarchy i en virtuell maskin med [Try Omarchy](https://github.com/omacom/try-omarchy).

### Vad du behöver

- macOS 15 Sequoia eller senare, och ett administratörskonto
- Ledigt diskutrymme för Omarchy. Installationsprogrammet föreslår en storlek och låter dig ändra den.
- En säkerhetskopia av din Mac, ström och en internetanslutning. Installationen laddar ner flera gigabyte.

### Installera

Du installerar från macOS. Installera Omarchy Installer med [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eller ladda ner den nyaste Omarchy Installer från dess [sida med utgåvor](https://github.com/omacom/omarchy-mac-installer/releases) och öppna den.

Installationsprogrammet kontrollerar din Mac, visar dig planen och frigör utrymme för Omarchy genom att krympa macOS-partitionen. macOS stannar kvar på disken och ingen USB-enhet behövs. När den första fasen är klar vägleder det dig genom att slutföra installationen i macOS Recovery: stäng av, håll in strömknappen tills "Loading startup options" visas, välj Omarchy och följ stegen.

Vid första starten ber Omarchy om ett lösenord som krypterar dess disk. Det finns ingen återställningsnyckel: om du glömmer lösenordet kan dina Omarchy-filer inte återställas.

För att växla mellan Omarchy och macOS senare stänger du av, håller sedan in strömknappen tills startalternativen visas och väljer ett.

### Kommer du från Omarchy Mac

Omarchy Mac är nu en del av Omarchy för Apple Silicon, och alla Macar som körde det stöds. Din nuvarande installation fortsätter att köra, och dess systempaket uppdateras fortfarande, men den får inga fler Omarchy-uppdateringar. Det finns ingen tidsfrist och ingen uppgradering på plats: du säkerhetskopierar, tar bort den gamla installationen, installerar på nytt och återställer. Steg 2 till 5 sker i macOS, så öppna den här sidan på din telefon innan du startar om.

1. **Säkerhetskopiera från Omarchy, bort från Macen.** Att ta bort den gamla installationen raderar den, och macOS kan inte läsa Omarchy-disken. Kopiera din hemmapp till en extern enhet eller en annan dator, inklusive SSH- och GPG-nycklar, webbläsarprofiler och arbete som inte har pushas. Spara din paketlista med `pacman -Qqe > ~/packages.txt`. Säkerhetskopiera macOS också, eftersom både borttagning och installation ändrar storlek på dess disk.
2. **Starta din Mac i macOS.** Stäng av, håll in strömknappen tills startalternativen visas och välj macOS.
3. **Installera Omarchy Installer** enligt beskrivningen i [Installera](#installing).
4. **Ta bort den gamla installationen.** Öppna Omarchy Installer och välj Installation > Remove Omarchy. Det visar vad det kommer att radera och återför utrymmet till macOS. Om det inte känner igen din installation stoppar det utan att ändra disken. Be om hjälp i [Discord](https://discord.gg/tXFUdasqhY) i stället för att radera partitioner för hand, vilket kan radera macOS.
5. **Installera Omarchy för Apple Silicon** med installationsprogrammet.
6. **Återställ dina filer.** Ta tillbaka dina inställningar en bit i taget i stället för att kopiera hela `~/.config` över de nya standardinställningarna, eftersom gamla inställningar kan skriva över dem.

### Bra att veta

- På MacBooks med M1 och M2 väcker du från viloläge genom att öppna locket eller trycka på strömknappen.
- Frågor eller problem: fråga i vår [Discord](https://discord.gg/tXFUdasqhY).

[Installationsprogrammets README](https://github.com/omacom/omarchy-mac-installer#readme) täcker utgåvokanaler, uppdatering av installationsprogrammet och borttagning av Omarchy.

## Intel-Macar

I ett enkelt test lyckades vi uppnå 36 % bättre prestanda på en MacBook Pro från 2019 bara genom att installera Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installera Omarchy på Mac

Omarchy stöder för närvarande bara att vara det **enda** operativsystemet som är installerat. Under installationen kommer enheten att raderas och MacOS kommer inte längre att kunna startas.

Du kan ändå återställa det senare via Internet Recovery om du vill.

För den här delens skull antar vi att du redan har läst [Kom igång](02-getting-started.md) och har din USB-enhet redo. Om du inte har det, gör det nu.

#### Inaktivera Secure Boot

Det är nödvändigt att inaktivera Apples Secure Boot för att kunna starta från det startbara USB-minnet, liksom operativsystemet. För att inaktivera det gör du följande:

1. Stäng av din Mac
2. Slå på den och tryck _omedelbart_ och håll in Command-R tills du ser laddningsskärmen visas
3. Välj din användare och ange ditt lösenord om du blir ombedd
4. När du är på återställningsskärmen väljer du **Utilities > Startup Security Utility** i menyraden
5. Ange ditt lösenord när du blir ombedd att autentisera dig
6. Välj "No Security" bland alternativen för Secure Boot
7. Välj "Allow booting from external or removable media" bland alternativen för External Boot

#### Starta installationen

1. Sätt i USB-enheten
2. Starta om din Mac och tryck _omedelbart_ och håll in Option tills du ser en skärm med startenheter
3. Välj den orangea EFI Boot-enheten
4. Fortsätt med [installationen som vanligt](02-getting-started.md)

Installationsprogrammet upptäcker Mac-hårdvara och tillämpar de korrigeringar som behövs automatiskt: Broadcom Wi-Fi-drivrutiner och firmware, SPI-drivrutinen för tangentbord på de MacBook-modeller som behöver den, och en korrigering för NVMe-viloläge för samma modeller.

### Kända begränsningar

Medlemmar i gemenskapen arbetar ständigt med lösningar på dessa utmaningar, så om de är problematiska för dig, gå med i #omarchy-on-other i vår [Discord](https://discord.gg/tXFUdasqhY) och se om det finns några aktuella metoder för att lösa dem.

#### Enheter med T1-chip

Apple T1-chippet introducerades i slutet av 2016 och användes uteslutande i första generationens MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-tums (2016, två Thunderbolt 3-portar) – Modell: A1706
- MacBook Pro 13-tums (2016, fyra Thunderbolt 3-portar) – Modell: A1708
- MacBook Pro 15-tums (2016) – Modell: A1707

#### Kända problem

- Touch Bar fungerar inte
- Ljudet fungerar inte

#### Enheter med T2-chip

Apple T2 Security Chip introducerades 2017. T2-chippet lades ner i samband med övergången till Apple silicon (chip i M-serien) med början 2020.

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

På dessa modeller ställer installationsprogrammet automatiskt in den patchade `linux-t2`-kärnan, ljudkonfigurationen för T2, Apples Broadcom Wi-Fi/Bluetooth-firmware och fläktstyrning via `t2fanrd`. Touch Bar körs på kärnans inbyggda stöd i Boot Camp-stil.

#### iMac Retina 5K (2017)

27-tums iMac från 2017 har inget T2-chip, så installationsprogrammet ställer in den som de andra Intel-Macarna.

- iMac (Retina 5K, 27-tums, 2017) – Modell: A1419

#### Kända problem

- Skärmen körs inte med dess inbyggda 5120×2880: panelen består av två plattor, och standarddrivrutinen tänder bara en
- Ljudet fungerar inte
- Ljusstyrkeregleringen har ingen effekt
- Viloläge får maskinen att hänga sig; bara en omstart med strömknappen återställer den

En patcher från gemenskapen för den här modellen fixar skärmen, ljudet och ljusstyrkan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
