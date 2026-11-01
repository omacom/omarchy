# Browsere

Omarchy vine cu [Chromium](https://www.chromium.org/) ca browser implicit. Este versiunea simplă, open source, tematizată să se potrivească cu restul sistemului tău, și este ce deschide `Super + Shift + Return` și ce găzduiește fiecare [aplicație web](25-web-apps.md).

Dacă Chromium nu e pe gustul tău, nu ești blocat cu el. Sub _Instalează > Browser_ în meniul Omarchy vei găsi Chrome, Edge, Brave, Brave Origin, Firefox și [Zen](https://zen-browser.app/). Alege unul și Omarchy îl instalează, îi configurează directorul de politici și îi aplică tema ta curentă.

## Cum faci unul implicit

Instalarea unui browser nu îl promovează. Odată ce este pe mașină, mergi la _Configurare > Implicite > Browser_ și alege-l — meniul listează doar browserele pe care le ai de fapt instalate și marchează implicitul curent cu o bifă.

Din terminal, este:

```bash
omarchy default browser firefox
```

Ruleaz-o fără argument și îți spune implicitul curent. Asta setează handler-ul XDG, așa că nu doar scurtăturile Omarchy urmează — orice deschide un link, de la o aplicație de chat la o comandă de terminal, merge la browserul pe care l-ai ales.

## Copiază URL-ul și descarcă videoclipul

Browserele din familia Chromium (Chromium în sine, Chrome, Edge și Brave) vin cu două extensii Omarchy care ies din browser și ajung în restul sistemului tău.

**Copy URL** pune adresa filei curente în clipboard cu `Alt + Shift + L`. Este mai rapid decât să faci clic în bara de adrese și să copiezi, iar pentru că trece prin clipboardul sistemului, mai degrabă decât prin cel al browserului, primești o notificare Omarchy care confirmă, iar URL-ul este disponibil imediat în [istoricul clipboardului](08-unified-clipboard-history.md) și în orice altă aplicație. Există și un buton în bara de instrumente, dacă preferi clicurile.

**Download Video** ia videoclipul care rulează pe pagina la care te uiți cu `Alt + Shift + D`. Predă URL-ul către [yt-dlp](https://github.com/yt-dlp/yt-dlp), așa că funcționează pe mult mai multe decât YouTube, iar descărcarea ajunge în `~/Videos`. Progresul apare în același afișaj pe ecran pe care îl folosesc volumul și luminozitatea, actualizându-se pe loc, mai degrabă decât să stivuiască notificări. Setează `OMARCHY_YTDLP_DIR` dacă ai prefera ca fișierele să meargă altundeva — vezi [întrebările frecvente](46-faq.md) pentru unde pui variabilele de mediu.

Ambele extensii vorbesc cu Omarchy printr-o mică gazdă de mesagerie nativă, care se instalează pentru tine împreună cu browserul. Aceea este piesa care permite ca videoclipul unei pagini web să ajungă în directorul tău home, iar un URL în managerul tău de clipboard, ceea ce o extensie normală nu poate face singură.

Acestea sunt numai pentru familia Chromium. Firefox și Zen nu le primesc.

## Firefox și Zen

Firefox și Zen sunt o altă familie, așa că primesc un alt tratament: Omarchy instalează un fișier de politici pentru valori implicite sensibile și le trece în mod nativ Wayland, pe care îl vrei pentru scalare fracționară și derulare lină cu touchpadul.

Nu primesc extensiile Chromium de mai sus și nu sunt tematizate de Omarchy, așa că acele părți ale experienței sunt ale tale de configurat.

## Eliminarea unuia

Orice ai instalat aici poate fi scos înapoi sub _Elimină > Browser_. Chromium nu este în acea listă — face parte din sistemul de bază.
