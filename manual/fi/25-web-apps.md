# Verkkosovellukset

Voit lisätä omia verkkosovelluksiasi Omarchy-valikon kohdasta _Asenna > Verkkosovellus_ (`Super + Space`). Se kysyy sinulta sovelluksen nimen, sovelluksen URL-osoitteen ja kuvakkeen URL-osoitteen, jos se ei saa sitä haettua faviconin kautta. Monille suosituille verkkosovelluksille löydät hienoja PNG-kuvakkeita sivustolta [Dashboard Icons](https://dashboardicons.com).

Ne ovat sen jälkeen käytettävissä sovellusten käynnistimen (`Super + Space`) kautta, ja ne käyttävät kaunista kehyksetöntä verkkosovellusikkunaa.

Jos haluat poistaa verkkosovelluksen, siirry vain Omarchy-valikon kohtaan _Poista > Verkkosovellus_.

On parasta, jos kirjaudut ensin kaikille tileillesi tavallisella selaimella ennen verkkosovellusten pikakuvakkeiden käyttämistä. Ohut wrapper-kehys ei toimi hyvin 1passwordin kanssa, joten on vain helpompaa olla kirjautuneena suoraan valmiiksi.

Kaikkia näiden verkkosovellusten pikanäppäimiä voi muuttaa tiedostossa `~/.config/hypr/bindings.lua`.

Kun olet verkkosovelluksessa, voit kopioida nykyisen URL-osoitteen leikepöydälle näppäinyhdistelmällä `Shift + Alt + L`.

Oletuksena Omarchyssa on jo valmiina valikoima oletussovelluksia:

## HEY

[HEY](https://www.hey.com/) on sähköposti- ja kalenteripalvelu, joka toimii loistavana vaihtoehtona ihmisille, jotka ovat kyllästyneet Gmailiin, Outlookiin tai Apple Mailiin. Sen on tehnyt [37signals](https://37signals.com/), josta Omarchy sai alkunsa.

Voit käynnistää HEY Email -sovelluksen näppäinyhdistelmällä `Super + Shift + E`, siirtyä suoraan uuden sähköpostin kirjoittamiseen näppäinyhdistelmällä `Super + Shift + Alt + E` ja käynnistää HEY Calendar -sovelluksen näppäinyhdistelmällä `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) on projektinhallintapalvelu, joka auttaa pieniä tiimejä etenemään nopeammin ja saamaan enemmän aikaan. Sen sijaan että kasaisit kokoon sekamelskan Trellosta, Slackista, Asanasta, Notionista tai mistä tahansa, voit saada kaiken yhdessä paikassa Basecampilla. Sen on tehnyt [37signals](https://37signals.com/), josta Omarchy sai alkunsa.

Voit käynnistää Basecampin sovellusten käynnistimellä (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) on maailman suosituin AI-chatbotti.

Voit käynnistää ChatGPT:n näppäinyhdistelmällä `Super + Shift + A`.

## Grok

[Grok](https://grok.com) on xAI:n chatbotti.

Voit käynnistää Grokin näppäinyhdistelmällä `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) on yksi maailman suosituimmista viestipalveluista, ja verkkosversio on loistava vaihtoehto Linuxille.

Voit käynnistää WhatsAppin näppäinyhdistelmällä `Super + Shift + Alt + G`. Se avautuu Omarchyn WhatsApp Slim -laajennuksella, joka saa sen noudattamaan teemaasi ja kutistaa keskusteluluettelon, kun ikkuna on kapea.

## Google-sovellukset

Google Messages, Google Photos, Google Maps ja Google Contacts sisältyvät kaikki myös verkkosovelluksina.

Voit käynnistää Google Messages -sovelluksen näppäinyhdistelmällä `Super + Shift + Ctrl + G`, Google Photos -sovelluksen näppäinyhdistelmällä `Super + Shift + P` ja Google Maps -sovelluksen näppäinyhdistelmällä `Super + Shift + S`. Google Contacts on käytettävissä sovellusten käynnistimen (`Super + Space`) kautta.

## X

X on paikka, jossa uutiset ilmestyvät ensimmäisenä.

Voit käynnistää X:n näppäinyhdistelmällä `Super + Shift + X` ja siirtyä suoraan uuden julkaisun kirjoittamiseen näppäinyhdistelmällä `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) on maailman suosituin videoalusta.

Voit käynnistää YouTuben näppäinyhdistelmällä `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) sisältyy verkkosovelluksena uusiin asennuksiin.

Käynnistät Netflixin sovellusten käynnistimellä (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) on suosituin Yhdysvalloissa käytetty videokeskustelujärjestelmä. Loistavat yhteydet kaikkialla maailmassa. Ja 40 minuutin kokouksia voi pitää ilman maksullista tiliä. Omarchy paketoi Zoomin verkko-ohjelman, ja Zoom-kokouslinkit avautuvat suoraan siihen.

Käynnistät Zoomin sovellusten käynnistimellä (`Super + Space`).

## Discord

[Discord](https://discord.com/) on paikka, jossa useimmat peli- ja avoimen lähdekoodin yhteisöt viettävät aikaa, mukaan lukien [Omarchyn oma](https://discord.gg/tXFUdasqhY).

Käynnistät Discordin sovellusten käynnistimellä (`Super + Space`).

## Microsoft-sovellukset

Valitse _Asenna > Palvelu > Microsoft_ lisätäksesi Outlook, Word, Excel, PowerPoint, Teams ja OneDrive verkkosovelluksina. Jokaisella sovelluksella on oma käynnistimensä, ja se avautuu suoraan käyttäen kaupallisia Microsoft 365 URL-osoitteita ja olemassa olevaa selainprofiiliasi. Ne avautuvat samoissa selaimen sovellusikkunoissa kuin Omarchyn muut verkkosovellukset; ne eivät asenna erillistä Teams for Linux -asiakasta.

Poista paketti kohdasta _Poista > Palvelut > Microsoft_ tai poista yksittäisiä sovelluksia kohdasta _Poista > Verkkosovellus_. Voit myös asentaa vain haluamasi sovellukset kohdan _Asenna > Verkkosovellus_ kautta.

Muokkaa valtionhallinnon tai suvereenin pilven tapauksessa URL-osoitetta asianmukaisen käynnistimen `Exec=`-rivillä kohteessa `~/.local/share/applications/`, kuten `Microsoft Teams.desktop`, käyttämällä organisaatiosi antamaa URL-osoitetta. Kirjoita jokainen kirjaimellinen `%` kyseisellä rivillä muodossa `%%`. Muutokset tulevat voimaan seuraavalla käynnistyskerralla. Paketin asennusohjelman suorittaminen uudelleen korvaa sen käynnistimet oletus-URL-osoitteilla.

Pitääksesi työkirjautumiset erillään lisää selaimen datahakemisto jokaisen käynnistimen `Exec=`-riville:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Korvaa esimerkkihakemisto valitsemallasi absoluuttisella polulla ja käytä samaa polkua kaikissa kuudessa käynnistimessä jakaaksesi työkirjautumiset niiden välillä. Verkkosovellukset käyttävät Omarchyn valittua tuettua selainta ja turvautuvat Chromeen, kun oletusselain ei ole tuettu.
