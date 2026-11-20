# Uppdateringar

Omarchy och dina paket hålls uppdaterade via _Uppdatera > Omarchy_ i Omarchy-menyn (`Super + Space`).

Omarchy installeras självt som vanliga pacman-paket från [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en uppdatering installerar [den senaste Omarchy-versionen](https://github.com/omacom/omarchy/releases), kör eventuella väntande migreringar för att få ditt system i synk med det senaste, och uppdaterar alla systempaket från [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) och [AUR](https://aur.archlinux.org/) (om du har installerat några AUR-paket).

När nya versioner släpps visas en ikon med en cirkelpil till höger om din klocka. Klicka på den så startar uppdateringsprocessen.

![update-available](images/update-available.webp)

### Fyra kanaler

Omarchy uppdateras längs fyra kanaler: stable, RC, edge och dev. Nya installationer börjar på stable-kanalen, som följer de [officiella versionerna](https://github.com/omacom/omarchy/releases/), samt den [stabila Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) som ligger en månad efter den senaste, så att vi kan fånga upp eventuella nya inkompatibiliteter som kräver konfigurationsändringar innan de ställer till problem för folk.

Men om du vill hjälpa till att upptäcka de där potentiella problemen kan du köra på edge-kanalen. Då fortsätter dina Omarchy-paket att följa de senaste utvecklingsbyggena, och du kan uppdatera till de senaste Arch-paketen så fort de blir tillgängliga. Du ska bara göra det om du är erfaren med Linux och vet hur man återställer ett system som har problem.

Inför varje ny större version gör vi den sista valideringen via RC-kanalen. Om du är intresserad av att hjälpa till med den sista finputsningen, kom och häng i #omarchy-release-candidates på Discord.

Till sist finns dev-kanalen, som länkar Omarchy direkt till en git-checkout av källkoden i `~/omarchy`, i kombination med edge-paketen. Du ska bara använda den här kanalen om du är en erfaren Linux-användare, arbetar direkt med Omarchy och är beredd att stå ut med att saker går sönder.

Du kan växla mellan kanaler via _Uppdatera > Kanal_ i Omarchy-menyn (eller `omarchy-channel-set` i terminalen).

### Byta kärna

Omarchy startar med sin egen `linux-omarchy`-kärna, men du kan ha andra installerade bredvid den, som Archs standardkärna `linux` eller ett experimentellt bygge du testar. När det finns fler än en listar _Uppdatera > Kärna_ i Omarchy-menyn dem med en bock bredvid den som startar som standard. Välj en annan, ange ditt lösenord en gång, så startar den efter nästa omstart. De andra kärnorna finns kvar i startmenyn, så du kan fortfarande välja en för hand om den nya standardkärnan ställer till problem för dig. I terminalen använder du `omarchy-kernel` för att se den aktuella standardkärnan, `omarchy-kernel list` för att se vad som är installerat och `omarchy-kernel set <kernel>` för att byta.

### Firmware-uppdateringar

Dina paket är inte det enda som blir föråldrat. Många bärbara datorer och kringutrustning levererar firmware för BIOS, SSD och docka via Linux Vendor Firmware Service, och _Uppdatera > Firmware_ i Omarchy-menyn hämtar och installerar allt som din hårdvara har väntande. Den installerar `fwupd` första gången du kör den. Mycket firmware kan bara skrivas under en omstart, så bli inte förvånad om du blir ombedd att göra en.

När du behöver ändra en inställning i själva BIOS, håll `Alt` i systemmenyn (`Super + Escape`) så förvandlas _Starta om_ till _Starta om till BIOS_, som startar om direkt till firmware-inställningarna utan att du behöver pricka rätt tangent vid uppstart. Från terminalen kör du `omarchy system firmware`.

### Varning om direkta pacman/yay-uppdateringar

Om du redan känner till Arch kanske du frestas att bara köra `pacman -Syu` eller `yay -Syu` själv, men om du gör det missar du ögonblicksbilden, migreringarna och konfigurationsuppdateringarna som Omarchy kör tillsammans med nya paket. Därför stoppar Omarchy faktiskt en direkt systemuppgradering och pekar dig i stället mot `omarchy update`. (Om du verkligen vet vad du gör talar skyddet om hur du kringgår det för en enda transaktion.)

### Rulla tillbaka dåliga uppdateringar

Om du någonsin får problem efter att ha gjort en uppdatering kan du rulla tillbaka systemet till ögonblicksbilden som togs före uppdateringen. Starta bara om och välj ögonblicksbilden från innan du påbörjade uppdateringen i startmenyn.

![bootloader](images/bootloader.webp)

Om dina konfigurationsfiler på något sätt har blivit korrupta kan du också göra en ominstallation av Omarchy med `omarchy reinstall` i terminalen. Det installerar om alla Omarchys standardpaket, sätter dig på stable och nedgraderar eventuella paket som är för nya, och återställer alla konfigurationsfiler. Observera att alla dina egna konfigurationsändringar av Omarchys standardvärden skrivs över när du gör det här!
