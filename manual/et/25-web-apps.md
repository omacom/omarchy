# Veebirakendused

Saad lisada oma veebirakendusi Omarchy menüüs valiku _Install > Web App_ abil (`Super + Space`). See küsib sinult rakenduse nime, rakenduse URL-i ja ikooni URL-i, kui see ei suuda seda faviconi kaudu hankida. Paljude populaarsete veebirakenduste jaoks leiad suurepäraseid PNG-ikoone lehelt [Dashboard Icons](https://dashboardicons.com).

Need on seejärel kättesaadavad rakenduste käivitaja (`Super + Space`) kaudu ja kasutavad kaunist raamita veebirakenduse akent.

Kui soovid veebirakenduse eemaldada, mine lihtsalt Omarchy menüüs valiku _Remove > Web App_ juurde.

Kõige parem on logida kõigile oma kontodele tavalise brauseriga sisse enne veebirakenduse otseteede kasutamist. Õhuke ümbrisraam ei tööta 1passwordiga hästi, nii et lihtsalt lihtsam on kõigepealt otse sisse logida.

Kõiki nende veebirakenduste kiirklahve saab muuta failis `~/.config/hypr/bindings.lua`.

Kui oled veebirakenduses, saad kopeerida praeguse URL-i lõikelauale klahvidega `Shift + Alt + L`.

Vaikimisi on Omarchyga juba kaasas valik vaikimisi rakendusi:

## HEY

[HEY](https://www.hey.com/) on e-posti- ja kalendriteenus, mis on suurepärane alternatiiv inimestele, kes on väsinud Gmailist, Outlookist või Apple Mailist. Selle on teinud [37signals](https://37signals.com/), kust Omarchy pärineb.

HEY Emaili saad käivitada klahvidega `Super + Shift + E`, hüpata otse uue e-kirja koostamise juurde klahvidega `Super + Shift + Alt + E` ja käivitada HEY Calendari klahvidega `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) on projektijuhtimisteenus, mis aitab väikestel meeskondadel kiiremini edasi liikuda ja rohkem edusamme teha. Selle asemel, et lapida kokku Trello, Slacki, Asana, Notioni või mille iganes segu, saad Basecampiga kõik ühes kohas. Selle on teinud [37signals](https://37signals.com/), kust Omarchy pärineb.

Basecampi saad käivitada rakenduste käivitaja abil (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) on maailma populaarseim AI-vestlusrobot.

ChatGPT saad käivitada klahvidega `Super + Shift + A`.

## Grok

[Grok](https://grok.com) on xAI vestlusrobot.

Groki saad käivitada klahvidega `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) on üks maailma populaarsemaid sõnumiteenuseid ja veebiversioon on Linuxi jaoks suurepärane võimalus.

WhatsAppi saad käivitada klahvidega `Super + Shift + Alt + G`. See avaneb Omarchy WhatsApp Slim laiendusega, mis paneb selle järgima sinu teemat ja ahendab vestluste loendi, kui aken on kitsas.

## Google'i rakendused

Google Messages, Google Photos, Google Maps ja Google Contacts on kõik samuti veebirakendustena kaasas.

Google Messagesi saad käivitada klahvidega `Super + Shift + Ctrl + G`, Google Photosi klahvidega `Super + Shift + P` ja Google Mapsi klahvidega `Super + Shift + S`. Google Contacts on kättesaadav rakenduste käivitaja (`Super + Space`) kaudu.

## X

X on koht, kus uudised ilmuvad.

X-i saad käivitada klahvidega `Super + Shift + X` ja minna otse uut postitust kirjutama klahvidega `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) on maailma populaarseim videoplatvorm.

YouTube'i saad käivitada klahvidega `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) on uutel installidel veebirakendusena kaasas.

Netflixi käivitad rakenduste käivitaja abil (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) on USAs enim kasutatav videovestlussüsteem. Suurepärased ühendused üle kogu maailma. Ja 40-minutilisi koosolekuid saab pidada ilma tasulise kontota. Omarchy ümbritseb Zoomi veebikliendi ja Zoomi koosolekulinkid avanevad otse selles.

Zoomi käivitad rakenduste käivitaja abil (`Super + Space`).

## Discord

[Discord](https://discord.com/) on koht, kus enamik mängu- ja avatud lähtekoodi kogukondi koos käib, sealhulgas [Omarchy oma](https://discord.gg/tXFUdasqhY).

Discordi käivitad rakenduste käivitaja abil (`Super + Space`).

## Microsofti rakendused

Vali _Install > Service > Microsoft_, et lisada Outlook, Word, Excel, PowerPoint, Teams ja OneDrive veebirakendustena. Igal rakendusel on oma käivitaja ja see avaneb otse, kasutades kommerts Microsoft 365 URL-e ja sinu olemasolevat brauseriprofiili. Need avanevad samades brauserirakenduse akendes nagu Omarchy teised veebirakendused; need ei installi eraldi Teams for Linux klienti.

Eemalda kogum valikuga _Remove > Services > Microsoft_ või eemalda üksikud rakendused valikuga _Remove > Web App_. Saad ka _Install > Web App_ kaudu installida ainult need rakendused, mida soovid.

Valitsuse või suveräänse pilve puhul muuda URL-i vastava käivitaja `Exec=` real kaustas `~/.local/share/applications/`, näiteks failis `Microsoft Teams.desktop`, kasutades sinu organisatsiooni antud URL-i. Kirjuta sellel real iga sõnasõnaline `%` kujul `%%`. Muudatused rakenduvad järgmisel käivitamisel. Kogumi installeri uuesti käivitamine asendab selle käivitajad vaike-URL-idega.

Tööga seotud sisselogimiste eraldi hoidmiseks lisa iga käivitaja `Exec=` reale brauseri andmekataloog:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Asenda näidiskataloog enda valitud absoluutse teega ja kasuta kõigi kuue käivitaja puhul sama teed, et jagada nende vahel tööga seotud sisselogimisi. Veebirakendused kasutavad Omarchy valitud toetatud brauserit, kasutades varuvariandina Chrome'i, kui vaikebrauserit ei toetata.
