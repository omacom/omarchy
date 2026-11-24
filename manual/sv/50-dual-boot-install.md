# Installation med dubbel uppstart

Du kan installera Omarchy på en enda partition tillsammans med Windows eller andra installationer.

Den här installationsmetoden använder fortfarande LUKS-kryptering för partitionen som standard, så den skiljer sig i praktiken inte från en installation på hela disken och kräver helt enkelt att det finns ledigt utrymme på disken.

## Skapa utrymme i Windows

För att installera tillsammans med Windows skriver du `disk management` i Start-menyn och väljer alternativet **Skapa och formatera hårddiskpartitioner**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hitta den partition som passar, högerklicka och välj **Krymp volym**.

![dual-boot-2](images/dual-boot-2.webp)

 Ange hur mycket du vill krympa volymen med. Observera att detta blir storleken på din framtida Omarchy-installation, inklusive startpartitionen.

 ![dual-boot-3](images/dual-boot-3.webp)

När du är klar bör du se något i stil med detta, där sektionen på 50 GB är den där vi installerar Omarchy i det här exemplet.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installera Omarchy

Installationsprocessen för Omarchy är i praktiken densamma som vanligt. När du har valt din disk får du alternativet **Installation i ledigt utrymme**. Välj det alternativet för att undvika att hela disken rensas.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekräfta att allt ser bra ut och vänta tills installationen är klar, precis som vanligt. Det är också här du kan välja att installera utan kryptering (rekommenderas inte), precis som vid en installation på hela disken.
 ![dual-boot-6](images/dual-boot-6.webp)

## Lägga till andra installationer i starthanteraren

När du är klar med din Omarchy-installation kommer du att märka att starthanteraren Limine nu är standard. Med den kan du också lägga till alternativ i Limine för dina andra installationer, till exempel Windows.

För att lägga till andra operativsystem kör du `limine-scan` och följer anvisningarna för att lägga till de poster du vill ha i din Limine-konfiguration. Startmenyn är dold som standard och startar Omarchy efter en sekund. För att välja Windows eller en annan post trycker du på valfri tangent så snart Limine startar; när menyn visas använder du piltangenterna för att välja en post och trycker på Enter. Om Omarchy startar innan du hinner trycka på en tangent startar du om och försöker igen.

## Bitlocker

Det är viktigt att observera att den här installationsmetoden inte är kompatibel med Bitlocker, eftersom den krypterar hela disken, inte bara partitionen. Om du får ett felmeddelande om att Bitlocker är aktiverat startar du Windows, går till **Inställningar -> Integritet och säkerhet -> Enhetskryptering** och stänger av Bitlocker. Det kan ta en stund att dekryptera disken.

 ![dual-boot-7](images/dual-boot-7.webp)

## Installera om Windows

Om den här datorn levererades med Windows lagras dess produktnyckel i den fasta programvaran. Kör `omarchy windows key` för att skriva ut den, så att du kan aktivera Windows igen om du någonsin installerar om det på den här datorn.
