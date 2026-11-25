# Spletne aplikacije

Svoje spletne aplikacije lahko dodate z _Install > Web App_ v meniju Omarchy (`Super + Space`). Vprašal vas bo za ime aplikacije, URL aplikacije in URL ikone, če je ne more pridobiti prek favicon. Odlične ikone PNG za številne priljubljene spletne aplikacije lahko dobite na [Dashboard Icons](https://dashboardicons.com).

Nato bodo dostopne prek zaganjalnika aplikacij (`Super + Space`) in bodo uporabljale čudovito okno spletne aplikacije brez okvirja.

Če želite spletno aplikacijo odstraniti, preprosto pojdite na _Remove > Web App_ v meniju Omarchy.

Najbolje je, da se v vse svoje račune prijavite z običajnim brskalnikom, preden uporabite bližnjice spletnih aplikacij. Tanek ovojni okvir ne deluje dobro z 1password, zato je preprosteje, če ste že neposredno prijavljeni.

Vse bližnjice na tipkovnici za te spletne aplikacije lahko spremenite v `~/.config/hypr/bindings.lua`.

Ko ste v spletni aplikaciji, lahko trenutni URL kopirate v odložišče z `Shift + Alt + L`.

Omarchy privzeto že vsebuje izbor privzetih aplikacij:

## HEY

[HEY](https://www.hey.com/) je storitev za e-pošto in koledar, ki je odlična alternativa za ljudi, ki imajo dovolj Gmail, Outlook ali Apple Mail. Razvija ga [37signals](https://37signals.com/), od koder izvira Omarchy.

HEY Email lahko zaženete z `Super + Shift + E`, z `Super + Shift + Alt + E` skočite naravnost na sestavljanje novega e-poštnega sporočila, HEY Calendar pa zaženete z `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je storitev za upravljanje projektov, ki majhnim ekipam pomaga delati hitreje in doseči večji napredek. Namesto da skupaj krpate zmešnjavo Trello, Slack, Asana, Notion ali česar koli drugega, lahko z Basecamp vse to imate na enem mestu. Razvija ga [37signals](https://37signals.com/), od koder izvira Omarchy.

Basecamp lahko zaženete z zaganjalnikom aplikacij (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najbolj priljubljen klepetalni robot z umetno inteligenco na svetu.

ChatGPT lahko zaženete z `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je klepetalni robot podjetja xAI.

Grok lahko zaženete z `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je ena najbolj priljubljenih storitev za sporočanje na svetu in spletna različica je odlična možnost za Linux.

WhatsApp lahko zaženete z `Super + Shift + Alt + G`. Odpre se z razširitvijo WhatsApp Slim za Omarchy, zaradi katere sledi vaši temi in strne seznam klepetov, ko je okno ozko.

## Googlove aplikacije

Google Messages, Google Photos, Google Maps in Google Contacts so prav tako vključeni kot spletne aplikacije.

Google Messages lahko zaženete z `Super + Shift + Ctrl + G`, Google Photos z `Super + Shift + P`, Google Maps pa z `Super + Shift + S`. Google Contacts je na voljo prek zaganjalnika aplikacij (`Super + Space`).

## X

X je kraj, kjer novice izbruhnejo.

X lahko zaženete z `Super + Shift + X` in z `Super + Shift + Alt + X` pojdite naravnost na pisanje nove objave.

## YouTube

[YouTube](https://youtube.com/) je najbolj priljubljena video platforma na svetu.

YouTube lahko zaženete z `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) je pri novih namestitvah vključen kot spletna aplikacija.

Netflix zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) je najbolj priljubljen sistem za video klepet, ki se uporablja v ZDA. Odlične povezave po vsem svetu. In 40-minutne sestanke lahko imate brez plačljivega računa. Omarchy ovije spletni odjemalec Zoom in povezave do sestankov Zoom se bodo odprle naravnost vanj.

Zoom zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Discord

[Discord](https://discord.com/) je kraj, kjer se druži večina igralniških in odprtokodnih skupnosti, vključno z [Omarchyjevo lastno](https://discord.gg/tXFUdasqhY).

Discord zaženete z zaganjalnikom aplikacij (`Super + Space`).

## Microsoftove aplikacije

Izberite _Install > Service > Microsoft_, da dodate Outlook, Word, Excel, PowerPoint, Teams in OneDrive kot spletne aplikacije. Vsaka aplikacija ima svoj zaganjalnik in se odpre neposredno, pri čemer uporablja komercialne URL-je Microsoft 365 in vaš obstoječi profil brskalnika. Odprejo se v istih oknih aplikacij brskalnika kot druge spletne aplikacije Omarchy; ne namestijo ločenega odjemalca Teams for Linux.

Paket odstranite z _Remove > Services > Microsoft_ ali pa posamezne aplikacije odstranite z _Remove > Web App_. Prek _Install > Web App_ lahko namestite tudi samo aplikacije, ki jih želite.

Za vladni ali suvereni oblak uredite URL v vrstici `Exec=` v ustreznem zaganjalniku pod `~/.local/share/applications/`, na primer `Microsoft Teams.desktop`, pri čemer uporabite URL, ki ga je zagotovila vaša organizacija. Vsak dobesedni `%` v tej vrstici zapišite kot `%%`. Spremembe začnejo veljati ob naslednjem zagonu. Če znova zaženete namestitveni program paketa, bo njegove zaganjalnike zamenjal s privzetimi URL-ji.

Če želite službene prijave ohraniti ločene, vsaki vrstici `Exec=` zaganjalnika pripnite imenik s podatki brskalnika:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Imenik iz primera zamenjajte z absolutno potjo po lastni izbiri in isto pot uporabite za vseh šest zaganjalnikov, da bodo službene prijave med njimi skupne. Spletne aplikacije uporabljajo izbrani podprti brskalnik Omarchy, če pa privzeti brskalnik ni podprt, se vrnejo na Chrome.
