# Dual Boot-installation

Du kan installera Omarchy till en enskild partition bredvid Windows eller andra installationer.

Denna installationsmetod levereras fortfarande med LUKS-kryptering för partitionen som standard, så den är effektivt inte annorlunda än en hel enhet och kräver helt enkelt att ledigt utrymme är tillgängligt på disken.

## Skapa utrymme på Windows

För att installera bredvid Windows skriver du `disk management` i startmenyn och väljer alternativet för **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hitta lämplig partition, högerklicka och välj **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Mata in hur mycket du vill krympa volymen med. Observera att detta kommer att vara storleken på din framtida Omarchy-installation inklusive startpartitionen.

 ![dual-boot-3](images/dual-boot-3.webp)

När du är klar bör du se något liknande där 50GB-sektionen är där vi kommer att installera Omarchy i detta exempel.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installera Omarchy

Installationsprocessen för Omarchy är effektivt densamma som normalt. Efter att du har valt din disk får du alternativet **Free space install**. Välj det alternativet för att förhindra att hela disken raderas.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekräfta att allt ser bra ut och vänta tills installationen är klar som normalt. Det är också här du kan välja att installera okrypterat (rekommenderas inte) precis som på en helenhetsinstallation.
 ![dual-boot-6](images/dual-boot-6.webp)

## Lägga till andra installationer till bootloadern

När du slutför din Omarchy-installation kommer du att märka att Limine-bootloadern är standard nu. Med denna kan du också lägga till alternativ till Limine för dina andra installationer som exempelvis Windows.

För att göra det kör du `limine-scan` och följer anvisningarna för att lägga till de poster du vill ha till din limine-konfiguration. Sedan, när du startar, kommer du att se dina normala alternativ för Omarchy, såväl som Windows Boot Manager eller andra.

## Bitlocker

Det är viktigt att notera att denna installationsmetod inte är kompatibel med Bitlocker eftersom den krypterar hela enheten, inte bara partitionen. Om du stöter på ett fel som säger att Bitlocker är aktiverat startar du till Windows, går till **Settings -> Privacy & Security -> Device encryption** och växlar av Bitlocker. Det kan ta lite tid att dekryptera enheten.

 ![dual-boot-7](images/dual-boot-7.webp)
