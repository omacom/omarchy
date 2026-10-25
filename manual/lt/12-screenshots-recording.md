# Ekrano nuotraukos ir įrašymas

Viskas, ką galite pagriebti iš ekrano, kabo ant Print Screen klavišo. Vienas klavišas pats vienas padaro nuotrauką, o modifikatoriai padaro įrašą, paima spalvą arba tekstą regiono viduje. Jei jūsų klaviatūra išvis neturi Print Screen klavišo, `Super + Ctrl + Alt + C` padaro tą pačią ekrano nuotrauką, o `Super + Ctrl + C` atveria visą rinkinį kaip meniu.

| Klavišų derinys | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrano nuotrauka |
| `Super + Ctrl + Alt + C` | Ekrano nuotrauka |
| `Alt + Print Screen` | Ekrano įrašymas (arba sustabdyti jau vykstantį) |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Išskirti tekstą iš regiono |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Super + Ctrl + .` | Perkonvertuoti paveikslėlį arba vaizdo įrašą |

## Ekrano nuotraukos

Paspauskite `Print Screen` (arba `Super + Ctrl + Alt + C`) ir Omasnap užfiksuoja sufokusuotą monitorių dar prieš pasirodant jo perdangai, todėl niekas nepaslenka po jumis, kol taikotės. Vilkite laisvos formos regioną, spustelėkite langą, kad jį užfiksuotumėte, arba spustelėkite tuščią vietą, kad užfiksuotumėte visą monitorių. Paspauskite `S` prieš braižydami, kad užfiksuotumėte slenkantį regioną. Apsigalvojote? Paspauskite tą patį klavišą dar kartą, kad uždarytumėte Omasnap.

Išsirinkus sritį, Omasnap išsaugo fiksavimą, nukopijuoja jį į iškarpinę ir 10 sekundžių rodo peržiūrą. Naudokite peržiūros prisegimo mygtuką arba `Ctrl + P`, kad ji liktų ekrane, arba pasirinkite Edit, kad ją anotuotumėte.

Anotacijų redaktorius gali piešti rodykles, linijas, figūras, paryškinimus, sunumeruotus žymeklius, tekstą ir saugius redagavimus; apkirpti arba iškirpti dalį vaizdo; atpažinti jo tekstą OCR būdu; ir pridėti foną. Redaktoriuje paspauskite `Enter`, kad nukopijuotumėte ir išsaugotumėte baigtą PNG, `Ctrl + C`, kad jį nukopijuotumėte neišsaugodami, arba `Ctrl + S`, kad jį išsaugotumėte nenukopijuodami.

Išsaugotos ekrano nuotraukos pagal numatytuosius nustatymus patenka į `~/Pictures/Screenshots`, pavadintos, pavyzdžiui, `screenshot-2026-08-13_14-22-05-firefox.png`. Nustatykite `OMASNAP_SCREENSHOT_DIR`, kad naudotumėte kitą katalogą — žr. [DUK](46-faq.md), kur nurodyta, kur dėti sesijos aplinkos kintamuosius. Omasnap sukuria katalogą, kai išsaugo pirmąją nuotrauką. Nustatykite `[output] autosave = false` faile `~/.config/omasnap/omasnap.conf`, kad išjungtumėte automatinį išsaugojimą.

Iš terminalo `omarchy screenshot` atveria tą pačią perdangą, o jūs galite pasirinkti jos pradinį režimą: `omarchy capture screenshot region`, `windows`, `fullscreen` arba `scroll`. Antras argumentas `copy` arba `save` praleidžia peržiūrą ir nusiunčia nuotrauką tiesiai į tą paskirties vietą. Kad redaguotumėte prieš išvestį, naudokite `omarchy screenshot --editor=overlay` viso ekrano redaktoriui arba `omarchy screenshot --editor=window` atskiram langui.

### Parinkiklio valdymas klaviatūra

Kol pasirinkimas atvertas, pelės jums išvis nereikia:

| Klavišas | Funkcija |
| --- | -------- |
| `S` | Perjungti slenkančio regiono režimą |
| `Super + Arrow keys` | Judėti tarp langų Window režime |
| `Return` | Užfiksuoti paryškintą langą |
| `Ctrl + A` | Užfiksuoti visą sufokusuotą monitorių |
| `R` | Atkurti paskutinį šioje sesijoje nubraižytą regioną |
| `Esc` | Uždaryti Omasnap |

Šie susiejimai egzistuoja tik kol Omasnap atvertas, todėl jie negali susikirsti su niekuo jūsų pačių konfigūracijoje.

## Ekrano įrašymas

`Alt + Print Screen` atveria _Trigger > Capture > Screenrecord_, kuris paklausia, ko norite garso takelyje: jokio garso, darbalaukio garso, darbalaukio ir mikrofono arba darbalaukio, mikrofono ir internetinės kameros. Pastarasis variantas rodomas tik jei iš tikrųjų turite prijungtą kamerą. Pasirinkite vieną, ir Omarchy įrašymo parinkiklis leis jums vilkti regioną arba spustelėti langą ar monitorių.

Įrašymas veikia per gpu-screen-recorder, kuris koduoja GPU aparatiškai 60fps ir, jei tenka, grįžta prie CPU. Rezultatas yra MP4 faile `~/Videos`, pavadintas `screenrecording-2026-08-13_14-22-05.mp4`. Nustatykite `OMARCHY_SCREENRECORD_DIR`, kad tai pakeistumėte — bet atminkite, kad, kitaip nei ekrano nuotraukų katalogas, šis jau turi egzistuoti, antraip įrašymas atsisakys prasidėti.

Kol įrašinėjate, juostoje pasirodo mažas indikatorius. Spustelėkite jį, kad sustabdytumėte. Taip pat galite sustabdyti dar kartą paspaudę `Alt + Print Screen` arba pasirinkę įrašą _Stop Screenrecording_ po _Trigger > Capture > Screenrecord_, kuris pasirodo tik kol kas nors iš tikrųjų įrašinėjama.

Sustabdymas prieš atiduodamas jums failą šiek tiek jį sutvarko: pirmasis kadras apkerpamas, o jei yra garsas, jis normalizuojamas iki -14 LUFS, o pačioje pradžioje esantis PipeWire fiksavimo spragtelėjimas nutildomas. Tada pasirodo pranešimas su miniatiūra iš įrašo. Spustelėkite jį, kad paleistumėte failą mpv grotuve.

### Internetinės kameros perdanga

Kai įrašinėjate su internetine kamera, kamera pasirodo kaip prisegtas, apkirptas portretinis langas apatiniame dešiniajame kampe to, ką įrašinėjate. Jei ji guli ant ko nors, ko jums reikia, keiskite jos dydį eigoje:

| Klavišų derinys | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Padaryti internetinės kameros perdangą mažesnę |
| `Super + Alt + ]` | Padaryti internetinės kameros perdangą didesnę |

Yra trys dydžiai — mažas, vidutinis ir didelis — o klavišų deriniai žingsniuoja tarp jų. Vidutinis yra numatytasis. Jie proporcingi įrašui, todėl kamera užima tą pačią kadro dalį, nesvarbu, ar įrašinėjate 1080p monitorių, ar 6K. O jei įrašėte regioną, o ne visą ekraną, perdanga prisitvirtina prie to regiono kampo, o ne monitoriaus, todėl lieka kadro viduje.

Taip pat galite ją iškviesti tiesiogiai su `omarchy-capture-webcam-resize small` arba `reset`, kad grįžtumėte prie vidutinio dydžio.

## Tekstas, QR kodai ir spalvos

`Super + Ctrl + Print Screen` pasirenka regioną ir OCR būdu perkelia jo tekstą į iškarpinę. Tai tinkamai aptarta skyriuje [Teksto išskyrimas ir diktavimas](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ atlieka tą patį triuką su QR kodais. Pasirinkite regioną su kodu jame, ir išdekoduota reikšmė nukeliauja į iškarpinę. Jis ieško tik QR kodų — tankus ekrano turinys kitais atvejais linkęs būti klaidingai atpažįstamas kaip brūkšninis kodas. Verta žinoti: išdekoduota reikšmė patenka į iškarpinę ir niekur kitur. Ji nespausdinama, jos nėra pranešime, ir ji pažymima kaip jautri, todėl neužsilieka [iškarpinės istorijoje](08-unified-clipboard-history.md). QR kodai paprastai neša paslaptis — pavyzdžiui, `otpauth://` URI už 2FA nustatymo kodo — ir jūs nenorite to žurnale. Įklijavimas vis tiek veikia puikiai.

`Super + Print Screen` (arba _Trigger > Capture > Color_) paverčia žymeklį pipete. Spustelėkite bet ką ekrane ir spalva atsidurs iškarpinėje. Paspauskite klavišų derinį dar kartą, kad atsitrauktumėte nieko nepasirinkę.

## Perkonvertavimas prieš bendrinant

4K ekrano įrašas arba neapdorotas HEIC iš jūsų telefono dažnai yra per didelis, kad tiesiog jį nusiųstumėte. `Super + Ctrl + .` (arba _Trigger > Transcode_) tai sutvarko. Jis pasiūlo jums neaiškiosios paieškos failų parinkiklį per `~/Pictures` ir `~/Videos`, tada paklausia formato ir dydžio.

Paveikslėliai keliauja į jpg arba png aukšta, vidutine arba žema kokybe, kurios apriboja plotį atitinkamai iki 3160, 2160 ir 1080 pikselių. Vaizdo įrašai keliauja į mp4 arba animuotą gif 4k, 1080p arba 720p raiška. Perkonvertuotas failas įrašomas šalia originalo su raiška pavadinime — `demo-1080p.mp4` — o kelias nukopijuojamas į iškarpinę kaip failo URI, todėl galite jį įklijuoti tiesiai į programą, priimančią numetamus failus.

Tai veikia ir iš terminalo, jei jau žinote, ko norite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Taip pat yra `omarchy transcode ascii`, kuris paverčia vaizdą ASCII menu — tas daugiausia skirtas [prekės ženklo įvaizdžiui](41-branding.md).

## Siuntimas kitur

Kai jau turite failą, `Super + Ctrl + S` atveria Share meniu ir nusiunčia jį į kitą įrenginį jūsų tinkle per LocalSend. Apie tai žr. [GUIs](22-guis.md).
