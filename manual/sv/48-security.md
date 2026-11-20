# Säkerhet

Omarchy tar säkerhet på största allvar. Det här är tänkt att vara ett operativsystem som du kan använda för att göra _Riktigt Arbete_ i den _Verkliga Världen_. Där att tappa bort en bärbar dator inte kan leda till en säkerhetskris. Så här gör vi:

1. *Fullständig diskkryptering är aktiverad som standard*: Detta är det viktigaste steget för att säkra det fysiska skyddet av dina data. Om din dator tappas bort eller blir stulen är data helt krypterade med standard-LUKS (Linux Unified Key Setup). Installationsprogrammet låter dig välja bort det för engångsdatorer (se [Kom igång](02-getting-started.md)); en installation utan kryptering har inget av detta skydd, och alla som har disken kan läsa den.
2. *Brandväggen är aktiverad som standard*: All inkommande trafik blockeras som standard, med några få undantag: port 53317 för [LocalSend](https://localsend.org/); DNS-frågor till datorns egen resolver på Docker-bryggans adress (172.17.0.1), som accepteras från de privata adressintervall som Docker ger sina containrar; och multicast DNS (port 5353), som låter skrivare och andra enheter på ditt nätverk hitta varandra och även tillkännager din dators namn där. Utöver dessa behåller brandväggen UFW:s standardundantag för ping, för att få en adress från din router (DHCP) och för UPnP-upptäckt. Även ssh är avstängt tills du aktiverar det via _Installation > Säkerhet > SSHD_, vilket auktoriserar din SSH-nyckel, stänger av lösenordsinloggningar och först därefter öppnar port 22 (hastighetsbegränsad mot brute force). Vi låser till och med ner Docker-åtkomst med hjälp av [ufw-docker](https://github.com/chaifeng/ufw-docker)-konfigurationen för att förhindra att dina containrar av misstag exponeras mot världen.
3. *Arch har alltid de senaste uppdateringarna*: Arch, den underliggande distribution som Omarchy bygger på, är en rullande distribution. Det innebär att varje säkerhetssårbarhet som upptäcks och åtgärdas i ett paket snabbt blir tillgänglig för installation med `omarchy-update`. På så sätt kör du alltid de senaste, säkraste versionerna av allt.
4. *Omarchy underhåller sina egna paket och sin egen spegel*: Omarchy förlitar sig som standard endast på paket från Archs egna core/extra/multilib-paketförråd (Arch Linux ARMs på ARM-datorer, plus Asahi ALARM på Apple Silicon) och sitt eget Omarchy Package Repository. Du kan installera programvara direkt från AUR, men basinstallationen gör det inte — endast ett fåtal valfria installationer, som webbläsare från tredje part, hämtar från AUR.
5. *Cloudflare skyddar oss mot DDoS*: Omarchys distributionsinfrastruktur — ISO-filerna, Omarchy-paketen, Arch-spegeln — skyddas bakom Cloudflares formidabla DDoS-sköld och hostas på deras CDN. Detta ger utmärkt tillgänglighet.

## Ändra dina lösenord

Du har två lösenord på en krypterad installation: det som låser upp disken vid start, och det du loggar in och använder `sudo` med. Installationsprogrammet gör dem till samma. Båda kan ändras under _Uppdatera > Lösenord_ i Omarchy-menyn — _Diskkryptering_ för det första, _Användare_ för det andra. För att ändra diskens lösenord behöver du ange det nuvarande först, så ha det till hands. Om en ändring avbryts, kör _Diskkryptering_ igen: den frågar efter det lösenord som låser upp disken nu och slutför ändringen.

## Lämna vidare en dator du redan har använt

Om du lämnar över din dator till någon annan behöver du inte installera om den. Kör _Ta bort > Fabriksåterställning_ i Omarchy-menyn, skriv `reset` för att bekräfta, ange ditt lösenord för diskkryptering om du blir ombedd, och starta om. Det raderar varje användarkonto och allt i `/home`, kastar bort alla paket och systemändringar du har gjort sedan installationen, och rensar datorns identitet — nätverksanslutningar, värdnycklar och allt. Det som startar upp igen är installationsguiden från första starten, redo för sin nya ägare att ange sitt eget namn, lösenord och krypteringslösenord.

Det fungerar genom att återställa den grundläggande ögonblicksbild som installationsprogrammet tar, så det är endast tillgängligt på datorer som installerats från Omarchy ISO. Och på en disk utan kryptering är en återställning radering snarare än en säker radering, så om data var känsliga, gör en nyinstallation i stället.

## Lösenordsfri sudo

Ibland vill du att `sudo` slutar fråga, oftast när en AI-agent utför ett långt systemarbete åt dig. _Installation > Säkerhet > Lösenordsfri Sudo_ frågar hur länge åtkomst ska tillåtas: **15 minuter**, **1 timme**, **1 dag**, eller **permanent**. En röd varningsikon visas bredvid de andra indikatorerna i menyraden medan åtkomst är aktiv. Klicka på den eller kör kommandot igen för att stänga av åtkomsten. Du kan också ange ditt eget antal minuter (från 1 till 1440) med `omarchy-sudo-passwordless 30`, eller använda `omarchy-sudo-passwordless permanent`.

Tidsbegränsad åtkomst upphör automatiskt, inklusive omedelbart efter återgång från ett viloläge som passerade tidsgränsen. Att starta om datorn avslutar den i förtid. Permanent åtkomst överlever omstarter och förblir aktiverad tills du inaktiverar den.

Att uppdatera eller ta bort Omarchys inställningspaket avslutar alla tillfälliga tillstånd innan stödet för deras utgång ändras. Om kommandot rapporterar ett auktoriserings- eller rensningsfel, åtgärda det innan du försöker aktivera ett annat tillstånd; ett fel betyder inte att lösenordsfri åtkomst är inaktiv.

Var klarsynt om detta: medan det är på kan allt som körs som din användare göra vad som helst som root utan att bli tillfrågat. Det är hela poängen, och det är också hela risken.

## Signeringsnycklar

Den offentliga nyckeln för alla ISO-signaturer och Omarchy-repo-paket är `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiera på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketet `omarchy/omarchy-keyring` innehåller också denna och kommer att användas för att rulla ut eventuella uppdateringar sömlöst.

Du hittar signaturen för varje ISO-utgåva genom att lägga till `.sig` i dess URL, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
