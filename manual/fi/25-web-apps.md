# Verkkosovellukset

Voit lisätä omia verkkosovelluksiasi Omarchy-valikon kohdasta _Asenna > Verkkosovellus_ (`Super + Space`). Se kysyy sinulta sovelluksen nimen, sovelluksen URL-osoitteen ja kuvakkeen URL-osoitteen, jos se ei saa sitä haettua faviconin kautta. Löydät upeita PNG-kuvakkeita monille suosituille verkkosovelluksille sivustolta [Dashboard Icons](https://dashboardicons.com).

Ne ovat sen jälkeen käytettävissä sovelluskäynnistimen (`Super + Space`) kautta, ja ne käyttävät kaunista kehyksetöntä verkkosovellusikkunaa.

Jos haluat poistaa verkkosovelluksen, siirry vain Omarchy-valikon kohtaan _Poista > Verkkosovellus_.

On parasta, jos kirjaudut kaikkiin tileihisi tavallisella selaimella ennen verkkosovellusten pikakuvakkeiden käyttämistä. Ohut wrapper-kehys ei toimi hyvin 1passwordin kanssa, joten on vain helpompaa olla kirjautuneena suoraan valmiiksi.

Kaikkia näiden verkkosovellusten pikanäppäimiä voi muuttaa tiedostossa `~/.config/hypr/bindings.lua`.

Kun olet verkkosovelluksessa, voit kopioida nykyisen URL-osoitteen leikepöydälle näppäinyhdistelmällä `Shift + Alt + L`.

Oletuksena Omarchyn mukana tulee jo valikoima oletussovelluksia:

## HEY

[HEY](https://www.hey.com/) on sähköposti- ja kalenteripalvelu, joka toimii loistavana vaihtoehtona ihmisille, jotka ovat kyllästyneet Gmailiin, Outlookiin tai Apple Mailiin. Sen on tehnyt [37signals](https://37signals.com/), josta Omarchy sai alkunsa.

Voit käynnistää HEY Emailin näppäinyhdistelmällä `Super + Shift + E`, siirtyä suoraan kirjoittamaan uutta sähköpostia näppäinyhdistelmällä `Super + Shift + Alt + E` ja käynnistää HEY Calendarin näppäinyhdistelmällä `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) on projektinhallintapalvelu, joka auttaa pieniä tiimejä etenemään nopeammin ja saamaan enemmän aikaan. Sen sijaan, että kasaisit kokoon sekamelskan Trellosta, Slackista, Asanasta, Notionista tai mistä tahansa, saat kaiken yhteen paikkaan Basecampilla. Sen on tehnyt [37signals](https://37signals.com/), josta Omarchy sai alkunsa.

Voit käynnistää Basecampin sovelluskäynnistimellä (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) on maailman suosituin tekoälychatbotti.

Voit käynnistää ChatGPT:n näppäinyhdistelmällä `Super + Shift + A`.

## Grok

[Grok](https://grok.com) on xAI:n chatbotti.

Voit käynnistää Grokin näppäinyhdistelmällä `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) on yksi maailman suosituimmista viestipalveluista, ja verkkoversio on loistava vaihtoehto Linuxille.

Voit käynnistää WhatsAppin näppäinyhdistelmällä `Super + Shift + Alt + G`.

## Google-sovellukset

Myös Google Messages, Google Photos, Google Maps ja Google Contacts sisältyvät verkkosovelluksina.

Voit käynnistää Google Messagesin näppäinyhdistelmällä `Super + Shift + Ctrl + G`, Google Photosin näppäinyhdistelmällä `Super + Shift + P` ja Google Mapsin näppäinyhdistelmällä `Super + Shift + S`. Google Contacts on käytettävissä sovelluskäynnistimen (`Super + Space`) kautta.

## X

X on paikka, jossa uutiset syntyvät.

Voit käynnistää X:n näppäinyhdistelmällä `Super + Shift + X` ja siirtyä suoraan kirjoittamaan uutta julkaisua näppäinyhdistelmällä `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) on maailman suosituin videoalusta.

Voit käynnistää YouTuben näppäinyhdistelmällä `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) on suosituin Yhdysvalloissa käytetty videokeskustelujärjestelmä. Loistavat yhteydet kaikkialle maailmaan. Ja 40 minuutin kokouksia voi pitää ilman maksullista tiliä. Omarchy paketoi Zoomin verkkoasiakkaan, ja Zoom-kokouslinkit avautuvat suoraan siihen.

Käynnistät Zoomin sovelluskäynnistimellä (`Super + Space`).

## Discord

[Discord](https://discord.com/) on paikka, jossa useimmat peli- ja avoimen lähdekoodin yhteisöt viettävät aikaansa, mukaan lukien [Omarchyn oma](https://discord.gg/tXFUdasqhY).

Käynnistät Discordin sovelluskäynnistimellä (`Super + Space`).

## Microsoft-sovellukset

Valitse _Asenna > Palvelu > Microsoft_ lisätäksesi Outlookin, Wordin, Excelin, PowerPointin, Teamsin ja OneDriven verkkosovelluksina. Jokaisella sovelluksella on oma käynnistimensä ja se avautuu suoraan käyttäen kaupallisia Microsoft 365 -URL-osoitteita ja nykyistä selainprofiiliasi. Ne avautuvat samoihin selainohjelmien ikkunoihin kuin Omarchyn muutkin verkkosovellukset; ne eivät asenna erillistä Teams for Linux -asiakasta.

Poista paketti kohdasta _Poista > Palvelu > Microsoft_ tai poista yksittäisiä sovelluksia kohdasta _Poista > Verkkosovellus_. Voit myös asentaa vain haluamasi sovellukset kohdan _Asenna > Verkkosovellus_ kautta.

Valtionhallinnon tai suvereenia pilveä varten muokkaa URL-osoitetta kyseisen käynnistimen `Exec=`-rivillä kansiossa `~/.local/share/applications/`, esimerkiksi tiedostossa `Microsoft Teams.desktop`, ja käytä organisaatiosi antamaa URL-osoitetta. Kirjoita jokainen kirjaimellinen `%` kyseiselle riville muodossa `%%`. Muutokset astuvat voimaan seuraavalla käynnistyksellä. Paketin asennusohjelman suorittaminen uudelleen korvaa sen käynnistimet oletus-URL-osoitteilla.

Jotta työkirjautumiset pysyvät erillään, lisää selaimen datakansio jokaisen käynnistimen `Exec=`-riville:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Korvaa esimerkkikansio valitsemallasi absoluuttisella polulla ja käytä samaa polkua kaikissa kuudessa käynnistimessä, jotta työkirjautumiset jaetaan niiden kesken. Verkkosovellukset käyttävät Omarchyn valitsemaa tuettua selainta ja turvautuvat Chromeen, kun oletusselainta ei tueta.
