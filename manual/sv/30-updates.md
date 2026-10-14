# Uppdateringar

Omarchy och dina paket hålls uppdaterade via _Uppdatera > Omarchy_ i Omarchy-menyn (`Super + Space`).

Omarchy självt installeras som vanliga pacman-paket från [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en uppdatering installerar [den senaste Omarchy-versionen](https://github.com/omacom/omarchy/releases), kör alla väntande migrationer för att få ditt system i synk med det senaste, och uppdaterar alla systempaket från [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) och [AUR](https://aur.archlinux.org/) (om du har installerat några AUR-paket).

När nya versioner släpps visas en cirkelpil-ikon till höger om din klocka. Klicka på den så startar uppdateringsprocessen.

![update-available](images/update-available.webp)

### Fyra kanaler

Omarchy uppdateras längs fyra kanaler: stable, RC, edge och dev. Nya installationer börjar på stable-kanalen, som spårar de [officiella versionerna](https://github.com/omacom/omarchy/releases/), liksom den [stabila Omarchy Arch-spegeln](https://github.com/omacom-io/omarchy-mirror) som kör en månad efter den senaste, så att vi kan fånga upp eventuella nya inkompatibiliteter som kräver configändringar innan de orsakar problem för folk.

Men om du vill hjälpa till att upptäcka de där potentiella problemen kan du köra på edge-kanalen. Det håller dina Omarchy-paket spårande de senaste utvecklingsbyggena, och låter dig uppdatera till de senaste Arch-paketen så snart de är tillgängliga. Du bör bara göra det här om du är erfaren med Linux och vet hur du återställer ett system som har problem.

Inför varje ny större version kommer vi att göra slutvalidering med RC-kanalen. Om du är intresserad av att hjälpa till med den sista poleringen, kom och häng i #omarchy-release-candidates på Discord.

Slutligen finns det dev-kanalen, som länkar Omarchy direkt till en git-checkout av källkoden i `~/omarchy`, kombinerat med edge-paketen. Du bör bara använda den här kanalen om du är en erfaren Linux-användare, arbetar direkt med Omarchy och är villig att tolerera att saker går sönder.

Du kan växla mellan kanaler via _Uppdatera > Channel_ från Omarchy-menyn (eller `omarchy-channel-set` i terminalen).

### Firmware-uppdateringar

Dina paket är inte det enda som blir inaktuellt. Många laptops och kringutrustningar levererar BIOS-, SSD- och dock-firmware via Linux Vendor Firmware Service, och _Uppdatera > Firmware_ i Omarchy-menyn hämtar och installerar vad din hårdvara än har väntande. Den installerar `fwupd` första gången du kör den. Massor av firmware kan bara skrivas under en omstart, så bli inte förvånad om du blir ombedd om en.

### Varning om direkta pacman/yay-uppdateringar

Om du redan är bekant med Arch kanske du frestas att bara köra `pacman -Syu` eller `yay -Syu` själv, men om du gör det missar du snapshoten, migrationerna och konfigurationsuppdateringarna som Omarchy kör tillsammans med nya paket. Det är därför Omarchy faktiskt stoppar en direkt systemuppgradering och pekar dig mot `omarchy update` istället. (Om du verkligen vet vad du gör talar skyddet om för dig hur du kringgår det för en enskild transaktion.)

### Återställa dåliga uppdateringar

Om du någonsin får problem efter att ha gjort en uppdatering kan du återställa ditt system till snapshoten som togs före uppdateringen. Starta bara om och välj snapshoten i bootmenyn från innan du startade uppdateringen.

![bootloader](images/bootloader.webp)

Om dina konfigurationsfiler på något sätt har skadats kan du också utföra en Omarchy-ominstallation med `omarchy reinstall` i terminalen. Det installerar om alla Omarchy-standardpaket, sätter dig på stable och nedgraderar alla paket som är för nya, och återställer alla konfigurationsfiler. Observera att alla dina användarconfigändringar av Omarchy-standarderna kommer att skrivas över när du gör det här!
