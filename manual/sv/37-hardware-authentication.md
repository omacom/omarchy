# Hårdvaruautentisering

### Autentisering med fingeravtryck

Många bärbara datorer har en fingeravtryckssensor för autentisering. Du kan använda den med Omarchy genom att köra _Konfigurera > Säkerhet > Fingeravtryck_ i Omarchy-menyn (`Super + Space`).

Det installerar fingeravtryckspaketet, samlar in ditt avtryck, verifierar det, och sedan kan du använda ditt fingeravtryck för att låsa upp från låsskärmen (som du kan aktivera med `Super + Ctrl + L`), gå in i sudo-läge och godkänna systemuppmaningar.

När låsskärmen har släckt skärmen vilar sensorn för att spara ström, så väck skärmen med valfri tangent eller styrplattan innan du rör vid den.

När locket på din bärbara dator är stängt hoppas fingeravtrycksuppmaningen automatiskt över, så du går direkt till lösenordsuppmaningen i stället för att vänta på en sensor du inte kan nå. Om du annars behöver arbeta på ett externt tangentbord som inte har någon sensor trycker du bara på `CTRL + C` när du uppmanas att ange ditt fingeravtryck under `sudo`.

Du kan ta bort fingeravtrycksautentiseringen under _Ta bort > Säkerhet > Fingeravtryck_ i Omarchy-menyn.

### Fido2-autentisering

Om du använder en Fido2-enhet kan du konfigurera den för `sudo`-autentisering med _Konfigurera > Säkerhet > Fido2_ i Omarchy-menyn (`Super + Space`). Den täcker dock uppmaningar för `sudo` och systemauktorisering, inte upplåsning av datorn.

Du kan ta bort fido2-autentiseringen under _Ta bort > Säkerhet > Fido2_ i Omarchy-menyn.
