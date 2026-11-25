# Vefforrit

Þú getur bætt við þínum eigin vefforritum með því að nota _Setja upp > Vefforrit_ í Omarchy valmyndinni (`Super + Space`). Það mun biðja þig um nafn forritsins, slóð forritsins og slóð táknsins, ef það getur ekki sótt það með favicon. Þú getur fengið frábær PNG tákn fyrir mörg vinsæl vefforrit á [Dashboard Icons](https://dashboardicons.com).

Þau verða síðan aðgengileg í gegnum forritaræsirinn (`Super + Space`) og nota fallega rammalausa vefforritsgluggann.

Ef þú vilt fjarlægja vefforrit skaltu bara fara í _Fjarlægja > Vefforrit_ í Omarchy valmyndinni.

Best er að skrá sig inn á alla reikningana sína í venjulegum vafra áður en flýtivísarnir fyrir vefforritin eru notaðir. Þunna umgjörðin virkar ekki vel með 1password, svo það er bara auðveldara að vera skráður inn beint fyrst.

Öllum flýtilyklum fyrir þessi vefforrit er hægt að breyta í `~/.config/hypr/bindings.lua`.

Þegar þú ert í vefforriti geturðu afritað núverandi slóð á klippiborðið með `Shift + Alt + L`.

Sjálfgefið fylgir Omarchy þegar úrval af sjálfgefnum forritum:

## HEY

[HEY](https://www.hey.com/) er tölvupóst- og dagatalþjónusta sem er frábær valkostur fyrir fólk sem hefur fengið nóg af Gmail, Outlook eða Apple Mail. Hún er gerð af [37signals](https://37signals.com/) þar sem Omarchy á uppruna sinn.

Þú getur ræst HEY Email með `Super + Shift + E`, farið beint í að semja nýjan tölvupóst með `Super + Shift + Alt + E` og ræst HEY Calendar með `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er verkefnastjórnunarþjónusta sem hjálpar litlum teymum að vinna hraðar og ná meiri framförum. Í stað þess að setja saman mishmash af Trello, Slack, Asana, Notion eða hverju sem er geturðu haft það allt á einum stað með Basecamp. Það er gert af [37signals](https://37signals.com/) þar sem Omarchy á uppruna sinn.

Þú getur ræst Basecamp með forritaræsinum (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er vinsælasta AI spjallmenni í heiminum.

Þú getur ræst ChatGPT með `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er spjallmenni xAI.

Þú getur ræst Grok með `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er ein vinsælasta skilaboðaþjónusta í heiminum og vefútgáfan er frábær valkostur fyrir Linux.

Þú getur ræst WhatsApp með `Super + Shift + Alt + G`. Það opnast með WhatsApp Slim viðbót Omarchy, sem lætur það fylgja þemanu þínu og fellir spjalllistann saman þegar glugginn er mjór.

## Google-forrit

Google Messages, Google Photos, Google Maps og Google Contacts fylgja líka öll sem vefforrit.

Þú getur ræst Google Messages með `Super + Shift + Ctrl + G`, Google Photos með `Super + Shift + P` og Google Maps með `Super + Shift + S`. Google Contacts er aðgengilegt í gegnum forritaræsirinn (`Super + Space`).

## X

X er staðurinn þar sem fréttir brotna.

Þú getur ræst X með `Super + Shift + X` og farið beint í að skrifa nýja færslu með `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er vinsælasta myndbandsvettvangur í heiminum.

Þú getur ræst YouTube með `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) fylgir sem vefforrit í nýjum uppsetningum.

Þú ræsir Netflix með forritaræsinum (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) er vinsælasta myndspjallkerfið sem notað er í US. Frábærar tengingar um allan heim. Og hægt er að halda 40 mínútna fundi án greidds reiknings. Omarchy umvefur vefbiðlara Zoom og Zoom fundatenglar opnast beint inn í hann.

Þú ræsir Zoom með forritaræsinum (`Super + Space`).

## Discord

[Discord](https://discord.com/) er staðurinn þar sem flest leikja- og opins hugbúnaðarsamfélög hanga, þar á meðal [samfélag Omarchy](https://discord.gg/tXFUdasqhY).

Þú ræsir Discord með forritaræsinum (`Super + Space`).

## Microsoft-forrit

Veldu _Setja upp > Þjónusta > Microsoft_ til að bæta við Outlook, Word, Excel, PowerPoint, Teams og OneDrive sem vefforritum. Hvert forrit hefur sinn eigin ræsi og opnast beint, með viðskiptaslóðum Microsoft 365 og núverandi vafrasniðinu þínu. Þau opnast í sömu vafraforritsgluggum og önnur vefforrit Omarchy; þau setja ekki upp sérstaka Teams for Linux biðlarann.

Fjarlægðu pakkann með _Fjarlægja > Þjónustur > Microsoft_, eða fjarlægðu einstök forrit með _Fjarlægja > Vefforrit_. Þú getur líka sett upp bara þau forrit sem þú vilt í gegnum _Setja upp > Vefforrit_.

Fyrir stjórnvalds- eða fullvalda ský skaltu breyta slóðinni á `Exec=` línunni í viðkomandi ræsi undir `~/.local/share/applications/`, svo sem `Microsoft Teams.desktop`, og nota slóðina sem stofnunin þín gefur upp. Skrifaðu hvert bókstaflegt `%` í þeirri línu sem `%%`. Breytingar taka gildi við næstu ræsingu. Ef pakkauppsetningarforritið er keyrt aftur koma sjálfgefnu slóðirnar í stað ræsanna þess.

Til að halda innskráningum fyrir vinnu aðskildum skaltu bæta vafragagnamöppu við `Exec=` línu hvers ræsis:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Skiptu út dæmamöppunni fyrir algera slóð að eigin vali og notaðu sömu slóð fyrir alla sex ræsana til að deila innskráningum fyrir vinnu á milli þeirra. Vefforritin nota valinn studdan vafra Omarchy og grípa til Chrome þegar sjálfgefni vafrinn er ekki studdur.
