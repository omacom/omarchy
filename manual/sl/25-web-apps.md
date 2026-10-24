# Spletne aplikacije

Lastne spletne aplikacije lahko dodate z _Namesti > Spletna aplikacija_ v meniju Omarchy (`Super + Space`). Povpraša vas po imenu aplikacije, URL-ju aplikacije in URL-ju ikone, če je ne more pridobiti prek favicon. Odlične ikone PNG za številne priljubljene spletne aplikacije najdete na [Dashboard Icons](https://dashboardicons.com).

Nato bodo dostopne prek zaganjalnika aplikacij (`Super + Space`) in uporabljale lepo brezokvirno okno spletne aplikacije.

Če želite spletno aplikacijo odstraniti, pojdite v _Odstrani > Spletna aplikacija_ v meniju Omarchy.

Najbolje je, da se v vse račune prijavite v običajnem brskalniku, preden uporabite bližnjice spletnih aplikacij. Tanek ovojni okvir ne deluje dobro z 1password, zato je lažje, če ste najprej prijavljeni neposredno.

Vse tipkovne bližnjice za te spletne aplikacije lahko spremenite v `~/.config/hypr/bindings.lua`.

Ko ste v spletni aplikaciji, lahko trenutni URL kopirate v odložišče s `Shift + Alt + L`.

Privzeto Omarchy že dobavlja izbor privzetih aplikacij:

## HEY

[HEY](https://www.hey.com/) je e-poštna in koledarska storitev, ki služi kot odlična alternativa ljudem, naveličanim Gmaila, Outlooka ali Apple Maila. Izdeluje jo [37signals](https://37signals.com/), kjer je Omarchy nastal.

HEY Email lahko zaženete s `Super + Shift + E`, skočite naravnost na sestavljanje nove e-pošte s `Super + Shift + Alt + E` in zaženete HEY Calendar s `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je storitev za vodenje projektov, ki malim ekipam pomaga hitreje napredovati in narediti več. Namesto krpanja zmesi Trella, Slacka, Asane, Notiona ali česar koli že lahko imate vse na enem mestu z Basecampom. Izdeluje ga [37signals](https://37signals.com/), kjer je Omarchy nastal.

Basecamp lahko zaženete z zaganjalnikom aplikacij (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najbolj priljubljen klepetalni robot AI na svetu.

ChatGPT lahko zaženete s `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je klepetalni robot podjetja xAI.

Grok lahko zaženete s `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je ena najbolj priljubljenih storitev za sporočanje na svetu, spletna različica pa je odlična možnost za Linux.

WhatsApp lahko zaženete s `Super + Shift + Alt + G`.

## Aplikacije Google

Google Messages, Google Photos, Google Maps in Google Contacts so prav tako vključeni kot spletne aplikacije.

Google Messages lahko zaženete s `Super + Shift + Ctrl + G`, Google Photos s `Super + Shift + P` in Google Maps s `Super + Shift + S`. Google Contacts je na voljo prek zaganjalnika aplikacij (`Super + Space`).

## X

X je kraj, kjer se zgodijo novice.

X lahko zaženete s `Super + Shift + X` in greste naravnost na pisanje nove objave s `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je najbolj priljubljena videoplatforma na svetu.

YouTube lahko zaženete s `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) je najbolj priljubljen sistem za videoklepet v ZDA. Odlične povezave po vsem svetu. 40-minutna srečanja pa je mogoče izvesti brez plačljivega računa. Omarchy ovija spletni odjemalec Zooma in povezave za sestanke zoom se bodo odprle naravnost vanj.

Zoom zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Discord

[Discord](https://discord.com/) je kraj, kjer se družijo večinoma igralnih in odprtokodnih skupnosti, vključno z [lastno skupnostjo Omarchy](https://discord.gg/tXFUdasqhY).

Discord zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Aplikacije Microsoft

Izberite _Namesti > Storitev > Microsoft_, da kot spletne aplikacije dodate Outlook, Word, Excel, PowerPoint, Teams in OneDrive. Vsaka aplikacija ima svoj zaganjalnik in se odpre neposredno, pri čemer uporablja komercialne URL-je Microsoft 365 in vaš obstoječi profil brskalnika. Odprejo se v istih oknih brskalnika kot druge spletne aplikacije Omarchy; ne namestijo ločenega odjemalca Teams for Linux.

Sveženj odstranite z _Odstrani > Storitev > Microsoft_ ali posamezne aplikacije z _Odstrani > Spletna aplikacija_. Prek _Namesti > Spletna aplikacija_ lahko namestite tudi samo aplikacije, ki jih želite.

Za vladni ali suvereni oblak uredite URL v vrstici `Exec=` v ustreznem zaganjalniku pod `~/.local/share/applications/`, na primer `Microsoft Teams.desktop`, z URL-jem, ki ga je posredovala vaša organizacija. Vsak dobesedni `%` v tej vrstici zapišite kot `%%`. Spremembe začnejo veljati ob naslednjem zagonu. Ponoven zagon namestitvenega svežnja nadomesti njegove zaganjalnike s privzetimi URL-ji.

Da delovne prijave ostanejo ločene, vrstici `Exec=` vsakega zaganjalnika pripnite mapo s podatki brskalnika:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Primer mape zamenjajte z absolutno potjo po svoji izbiri in isto pot uporabite za vseh šest zaganjalnikov, da med njimi delite delovne prijave. Spletne aplikacije uporabljajo izbrani podprti brskalnik Omarchy in se zatečejo k Chromiumu, ko privzeti brskalnik ni podprt.
