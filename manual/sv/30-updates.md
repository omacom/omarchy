# Uppdateringar

Omarchy och dina paket hålls uppdaterade via _Uppdatera > Omarchy_ i Omarchy-menyn (`Super + Space`).

Omarchy självt installeras som vanliga pacman-paket från [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en uppdatering installerar [den senaste Omarchy-versionen](https://github.com/omacom/omarchy/releases), kör eventuella väntande migreringar för att få ditt system i synk med det senaste, och uppdaterar alla systempaket från [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) och [AUR](https://aur.archlinux.org/) (om du har installerat några AUR-paket).

När nya versioner släpps visas en ikon med en cirkelpil till höger om din klocka. Klicka på den så startar uppdateringsprocessen.

![update-available](images/update-available.webp)

### Fyra kanaler

Omarchy uppdateras längs fyra kanaler: stable, RC, edge och dev. Nya installationer börjar på stable-kanalen, som följer de [officiella versionerna](https://github.com/omacom/omarchy/releases/), liksom den [stabila Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) som ligger en månad bakom det senaste, så att vi kan fånga eventuella nya inkompatibiliteter som kräver konfigurationsändringar innan de orsakar problem för folk.

Men om du vill hjälpa till att upptäcka de potentiella problemen kan du köra på edge-kanalen. Då fortsätter dina Omarchy-paket att följa de senaste utvecklingsbyggena, och du kan uppdatera till de senaste Arch-paketen så snart de finns tillgängliga. Du bör bara göra detta om du är erfaren med Linux, och vet hur man återställer ett system som har problem.

Inför varje ny större version kommer vi att göra den slutliga valideringen med RC-kanalen. Om du är intresserad av att hjälpa till med den sista finputsningen, kom och häng med oss i #omarchy-release-candidates på Discord.

Till sist finns dev-kanalen, som länkar Omarchy direkt till en git-utcheckning av källkoden i `~/omarchy`, kombinerat med edge-paketen. Du bör bara använda den här kanalen om du är en erfaren Linux-användare, arbetar direkt med Omarchy och är beredd att stå ut med att saker går sönder.

Du kan byta mellan kanaler med _Uppdatera > Channel_ från Omarchy-menyn (eller `omarchy-channel-set` i terminalen).

### Byta kärna

Omarchy startar sin egen `linux-omarchy`-kärna, men du kan ha andra installerade bredvid den, som Archs standardkärna `linux` eller ett experimentellt bygge som du testar. När det finns mer än en listar _Uppdatera > Kernel_ i Omarchy-menyn dem med en bock bredvid den som startar som standard. Välj en annan, ange ditt lösenord en gång, så startar den efter nästa omstart. De andra kärnorna stannar kvar i startmenyn, så du kan fortfarande välja en för hand om den nya standardkärnan ger dig problem. I terminalen är det `omarchy-kernel` för att se nuvarande standard, `omarchy-kernel list` för vad som är installerat, och `omarchy-kernel set <kernel>` för att byta.

### Uppdateringar av firmware

Dina paket är inte det enda som blir föråldrat. Många bärbara datorer och kringutrustning levererar BIOS-, SSD- och dockningsfirmware via Linux Vendor Firmware Service, och _Uppdatera > Firmware_ i Omarchy-menyn hämtar och installerar allt som din hårdvara väntar på. Den installerar `fwupd` första gången du kör den. Massor av firmware kan bara skrivas under en omstart, så bli inte förvånad om du blir ombedd att göra en.

### Varning för direkta pacman/yay-uppdateringar

Om du redan är bekant med Arch kan du frestas att bara köra `pacman -Syu` eller `yay -Syu` själv, men om du gör det missar du ögonblicksbilden, migreringarna och konfigurationsuppdateringarna som Omarchy kör tillsammans med nya paket. Därför kommer Omarchy faktiskt att stoppa en direkt systemuppgradering och hänvisa dig till `omarchy update` i stället. (Om du verkligen vet vad du gör talar skyddet om för dig hur du kringgår det för en enda transaktion.)

### Rulla tillbaka dåliga uppdateringar

Om du någonsin får problem efter att ha gjort en uppdatering kan du rulla tillbaka systemet till ögonblicksbilden som togs före uppdateringen. Starta bara om och välj ögonblicksbilden i startmenyn från innan du påbörjade uppdateringen.

![bootloader](images/bootloader.webp)

Om dina konfigurationsfiler på något sätt har skadats kan du också göra en ominstallation av Omarchy med `omarchy reinstall` i terminalen. Det installerar om alla Omarchy-standardpaket, sätter dig på stable och nedgraderar eventuella paket som är för nya, och återställer alla konfigurationsfiler. Observera att alla dina egna konfigurationsändringar av Omarchy-standarderna skrivs över när du gör detta!
