# Vefforrit

Þú getur bætt við þínum eigin vefforritum með því að nota _Install > Web App_ í Omarchy-valmyndinni (`Super + Space`). Það mun biðja þig um nafn forritsins, vefslóð forritsins og vefslóð táknsins, ef það getur ekki sótt það með favicon. Þú getur fengið frábær PNG-tákn fyrir mörg vinsæl vefforrit á [Dashboard Icons](https://dashboardicons.com).

Þau verða síðan aðgengileg í gegnum forritavalmyndina (`Super + Space`) og nota fallega rammalausa vefforritsgluggann.

Ef þú vilt fjarlægja vefforrit skaltu bara fara í _Remove > Web App_ í Omarchy-valmyndinni.

Best er ef þú skráir þig inn á alla reikningana þína í venjulegum vafra áður en þú notar flýtileiðirnar fyrir vefforritin. Þunna umgjörðin virkar ekki vel með 1password, svo það er bara auðveldara að vera skráður inn beint fyrir fram.

Öllum flýtilyklum fyrir þessi vefforrit er hægt að breyta í `~/.config/hypr/bindings.lua`.

Þegar þú ert í vefforriti geturðu afritað núverandi vefslóð á klippiborðið með `Shift + Alt + L`.

Sjálfgefið fylgir Omarchy nú þegar með úrval af sjálfgefnum forritum:

## HEY

[HEY](https://www.hey.com/) er tölvupóst- og dagatalsþjónusta sem er frábær valkostur fyrir fólk sem er orðið þreytt á Gmail, Outlook eða Apple Mail. Hún er gerð af [37signals](https://37signals.com/) þar sem Omarchy á uppruna sinn.

Þú getur ræst HEY Email með `Super + Shift + E`, farið beint í að semja nýjan tölvupóst með `Super + Shift + Alt + E` og ræst HEY Calendar með `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er verkefnastjórnunarþjónusta sem hjálpar litlum teymum að vinna hraðar og ná meiri árangri. Í stað þess að setja saman óreiðu af Trello, Slack, Asana, Notion eða hvað það nú er, geturðu haft allt á einum stað með Basecamp. Það er gert af [37signals](https://37signals.com/) þar sem Omarchy á uppruna sinn.

Þú getur ræst Basecamp í gegnum forritavalmyndina (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er vinsælasta gervigreindarspjallmenni heims.

Þú getur ræst ChatGPT með `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er spjallmenni xAI.

Þú getur ræst Grok með `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er ein vinsælasta skilaboðaþjónusta heims og vefútgáfan er frábær kostur fyrir Linux.

Þú getur ræst WhatsApp með `Super + Shift + Alt + G`.

## Google-forrit

Google Messages, Google Photos, Google Maps og Google Contacts fylgja öll með sem vefforrit líka.

Þú getur ræst Google Messages með `Super + Shift + Ctrl + G`, Google Photos með `Super + Shift + P` og Google Maps með `Super + Shift + S`. Google Contacts er aðgengilegt í gegnum forritavalmyndina (`Super + Space`).

## X

X er þar sem fréttirnar berast fyrst.

Þú getur ræst X með `Super + Shift + X` og farið beint í að skrifa nýja færslu með `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er vinsælasta myndbandavettvangur heims.

Þú getur ræst YouTube með `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) er vinsælasta myndfundakerfið sem notað er í Bandaríkjunum. Frábærar tengingar um allan heim. Og hægt er að halda 40 mínútna fundi án greidds reiknings. Omarchy notar vefútgáfu Zoom sem umgjörð og Zoom-fundatenglar opnast beint í henni.

Þú ræsir Zoom í gegnum forritavalmyndina (`Super + Space`).

## Discord

[Discord](https://discord.com/) er þar sem flest leikja- og opins kóða samfélög halda sig, þar á meðal [eigið samfélag Omarchy](https://discord.gg/tXFUdasqhY).

Þú ræsir Discord í gegnum forritavalmyndina (`Super + Space`).

## Microsoft-forrit

Veldu _Install > Service > Microsoft_ til að bæta Outlook, Word, Excel, PowerPoint, Teams og OneDrive við sem vefforrit. Hvert forrit hefur sinn eigin ræsi og opnast beint, notar viðskiptaútgáfu vefslóðanna fyrir Microsoft 365 og núverandi vafrasniðið þitt. Þau opnast í sömu vafraforritsgluggum og önnur vefforrit Omarchy; þau setja ekki upp sérstaka Teams for Linux-útgáfuna.

Fjarlægðu pakkann með _Remove > Service > Microsoft_ eða fjarlægðu einstök forrit með _Remove > Web App_. Þú getur líka sett upp bara þau forrit sem þú vilt í gegnum _Install > Web App_.

Fyrir ský stjórnvalda eða fullvalda ský skaltu breyta vefslóðinni á `Exec=` línunni í viðkomandi ræsi undir `~/.local/share/applications/`, svo sem `Microsoft Teams.desktop`, og nota vefslóðina sem stofnunin þín lætur þér í té. Skrifaðu hvert bókstaflegt `%` í þeirri línu sem `%%`. Breytingarnar taka gildi við næstu ræsingu. Ef pakkauppsetningarforritið er keyrt aftur skiptir það ræsunum út fyrir sjálfgefnu vefslóðirnar.

Til að halda vinnuinnskráningum aðskildum skaltu bæta möppu fyrir vafragögn við `Exec=` línu hvers ræsis:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Skiptu dæmamöppunni út fyrir algilt slóð að eigin vali og notaðu sömu slóðina fyrir alla sex ræsana til að deila vinnuinnskráningum á milli þeirra. Vefforritin nota valinn studdan vafra Omarchy og grípa til Chrome þegar sjálfgefni vafrinn er ekki studdur.
