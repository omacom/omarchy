# Spletne aplikacije

Svoje spletne aplikacije lahko dodate z _Install > Web App_ v meniju Omarchy (`Super + Space`). Vprašalo vas bo po imenu aplikacije, URL-ju aplikacije in URL-ju ikone, če je ne more pridobiti prek favicon. Odlične ikone PNG za številne priljubljene spletne aplikacije lahko dobite na [Dashboard Icons](https://dashboardicons.com).

Nato bodo dostopne prek zaganjalnika aplikacij (`Super + Space`) in bodo uporabljale čudovito okno spletne aplikacije brez okvirja.

Če želite odstraniti spletno aplikacijo, preprosto pojdite na _Remove > Web App_ v meniju Omarchy.

Najbolje je, da se v vse svoje račune prijavite z običajnim brskalnikom, preden uporabite bližnjice spletnih aplikacij. Tanek okvir ovojalnice ne deluje dobro z 1password, zato se je preprosto lažje najprej prijaviti neposredno.

Vse bližnjice na tipkovnici za te spletne aplikacije lahko spremenite v `~/.config/hypr/bindings.lua`.

Ko ste v spletni aplikaciji, lahko trenutni URL kopirate v odložišče z `Shift + Alt + L`.

Omarchy privzeto že vključuje izbor privzetih aplikacij:

## HEY

[HEY](https://www.hey.com/) je storitev za e-pošto in koledar, ki je odlična alternativa za ljudi, naveličane Gmail, Outlook ali Apple Mail. Izdeluje jo [37signals](https://37signals.com/), kjer je Omarchy nastal.

HEY Email lahko zaženete z `Super + Shift + E`, skočite naravnost na sestavljanje nove e-pošte z `Super + Shift + Alt + E` in zaženete HEY Calendar z `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je storitev za vodenje projektov, ki majhnim ekipam pomaga delati hitreje in doseči večji napredek. Namesto da skupaj lepite mešanico Trello, Slack, Asana, Notion ali česarkoli že, lahko imate z Basecamp vse na enem mestu. Izdeluje jo [37signals](https://37signals.com/), kjer je Omarchy nastal.

Basecamp lahko zaženete z zaganjalnikom aplikacij (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najbolj priljubljen klepetalni robot z umetno inteligenco na svetu.

ChatGPT lahko zaženete z `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je klepetalni robot podjetja xAI.

Grok lahko zaženete z `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je ena najbolj priljubljenih storitev za sporočanje na svetu, spletna različica pa je odlična možnost za Linux.

WhatsApp lahko zaženete z `Super + Shift + Alt + G`.

## Googlove aplikacije

Google Messages, Google Photos, Google Maps in Google Contacts so prav tako vključeni kot spletne aplikacije.

Google Messages lahko zaženete z `Super + Shift + Ctrl + G`, Google Photos z `Super + Shift + P` in Google Maps z `Super + Shift + S`. Google Contacts je na voljo prek zaganjalnika aplikacij (`Super + Space`).

## X

X je kraj, kjer novice izbruhnejo.

X lahko zaženete z `Super + Shift + X` in greste naravnost na pisanje nove objave z `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je najbolj priljubljena video platforma na svetu.

YouTube lahko zaženete z `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) je najbolj priljubljen sistem za video klepet, ki se uporablja v ZDA. Odlične povezave po vsem svetu. In 40-minutne sestanke lahko izvedete brez plačljivega računa. Omarchy ovije spletnega odjemalca Zoom, povezave do sestankov Zoom pa se bodo odprle naravnost vanj.

Zoom zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Discord

[Discord](https://discord.com/) je kraj, kjer se druži večina igralnih in odprtokodnih skupnosti, vključno z [Omarchyjevo lastno](https://discord.gg/tXFUdasqhY).

Discord zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Microsoftove aplikacije

Izberite _Install > Service > Microsoft_, da dodate Outlook, Word, Excel, PowerPoint, Teams in OneDrive kot spletne aplikacije. Vsaka aplikacija ima svoj zaganjalnik in se odpre neposredno, pri čemer uporablja komercialne URL-je Microsoft 365 in vaš obstoječi profil brskalnika. Odprejo se v istih oknih aplikacij brskalnika kot druge spletne aplikacije Omarchy; ne namestijo ločenega odjemalca Teams for Linux.

Paket odstranite z _Remove > Service > Microsoft_ ali odstranite posamezne aplikacije z _Remove > Web App_. Prek _Install > Web App_ lahko namestite tudi samo aplikacije, ki jih želite.

Za vladni ali suvereni oblak uredite URL v vrstici `Exec=` v ustreznem zaganjalniku pod `~/.local/share/applications/`, na primer `Microsoft Teams.desktop`, pri čemer uporabite URL, ki ga zagotovi vaša organizacija. Vsak dobesedni `%` v tej vrstici zapišite kot `%%`. Spremembe začnejo veljati ob naslednjem zagonu. Če namestitveni program paketa zaženete znova, bo njegove zaganjalnike zamenjal s privzetimi URL-ji.

Če želite službene prijave ohraniti ločene, vsaki vrstici `Exec=` zaganjalnika dodajte imenik s podatki brskalnika:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Imenik primera zamenjajte z absolutno potjo po svoji izbiri in isto pot uporabite za vseh šest zaganjalnikov, da bodo službene prijave med njimi deljene. Spletne aplikacije uporabljajo izbrani podprti brskalnik Omarchy, pri čemer uporabijo Chrome kot nadomestno možnost, kadar privzeti brskalnik ni podprt.
