# Capturi de ecran și înregistrare

Tot ce poți lua de pe ecran atârnă de tasta Print Screen. O singură tastă face o fotografie, iar modificatorii fac o înregistrare, iau o culoare sau textul din interiorul unei regiuni. Dacă tastatura ta nu are deloc o tastă Print Screen, `Super + Ctrl + C` deschide același set ca meniu.

| Scurtătură | Funcție |
| ------ | -------- |
| `Print Screen` | Captură de ecran |
| `Alt + Print Screen` | Înregistrare ecran (sau oprește-o pe cea care rulează) |
| `Super + Print Screen` | Selector de culoare |
| `Super + Ctrl + Print Screen` | Extrage text dintr-o regiune |
| `Super + Ctrl + C` | Meniu Captură |
| `Super + Ctrl + .` | Transcodează o imagine sau un video |

## Capturi de ecran

Apasă `Print Screen` și Omasnap capturează monitorul focalizat înainte să apară suprapunerea lui, astfel încât nimic nu se mișcă sub tine cât țintești. Trage o regiune liberă, fă clic pe o fereastră ca să o capturezi sau fă clic pe spațiul deschis ca să capturezi întregul monitor. Apasă `S` înainte să desenezi ca să capturezi o regiune defilantă. Te-ai răzgândit? Apasă din nou `Print Screen` ca să închizi Omasnap.

După ce selectezi o zonă, Omasnap salvează captura, o copiază pe clipboard și arată o previzualizare timp de 10 secunde. Folosește butonul de fixare al previzualizării sau `Ctrl + P` ca să o păstrezi pe ecran sau alege Edit ca să o adnotezi.

Editorul de adnotare poate desena săgeți, linii, forme, evidențieri, marcaje numerotate, text și cenzurări sigure; poate decupa sau tăia o parte din imagine; poate face OCR pe textul ei; și poate adăuga un fundal. În editor, apasă `Enter` ca să copiezi și să salvezi PNG-ul terminat, `Ctrl + C` ca să-l copiezi fără să-l salvezi sau `Ctrl + S` ca să-l salvezi fără să-l copiezi.

Capturile de ecran salvate ajung implicit în `~/Pictures/Screenshots`, cu un nume precum `screenshot-2026-08-13_14-22-05-firefox.png`. Setează `OMASNAP_SCREENSHOT_DIR` ca să folosești alt director — vezi [întrebările frecvente](46-faq.md) pentru locul în care să pui variabilele de mediu ale sesiunii. Omasnap creează directorul atunci când salvează prima captură. Setează `[output] autosave = false` în `~/.config/omasnap/omasnap.conf` ca să dezactivezi salvarea automată.

Din terminal, `omarchy screenshot` deschide aceeași suprapunere și îi poți alege modul de pornire: `omarchy capture screenshot region`, `windows`, `fullscreen` sau `scroll`. Un al doilea argument, `copy` sau `save`, sare peste previzualizare și trimite captura direct la destinația aceea. Ca să editezi înainte de ieșire, folosește `omarchy screenshot --editor=overlay` pentru un editor pe tot ecranul sau `omarchy screenshot --editor=window` pentru o fereastră separată.

### Conducerea selectorului de la tastatură

Cât selecția este afișată, nu trebuie să folosești deloc mouse-ul:

| Tastă | Funcție |
| --- | -------- |
| `S` | Comută modul de regiune defilantă |
| `Super + Arrow keys` | Te muți între ferestre în modul Fereastră |
| `Return` | Capturează fereastra evidențiată |
| `Ctrl + A` | Capturează întregul monitor focalizat |
| `R` | Restabilește ultima regiune desenată în această sesiune |
| `Esc` | Închide Omasnap |

Aceste mapări există doar cât Omasnap este deschis, așa că nu se pot ciocni cu nimic din configurația ta.

## Înregistrarea ecranului

`Alt + Print Screen` deschide _Declanșator > Captură > Înregistrare ecran_, care întreabă ce vrei pe coloana sonoră: fără sunet, sunet desktop, desktop plus microfon sau desktop plus microfon plus webcam. Ultima apare doar dacă chiar ai o cameră conectată. Alege una și selectorul de înregistrare al Omarchy îți permite să tragi o regiune sau să faci clic pe o fereastră sau un monitor.

Înregistrarea rulează pe gpu-screen-recorder, care codează pe GPU la 60 fps și revine la CPU dacă trebuie. Rezultatul este un MP4 în `~/Videos`, numit `screenrecording-2026-08-13_14-22-05.mp4`. Setează `OMARCHY_SCREENRECORD_DIR` ca să schimbi asta — dar reține că, spre deosebire de directorul capturilor de ecran, acesta trebuie să existe deja, altfel înregistrarea refuză să pornească.

Cât înregistrezi, în bară apare un mic indicator. Fă clic pe el ca să oprești. Poți opri și cu `Alt + Print Screen` din nou sau cu intrarea _Oprește înregistrarea_ de sub _Declanșator > Captură > Înregistrare ecran_, care apare doar cât timp ceva înregistrează cu adevărat.

Oprirea face puțină curățenie înainte să-ți înmâneze fișierul: primul cadru este tăiat și, dacă există sunet, este normalizat la -14 LUFS, cu pocnitura de captură PipeWire de la începutul începutului dezactivată. Apoi apare o notificare cu o miniatură din înregistrare. Fă clic pe ea ca să redai fișierul în mpv.

### Suprapunerea webcam

Atunci când înregistrezi cu o cameră web, camera apare ca o fereastră-portret fixată și decupată, în colțul din dreapta jos al oricărui lucru pe care îl înregistrezi. Dacă stă peste ceva de care ai nevoie, redimensioneaz-o din mers:

| Scurtătură | Funcție |
| ------ | -------- |
| `Super + Alt + [` | Face suprapunerea webcam mai mică |
| `Super + Alt + ]` | Face suprapunerea webcam mai mare |

Există trei dimensiuni — mică, medie și mare — iar scurtăturile pășesc între ele. Media este implicită. Sunt proporționale cu înregistrarea, astfel încât camera ocupă aceeași cotă din cadru fie că înregistrezi un monitor 1080p, fie unul 6K. Și, dacă ai înregistrat o regiune mai degrabă decât un întreg afișaj, suprapunerea se ancorează în colțul regiunii, mai degrabă decât în cel al monitorului, astfel încât rămâne în interiorul capturii.

O poți apela și direct cu `omarchy-capture-webcam-resize small` sau cu `reset` ca să revii la medie.

## Text, coduri QR și culori

`Super + Ctrl + Print Screen` selectează o regiune și o trece prin OCR pe clipboard. Asta este tratat cum se cuvine în [Extragerea textului și dictarea](11-text-extraction-dictation.md).

_Declanșator > Captură > Cod QR_ face același truc pentru codurile QR. Selectează regiunea în care se află codul, iar valoarea decodată ajunge pe clipboard. Caută doar coduri QR — altfel, conținutul dens de ecran are obiceiul de a da rezultate fals pozitive ca cod de bare. Merită știut: valoarea decodată ajunge pe clipboard și nicăieri altundeva. Nu este tipărită, nu este în notificare și este marcată sensibilă, astfel încât să nu rămână în [istoricul clipboard](08-unified-clipboard-history.md). Codurile QR poartă în mod obișnuit secrete — URI-ul `otpauth://` din spatele unui cod de configurare 2FA, de exemplu — și nu vrei asta într-un jurnal. Lipirea funcționează în continuare bine.

`Super + Print Screen` (sau _Declanșator > Captură > Culoare_) transformă cursorul într-o pipetă. Fă clic pe orice de pe ecran, iar culoarea ajunge pe clipboard. Apasă scurtătura din nou ca să te retragi fără să alegi.

## Transcodarea înainte de a partaja

O înregistrare de ecran 4K sau un HEIC brut de pe telefon este adesea prea mare ca să o trimiți pur și simplu. `Super + Ctrl + .` (sau _Declanșator > Transcodează_) rezolvă asta. Îți oferă un selector difuz de fișiere peste `~/Pictures` și `~/Videos`, apoi cere un format și o dimensiune.

Imaginile ajung jpg sau png la calitate înaltă, medie sau joasă, care limitează lățimea la 3160, 2160 și 1080 de pixeli. Videoclipurile ajung mp4 sau un gif animat la 4k, 1080p sau 720p. Fișierul convertit este scris lângă original, cu rezoluția în nume — `demo-1080p.mp4` — iar calea este copiată pe clipboard ca URI de fișier, astfel încât o poți lipi direct într-o aplicație care acceptă fișiere trăsnite.

Funcționează și din terminal, dacă știi deja ce vrei: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Există și `omarchy transcode ascii`, care transformă o imagine în artă ASCII — aceea este mai ales pentru [branding](41-branding.md).

## Trimiterea undeva

Odată ce ai fișierul, `Super + Ctrl + S` deschide meniul Partajează și îl trimite pe alt dispozitiv din rețeaua ta prin LocalSend. Vezi [GUI-urile](22-guis.md) pentru asta.
