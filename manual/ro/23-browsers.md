# Browsere

Omarchy vine cu [Google Chrome](https://www.google.com/chrome/) ca browser implicit. Are o temă asortată cu restul sistemului tău și este ceea ce deschide `Super + Shift + Return` (sau `Super + Shift + B`), cu `Super + Shift + Alt + B` pentru o fereastră privată, și ceea ce rulează în interior fiecare [aplicație web](25-web-apps.md). Se deschide direct într-o fereastră de browser: nu există niciun ecran de bun venit sau solicitare de autentificare, statisticile de utilizare și rapoartele de blocare nu sunt trimise către Google, iar solicitările privind confidențialitatea publicitară sunt dezactivate. Te poți conecta oricând la contul tău Google din butonul de profil, dacă vrei sincronizare.

Dacă Chrome nu e pe gustul tău, nu ești blocat cu el. Sub _Instalare > Browser_ în meniul Omarchy vei găsi [Chromium](https://www.chromium.org/) (versiunea simplă, open-source, din care este făcut Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) și [Ladybird](https://ladybird.org/) (Edge numai pe mașinile x86). Alege unul, iar Omarchy îl instalează, îi configurează directorul de politici și îi aplică tema ta curentă.

## Setarea unuia ca implicit

Instalarea unui browser nu îl promovează. Pentru a schimba, mergi la _Configurare > Valori implicite > Browser_ și alege unul. Cel implicit curent este marcat cu o bifă, iar alegerea unui browser pe care nu îl ai încă îl instalează mai întâi.

Din terminal este:

```bash
omarchy default browser firefox
```

Rulează-l fără niciun argument și îți spune care este cel implicit curent. Acesta setează handlerul XDG, așa că nu doar tastele rapide Omarchy îl urmează — orice deschide un link, de la o aplicație de chat la o comandă din terminal, merge în browserul pe care l-ai ales.

## Copy URL și Download Video

Browserele din familia Chromium (Chromium însuși, Chrome, Edge, Brave și Brave Origin) vin cu trei extensii Omarchy: două care ies din browser și ajung în restul sistemului tău și una care pune ordine în WhatsApp.

**Copy URL** pune adresa filei curente în clipboard cu `Alt + Shift + L`. E mai rapid decât să dai clic în bara de adrese și să copiezi, iar pentru că trece prin clipboardul sistemului, nu prin cel al browserului, primești o notificare Omarchy care confirmă și URL-ul este disponibil imediat în [istoricul clipboardului](08-unified-clipboard-history.md) și în orice altă aplicație. Există și un buton în bara de instrumente, dacă preferi să dai clic.

**Download Video** preia videoclipul care se redă pe pagina la care te uiți cu `Alt + Shift + D`. Îi transmite URL-ul lui [yt-dlp](https://github.com/yt-dlp/yt-dlp), așa că funcționează pe mult mai multe decât YouTube, iar descărcarea ajunge în `~/Videos`. Progresul apare în același afișaj pe ecran folosit de volum și luminozitate, actualizându-se pe loc, în loc să adune notificări una peste alta. Setează `OMARCHY_YTDLP_DIR` dacă preferi ca fișierele să ajungă în altă parte — vezi [FAQ](46-faq.md) pentru unde se pun variabilele de mediu.

Ambele extensii comunică cu Omarchy printr-un mic host de mesagerie nativă, care este instalat pentru tine odată cu browserul. Aceasta este piesa care permite ca un videoclip de pe o pagină web să ajungă în directorul tău personal și ca un URL să ajungă în managerul tău de clipboard, lucru pe care o extensie normală nu îl poate face singură.

**WhatsApp Slim** face ca WhatsApp Web să urmeze tema sistemului tău și îi restrânge lista de conversații când fereastra este îngustă.

Acestea sunt numai pentru familia Chromium. Firefox și Zen nu le primesc.

## Firefox și Zen

Firefox și Zen sunt o familie diferită, așa că primesc un tratament diferit: Omarchy instalează un fișier de politici pentru valori implicite rezonabile și le comută în modul Wayland nativ, pe care îl vrei pentru scalarea fracționară și derularea lină cu trackpadul.

Nu primesc extensiile Chromium de mai sus și nu sunt tematizate de Omarchy, așa că acele părți ale experienței rămân să le configurezi tu.

## Ladybird

Ladybird este un browser scris de la zero, cu propriul motor, nu al Chromium sau al Firefox. Este încă în alpha, așa că așteaptă-te la site-uri care încă nu funcționează, iar Omarchy îl instalează așa cum vine: fără extensii, fără temă, fără politici. Nu are nici fereastră privată, așa că `Super + Shift + Alt + B` îl deschide cu un profil temporar care este șters când îl închizi. [Aplicațiile web](25-web-apps.md) continuă să ruleze în Chrome sau Chromium.

## Eliminarea unuia

Oricare dintre aceste browsere, inclusiv Chrome, poate fi scos din nou de sub _Eliminare > Browser_. Linkurile merg apoi în Chrome sau Chromium, dacă celălalt este încă instalat.
