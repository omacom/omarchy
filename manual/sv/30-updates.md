# Uppdateringar

Omarchy och dina paket hålls uppdaterade via _Uppdatera > Omarchy_ i Omarchy-menyn (`Super + Space`).

Omarchy i sig installeras som vanliga pacman-paket från [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en uppdatering installerar [den senaste Omarchy-versionen](https://github.com/omacom/omarchy/releases), kör alla väntande migreringar för att få ditt system i synk med det senaste, och uppdaterar alla systempaket från [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) och [AUR](https://aur.archlinux.org/) (om du har installerat några AUR-paket).

När nya versioner släpps visas en ikon med en cirkelpil till höger om din klocka. Klicka på den så startar uppdateringsprocessen.

![update-available](images/update-available.webp)

### Fyra kanaler

Omarchy uppdateras längs fyra kanaler: stable, RC, edge och dev. Nya installationer börjar på stable-kanalen, som följer de [officiella versionerna](https://github.com/omacom/omarchy/releases/), liksom den [stabila Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) som ligger en månad efter det senaste, så att vi kan fånga upp nya inkompatibiliteter som kräver konfigurationsändringar innan de orsakar problem för folk.

Men om du vill hjälpa till att upptäcka de potentiella problemen kan du köra på edge-kanalen. Det håller dina Omarchy-paket i takt med de senaste utvecklingsbyggena och låter dig uppdatera till de senaste Arch-paketen så snart de är tillgängliga. Du bör bara göra detta om du är erfaren med Linux och vet hur man återställer ett system som har problem.

Inför varje ny större version gör vi en slutlig validering med RC-kanalen. Om du är intresserad av att hjälpa till med den sista finputsningen, kom och häng i #omarchy-release-candidates på Discord.

Slutligen finns dev-kanalen, som länkar Omarchy direkt till en git-checkout av källkoden i `~/omarchy`, kombinerat med edge-paketen. Du bör bara använda den här kanalen om du är en erfaren Linux-användare, arbetar direkt med Omarchy och är beredd att stå ut med att saker går sönder.

Du kan byta mellan kanaler via _Uppdatera > Kanal_ i Omarchy-menyn (eller `omarchy channel set <stable|rc|edge|dev>` i terminalen, med `omarchy channel current` för att se var du är).

### Byta kärna

Omarchy startar med sin egen `linux-omarchy`-kärna, men du kan ha andra installerade bredvid den, som standardkärnan `linux` från Arch eller ett experimentellt bygge som du testar. När det finns mer än en listar _Uppdatera > Kärna_ i Omarchy-menyn dem med en bock bredvid den som startar som standard. Välj en annan, ange ditt lösenord en gång, så startar den efter nästa omstart. De andra kärnorna stannar kvar i startmenyn, så du kan fortfarande välja en för hand om det nya standardvalet ställer till problem för dig. I terminalen är det `omarchy kernel` för att se det aktuella standardvalet, `omarchy kernel list` för vad som är installerat och `omarchy kernel set <kernel>` för att byta.

### Uppdateringar av firmware

Dina paket är inte det enda som blir inaktuellt. Många bärbara datorer och tillbehör levererar BIOS-, SSD- och dockningsfirmware via Linux Vendor Firmware Service, och _Uppdatera > Firmware_ i Omarchy-menyn hämtar och installerar allt som din hårdvara har väntande. Det installerar `fwupd` första gången du kör det. Mycket firmware kan bara skrivas under en omstart, så bli inte förvånad om du blir ombedd att göra en.

När du behöver ändra en inställning i själva BIOS, håll ned `Alt` i systemmenyn (`Super + Escape`) så förvandlas _Starta om_ till _Starta om till BIOS_, vilket startar om direkt till firmware-inställningarna utan att du behöver pricka rätt tangent vid uppstarten. Från terminalen är det `omarchy system firmware`.

### Varning om direkta pacman/yay-uppdateringar

Om du redan är bekant med Arch kan du frestas att bara köra `pacman -Syu` eller `yay -Syu` själv, men om du gör det missar du ögonblicksbilden, migreringarna och konfigurationsuppdateringarna som Omarchy kör tillsammans med nya paket. Därför stoppar Omarchy faktiskt en direkt systemuppgradering och hänvisar dig till `omarchy update` i stället. (Om du verkligen vet vad du gör talar skyddet om hur du kringgår det för en enda transaktion.)

### Återställa efter dåliga uppdateringar

Om du någonsin får problem efter en uppdatering kan du rulla tillbaka systemet till ögonblicksbilden som togs före uppdateringen. Starta bara om och välj ögonblicksbilden från innan du startade uppdateringen i startmenyn.

![bootloader](images/bootloader.webp)

Om dina konfigurationsfiler på något sätt har skadats kan du också göra en ominstallation av Omarchy med `omarchy reinstall` i terminalen. Det installerar om alla Omarchys standardpaket, sätter dig på stable (edge på Apple Silicon) och nedgraderar alla paket som är för nya, och återställer alla konfigurationsfiler. Observera att alla dina egna konfigurationsändringar av Omarchys standardinställningar skrivs över när du gör detta!
