# Hårdvaruautentisering

### Fingeravtrycksautentisering

Många bärbara datorer har en fingeravtryckssensor för autentisering. Du kan använda den med Omarchy genom att köra _Setup > Security > Fingerprint_ i Omarchy-menyn (`Super + Space`).

Det öppnar ett fingeravtryck i helskärm som fylls i efter hand som du rör vid sensorn. Bakom kulisserna installerar Omarchy fingeravtryckspaketet, samlar in ditt avtryck, verifierar det, och sedan är du redo att använda ditt fingeravtryck för att låsa upp från låsskärmen (som du kan visa med `Super + Ctrl + L`), gå in i sudo-läge och godkänna systemuppmaningar.

När låsskärmen har stängt av skärmen vilar sensorn för att spara ström, så väck skärmen med valfri tangent eller styrplattan innan du rör vid den.

När locket till din bärbara dator är stängt hoppas fingeravtrycksuppmaningen automatiskt över, så du går direkt till lösenordsuppmaningen i stället för att vänta på en sensor du inte kan nå. Om du annars behöver arbeta med ett externt tangentbord som inte har någon sensor trycker du bara på `CTRL + C` när du blir ombedd att använda ditt fingeravtryck under `sudo`.

Du kan ta bort fingeravtrycksautentiseringen under _Remove > Security > Fingerprint_ i Omarchy-menyn.

### Fido2-autentisering

Om du använder en Fido2-enhet kan du ställa in den för `sudo`-autentisering med _Setup > Security > Fido2_ i Omarchy-menyn (`Super + Space`). Den täcker dock `sudo` och systemuppmaningar för godkännande, inte upplåsning av datorn.

Du kan ta bort Fido2-autentiseringen under _Remove > Security > Fido2_ i Omarchy-menyn.
