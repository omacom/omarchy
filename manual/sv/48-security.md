# Säkerhet

Omarchy tar säkerhet på största allvar. Det här är menat att vara ett operativsystem som du kan använda för att göra _riktigt arbete_ i _den verkliga världen_. Där en borttappad bärbar dator inte kan leda till en säkerhetskris. Så här gör vi:

1. *Fullständig diskkryptering är aktiverad som standard*: Det här är det viktigaste steget för att säkra det fysiska skyddet av dina data. Om din dator tappas bort eller blir stulen är data helt krypterade med standard-LUKS (Linux Unified Key Setup). Installationsprogrammet låter dig välja bort det för engångsmaskiner (se [Kom igång](02-getting-started.md)); en installation utan kryptering har inget av det här skyddet, och den som har disken kan läsa den.
2. *Brandväggen är aktiverad som standard*: All inkommande trafik blockeras som standard, med några få undantag: port 53317 för [LocalSend](https://localsend.org/); DNS-frågor till datorns egen resolver på Docker-bryggadressen (172.17.0.1), som accepteras från de privata adressintervall som Docker ger sina containrar; och multicast DNS (port 5353), som låter skrivare och andra enheter på ditt nätverk hitta varandra och även tillkännager din dators namn där. Utöver dem behåller brandväggen UFW:s standardtillåtelser för ping, att hämta en adress från din router (DHCP) och UPnP-upptäckt. Till och med ssh är avstängt tills du aktiverar det via _Inställningar > Säkerhet > SSHD_, vilket öppnar port 22 (med hastighetsbegränsning mot brute force) som en del av konfigurationen. Vi låser till och med ner Docker-åtkomst med [ufw-docker](https://github.com/chaifeng/ufw-docker)-konfigurationen för att förhindra att dina containrar av misstag exponeras mot världen.
3. *Arch har alltid de senaste uppdateringarna*: Arch, den underliggande distribution som Omarchy bygger på, är en rullande distribution. Det innebär att varje säkerhetssårbarhet som upptäcks och åtgärdas i något paket snabbt blir tillgänglig att installera med `omarchy-update`. På så sätt kör du alltid de senaste, säkraste versionerna av allt.
4. *Omarchy underhåller sina egna paket och sin egen spegel*: Omarchy förlitar sig som standard endast på paket från Archs egna core/extra/multilib-förråd och sitt eget Omarchy Package Repository. Du kan installera programvara direkt från AUR, men basinstallationen gör det inte — endast några få valfria installationer, som tredjepartswebbläsarna, hämtar från AUR.
5. *Cloudflare skyddar oss mot DDoS*: Omarchys distributionsinfrastruktur — ISO-filerna, Omarchy-paketen, Arch-spegeln — skyddas bakom Cloudflares formidabla DDoS-sköld och driftas på deras CDN. Det ger suverän tillgänglighet.

## Ändra dina lösenord

Du har två lösenord på en krypterad installation: det som låser upp disken vid start, och det som du loggar in och använder `sudo` med. Under installationen sätts de till samma. Båda kan ändras under _Uppdatera > Lösenord_ i Omarchy-menyn — _Diskkryptering_ för det första, _Användare_ för det andra. När du ändrar disklösenordet måste du först ange det nuvarande, så ha det till hands. Om en ändring avbryts ska du köra _Diskkryptering_ igen: det ber om lösenordet som låser upp disken nu och slutför ändringen.

## Lämna över en dator du redan har använt

Om du lämnar över din dator till någon annan behöver du inte installera om den. Kör _Ta bort > Fabriksåterställning_ i Omarchy-menyn, skriv `reset` för att bekräfta och starta om. Det raderar varje användarkonto och allt i `/home`, kastar bort alla paket och systemändringar som du har gjort sedan installationen och rensar datorns identitet — nätverksanslutningar, värdnycklar och allt. Det som startar upp igen är installationsguiden från första starten, redo för sin nya ägare att ange sitt eget namn, lösenord och krypteringslösenord.

Det fungerar genom att återställa den grundögonblicksbild som installationsprogrammet tar, så det är bara tillgängligt på datorer som har installerats från Omarchy ISO. Och på en disk utan kryptering är en återställning radering snarare än säker radering, så om data var känsliga ska du göra en nyinstallation i stället.

## Lösenordsfri sudo

Ibland vill du att `sudo` ska sluta fråga, oftast när en AI-agent gör ett långt stycke systemarbete åt dig. _Inställningar > Säkerhet > Lösenordsfri sudo_ frågar hur länge åtkomst ska tillåtas: **15 minuter**, **1 timme**, **1 dag** eller **Permanent**. En röd varningsikon visas bredvid de andra indikatorerna i menyraden medan åtkomsten är aktiv. Klicka på den eller kör kommandot igen för att stänga av åtkomsten. Du kan också ange ditt eget antal minuter (från 1 till 1440) med `omarchy-sudo-passwordless 30`, eller använda `omarchy-sudo-passwordless permanent`.

Tidsbegränsad åtkomst upphör automatiskt, inklusive omedelbart efter att datorn återupptas från ett viloläge som passerade tidsgränsen. Att starta om datorn avslutar den i förtid. Permanent åtkomst överlever omstarter och förblir aktiverad tills du inaktiverar den.

Att uppdatera eller ta bort Omarchys inställningspaket avslutar varje tillfällig behörighet innan stödet för dess utgång ändras. Om kommandot rapporterar ett auktoriserings- eller upprensningsfel ska du lösa det innan du försöker aktivera en annan behörighet; ett fel betyder inte att lösenordsfri åtkomst är inaktiv.

Var klarsynt med det här: medan det är på kan allt som körs som din användare göra vad som helst som root utan att bli tillfrågat. Det är hela poängen, och det är också hela risken.

## Signeringsnycklar

Den offentliga nyckeln för alla ISO-signaturer och Omarchy-förrådspaket är `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiera på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketet `omarchy/omarchy-keyring` innehåller också detta och kommer att användas för att rulla ut eventuella uppdateringar sömlöst.

Du hittar signaturen för en ISO-utgåva genom att lägga till `.sig` i dess URL, till exempel `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
