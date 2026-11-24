# Säkerhet

Omarchy tar säkerhet på största allvar. Det här är menat att vara ett operativsystem som du kan använda för att göra _riktigt arbete_ i den _verkliga världen_. Där en förlorad bärbar dator inte kan leda till en säkerhetskris. Så här gör vi:

1. *Fullständig diskkryptering är aktiverad som standard*: Detta är det viktigaste steget för att säkra det fysiska skyddet av dina data. Om din dator försvinner eller blir stulen är data fullständigt krypterade med standardmässig LUKS (Linux Unified Key Setup). Installationsprogrammet låter dig välja bort det för engångsdatorer (se [Kom igång](02-getting-started.md)); en installation utan kryptering har inget av detta skydd, och vem som helst som har disken kan läsa den.
2. *Brandväggen är aktiverad som standard*: All inkommande trafik blockeras som standard, med några få undantag: port 53317 för [LocalSend](https://localsend.org/); DNS-frågor till datorns egen resolver på Docker-bryggadressen (172.17.0.1), som accepteras från de privata adressintervall som Docker ger sina containrar; och multicast DNS (port 5353), som låter skrivare och andra enheter på ditt nätverk hitta varandra och även tillkännager din dators namn där. Utöver dessa behåller brandväggen UFW:s standardtillåtelser för ping, för att få en adress från din router (DHCP) och för UPnP-upptäckt. Även ssh är avstängt tills du slår på det via _Inställningar > Säkerhet > SSHD_, vilket auktoriserar din SSH-nyckel, stänger av lösenordsinloggningar och först därefter öppnar port 22 (hastighetsbegränsad mot brute force). Vi låser till och med ner Docker-åtkomsten med [ufw-docker](https://github.com/chaifeng/ufw-docker)-konfigurationen för att förhindra att dina containrar av misstag exponeras mot världen.
3. *Arch har alltid de senaste uppdateringarna*: Arch, den underliggande distribution som Omarchy bygger på, är en rullande distribution. Det betyder att varje säkerhetssårbarhet som upptäcks och åtgärdas i något paket snabbt blir tillgänglig för installation med `omarchy-update`. På så sätt kör du alltid de senaste och säkraste versionerna av allt.
4. *Omarchy underhåller sina egna paket och sin egen spegel*: Omarchy förlitar sig som standard endast på paket från Archs egna core/extra/multilib-förråd (Arch Linux ARMs på ARM-datorer, plus Asahi ALARM på Apple Silicon) och sitt eget Omarchy Package Repository. Du kan installera programvara direkt från AUR, men grundinstallationen gör det inte — bara några få valfria installationer, som webbläsarna från tredje part, hämtar från AUR.
5. *Cloudflare skyddar oss mot DDoS*: Omarchys distributionsinfrastruktur — ISO-filerna, Omarchy-paketen, Arch-spegeln — skyddas bakom Cloudflares formidabla DDoS-sköld och driftas på deras CDN. Detta ger enastående tillgänglighet.

## Ändra dina lösenord

Du har två lösenord på en krypterad installation: det som låser upp disken vid start, och det som du loggar in och använder `sudo` med. Installationen gör dem till samma. _Uppdatera > Lösenord_ i Omarchy-menyn ändrar båda på en gång, så att de förblir samma: den ber om det aktuella disklösenordet, sedan det nya, ändrar diskens och sätter sedan ditt inloggningslösenord så att det matchar. Utan diskkryptering ändrar den bara ditt inloggningslösenord. Om en ändring avbryts kör du _Uppdatera > Lösenord_ igen: den ber om lösenordet som låser upp disken nu, slutför ändringen och sätter ditt inloggningslösenord till det. För att ändra lösenordet för en annan krypterad disk kör du `omarchy-drive-password` i en terminal.

## Lämna vidare en dator du redan har använt

Om du ska lämna över din dator till någon annan behöver du inte installera om den. Kör _Ta bort > Fabriksåterställning_ i Omarchy-menyn, skriv `reset` för att bekräfta, ange ditt diskkrypteringslösenord om du blir ombedd och starta om. Det raderar varje användarkonto och allt i `/home`, kastar bort alla paket och systemändringar du har gjort sedan installationen och rensar datorns identitet — nätverksanslutningar, värdnycklar och allt. Det som startar upp igen är installationsguiden från första starten, redo för sin nya ägare att ange sitt eget namn, lösenord och krypteringslösenord.

Det fungerar genom att återställa den grundögonblicksbild som installationsprogrammet tar, så det är bara tillgängligt på datorer som installerats från Omarchy ISO. Och på en disk utan kryptering är en återställning radering snarare än säker radering, så om data var känsliga bör du göra en nyinstallation i stället.

## Lösenordslös sudo

Ibland vill du att `sudo` ska sluta fråga, oftast när en AI-agent gör ett långt stycke systemarbete åt dig. _Inställningar > Säkerhet > Lösenordslös sudo_ frågar hur länge åtkomst ska tillåtas: **15 minuter**, **1 timme**, **1 dag** eller **Permanent**. En röd varningsikon visas bredvid de andra indikatorerna i menyraden medan åtkomsten är aktiv. Klicka på den eller kör kommandot igen för att stänga av åtkomsten. Du kan också ange ditt eget antal minuter (från 1 till 1440) med `omarchy-sudo-passwordless 30`, eller använda `omarchy-sudo-passwordless permanent`.

Tidsbegränsad åtkomst upphör automatiskt, inklusive omedelbart efter att datorn väckts från ett viloläge som passerade tidsgränsen. Att starta om datorn avslutar den i förtid. Permanent åtkomst överlever omstarter och förblir aktiverad tills du inaktiverar den.

Att uppdatera eller ta bort Omarchys inställningspaket avslutar varje tillfälligt beviljande innan dess stöd för utgång ändras. Om kommandot rapporterar ett auktoriserings- eller rensningsfel ska du lösa det innan du försöker aktivera ett annat beviljande; ett fel betyder inte att lösenordslös åtkomst är inaktiv.

Var klarsynt med det här: medan det är påslaget kan allt som körs som din användare göra vad som helst som root utan att bli tillfrågat. Det är hela poängen, och det är också hela risken.

## Signeringsnycklar

Den publika nyckeln för alla ISO-signaturer och Omarchy-repo-paket är `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiera på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketet `omarchy/omarchy-keyring` innehåller även denna och kommer att användas för att rulla ut eventuella uppdateringar sömlöst.

Du hittar signaturen för varje ISO-utgåva genom att lägga till `.sig` i dess URL, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
