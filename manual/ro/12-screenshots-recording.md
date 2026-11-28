# Capturi de ecran și înregistrare

Tot ce poți captura de pe ecran depinde de tasta Print Screen. O tastă singură face o fotografie, iar modificatorii fac o înregistrare, aleg o culoare sau iau textul dintr-o regiune. Dacă tastatura ta nu are deloc o tastă Print Screen, `Super + Ctrl + Alt + C` face aceeași captură de ecran, iar `Super + Ctrl + C` deschide tot setul ca meniu.

| Comandă rapidă | Funcție |
| ------ | -------- |
| `Print Screen` | Captură de ecran |
| `Super + Ctrl + Alt + C` | Captură de ecran |
| `Alt + Print Screen` | Înregistrare ecran (sau oprește înregistrarea în curs) |
| `Super + Print Screen` | Selector de culoare |
| `Super + Ctrl + Print Screen` | Extrage textul dintr-o regiune |
| `Super + Ctrl + C` | Meniu de captură |
| `Super + Ctrl + .` | Transcodează o imagine sau un videoclip |

## Capturi de ecran

Apasă `Print Screen` (sau `Super + Ctrl + Alt + C`) și Omasnap capturează monitorul focalizat înainte să apară suprapunerea lui, așa că nimic nu se mișcă sub tine cât timp țintești. Trage o regiune cu formă liberă, dă clic pe o fereastră ca să o capturezi sau dă clic pe un spațiu gol ca să capturezi tot monitorul. Apasă `S` înainte să desenezi ca să capturezi o regiune cu derulare. Te-ai răzgândit? Apasă din nou aceeași tastă ca să închizi Omasnap.

După ce selectezi o zonă, Omasnap salvează captura, o copiază în clipboard și afișează o notificare cu miniatura ei, la fel cum face o înregistrare de ecran salvată. Alege Open ca să vezi captura salvată în vizualizatorul tău de imagini sau Edit ca să o adnotezi.

Editorul de adnotări poate desena săgeți, linii, forme, evidențieri, marcaje numerotate, text și redactări sigure; poate decupa sau tăia o parte din imagine; poate extrage textul din ea prin OCR; și poate adăuga un fundal. În editor, apasă `Enter` ca să copiezi și să salvezi PNG-ul final, `Ctrl + C` ca să îl copiezi fără să îl salvezi sau `Ctrl + S` ca să îl salvezi fără să îl copiezi.

Capturile de ecran salvate ajung implicit în `~/Pictures/Screenshots`, cu un nume precum `screenshot-2026-08-13_14-22-05-firefox.png`. Setează `OMASNAP_SCREENSHOT_DIR` ca să folosești alt director — vezi [întrebările frecvente](46-faq.md) pentru unde se pun variabilele de mediu ale sesiunii. Omasnap creează directorul când salvează prima captură. Setează `[output] autosave = false` în `~/.config/omasnap/omasnap.conf` ca să dezactivezi salvarea automată; capturile sunt atunci doar copiate și afișate într-o previzualizare timp de 7 secunde, pe care o poți ține pe ecran cu butonul ei de fixare sau cu `Ctrl + P`.

Din terminal, `omarchy screenshot` deschide aceeași suprapunere și îi poți alege modul de pornire: `omarchy capture screenshot region`, `windows`, `fullscreen` sau `scroll`. Un al doilea argument, `copy` sau `save`, trimite captura direct la destinația respectivă. Ca să editezi înainte de ieșire, folosește `omarchy screenshot --editor=overlay` pentru un editor pe tot ecranul sau `omarchy screenshot --editor=window` pentru o fereastră separată.

### Controlul selectorului de la tastatură

Cât timp selecția este afișată, nu trebuie să folosești deloc mouse-ul:

| Tastă | Funcție |
| --- | -------- |
| `S` | Activează/dezactivează modul regiune cu derulare |
| `Super + Arrow keys` | Deplasare între ferestre în modul Window |
| `Return` | Capturează fereastra evidențiată |
| `Ctrl + A` | Capturează întregul monitor focalizat |
| `R` | Restaurează ultima regiune desenată în această sesiune |
| `Esc` | Închide Omasnap |

Aceste combinații există doar cât timp Omasnap este deschis, așa că nu pot intra în conflict cu nimic din configurația ta.

## Înregistrarea ecranului

`Alt + Print Screen` deschide _Trigger > Capture > Screenrecord_, care te întreabă ce vrei pe coloana sonoră: fără audio, audio de pe desktop, desktop plus microfon sau desktop plus microfon plus webcam. Ultima variantă apare doar dacă chiar ai o cameră conectată. Alege una, iar selectorul de înregistrare din Omarchy te lasă să tragi o regiune sau să dai clic pe o fereastră sau pe un monitor.

Înregistrarea rulează pe gpu-screen-recorder, care codifică pe GPU la 60fps și revine la CPU dacă trebuie; pe GPU-urile pe care nu le acceptă, cum sunt cele Apple Silicon, Omarchy înregistrează în schimb cu wf-recorder. Rezultatul este un MP4 în `~/Videos`, denumit `screenrecording-2026-08-13_14-22-05.mp4`. Setează `OMARCHY_SCREENRECORD_DIR` ca să schimbi asta — dar reține că, spre deosebire de directorul pentru capturi de ecran, acesta trebuie să existe deja, altfel înregistrarea refuză să pornească.

În timp ce înregistrezi, în bară apare un mic indicator. Dă clic pe el ca să oprești. Poți opri și cu `Alt + Print Screen` din nou sau cu intrarea _Stop Screenrecording_ de sub _Trigger > Capture > Screenrecord_, care apare doar cât timp chiar se înregistrează ceva.

Oprirea face puțină ordine înainte să îți dea fișierul: primul cadru este tăiat, iar dacă există audio, acesta este normalizat la -14 LUFS, cu pocnetul de captură PipeWire de la început redus la tăcere. Apoi apare o notificare cu o miniatură din înregistrare. Alege _Open_ ca să redai fișierul în Omaview sau _Cut_ ca să îl tai în Omacut.

### Suprapunerea webcam

Când înregistrezi cu o webcam, camera apare ca o fereastră portret fixată și decupată în colțul din dreapta jos al zonei pe care o înregistrezi. Dacă stă peste ceva de care ai nevoie, o poți redimensiona din mers:

| Comandă rapidă | Funcție |
| ------ | -------- |
| `Super + Alt + [` | Face suprapunerea webcam mai mică |
| `Super + Alt + ]` | Face suprapunerea webcam mai mare |

Există trei dimensiuni — mică, medie și mare — iar comenzile rapide trec de la una la alta. Dimensiunea medie este cea implicită. Sunt proporționale cu înregistrarea, așa că camera ocupă aceeași parte din cadru fie că înregistrezi un monitor 1080p, fie unul 6K. Iar dacă ai înregistrat o regiune, nu un întreg ecran, suprapunerea se ancorează în colțul acelei regiuni, nu al monitorului, așa că rămâne în interiorul capturii.

O poți apela și direct cu `omarchy-capture-webcam-resize small` sau cu `reset` ca să revii la dimensiunea medie.

## Text, coduri QR și culori

`Super + Ctrl + Print Screen` selectează o regiune și îi extrage textul prin OCR în clipboard. Asta este tratat cum trebuie în [Extragerea textului și dictarea](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ face același truc pentru codurile QR. Selectează regiunea în care se află codul, iar valoarea decodificată ajunge în clipboard. Caută doar coduri QR — în rest, conținutul dens de pe ecran are obiceiul să dea rezultate fals pozitive ca un cod de bare. Merită știut: valoarea decodificată ajunge în clipboard și nicăieri altundeva. Nu este tipărită, nu este în notificare și este marcată ca sensibilă, așa că nu rămâne în [istoricul clipboardului](08-unified-clipboard-history.md). Codurile QR cară în mod obișnuit secrete — URI-ul `otpauth://` din spatele unui cod de configurare 2FA, de exemplu — și nu vrei așa ceva într-un jurnal. Lipirea funcționează în continuare fără probleme.

`Super + Print Screen` (sau _Trigger > Capture > Color_) transformă cursorul într-o pipetă. Dă clic pe orice de pe ecran, iar culoarea ajunge în clipboard. Apasă din nou comanda rapidă ca să renunți fără să alegi ceva.

## Transcodarea înainte de partajare

O înregistrare de ecran 4K sau un HEIC brut de pe telefon este adesea prea mare ca să îl trimiți pur și simplu. `Super + Ctrl + .` (sau _Trigger > Transcode_) rezolvă asta. Îți oferă un selector de fișiere cu căutare fuzzy peste `~/Pictures` și `~/Videos`, apoi te întreabă ce format și ce dimensiune vrei.

Imaginile ajung la jpg sau png la calitate înaltă, medie sau joasă, care limitează lățimea la 3160, 2160 și 1080 pixeli. Videoclipurile ajung la mp4 sau la un gif animat la 4k, 1080p sau 720p. Fișierul convertit este scris lângă original, cu rezoluția în nume — `demo-1080p.mp4` — iar calea este copiată în clipboard ca URI de fișier, așa că îl poți lipi direct într-o aplicație care acceptă fișiere trase peste ea.

Funcționează și din terminal, dacă știi deja ce vrei: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Există și `omarchy transcode ascii`, care transformă o imagine în artă ASCII — asta este mai ales pentru [branding](41-branding.md).

## Trimiterea undeva

Odată ce ai fișierul, `Super + Ctrl + S` deschide meniul Share și îl trimite către alt dispozitiv din rețeaua ta prin LocalSend. Vezi [GUI-uri](22-guis.md) pentru asta.
