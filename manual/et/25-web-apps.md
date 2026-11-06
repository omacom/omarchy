# Veebirakendused

Saad lisada oma veebirakendusi, kasutades Omarchy menüüs (`Super + Space`) jaotist _Paigalda > Web App_. See küsib rakenduse nime, rakenduse URL-i ja ikooni URL-i, kui see ei saa seda faviconi kaudu kätte. Paljud populaarsed veebirakendused saavad suurepäraseid PNG ikoone saidil [Dashboard Icons](https://dashboardicons.com).

Seejärel on neile juurdepääs rakenduste käivitaja (`Super + Space`) kaudu ja need kasutavad kaunist raamita veebirakenduse akent.

Kui soovid veebirakenduse eemaldada, mine lihtsalt Omarchy menüüs jaotisesse _Eemalda > Web App_.

Parim on, kui logid kõigile oma kontodele sisse tavalise brauseriga enne veebirakenduste otseteede kasutamist. Õhuke mähisraam ei tööta 1passwordiga hästi, nii et lihtsam on kõigepealt otse sisse logida.

Kõiki nende veebirakenduste klaviatuuri kiirklahve saab muuta failis `~/.config/hypr/bindings.lua`.

Kui oled veebirakenduses, saad praeguse URL-i lõikelauale kopeerida kombinatsiooniga `Shift + Alt + L`.

Vaikimisi tuleb Omarchy juba valiku vaikerakendustega:

## HEY

[HEY](https://www.hey.com/) on e-posti ja kalenderiteenus, mis on suurepärane alternatiiv inimestele, kes on väsinud Gmailist, Outlookist või Apple Mailist. Selle on teinud [37signals](https://37signals.com/), kust Omarchy pärit on.

HEY Emaili saad käivitada kombinatsiooniga `Super + Shift + E`, hüpata otse uue e-kirja koostamise juurde kombinatsiooniga `Super + Shift + Alt + E` ja käivitada HEY Calendari kombinatsiooniga `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) on projektijuhtimisteenus, mis aitab väikestel meeskondadel kiiremini liikuda ja rohkem edusamme teha. Selle asemel, et kokku lapida Trello, Slacki, Asana, Notioni või mille iganes segu, saad Basecampiga kõik ühes kohas. Selle on teinud [37signals](https://37signals.com/), kust Omarchy pärit on.

Basecampi saad käivitada rakenduste käivitaja abil (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) on maailma populaarseim AI vestlusrobot.

ChatGPT saad käivitada kombinatsiooniga `Super + Shift + A`.

## Grok

[Grok](https://grok.com) on xAI vestlusrobot.

Groki saad käivitada kombinatsiooniga `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) on üks maailma populaarsemaid sõnumiteenuseid ja veebiversioon on Linuxi jaoks suurepärane valik.

WhatsAppi saad käivitada kombinatsiooniga `Super + Shift + Alt + G`.

## Google'i rakendused

Google Messages, Google Photos, Google Maps ja Google Contacts on kõik samuti veebirakendustena kaasas.

Google Messages'i saad käivitada kombinatsiooniga `Super + Shift + Ctrl + G`, Google Photosi kombinatsiooniga `Super + Shift + P` ja Google Mapsi kombinatsiooniga `Super + Shift + S`. Google Contacts on saadaval rakenduste käivitaja kaudu (`Super + Space`).

## X

X on koht, kus uudised purunevad.

X saad käivitada kombinatsiooniga `Super + Shift + X` ja minna otse uue postituse kirjutamise juurde kombinatsiooniga `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) on maailma populaarseim videoplatvorm.

YouTube'i saad käivitada kombinatsiooniga `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) on USA-s kõige populaarsem videovestlussüsteem. Suurepärased ühendused üle kogu maailma. Ja 40-minutilisi koosolekuid saab pidada ilma tasulise kontota. Omarchy mähib Zoomi veebikliendi ja zoomi koosolekulinkid avanevad otse sellesse.

Zoomi käivitad rakenduste käivitaja abil (`Super + Space`).

## Discord

[Discord](https://discord.com/) on koht, kus enamik mängude ja avatud lähtekoodi kogukondi aega veedab, sealhulgas [Omarchy enda oma](https://discord.gg/tXFUdasqhY).

Discordi käivitad rakenduste käivitaja abil (`Super + Space`).

## Microsofti rakendused

Vali _Paigalda > Service > Microsoft_, et lisada Outlook, Word, Excel, PowerPoint, Teams ja OneDrive veebirakendustena. Igal rakendusel on oma käivitaja ja see avaneb otse, kasutades ärilisi Microsoft 365 URL-e ja sinu olemasolevat brauseriprofiili. Need avanevad samades brauseri rakenduse akendes nagu Omarchy teised veebirakendused; nad ei paigalda eraldi Teams for Linux klienti.

Eemalda pakett jaotisega _Eemalda > Service > Microsoft_ või eemalda üksikud rakendused jaotisega _Eemalda > Web App_. Saad paigaldada ka ainult soovitud rakendused jaotise _Paigalda > Web App_ kaudu.

Valitsuse või suveräänse pilve jaoks redigeeri URL-i real `Exec=` asjakohases käivitajas kaustas `~/.local/share/applications/`, näiteks `Microsoft Teams.desktop`, kasutades oma organisatsiooni antud URL-i. Kirjuta iga sõnasõnaline `%` sellel real kujul `%%`. Muudatused kehtivad järgmisel käivitamisel. Paketi paigaldaja uuesti käivitamine asendab selle käivitajad vaike-URL-idega.

Tööalaste sisselogimiste eraldi hoidmiseks lisa iga käivitaja reale `Exec=` brauseri andmekaust:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Asenda näidiskaust oma valitud absoluutse teega ja kasuta kõigis kuues käivitajas sama teed, et jagada tööalaseid sisselogimisi nende vahel. Veebirakendused kasutavad Omarchy valitud toetatud brauserit, taandudes Chromiumile, kui vaikebrauser pole toetatud.
