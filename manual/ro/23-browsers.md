# Browsere

Omarchy vine cu [Google Chrome](https://www.google.com/chrome/) ca browser implicit. Este tematizat ca să se potrivească cu restul sistemului tău și este ceea ce deschide `Super + Shift + Return` și în interiorul căruia rulează fiecare [aplicație web](25-web-apps.md). Se deschide direct într-o fereastră de browser: nu există niciun ecran de bun venit sau nicio solicitare de autentificare, statisticile de utilizare și rapoartele de blocare nu sunt trimise către Google, iar solicitările privind confidențialitatea publicității sunt dezactivate. Te poți autentifica totuși în contul tău Google din butonul de profil oricând vrei sincronizare.

Dacă Chrome nu e pe gustul tău, nu ești blocat cu el. Sub _Install > Browser_ în meniul Omarchy vei găsi [Chromium](https://www.chromium.org/) (versiunea simplă, open-source, din care este făcut Chrome), Edge, Brave, Brave Origin, Firefox și [Zen](https://zen-browser.app/). Alege unul și Omarchy îl instalează, îi configurează directorul de politici și îi aplică tema ta curentă.

## Cum îl setezi pe unul ca implicit

Instalarea unui browser nu îl promovează. După ce e pe mașină, mergi la _Setup > Defaults > Browser_ și alege-l — meniul listează doar browserele pe care le ai instalate de fapt și marchează browserul implicit curent cu o bifă.

Din terminal este:

```bash
omarchy default browser firefox
```

Rulează-l fără niciun argument și îți spune browserul implicit curent. Acesta setează handlerul XDG, așa că nu doar scurtăturile Omarchy îl urmează — orice deschide un link, de la o aplicație de chat la o comandă din terminal, merge la browserul pe care l-ai ales.

## Copy URL și Download Video

Browserele din familia Chromium (Chromium însuși, Chrome, Edge și Brave) vin cu două extensii Omarchy care ajung dincolo de browser, în restul sistemului tău.

**Copy URL** pune adresa filei curente în clipboard cu `Alt + Shift + L`. E mai rapid decât să dai clic în bara de adrese și să copiezi, iar pentru că trece prin clipboardul sistemului, nu prin cel al browserului, primești o notificare Omarchy care confirmă acest lucru, iar URL-ul este disponibil imediat în [istoricul clipboardului](08-unified-clipboard-history.md) și în orice altă aplicație. Există și un buton în bara de instrumente, dacă preferi să dai clic.

**Download Video** preia videoclipul redat pe pagina la care te uiți cu `Alt + Shift + D`. Îi transmite URL-ul lui [yt-dlp](https://github.com/yt-dlp/yt-dlp), așa că funcționează pe mult mai multe decât YouTube, iar descărcarea ajunge în `~/Videos`. Progresul apare în același afișaj pe ecran pe care îl folosesc volumul și luminozitatea, actualizându-se pe loc, în loc să adune notificări. Setează `OMARCHY_YTDLP_DIR` dacă preferi ca fișierele să ajungă în altă parte — vezi [FAQ](46-faq.md) pentru unde se pun variabilele de mediu.

Ambele extensii vorbesc cu Omarchy printr-un mic host de mesagerie nativă, care ți se instalează odată cu browserul. Asta e piesa care permite ca videoclipul unei pagini web să ajungă în directorul tău home și ca un URL să ajungă în managerul tău de clipboard, lucru pe care o extensie normală nu îl poate face singură.

Acestea sunt doar pentru familia Chromium. Firefox și Zen nu le primesc.

## Firefox și Zen

Firefox și Zen sunt o familie diferită, așa că primesc un tratament diferit: Omarchy instalează un fișier de politici pentru setări implicite rezonabile și le comută în modul Wayland nativ, pe care îl vrei pentru scalare fracționară și derulare lină pe trackpad.

Nu primesc extensiile Chromium de mai sus și nu sunt tematizate de Omarchy, așa că acele părți ale experienței rămân să le configurezi singur.

## Cum îl elimini din nou

Oricare dintre aceste browsere, inclusiv Chrome, poate fi scos din nou de sub _Remove > Browser_. Linkurile merg apoi către Chrome sau Chromium, dacă celălalt este încă instalat.
