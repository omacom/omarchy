# Browsere

Omarchy vine cu [Google Chrome](https://www.google.com/chrome/) ca browser implicit. Este tematizat să se potrivească cu restul sistemului tău, este cel pe care îl deschide `Super + Shift + Return` (sau `Super + Shift + B`), cu `Super + Shift + Alt + B` pentru o fereastră privată, și cel în care rulează fiecare [aplicație web](25-web-apps.md). Se deschide direct într-o fereastră de browser: nu există ecran de bun venit sau solicitare de autentificare, statisticile de utilizare și rapoartele de blocare nu sunt trimise la Google, iar solicitările privind confidențialitatea publicității sunt dezactivate. Poți în continuare să te autentifici în contul tău Google din butonul de profil oricând vrei sincronizare.

Dacă Chrome nu este pe gustul tău, nu ești blocat cu el. Sub _Install > Browser_ în meniul Omarchy vei găsi [Chromium](https://www.chromium.org/) (versiunea simplă open-source din care este făcut Chrome), Edge, Brave, Brave Origin, Firefox și [Zen](https://zen-browser.app/) (Edge doar pe mașinile x86). Alege unul și Omarchy îl instalează, îi configurează directorul de politici și îi aplică tema ta curentă.

## Cum setezi unul ca implicit

Instalarea unui browser nu îl promovează. Pentru a schimba, mergi la _Setup > Defaults > Browser_ și alege unul. Browserul implicit curent este marcat cu o bifă, iar dacă alegi un browser pe care nu îl ai încă, acesta este instalat mai întâi.

Din terminal este:

```bash
omarchy default browser firefox
```

Rulează-l fără niciun argument și îți spune browserul implicit curent. Acesta setează handlerul XDG, așa că nu doar tastele rapide Omarchy țin cont de el — orice deschide un link, de la o aplicație de chat la o comandă din terminal, merge la browserul pe care l-ai ales.

## Copy URL și Download Video

Browserele din familia Chromium (Chromium însuși, Chrome, Edge, Brave și Brave Origin) vin cu trei extensii Omarchy: două care ajung dincolo de browser și în restul sistemului tău, și una care pune ordine în WhatsApp.

**Copy URL** pune adresa filei curente în clipboard cu `Alt + Shift + L`. Este mai rapid decât să dai clic în bara de adrese și să copiezi, și pentru că trece prin clipboardul de sistem mai degrabă decât prin cel al browserului, primești o notificare Omarchy care confirmă acest lucru, iar URL-ul este disponibil imediat în [istoricul clipboardului](08-unified-clipboard-history.md) și în orice altă aplicație. Există și un buton în bara de instrumente, dacă preferi să dai clic.

**Download Video** ia videoclipul care rulează pe pagina la care te uiți cu `Alt + Shift + D`. Îi transmite URL-ul lui [yt-dlp](https://github.com/yt-dlp/yt-dlp), așa că funcționează pe mult mai multe decât YouTube, iar descărcarea ajunge în `~/Videos`. Progresul apare în același afișaj pe ecran folosit de volum și luminozitate, actualizându-se pe loc în loc să adune notificări una peste alta. Setează `OMARCHY_YTDLP_DIR` dacă preferi ca fișierele să ajungă în altă parte — vezi [FAQ](46-faq.md) pentru unde se pun variabilele de mediu.

Ambele extensii vorbesc cu Omarchy printr-un mic host de mesagerie nativă, care este instalat pentru tine odată cu browserul. Aceasta este piesa care permite ca videoclipul de pe o pagină web să ajungă în directorul tău personal și ca un URL să ajungă în managerul tău de clipboard, lucru pe care o extensie normală nu îl poate face de una singură.

**WhatsApp Slim** face WhatsApp Web să urmeze tema sistemului tău și îi restrânge lista de chat atunci când fereastra este îngustă.

Acestea sunt doar pentru familia Chromium. Firefox și Zen nu le primesc.

## Firefox și Zen

Firefox și Zen sunt o familie diferită, așa că primesc un tratament diferit: Omarchy instalează un fișier de politici pentru setări implicite sensibile și le comută în modul nativ Wayland, pe care îl vrei pentru scalarea fracționară și derularea fluidă pe trackpad.

Nu primesc extensiile Chromium de mai sus și nu sunt tematizate de Omarchy, așa că acele părți ale experienței rămân să le configurezi tu.

## Eliminarea unuia

Oricare dintre aceste browsere, inclusiv Chrome, poate fi scos din nou sub _Remove > Browser_. Linkurile merg apoi la Chrome sau Chromium dacă celălalt este încă instalat.
