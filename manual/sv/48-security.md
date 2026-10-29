# Säkerhet

Omarchy tar säkerhet på yttersta allvar. Det här ska vara ett operativsystem som du kan använda för att göra _Riktigt Arbete_ i _Den Verkliga Världen_. Där en förlorad bärbar dator inte kan leda till en säkerhetskris. Så här gör vi:

1. *Fullständig diskkryptering är obligatorisk*: Det här är det viktigaste steget för att säkra det fysiska skyddet av dina data. Om din dator försvinner eller blir stulen är data helt krypterade med standardmässiga LUKS (Linux Unified Key Setup).
2. *Brandväggen är aktiverad som standard*: All inkommande trafik blockeras som standard, förutom på port 53317 för [LocalSend](https://localsend.org/). Även ssh är avstängt tills du slår på det via _Setup > Security > SSHD_, vilket öppnar port 22 (med hastighetsbegränsning mot brute force) som en del av konfigurationen. Vi låser till och med ner Docker-åtkomst med [ufw-docker](https://github.com/chaifeng/ufw-docker)-konfigurationen för att förhindra att dina containrar av misstag exponeras mot världen.
3. *Arch har alltid de senaste uppdateringarna*: Arch, den underliggande distribution som Omarchy bygger på, är en rullande distribution. Det betyder att varje säkerhetsbrist som upptäcks och åtgärdas i något paket snabbt blir tillgänglig att installera med `omarchy-update`. På så sätt kör du alltid de senaste, säkraste versionerna av allting.
4. *Omarchy underhåller sina egna paket och sin egen spegel*: Omarchy förlitar sig som standard endast på paket från Archs egna core/extra/multilib-förråd och sitt eget Omarchy Package Repository. Du kan installera programvara direkt från AUR, men basinstallationen gör det inte — endast ett fåtal valfria installationer, som webbläsare från tredje part, hämtar från AUR.
5. *Cloudflare skyddar oss mot DDoS*: Omarchys distributionsinfrastruktur — ISO-filerna, Omarchy-paketen, Arch-spegeln — skyddas bakom Cloudflares formidabla DDoS-sköld och hostas på deras CDN. Det ger suverän tillgänglighet.

## Ändra dina lösenord

Du har två lösenord på en krypterad installation: det som låser upp disken vid start, och det som du loggar in och använder `sudo` med. Konfigurationen gör dem till samma. Båda kan ändras under _Update > Password_ i Omarchy-menyn — _Drive Encryption_ för det första, _User_ för det andra. För att ändra diskens lösenord behöver du först ange det nuvarande, så ha det till hands. Om en ändring avbryts, kör _Drive Encryption_ igen: den frågar efter lösenordet som låser upp disken nu och slutför ändringen.

## Lämna vidare en dator du redan har använt

Om du ska lämna över din dator till någon annan behöver du inte installera om den. Kör _Setup > Reset Computer_ i Omarchy-menyn, skriv `reset` för att bekräfta, och starta om. Det raderar varje användarkonto och allt i `/home`, kastar bort alla paket och systemändringar du har gjort sedan installationen, och rensar datorns identitet — nätverksanslutningar, värdnycklar och allt. Det som kommer tillbaka är installationsguiden från första starten, redo för sin nya ägare att ange sitt eget namn, lösenord och krypteringslösenord.

Det fungerar genom att återställa den baslinjeögonblicksbild som installeraren tar, så det är endast tillgängligt på datorer som installerats från Omarchy-ISO:n. Och på en disk utan kryptering är en återställning radering snarare än säker radering, så om data var känsliga, gör en nyinstallation i stället.

## Lösenordsfri sudo

Ibland vill du att `sudo` ska sluta fråga, oftast när en AI-agent gör ett långt stycke systemarbete åt dig. _Setup > Security > Passwordless Sudo_ frågar hur länge åtkomst ska tillåtas: **15 minuter**, **1 timme**, **1 dag** eller **Permanent**. En röd varningsikon visas bredvid de andra indikatorerna i menyraden medan åtkomsten är aktiv. Klicka på den eller kör kommandot igen för att stänga av åtkomsten. Du kan också ange ditt eget antal minuter (från 1 till 1440) med `omarchy-sudo-passwordless 30`, eller använda `omarchy-sudo-passwordless permanent`.

Tidsbegränsad åtkomst upphör automatiskt, även omedelbart efter att datorn väckts från ett viloläge som passerade tidsgränsen. Att starta om datorn avslutar den i förtid. Permanent åtkomst överlever omstarter och förblir aktiverad tills du inaktiverar den.

Att uppdatera eller ta bort Omarchys inställningspaket avslutar varje tillfälligt beviljande innan stödet för dess utgång ändras. Om kommandot rapporterar ett auktoriserings- eller rensningsfel, åtgärda det innan du försöker aktivera ett annat beviljande; ett fel betyder inte att lösenordsfri åtkomst är inaktiv.

Se nyktert på det här: medan det är påslaget kan allt som körs som din användare göra vad som helst som root utan att bli tillfrågat. Det är hela poängen, och det är också hela risken.

## Signeringsnycklar

Den publika nyckeln för alla ISO-signaturer och Omarchy-förrådets paket är `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiera på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketet `omarchy/omarchy-keyring` innehåller också den här och kommer att användas för att sömlöst rulla ut eventuella uppdateringar.

Du kan hitta signaturen för varje ISO-utgåva genom att lägga till `.sig` i dess URL, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
