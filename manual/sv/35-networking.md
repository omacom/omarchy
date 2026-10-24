# Nätverk

Nätverket i Omarchy hanteras av NetworkManager, och du styr det från nätverksikonen i [menyfältet](05-the-top-bar.md) eller med `Super + Ctrl + W`.

Den panelen söker efter Wi-Fi-nätverk, visar signalstyrka och ansluter. Ethernet kräver ingenting alls — koppla in kabeln så fungerar det. Om du hellre stannar i terminalen ger `nmtui` dig samma kontroller, och det finns också en kommandogrupp med `omarchy network`.

## Dela ditt Wi-Fi

I stället för att läsa upp ett långt lösenord högt kör du _Installation > Nätverk > QR-kod_ medan du är på Wi-Fi. Då visas en QR-kod på skärmen som vilken telefonkamera som helst kan skanna för att ansluta. Det är en av de där sakerna du kommer att använda oftare än du tror när du väl vet att den finns där.

Om du faktiskt behöver själva lösenordet skriver `omarchy network password <interface>` ut det.

## DNS

Omarchy använder den DNS som ditt nätverk delar ut via DHCP. Du kan åsidosätta det för hela datorn under _Installation > Nätverk > DNS_, där Cloudflare och Google finns ett klick bort. Välj _Anpassad_ för att skriva in dina egna servrar.

Från terminalen skriver `omarchy dns` ut den aktuella leverantören och `omarchy dns Cloudflare` anger en.

## Låsa Wi-Fi-band

Om din router lägger 2,4GHz, 5GHz och 6GHz på samma nätverksnamn kommer din bärbara dator ibland att hålla fast vid det långsamma. `omarchy network band` visar vilket band du är på, och `omarchy network band 5` låser det. Använd `auto` för att låta det välja igen.

Detta låser bandet snarare än en specifik åtkomstpunkt, så du fortsätter att roama mellan åtkomstpunkter som vanligt.

## Hur snabbt går det?

_Utlös > Hastighetstest > Nätverkshastighetstest_ mäter din faktiska upp- och nedladdningshastighet med ett par mätare. Från terminalen är det `omarchy network speedtest down` eller `up`. (Det finns ett diskhastighetstest bredvid i den menyn, om du mäter den andra flaskhalsen.)

## Brandväggen

Brandväggen är på som standard och blockerar all inkommande trafik, med ett undantag: port 53317, så att [LocalSend](22-guis.md) fungerar direkt.

SSH är avstängt tills du slår på det med _Installation > Security > SSHD_, som startar demonen, öppnar port 22 med hastighetsbegränsning mot brute force och auktoriserar en nyckel. Docker är också låst, så behållare inte kan exponera sig själva mot världen av misstag. Se [säkerhet](48-security.md) för hela historien.

## Tailscale

[Tailscale](https://tailscale.com/) är ett mesh-VPN som gör det enkelt och säkert att nå alla dina datorer och servrar över internet. Installera det med _Installera > Service > Tailscale_.

Det ger dig en Tailscale-panel i fältet, som ansluter och kopplar från tailnet, byter konto och väljer en exit-nod — både dina egna datorer och Mullvad-regioner visas i listan. Det bläddrar också bland dina datorer, och det är där Taildrop bor: välj en dator och tryck på `s` för att skicka filer till den, eller `c`, `n` och `d` för att kopiera dess IP, namn eller fullständiga DNS-namn. Terminalmotsvarigheten är `omarchy tailscale send <machine> [file...]`, och filer som skickas till dig hamnar automatiskt i `~/Downloads`. Aviseringen som meddelar en ankomst väntar tills du klickar upp den eller avvisar den, så en fil som dyker upp medan du är borta från datorn finns fortfarande kvar att svara på när du kommer tillbaka.

Installeringen lägger också till en webbapp för Tailscales administratörskonsol.

## När det slutar fungera

Innan du startar om, prova att starta om den felande delen på egen hand. Under _Uppdatera > Hardware_ finns Wi-Fi, Bluetooth, Audio och Trackpad, och att ladda om en av dem löser de flesta ”det fungerade för fem minuter sedan”-situationer. Se [felsökning](45-troubleshooting.md).
