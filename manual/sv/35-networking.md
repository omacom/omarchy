# Nätverk

Nätverk i Omarchy hanteras av NetworkManager, och du styr det från nätverksikonen i [övre listen](05-the-top-bar.md) eller med `Super + Ctrl + N`.

Den panelen söker efter Wi-Fi-nätverk, visar signalstyrka och ansluter. Ethernet kräver ingenting alls — anslut kabeln så fungerar det. Om du hellre stannar i terminalen ger `nmtui` dig samma kontroller, och det finns också en kommandogrupp `omarchy network`.

## Dela ditt Wi-Fi

I stället för att läsa upp ett långt lösenord högt kör du _Inställningar > Nätverk > QR-kod_ medan du är på Wi-Fi. Då visas en QR-kod på skärmen som vilken telefonkamera som helst kan skanna för att ansluta. Det är en av de där sakerna du kommer att använda oftare än du tror när du väl vet att den finns där.

Om du faktiskt behöver själva lösenordet skriver `omarchy network password <interface>` ut det.

## DNS

Omarchy använder den DNS som ditt nätverk delar ut via DHCP. Du kan åsidosätta det för hela datorn under _Inställningar > Nätverk > DNS_, där Cloudflare och Google finns ett klick bort. Välj _Anpassad_ för att skriva in dina egna servrar.

Från terminalen skriver `omarchy dns` ut den aktuella leverantören och `omarchy dns Cloudflare` anger en.

## Lås Wi-Fi-bandet

Om din router lägger 2.4GHz, 5GHz och 6GHz på samma nätverksnamn kommer din bärbara dator ibland att hålla fast vid det långsamma. `omarchy network band` visar vilket band du använder, och `omarchy network band 5` låser det. Använd `auto` för att låta det välja igen.

Detta låser bandet snarare än en specifik åtkomstpunkt, så du fortsätter att roama mellan AP:er som vanligt.

## Hur snabbt går det?

_Utlösare > Hastighetstest > Nätverkshastighetstest_ mäter din faktiska hastighet upp och ner med ett par mätare. Från terminalen är det `omarchy network speedtest down` eller `up`. Det mäter mot Omarchys egen tjänst och räknar bara dess testöverföringar. Andra nedladdningar kan konkurrera om bandbredden, men de läggs inte till i hastighetstestets resultat. (Det finns ett diskhastighetstest bredvid det i den menyn, om du benchmarkar den andra flaskhalsen.)

## Brandväggen

Brandväggen är på som standard och blockerar all inkommande trafik, med ett undantag: port 53317, så att [LocalSend](22-guis.md) fungerar direkt från start.

SSH är avstängt tills du slår på det med _Inställningar > Säkerhet > SSHD_, vilket startar daemonen, öppnar port 22 med begränsning mot brute-force och auktoriserar en nyckel. Docker är också nedlåst, så att containers inte av misstag kan exponera sig själva mot omvärlden. Se [säkerhet](48-security.md) för hela historien.

## Tailscale

[Tailscale](https://tailscale.com/) är ett mesh-VPN som gör det enkelt och säkert att nå alla dina datorer och servrar över internet. Installera det med _Installera > Tjänst > Tailscale_.

Det ger dig en Tailscale-panel i listen, som ansluter till och kopplar från tailnet, byter konton och väljer en exit node — både dina egna maskiner och Mullvad-regioner dyker upp i listan. Den bläddrar också bland dina maskiner, och det är där Taildrop bor: välj en maskin och tryck på `s` för att skicka filer till den, eller `c`, `n` och `d` för att kopiera dess IP, namn eller fullständiga DNS-namn. Motsvarigheten i terminalen är `omarchy tailscale send <machine> [file...]`, och filer som skickas till dig hamnar automatiskt i `~/Downloads`. Aviseringen som meddelar en ankomst väntar tills du klickar för att öppna eller avfärdar den, så att en fil som dyker upp medan du är borta från datorn fortfarande finns där att svara på när du kommer tillbaka.

Installationen lägger också till en webbapp för Tailscales admin-konsol.

## När det slutar fungera

Innan du startar om, prova att starta om den krånglande delen för sig. _Uppdatera > Hårdvara_ har Wi-Fi, Bluetooth, Ljud och Styrplatta, och att läsa in en av dem på nytt löser de flesta "det fungerade för fem minuter sedan"-situationer. Se [felsökning](45-troubleshooting.md).
