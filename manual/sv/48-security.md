# Säkerhet

Omarchy tar säkerhet extremt seriöst. Detta är avsett att vara ett operativsystem som du kan använda för att göra _Verkligt Arbete_ i den _Verkliga Världen_. Där att förlora en bärbar dator inte kan leda till en säkerhetsnödsituation. Så här är vad vi gör:

1. *Fullständig diskkryptering är obligatorisk*: Detta är det viktigaste steget för att säkra det fysiska skyddet av dina data. Om din dator försvinner eller blir stulen är data fullständigt krypterade med standard LUKS (Linux Unified Key Setup).
2. *Brandvägg är aktiverad som standard*: All inkommande trafik blockeras som standard utom för port 53317 för [LocalSend](https://localsend.org/). Till och med ssh är avstängt tills du slår på det via _Installation > Security > SSHD_, som öppnar port 22 (hastighetsbegränsad mot brute force) som en del av konfigurationen. Vi låser till och med ned Docker-åtkomst med [ufw-docker](https://github.com/chaifeng/ufw-docker)-konfigurationen för att förhindra att dina behållare av misstag exponeras mot världen.
3. *Arch har alltid de senaste uppdateringarna*: Arch, den underliggande distro som Omarchy är byggd på, är en rullande distribution. Detta betyder att alla säkerhetssårbarheter som upptäcks och patchas i något paket snabbt är tillgängliga för installation med `omarchy-update`. På så sätt kör du alltid de senaste, mest säkra versionerna av allting.
4. *Omarchy underhåller sina egna paket och spegel*: Omarchy förlitar sig endast på paket från Archs egna core/extra/multilib-repositories och sitt eget Omarchy Package Repository som standard. Du kan installera mjukvara direkt från AUR, men basinstallationen gör det inte — endast några få valfria installationer, som webbläsarna från tredje part, hämtar från AUR.
5. *Cloudflare skyddar oss från DDoS*: All Omarchys distributionsinfrastruktur — ISO:erna, Omarchy-paketen, Arch-spegeln — är skyddad bakom Cloudflares formidabla DDoS-sköld och hostad på deras CDN. Detta ger suverän tillgänglighet.

## Ändra dina lösenord

Du har två lösenord på en krypterad installation: det som låser upp enheten vid start, och det du loggar in och använder `sudo` med. Konfigurationen gör dem till samma. Båda kan ändras under _Uppdatera > Password_ i Omarchy-menyn — _Drive Encryption_ för det första, _User_ för det andra. Att ändra enhetslösenordet frågar efter det nuvarande först, så ha det till hands. Om en ändring avbryts kör du _Drive Encryption_ igen: den frågar efter lösenordet som låser upp enheten nu och slutför ändringen.

## Lämna över en dator du redan har använt

Om du lämnar över din dator till någon annan behöver du inte ominstallera den. Kör _Installation > Reset Computer_ i Omarchy-menyn, skriv `reset` för att bekräfta och starta om. Det raderar varje användarkonto och allt i `/home`, kastar bort alla paket och systemändringar du gjorde sedan installationen, och rensar datorns identitet — nätverksanslutningar, värdnycklar och allt. Det som kommer tillbaka är installationsguiden från första starten, redo för dess nya ägare att mata in sitt eget namn, lösenord och krypteringslösenord.

Det fungerar genom att återställa baslinjeögonblicksbilden som installationsprogrammet tar, så det är endast tillgängligt på datorer installerade från Omarchy ISO. Och på en enhet utan kryptering är en återställning radering snarare än en säker rensning, så om data var känsliga gör du i stället en ren installation.

## Lösenordsfritt sudo

Ibland vill du att `sudo` ska sluta fråga, oftast när en AI-agent gör en lång sträcka systemarbete åt dig. _Installation > Security > Passwordless Sudo_ frågar hur länge åtkomsten ska tillåtas: **15 minutes**, **1 Hour**, **1 Day** eller **Permanently**. En röd varningsikon visas bredvid de andra indikatorerna i menyfältet medan åtkomsten är aktiv. Klicka på den eller kör kommandot igen för att stänga av åtkomsten. Du kan också skicka in ditt eget antal minuter (från 1 till 1440) med `omarchy-sudo-passwordless 30`, eller använda `omarchy-sudo-passwordless permanent`.

Tidsbegränsad åtkomst går ut automatiskt, inklusive omedelbart efter återupptagande från ett viloläge som passerade tidsfristen. Att starta om datorn avslutar det tidigt. Permanent åtkomst överlever omstarter och förblir aktiverad tills du inaktiverar den.

Att uppdatera eller ta bort Omarchys inställningspaket avslutar varje tillfällig beviljan innan dess stöd för utgång ändras. Om kommandot rapporterar ett auktoriserings- eller rensningsfel löser du det innan du försöker aktivera en annan beviljan; ett fel betyder inte att lösenordsfri åtkomst är inaktiv.

Var klarsynt för denna: medan den är på kan allt som körs som din användare göra allt som root utan att bli tillfrågat. Det är hela poängen, och det är också hela risken.

## Signeringsnycklar

Den offentliga nyckeln för alla ISO-signaturer och Omarchy-repo-paket är `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiera på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketet `omarchy/omarchy-keyring` innehåller också detta och kommer att användas för att rulla ut eventuella uppdateringar sömlöst.

Du kan hitta signaturen för vilken ISO-version som helst genom att lägga till .sig till URL:en. Som https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
