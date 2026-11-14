# Capturi de ecran și înregistrare

Tot ce poți lua de pe ecran depinde de tasta Print Screen. O tastă singură face o fotografie, iar modificatorii fac o înregistrare, o culoare sau textul dintr-o regiune. Dacă tastatura ta nu are deloc o tastă Print Screen, `Super + Ctrl + Alt + C` face aceeași captură de ecran, iar `Super + Ctrl + C` deschide întregul set ca meniu.

| Tastă rapidă | Funcție |
| ------ | -------- |
| `Print Screen` | Captură de ecran |
| `Super + Ctrl + Alt + C` | Captură de ecran |
| `Alt + Print Screen` | Înregistrare ecran (sau oprește înregistrarea în curs) |
| `Super + Print Screen` | Selector de culoare |
| `Super + Ctrl + Print Screen` | Extrage textul dintr-o regiune |
| `Super + Ctrl + C` | Meniu de captură |
| `Super + Ctrl + .` | Transcodează o imagine sau un videoclip |

## Capturi de ecran

Apasă `Print Screen` (sau `Super + Ctrl + Alt + C`) și Omasnap capturează monitorul focalizat înainte să-i apară suprapunerea, așa că nimic nu se mișcă sub tine cât timp țintești. Trage o regiune cu formă liberă, dă clic pe o fereastră ca s-o capturezi sau dă clic pe un spațiu gol ca să capturezi întregul monitor. Apasă `S` înainte de a desena ca să capturezi o regiune cu derulare. Te-ai răzgândit? Apasă din nou aceeași tastă ca să închizi Omasnap.

După ce selectezi o zonă, Omasnap salvează captura, o copiază în clipboard și afișează o notificare cu miniatura ei, la fel cum face o înregistrare a ecranului salvată. Alege Open ca să vezi captura salvată în vizualizatorul tău de imagini sau Edit ca s-o adnotezi.

Editorul de adnotări poate desena săgeți, linii, forme, evidențieri, marcaje numerotate, text și redactări sigure; poate decupa sau tăia o parte din imagine; îi poate face OCR textului; și poate adăuga un fundal. În editor, apasă `Enter` ca să copiezi și să salvezi PNG-ul final, `Ctrl + C` ca să-l copiezi fără să-l salvezi sau `Ctrl + S` ca să-l salvezi fără să-l copiezi.

Capturile de ecran salvate ajung implicit în `~/Pictures/Screenshots`, cu un nume precum `screenshot-2026-08-13_14-22-05-firefox.png`. Setează `OMASNAP_SCREENSHOT_DIR` ca să folosești alt director — vezi [întrebările frecvente](46-faq.md) pentru unde se pun variabilele de mediu ale sesiunii. Omasnap creează directorul când salvează prima captură. Setează `[output] autosave = false` în `~/.config/omasnap/omasnap.conf` ca să dezactivezi salvarea automată; capturile sunt atunci doar copiate și afișate într-o previzualizare timp de 10 secunde, pe care o poți ține pe ecran cu butonul ei de fixare sau cu `Ctrl + P`.

Din terminal, `omarchy screenshot` deschide aceeași suprapunere, iar tu îi poți alege modul de pornire: `omarchy capture screenshot region`, `windows`, `fullscreen` sau `scroll`. Un al doilea argument, `copy` sau `save`, trimite captura direct la acea destinație. Ca să editezi înainte de ieșire, folosește `omarchy screenshot --editor=overlay` pentru un editor pe tot ecranul sau `omarchy screenshot --editor=window` pentru o fereastră separată.

### Controlarea selectorului de la tastatură

Cât timp selecția este activă, nu trebuie să folosești deloc mouse-ul:

| Tastă | Funcție |
| --- | -------- |
| `S` | Comută modul regiune cu derulare |
| `Super + Arrow keys` | Deplasează-te între ferestre în modul Fereastră |
| `Return` | Capturează fereastra evidențiată |
| `Ctrl + A` | Capturează întregul monitor focalizat |
| `R` | Restaurează ultima regiune desenată în această sesiune |
| `Esc` | Închide Omasnap |

Aceste combinații există doar cât timp Omasnap este deschis, așa că nu pot intra în conflict cu nimic din propria ta configurare.

## Înregistrarea ecranului

`Alt + Print Screen` deschide _Trigger > Capture > Screenrecord_, care te întreabă ce vrei pe coloana sonoră: fără sunet, sunet de desktop, desktop plus microfon sau desktop plus microfon plus webcam. Ultima opțiune apare doar dacă chiar ai o cameră conectată. Alege una, iar selectorul de înregistrare din Omarchy te lasă să tragi o regiune sau să dai clic pe o fereastră sau pe un monitor.

Înregistrarea rulează pe gpu-screen-recorder, care codifică pe GPU la 60fps și revine la CPU dacă trebuie. Rezultatul este un MP4 în `~/Videos`, numit `screenrecording-2026-08-13_14-22-05.mp4`. Setează `OMARCHY_SCREENRECORD_DIR` ca să schimbi asta — dar reține că, spre deosebire de directorul pentru capturi de ecran, acesta trebuie să existe deja, altfel înregistrarea refuză să pornească.

Cât timp înregistrezi, în bară apare un mic indicator. Dă clic pe el ca să oprești. Poți opri și cu `Alt + Print Screen` din nou sau cu intrarea _Stop Screenrecording_ de sub _Trigger > Capture > Screenrecord_, care apare doar cât timp chiar se înregistrează ceva.

Oprirea face puțină curățenie înainte să-ți dea fișierul: primul cadru este tăiat, iar dacă există sunet, acesta este normalizat la -14 LUFS, cu pocnitura de captură PipeWire de chiar la început eliminată în surdină. Apoi apare o notificare cu o miniatură din înregistrare. Dă clic pe ea ca să redai fișierul în mpv.

### Suprapunerea webcam

Când înregistrezi cu o webcam, camera apare ca o fereastră portret fixată și decupată în colțul din dreapta jos al a ceea ce înregistrezi. Dacă stă peste ceva de care ai nevoie, redimensioneaz-o din mers:

| Tastă rapidă | Funcție |
| ------ | -------- |
| `Super + Alt + [` | Micșorează suprapunerea webcam |
| `Super + Alt + ]` | Mărește suprapunerea webcam |

Există trei dimensiuni — mică, medie și mare — iar tastele rapide trec de la una la alta. Cea medie este implicită. Sunt proporționale cu înregistrarea, așa că camera ocupă aceeași parte din cadru indiferent dacă înregistrezi un monitor 1080p sau unul 6K. Iar dacă ai înregistrat o regiune, nu un întreg ecran, suprapunerea se ancorează în colțul acelei regiuni, nu al monitorului, așa că rămâne în interiorul capturii.

O poți apela și direct cu `omarchy-capture-webcam-resize small` sau cu `reset` ca să revii la medie.

## Text, coduri QR și culori

`Super + Ctrl + Print Screen` selectează o regiune și îi face OCR în clipboard. Asta este tratat cum trebuie în [Extragerea textului și dictare](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ face același truc pentru codurile QR. Selectează regiunea cu codul în ea, iar valoarea decodificată ajunge în clipboard. Caută doar coduri QR — conținutul dens de pe ecran are obiceiul să dea fals pozitive ca cod de bare în alte cazuri. Merită știut: valoarea decodificată ajunge în clipboard și nicăieri altundeva. Nu este tipărită, nu este în notificare și este marcată ca sensibilă, așa că nu rămâne în [istoricul clipboardului](08-unified-clipboard-history.md). Codurile QR transportă în mod obișnuit secrete — URI-ul `otpauth://` din spatele unui cod de configurare 2FA, de exemplu — și nu vrei așa ceva într-un jurnal. Lipirea funcționează în continuare fără probleme.

`Super + Print Screen` (sau _Trigger > Capture > Color_) transformă cursorul într-o pipetă. Dă clic pe orice de pe ecran, iar culoarea ajunge în clipboard. Apasă din nou tasta rapidă ca să ieși fără să alegi.

## Transcodarea înainte de a partaja

O înregistrare de ecran 4K sau un HEIC brut de pe telefon este adesea prea mare ca pur și simplu s-o trimiți. `Super + Ctrl + .` (sau _Trigger > Transcode_) rezolvă asta. Îți oferă un selector de fișiere cu căutare fuzzy peste `~/Pictures` și `~/Videos`, apoi te întreabă formatul și dimensiunea.

Imaginile ajung în jpg sau png la calitate înaltă, medie sau scăzută, care limitează lățimea la 3160, 2160 și 1080 pixeli. Videoclipurile ajung în mp4 sau într-un gif animat la 4k, 1080p sau 720p. Fișierul convertit este scris lângă original, cu rezoluția în nume — `demo-1080p.mp4` — iar calea este copiată în clipboard ca URI de fișier, așa că îl poți lipi direct într-o aplicație care acceptă fișiere trase în ea.

Funcționează și din terminal, dacă știi deja ce vrei: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Există și `omarchy transcode ascii`, care transformă o imagine în artă ASCII — asta e mai ales pentru [branding](41-branding.md).

## Trimiterea undeva

Odată ce ai fișierul, `Super + Ctrl + S` deschide meniul Share și îl trimite către alt dispozitiv din rețeaua ta prin LocalSend. Vezi [GUIs](22-guis.md) pentru asta.
