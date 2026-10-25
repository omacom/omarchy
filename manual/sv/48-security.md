# Säkerhet

Omarchy tar säkerhet på största allvar. Det här är tänkt att vara ett operativsystem som du kan använda för att göra _Riktigt Arbete_ i _Verkliga Världen_. Där en förlorad bärbar dator inte kan leda till en säkerhetskris. Så här gör vi:

1. *Fullständig diskkryptering är obligatorisk*: Detta är det viktigaste steget för att säkra det fysiska skyddet av dina data. Om din dator försvinner eller blir stulen är data fullständigt krypterad med standarden LUKS (Linux Unified Key Setup).
2. *Brandväggen är aktiverad som standard*: All inkommande trafik blockeras som standard förutom port 53317 för [LocalSend](https://localsend.org/). Till och med ssh är avstängt tills du slår på det via _Konfiguration > Säkerhet > SSHD_, vilket öppnar port 22 (med frekvensbegränsning mot brute-force-attacker) som en del av konfigurationen. Vi låser till och med ner Docker-åtkomst med [ufw-docker](https://github.com/chaifeng/ufw-docker)-konfigurationen för att förhindra att dina containrar av misstag exponeras mot omvärlden.
3. *Arch har alltid de senaste uppdateringarna*: Arch, den underliggande distribution som Omarchy bygger på, är en rullande distribution. Det betyder att varje säkerhetssårbarhet som upptäcks och åtgärdas i något paket snabbt finns tillgänglig att installera med `omarchy-update`. På så sätt kör du alltid de senaste, säkraste versionerna av allting.
4. *Omarchy underhåller sina egna paket och sin egen spegel*: Omarchy förlitar sig som standard bara på paket från Archs egna core/extra/multilib-förråd och sitt eget Omarchy Package Repository. Du kan installera programvara direkt från AUR, men basinstallationen gör det inte — bara några få valfria installationer, som webbläsare från tredje part, hämtar från AUR.
5. *Cloudflare skyddar oss mot DDoS*: Omarchys distributionsinfrastruktur — ISO-filerna, Omarchy-paketen, Arch-spegeln — skyddas bakom Cloudflares formidabla DDoS-skydd och driftas på deras CDN. Det ger utmärkt tillgänglighet.

## Ändra dina lösenord

Du har två lösenord på en krypterad installation: det som låser upp disken vid uppstart, och det som du loggar in och använder `sudo` med. Konfigurationen gör dem till samma. Båda kan ändras under _Uppdatera > Lösenord_ i Omarchy-menyn — _Diskkryptering_ för det första, _Användare_ för det andra. För att ändra diskens lösenord behöver du först ange det nuvarande, så ha det till hands. Om en ändring avbryts kör du _Diskkryptering_ igen: den frågar efter lösenordet som låser upp disken nu och slutför ändringen.

## Lämna vidare en dator du redan har använt

Om du ska lämna över din dator till någon annan behöver du inte installera om den. Kör _Konfiguration > Återställ datorn_ i Omarchy-menyn, skriv `reset` för att bekräfta, och starta om. Det raderar varje användarkonto och allt i `/home`, kastar bort alla paket och systemändringar du har gjort sedan installationen, och rensar datorns identitet — nätverksanslutningar, värdnycklar och allt. Det som startar upp igen är installationsguiden från första uppstarten, redo för den nya ägaren att ange sitt eget namn, lösenord och krypteringslösenord.

Det fungerar genom att återställa den baslinjeögonblicksbild som installationsprogrammet tar, så det är bara tillgängligt på datorer som installerats från Omarchy-ISO:n. Och på en disk utan kryptering är en återställning en radering snarare än en säker radering, så om datan var känslig bör du göra en nyinstallation i stället.

## sudo utan lösenord

Ibland vill du att `sudo` ska sluta fråga, oftast när en AI-agent gör ett långt stycke systemarbete åt dig. _Konfiguration > Säkerhet > sudo utan lösenord_ frågar hur länge åtkomst ska tillåtas: **15 minuter**, **1 timme**, **1 dag**, eller **Permanent**. En röd varningsikon visas bredvid de andra indikatorerna i menyraden medan åtkomsten är aktiv. Klicka på den eller kör kommandot igen för att stänga av åtkomsten. Du kan också ange ditt eget antal minuter (från 1 till 1440) med `omarchy-sudo-passwordless 30`, eller använda `omarchy-sudo-passwordless permanent`.

Tidsbegränsad åtkomst upphör automatiskt, även omedelbart efter att datorn återupptagits från ett viloläge som passerade tidsgränsen. Att starta om datorn avslutar den i förtid. Permanent åtkomst överlever omstarter och förblir aktiverad tills du inaktiverar den.

Att uppdatera eller ta bort Omarchys inställningspaket avslutar alla tillfälliga beviljanden innan stödet för deras utgång ändras. Om kommandot rapporterar ett fel med auktorisering eller upprensning ska du lösa det innan du försöker aktivera ett annat beviljande; ett fel betyder inte att åtkomsten utan lösenord är inaktiv.

Var klarsynt med det här: medan det är på kan allt som körs som din användare göra vad som helst som root utan att bli tillfrågat. Det är hela poängen, och det är också hela risken.

## Signeringsnycklar

Den offentliga nyckeln för alla ISO-signaturer och Omarchy-repo-paket är `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiera på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketet `omarchy/omarchy-keyring` innehåller också den här och kommer att användas för att rulla ut eventuella uppdateringar sömlöst.

Du hittar signaturen för varje ISO-utgåva genom att lägga till .sig i URL:en. Som https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
