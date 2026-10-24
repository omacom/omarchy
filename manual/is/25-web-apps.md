# Vefforrit

Þú getur bætt við þínum eigin vefforritum með _Setja upp > Vefforrit_ í Omarchy-valmyndinni (`Super + Space`). Það mun biðja þig um nafn forritsins, vefslóð forritsins og vefslóð táknsins, ef það getur ekki sótt það með favicon. Þú getur fengið frábær PNG-tákn fyrir mörg vinsæl vefforrit á [Dashboard Icons](https://dashboardicons.com).

Þau verða þá aðgengileg í gegnum forritaræsinn (`Super + Space`), og nota fallega rammalausa vefforritsgluggann.

Ef þú vilt fjarlægja vefforrit skaltu bara fara í _Fjarlægja > Vefforrit_ í Omarchy-valmyndinni.

Það er best ef þú skráir þig inn á alla reikningana þína með venjulegum vafra áður en þú notar vefforritsflýtileiðirnar. Þunni umbúðaramminn virkar ekki vel með 1password, þannig að það er bara auðveldara að vera skráður inn beint fyrst.

Öllum lyklaborðsflýtilyklum fyrir þessi vefforrit er hægt að breyta í `~/.config/hypr/bindings.lua`.

Þegar þú ert í vefforriti geturðu afritað núverandi vefslóð á klippiborðið með `Shift + Alt + L`.

Sjálfgefið kemur Omarchy þegar með úrvali af sjálfgefnum forritum:

## HEY

[HEY](https://www.hey.com/) er tölvupóst- og dagatalsþjónusta sem þjónar sem frábær valkostur fyrir fólk sem er þreytt á Gmail, Outlook eða Apple Mail. Hann er gerður af [37signals](https://37signals.com/) þar sem Omarchy á uppruna sinn.

Þú getur ræst HEY Email með `Super + Shift + E`, stokkið beint í að semja nýjan tölvupóst með `Super + Shift + Alt + E`, og ræst HEY Calendar með `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er verkefnastjórnunarþjónusta sem hjálpar litlum teymum að fara hraðar og ná meiri framförum. Í stað þess að setja saman samsuðu af Trello, Slack, Asana, Notion eða hvað sem er geturðu haft þetta allt á einum stað með Basecamp. Hann er gerður af [37signals](https://37signals.com/) þar sem Omarchy á uppruna sinn.

Þú getur ræst Basecamp með forritaræsinum (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er vinsælasti AI-spjallbotninn í heiminum.

Þú getur ræst ChatGPT með `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er spjallbotni xAI.

Þú getur ræst Grok með `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er ein af vinsælustu skilaboðaþjónustum heims, og vefútgáfan er frábær valkostur fyrir Linux.

Þú getur ræst WhatsApp með `Super + Shift + Alt + G`.

## Google-forrit

Google Messages, Google Photos, Google Maps og Google Contacts eru öll líka innifalin sem vefforrit.

Þú getur ræst Google Messages með `Super + Shift + Ctrl + G`, Google Photos með `Super + Shift + P` og Google Maps með `Super + Shift + S`. Google Contacts er fáanlegt í gegnum forritaræsinn (`Super + Space`).

## X

X er þar sem fréttir brjótast út.

Þú getur ræst X með `Super + Shift + X` og farið beint í að skrifa nýjan póst með `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er vinsælasti myndbandavettvangur heims.

Þú getur ræst YouTube með `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) er vinsælasta myndspjallkerfið sem notað er í Bandaríkjunum. Frábærar tengingar um allan heim. Og hægt er að halda 40 mínútna fundi án greidds reiknings. Omarchy vefur vefviðskiptavin Zoom, og zoom-fundartenglar opnast beint í hann.

Þú ræsir Zoom með forritaræsinum (`Super + Space`).

## Discord

[Discord](https://discord.com/) er þar sem flest leikja- og opins hugbúnaðarsamfélög hanga, þar á meðal [samfélag Omarchy sjálfs](https://discord.gg/tXFUdasqhY).

Þú ræsir Discord með forritaræsinum (`Super + Space`).

## Microsoft-forrit

Veldu _Setja upp > Þjónusta > Microsoft_ til að bæta Outlook, Word, Excel, PowerPoint, Teams og OneDrive við sem vefforritum. Hvert forrit hefur sinn eigin ræsi og opnast beint, með því að nota viðskiptavefslóðir Microsoft 365 og núverandi vafraprófíl þinn. Þau opnast í sömu vafraforritsgluggum og önnur vefforrit Omarchy; þau setja ekki upp aðskilda Teams for Linux-viðskiptavininn.

Fjarlægðu pakkann með _Fjarlægja > Þjónusta > Microsoft_, eða fjarlægðu einstök forrit með _Fjarlægja > Vefforrit_. Þú getur líka sett upp bara forritin sem þú vilt í gegnum _Setja upp > Vefforrit_.

Fyrir ríkis- eða fullveldis-ský skaltu breyta vefslóðinni á línunni `Exec=` í viðeigandi ræsi undir `~/.local/share/applications/`, svo sem `Microsoft Teams.desktop`, með því að nota vefslóðina sem stofnunin þín gefur upp. Skrifaðu hvaða bókstaflega `%` sem er í þeirri línu sem `%%`. Breytingar taka gildi við næstu ræsingu. Að keyra pakkauppsetninguna aftur skiptir út ræsunum hans fyrir sjálfgefnu vefslóðirnar.

Til að halda vinnuinnskráningum aðskildum skaltu bæta vafragagnamöppu við línuna `Exec=` hvers ræsis:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Skiptu dæmamöppunni út fyrir algilda slóð að eigin vali og notaðu sömu slóð fyrir alla sex ræsana til að deila vinnuinnskráningum á milli þeirra. Vefforritin nota valinn studdan vafra Omarchy, og falla til baka á Chromium þegar sjálfgefni vafrinn er ekki studdur.
