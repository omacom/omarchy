# Kommersiella appar/tjänster

Omarchy fokuserar mest på att tillhandahålla fri programvara med öppen källkod, men det är inte religiöst på den punkten. Ibland är den bästa lösningen ett kommersiellt erbjudande, och det är helt okej. Här är några av alternativen som vi gör det enkelt att installera.

## 1Password

Att förvara dina lösenord i en lösenordshanterare är bästa praxis. Dubbelt så om du arbetar i ett team. Och [1password](https://1password.com/) är en utmärkt lösning, som också kommer med ett kommandoradsverktyg för att integrera nyckeluppslagningar i skript.

Du startar 1Password med `Super + Shift + /`. Om det inte är installerat ännu drar det kortkommandot igång installationen först (du kan också använda _Install > Service > 1Password_ från Omarchy-menyn). Installationsprogrammet tar också med 1Password-kommandoradsverktyget och konfigurerar 1Password-tillägget för Chrome och Chromium; starta om webbläsaren för att läsa in det.

## Bitwarden

[Bitwarden](https://bitwarden.com/) är alternativet med öppen källkod bland lösenordshanterarna, med en gratisnivå som täcker de flesta personliga behov. Installera det med _Install > Service > Bitwarden_ från Omarchy-menyn, vilket också tar med Bitwardens kommandoradsverktyg.

## Spotify

[Spotify](https://spotify.com/) är världens mest populära tjänst för strömmande musik. Omarchy levererar den som en webbapp, vilket ger dig den fullständiga spelaren, mediaknappar och Spotify Connect, men inte nedladdningar offline. Starta den med `Super + Shift + M`.

## Slack

[Slack](https://slack.com/) är där många team chattar, både inom företaget och med externa samarbetspartner. Installera det med _Install > Service > Slack_ från Omarchy-menyn, så öppnas det så snart det är klart.

## Notion

[Notion](https://www.notion.com/) är en arbetsyta för anteckningar, dokument och projekt. Installera dess skrivbordsapp med _Install > Service > Notion_ från Omarchy-menyn.

## Dropbox

[Dropbox](https://www.dropbox.com/) är ett utmärkt sätt att synkronisera filer mellan maskiner samtidigt som du har en säkerhetskopia i molnet. För att konfigurera det väljer du _Install > Service > Dropbox_ från Omarchy-menyn. Det lägger till en Dropbox-ikon i panelen: klicka på den för att logga in, och använd sedan samma panel för att kontrollera ditt lagringsutrymme och öppna nyligen synkroniserade filer.

## Tailscale

[Tailscale](https://tailscale.com/) är ett mesh-VPN som gör det superenkelt att säkert komma åt alla dina datorer och servrar via internet. För att konfigurera det väljer du _Install > Service > Tailscale_ från Omarchy-menyn.

Det får en panel i fältet, en webbapp för administrationskonsolen och Taildrop för att skicka filer mellan dina maskiner — se [nätverk](35-networking.md).

## ONCE

[ONCE](https://once.com/) är 37signals serie av programvara som du köper en gång och kör på din egen server, som chattsystemet Campfire. Välj _Install > Service > ONCE_ från Omarchy-menyn för att installera det, vilket aktiverar dess bakgrundstjänst och släpper in dig i ONCE-terminalgränssnittet för att ta det därifrån.

## NordVPN

[NordVPN](https://nordvpn.com/) är en standard-VPN-tjänst som låter dig låta din trafik gå ut från de flesta regioner runt om i världen. För att konfigurera det väljer du _Install > Service > NordVPN_ från Omarchy-menyn. Efter den omstart som den ber om kör du `nordvpn login` för att autentisera dig.
