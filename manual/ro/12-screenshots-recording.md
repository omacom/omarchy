# Capturi de ecran și înregistrare

Tot ce poți lua de pe ecran depinde de tasta Print Screen. O singură tastă singură face o poză, iar modificatorii fac o înregistrare, o culoare sau textul din interiorul unei regiuni. Dacă tastatura ta nu are deloc o tastă Print Screen, `Super + Ctrl + Alt + C` face aceeași captură de ecran, iar `Super + Ctrl + C` deschide tot setul ca meniu.

| Tastă rapidă | Funcție |
| ------ | -------- |
| `Print Screen` | Captură de ecran |
| `Super + Ctrl + Alt + C` | Captură de ecran |
| `Alt + Print Screen` | Înregistrarea ecranului (sau oprește înregistrarea care rulează) |
| `Super + Print Screen` | Selector de culoare |
| `Super + Ctrl + Print Screen` | Extrage textul dintr-o regiune |
| `Super + Ctrl + C` | Meniu de captură |
| `Super + Ctrl + .` | Transcodează o poză sau un videoclip |

## Capturi de ecran

Apasă `Print Screen` (sau `Super + Ctrl + Alt + C`) și Omasnap capturează monitorul focalizat înainte să-i apară suprapunerea, așa că nimic nu se mișcă sub tine cât timp țintești. Trage o regiune cu formă liberă, dă clic pe o fereastră ca s-o capturezi sau dă clic pe spațiul gol ca să capturezi tot monitorul. Apasă `S` înainte să desenezi ca să capturezi o regiune cu derulare. Te-ai răzgândit? Apasă aceeași tastă din nou ca să închizi Omasnap.

După ce selectezi o zonă, Omasnap salvează captura, o copiază în clipboard și arată o notificare cu miniatura ei, la fel cum face o înregistrare de ecran salvată. Alege Open ca să vezi poza salvată în vizualizatorul tău de imagini sau Edit ca s-o adnotezi.

Editorul de adnotări poate desena săgeți, linii, forme, evidențieri, marcatori numerotați, text și redactări sigure; poate decupa sau tăia o parte din imagine; îi poate extrage textul prin OCR; și poate adăuga un fundal. În editor, apasă `Enter` ca să copiezi și să salvezi PNG-ul final, `Ctrl + C` ca să-l copiezi fără să-l salvezi sau `Ctrl + S` ca să-l salvezi fără să-l copiezi.

Capturile de ecran salvate ajung implicit în `~/Pictures/Screenshots`, cu un nume precum `screenshot-2026-08-13_14-22-05-firefox.png`. Setează `OMASNAP_SCREENSHOT_DIR` ca să folosești alt director — vezi [întrebările frecvente](46-faq.md) pentru unde se pun variabilele de mediu ale sesiunii. Omasnap creează directorul când salvează prima poză. Setează `[output] autosave = false` în `~/.config/omasnap/omasnap.conf` ca să dezactivezi salvarea automată; capturile sunt atunci doar copiate și arătate într-o previzualizare timp de 10 secunde, pe care o poți ține pe ecran cu butonul ei de fixare sau cu `Ctrl + P`.

Din terminal, `omarchy screenshot` deschide aceeași suprapunere și îi poți alege modul de pornire: `omarchy capture screenshot region`, `windows`, `fullscreen` sau `scroll`. Un al doilea argument, `copy` sau `save`, trimite poza direct la destinația respectivă. Ca să editezi înainte de ieșire, folosește `omarchy screenshot --editor=overlay` pentru un editor pe tot ecranul sau `omarchy screenshot --editor=window` pentru o fereastră separată.

### Controlul selectorului de la tastatură

Cât timp selecția este deschisă, nu trebuie să folosești deloc mouse-ul:

| Tastă | Funcție |
| --- | -------- |
| `S` | Comută modul regiune cu derulare |
| `Super + Arrow keys` | Mută-te între ferestre în modul Window |
| `Return` | Capturează fereastra evidențiată |
| `Ctrl + A` | Capturează tot monitorul focalizat |
| `R` | Restaurează ultima regiune desenată în această sesiune |
| `Esc` | Închide Omasnap |

Aceste legături există doar cât timp Omasnap este deschis, așa că nu pot intra în conflict cu nimic din configul tău.

## Înregistrarea ecranului

`Alt + Print Screen` deschide _Trigger > Capture > Screenrecord_, care te întreabă ce vrei pe coloana sonoră: fără audio, audio de pe desktop, desktop plus microfon sau desktop plus microfon plus cameră web. Ultima variantă apare doar dacă chiar ai o cameră conectată. Alege una și selectorul de înregistrare din Omarchy te lasă să tragi o regiune sau să dai clic pe o fereastră ori pe un monitor.

Înregistrarea rulează pe gpu-screen-recorder, care codează pe GPU la 60fps și trece pe CPU dacă trebuie. Rezultatul este un MP4 în `~/Videos`, numit `screenrecording-2026-08-13_14-22-05.mp4`. Setează `OMARCHY_SCREENRECORD_DIR` ca să schimbi asta — dar reține că, spre deosebire de directorul pentru capturi de ecran, acesta trebuie să existe deja, altfel înregistrarea refuză să pornească.

Cât timp înregistrezi, în bară apare un mic indicator. Dă clic pe el ca să oprești. Poți opri și cu `Alt + Print Screen` din nou sau cu intrarea _Stop Screenrecording_ de sub _Trigger > Capture > Screenrecord_, care apare doar cât timp chiar se înregistrează ceva.

Oprirea face puțină ordine înainte să-ți dea fișierul: primul cadru este tăiat, iar dacă există audio, este normalizat la -14 LUFS, cu pocnetul de captură PipeWire de chiar la început scos pe mut. Apoi apare o notificare cu o miniatură din înregistrare. Dă clic pe ea ca să redai fișierul în Omaview.

### Suprapunerea camerei web

Când înregistrezi cu o cameră web, camera apare ca o fereastră portret fixată și decupată în colțul din dreapta jos al a ceea ce înregistrezi. Dacă stă peste ceva de care ai nevoie, redimensioneaz-o din mers:

| Tastă rapidă | Funcție |
| ------ | -------- |
| `Super + Alt + [` | Micșorează suprapunerea camerei web |
| `Super + Alt + ]` | Mărește suprapunerea camerei web |

Există trei mărimi — mică, medie și mare — iar tastele rapide trec de la una la alta. Medie este mărimea implicită. Sunt proporționale cu înregistrarea, așa că camera ocupă aceeași parte din cadru fie că înregistrezi un monitor 1080p, fie unul 6K. Iar dacă ai înregistrat o regiune, nu tot ecranul, suprapunerea se ancorează în colțul regiunii respective, nu al monitorului, așa că rămâne în interiorul pozei.

O poți apela și direct cu `omarchy-capture-webcam-resize small` sau cu `reset` ca să revii la medie.

## Text, coduri QR și culori

`Super + Ctrl + Print Screen` selectează o regiune și îi extrage textul prin OCR în clipboard. Asta este explicat cum trebuie în [Extragerea textului și dictare](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ face același truc pentru codurile QR. Selectează regiunea în care se află codul, iar valoarea decodată ajunge în clipboard. Caută doar coduri QR — altfel, conținutul dens de pe ecran are obiceiul să fie detectat fals drept cod de bare. Bine de știut: valoarea decodată ajunge în clipboard și nicăieri altundeva. Nu este tipărită, nu este în notificare și este marcată ca sensibilă, ca să nu rămână în [istoricul clipboardului](08-unified-clipboard-history.md). Codurile QR cară de obicei secrete — URI-ul `otpauth://` din spatele unui cod de configurare 2FA, de exemplu — și nu vrei așa ceva într-un jurnal. Lipirea merge în continuare fără probleme.

`Super + Print Screen` (sau _Trigger > Capture > Color_) transformă cursorul într-o pipetă. Dă clic pe orice de pe ecran și culoarea ajunge în clipboard. Apasă tasta rapidă din nou ca să ieși fără să alegi nimic.

## Transcodarea înainte să distribui

O înregistrare de ecran 4K sau un HEIC brut de pe telefon este adesea prea mare ca să-l trimiți pur și simplu. `Super + Ctrl + .` (sau _Trigger > Transcode_) rezolvă asta. Îți oferă un selector de fișiere cu căutare aproximativă peste `~/Pictures` și `~/Videos`, apoi te întreabă formatul și mărimea.

Pozele merg în jpg sau png la calitate mare, medie sau mică, care limitează lățimea la 3160, 2160 și 1080 pixeli. Videoclipurile merg în mp4 sau gif animat la 4k, 1080p sau 720p. Fișierul convertit este scris lângă original, cu rezoluția în nume — `demo-1080p.mp4` — iar calea este copiată în clipboard ca URI de fișier, așa că îl poți lipi direct într-o aplicație care acceptă fișiere trase peste ea.

Merge și din terminal, dacă știi deja ce vrei: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Există și `omarchy transcode ascii`, care transformă o imagine în artă ASCII — asta e mai ales pentru [branding](41-branding.md).

## Trimiterea undeva

După ce ai fișierul, `Super + Ctrl + S` deschide meniul Share și îl trimite altui dispozitiv din rețeaua ta prin LocalSend. Pentru asta, vezi [Interfețe grafice](22-guis.md).
