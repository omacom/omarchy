# Verkkosovellukset

Voit lisätä omia verkkosovelluksiasi käyttämällä Omarchy-valikon (`Super + Space`) kohtaa _Asenna > Verkkosovellus_. Se kysyy sinulta sovelluksen nimen, sovelluksen URL:n ja kuvakkeen URL:n, jollei se pysty noutamaan sitä faviconin kautta. Voit saada upeita PNG-kuvakkeita monille suosituille verkkosovelluksille sivustolla [Dashboard Icons](https://dashboardicons.com).

Niihin pääsee sitten sovellusten käynnistimen kautta (`Super + Space`), ja ne käyttävät kaunista kehyksetöntä verkkosovelluksen ikkunaa.

Jos haluat poistaa verkkosovelluksen, siirry vain Omarchy-valikon kohtaan _Poista > Verkkosovellus_.

On parasta, jos kirjaudut kaikille tileillesi tavallisella selaimella ennen verkkosovellusten pikanäppäinten käyttöä. Ohut käärekehys ei toimi hyvin 1passwordin kanssa, joten on vain helpompaa olla kirjautuneena suoraan ensin.

Kaikkia näiden verkkosovellusten pikanäppäimiä voi muuttaa tiedostossa `~/.config/hypr/bindings.lua`.

Kun olet verkkosovelluksessa, voit kopioida nykyisen URL:n leikepöydälle näppäimillä `Shift + Alt + L`.

Oletuksena Omarchyssa on jo valikoima oletussovelluksia:

## HEY

[HEY](https://www.hey.com/) on sähköposti- ja kalenteripalvelu, joka on erinomainen vaihtoehto Gmailiin, Outlookiin tai Apple Mailiin kyllästyneille. Sen on tehnyt [37signals](https://37signals.com/), jossa Omarchy sai alkunsa.

Voit käynnistää HEY Emailin näppäimillä `Super + Shift + E`, hypätä suoraan uuden sähköpostin kirjoittamiseen näppäimillä `Super + Shift + Alt + E` ja käynnistää HEY Calendarin näppäimillä `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) on projektinhallintapalvelu, joka auttaa pieniä tiimejä etenemään nopeammin ja saamaan aikaan enemmän edistystä. Sen sijaan, että kursisit kokoon sekalaisen sekoituksen Trelloa, Slackia, Asanaa, Notionia tai mitä tahansa, voit saada kaiken yhdessä paikassa Basecampilla. Sen on tehnyt [37signals](https://37signals.com/), jossa Omarchy sai alkunsa.

Voit käynnistää Basecampin käyttämällä sovellusten käynnistintä (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) on maailman suosituin tekoäly-chattibotti.

Voit käynnistää ChatGPT:n näppäimillä `Super + Shift + A`.

## Grok

[Grok](https://grok.com) on xAI:n chattibotti.

Voit käynnistää Grokin näppäimillä `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) on yksi maailman suosituimmista viestipalveluista, ja verkkoversio on erinomainen vaihtoehto Linuxille.

Voit käynnistää WhatsAppin näppäimillä `Super + Shift + Alt + G`.

## Google-sovellukset

Google Messages, Google Photos, Google Maps ja Google Contacts ovat myös mukana verkkosovelluksina.

Voit käynnistää Google Messagesin näppäimillä `Super + Shift + Ctrl + G`, Google Photosin näppäimillä `Super + Shift + P` ja Google Mapsin näppäimillä `Super + Shift + S`. Google Contacts on saatavilla sovellusten käynnistimen kautta (`Super + Space`).

## X

X on paikka, jossa uutiset puhkeavat.

Voit käynnistää X:n näppäimillä `Super + Shift + X` ja siirtyä suoraan uuden julkaisun kirjoittamiseen näppäimillä `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) on maailman suosituin videoalusta.

Voit käynnistää YouTuben näppäimillä `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) on Yhdysvalloissa käytetty suosituin videochat-järjestelmä. Erinomaiset yhteydet ympäri maailmaa. Ja 40 minuutin kokouksia voi pitää ilman maksullista tiliä. Omarchy käärii Zoomin verkkoasiakkaan, ja zoom-kokouslinkit avautuvat suoraan siihen.

Käynnistät Zoomin käyttämällä sovellusten käynnistintä (`Super + Space`).

## Discord

[Discord](https://discord.com/) on paikka, jossa useimmat peli- ja avoimen lähdekoodin yhteisöt viettävät aikaa, mukaan lukien [Omarchyn oma](https://discord.gg/tXFUdasqhY).

Käynnistät Discordin käyttämällä sovellusten käynnistintä (`Super + Space`).

## Microsoft-sovellukset

Valitse _Asenna > Palvelu > Microsoft_ lisätäksesi Outlookin, Wordin, Excelin, PowerPointin, Teamsin ja OneDriven verkkosovelluksina. Jokaisella sovelluksella on oma käynnistimensä ja se avautuu suoraan käyttäen kaupallisia Microsoft 365 -URL-osoitteita ja olemassa olevaa selainprofiiliasi. Ne avautuvat samoihin selain-sovellusikkunoihin kuin Omarchyn muut verkkosovellukset; ne eivät asenna erillistä Teams for Linux -asiakasta.

Poista paketti kohdassa _Poista > Palvelu > Microsoft_ tai poista yksittäisiä sovelluksia kohdassa _Poista > Verkkosovellus_. Voit myös asentaa vain haluamasi sovellukset kohdan _Asenna > Verkkosovellus_ kautta.

Valtion- tai suvereenia pilveä varten muokkaa URL-osoitetta rivillä `Exec=` asiaankuuluvassa käynnistimessä hakemistossa `~/.local/share/applications/`, kuten `Microsoft Teams.desktop`, käyttäen organisaatiosi toimittamaa URL-osoitetta. Kirjoita mikä tahansa kirjaimellinen `%` tuolle riville muodossa `%%`. Muutokset tulevat voimaan seuraavalla käynnistyksellä. Paketin asennusohjelman ajaminen uudelleen korvaa sen käynnistimet oletus-URL-osoitteilla.

Pitääksesi työkirjautumiset erillään liitä selaimen datahakemisto jokaisen käynnistimen riville `Exec=`:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Korvaa esimerkkihakemisto valitsemallasi absoluuttisella polulla ja käytä samaa polkua kaikille kuudelle käynnistimelle jakaaksesi työkirjautumiset niiden välillä. Verkkosovellukset käyttävät Omarchyn valittua tuettua selainta ja palaavat Chromiumiin, kun oletusselainta ei tueta.
