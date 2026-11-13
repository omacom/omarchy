# Veebirakendused

Saad lisada oma veebirakendusi Omarchy menüü _Install > Web App_ kaudu (`Super + Space`). See küsib sinult rakenduse nime, rakenduse URL-i ja ikooni URL-i, kui ta ei suuda seda faviconi kaudu hankida. Paljude populaarsete veebirakenduste jaoks saad suurepäraseid PNG-ikoone lehelt [Dashboard Icons](https://dashboardicons.com).

Seejärel pääsed neile ligi rakenduste käivitaja (`Super + Space`) kaudu ja need kasutavad kaunist raamita veebirakenduse akent.

Kui soovid veebirakenduse eemaldada, mine lihtsalt Omarchy menüüs valiku _Remove > Web App_ juurde.

Kõige parem on, kui logid kõikidele oma kontodele sisse tavalise brauseriga, enne kui veebirakenduste otseteid kasutad. See õhuke ümbrisraam ei tööta 1passwordiga hästi, nii et lihtsalt kergem on enne otse sisse logida.

Kõiki nende veebirakenduste kiirklahve saab muuta failis `~/.config/hypr/bindings.lua`.

Kui oled veebirakenduses, saad kopeerida praeguse URL-i lõikelauale klahvidega `Shift + Alt + L`.

Vaikimisi on Omarchyga juba kaasas valik vaikimisi rakendusi:

## HEY

[HEY](https://www.hey.com/) on e-posti ja kalendri teenus, mis on suurepärane alternatiiv inimestele, kellel on Gmailist, Outlookist või Apple Mailist kõrini. Selle on teinud [37signals](https://37signals.com/), kust Omarchy alguse sai.

HEY Emaili saad käivitada klahvidega `Super + Shift + E`, hüpata otse uue e-kirja koostamise juurde klahvidega `Super + Shift + Alt + E` ja käivitada HEY Calendari klahvidega `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) on projektijuhtimise teenus, mis aitab väikestel meeskondadel kiiremini edasi liikuda ja rohkem ära teha. Selle asemel, et lappida kokku mingi segapudru Trellost, Slackist, Asanast, Notionist või millest iganes, saad Basecampiga kõik ühes kohas. Selle on teinud [37signals](https://37signals.com/), kust Omarchy alguse sai.

Basecampi saad käivitada rakenduste käivitaja abil (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) on maailma kõige populaarsem AI vestlusrobot.

ChatGPT saad käivitada klahvidega `Super + Shift + A`.

## Grok

[Grok](https://grok.com) on xAI vestlusrobot.

Groki saad käivitada klahvidega `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) on üks maailma populaarsemaid sõnumiteenuseid ja veebiversioon on Linuxi jaoks suurepärane valik.

WhatsAppi saad käivitada klahvidega `Super + Shift + Alt + G`.

## Google'i rakendused

Google Messages, Google Photos, Google Maps ja Google Contacts on kõik samuti veebirakendustena kaasas.

Google Messages saad käivitada klahvidega `Super + Shift + Ctrl + G`, Google Photos klahvidega `Super + Shift + P` ja Google Mapsi klahvidega `Super + Shift + S`. Google Contacts on saadaval rakenduste käivitaja kaudu (`Super + Space`).

## X

X on koht, kus uudised esimesena puhkevad.

X-i saad käivitada klahvidega `Super + Shift + X` ja minna otse uut postitust kirjutama klahvidega `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) on maailma kõige populaarsem videoplatvorm.

YouTube'i saad käivitada klahvidega `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) on USAs kõige populaarsem videovestlussüsteem. Suurepärased ühendused üle kogu maailma. Ja 40-minutilisi koosolekuid saab pidada ka ilma tasulise kontota. Omarchy kasutab Zoomi veebiklienti ja zoomi koosolekute lingid avanevad otse selles.

Zoomi käivitad rakenduste käivitaja abil (`Super + Space`).

## Discord

[Discord](https://discord.com/) on koht, kus enamik mängu- ja avatud lähtekoodiga kogukondi koos käib, sealhulgas [Omarchy oma](https://discord.gg/tXFUdasqhY).

Discordi käivitad rakenduste käivitaja abil (`Super + Space`).

## Microsofti rakendused

Vali _Install > Service > Microsoft_, et lisada Outlook, Word, Excel, PowerPoint, Teams ja OneDrive veebirakendustena. Igal rakendusel on oma käivitaja ja see avaneb otse, kasutades kommertslikke Microsoft 365 URL-e ja sinu olemasolevat brauseri profiili. Need avanevad samades brauserirakenduse akendes nagu Omarchy teised veebirakendused; need ei installi eraldi Teams for Linux klienti.

Eemalda pakett valikuga _Remove > Service > Microsoft_ või eemalda üksikud rakendused valikuga _Remove > Web App_. Samuti saad installida ainult need rakendused, mida tahad, valiku _Install > Web App_ kaudu.

Valitsus- või suveräänse pilve jaoks muuda vastava käivitaja `Exec=` real olevat URL-i kataloogis `~/.local/share/applications/`, näiteks failis `Microsoft Teams.desktop`, kasutades sinu organisatsiooni antud URL-i. Kirjuta sellel real iga sõnasõnaline `%` kujul `%%`. Muudatused rakenduvad järgmisel käivitamisel. Paketi installeri uuesti käivitamine asendab selle käivitajad vaike-URL-idega.

Tööga seotud sisselogimiste eraldi hoidmiseks lisa iga käivitaja `Exec=` reale brauseri andmete kataloog:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Asenda näidiskataloog enda valitud absoluutse teega ja kasuta kõigi kuue käivitaja puhul sama teed, et jagada nende vahel tööga seotud sisselogimisi. Veebirakendused kasutavad Omarchy valitud toetatud brauserit, minnes varuvariandina Chrome'i peale, kui vaikebrauserit ei toetata.
