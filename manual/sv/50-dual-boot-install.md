# Installation med dual boot

Du kan installera Omarchy på en enda partition bredvid Windows eller andra installationer.

Den här installationsmetoden levereras fortfarande med LUKS-kryptering för partitionen som standard, så den skiljer sig i praktiken inte från en installation på hela disken och kräver helt enkelt att det finns ledigt utrymme på disken.

## Frigöra utrymme i Windows

För att installera bredvid Windows skriver du `disk management` i startmenyn och väljer alternativet **Skapa och formatera hårddiskpartitioner**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hitta rätt partition, högerklicka och välj **Krymp volym**.

![dual-boot-2](images/dual-boot-2.webp)

 Ange hur mycket du vill krympa volymen med. Observera att detta blir storleken på din framtida Omarchy-installation, inklusive startpartitionen.

 ![dual-boot-3](images/dual-boot-3.webp)

När du är klar bör du se något liknande detta, där avsnittet på 50GB är där vi installerar Omarchy i det här exemplet.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installera Omarchy

Installationsprocessen för Omarchy är i praktiken densamma som vanligt. När du har valt din disk får du alternativet **Installation på ledigt utrymme**. Välj det alternativet för att undvika att hela disken rensas.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekräfta att allt ser bra ut och vänta tills installationen är klar, precis som vanligt. Det är också här du kan välja att installera okrypterat (rekommenderas inte), precis som vid en installation på hela disken.
 ![dual-boot-6](images/dual-boot-6.webp)

## Lägga till andra installationer i bootloadern

När du är klar med din Omarchy-installation kommer du att märka att bootloadern Limine nu är standard. Med den kan du också lägga till alternativ i Limine för dina andra installationer, till exempel Windows.

För att lägga till andra operativsystem kör du `limine-scan` och följer anvisningarna för att lägga till de poster du vill ha i din Limine-konfiguration. Startmenyn förblir dold som standard och startar Omarchy efter en sekund. För att välja Windows eller en annan post trycker du på valfri tangent så snart Limine startar; när menyn visas använder du piltangenterna för att välja en post och trycker på Enter. Om Omarchy startar innan du hinner trycka på en tangent startar du om och försöker igen. Om du har aktiverat _Setup > Direct Boot_ hoppar firmware över Limine helt, så välj Limine från din BIOS-startmeny eller kör _Setup > Direct Boot_ igen för att ta bort posten.

## Bitlocker

Det är viktigt att notera att den här installationsmetoden inte är kompatibel med Bitlocker, eftersom Bitlocker krypterar hela disken, inte bara partitionen. Om du stöter på ett fel som säger att Bitlocker är aktiverat startar du Windows, går till **Inställningar -> Sekretess och säkerhet -> Enhetskryptering** och stänger av Bitlocker. Det kan ta en stund att dekryptera disken.

 ![dual-boot-7](images/dual-boot-7.webp)
