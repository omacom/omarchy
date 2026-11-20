# Ekrano kopijos ir įrašymas

Viskas, ką galite pagriebti iš ekrano, kabo ant Print Screen klavišo. Vienas klavišas pats vienas padaro nuotrauką, o modifikatoriai padaro įrašą, spalvą arba tekstą srities viduje. Jei jūsų klaviatūra išvis neturi Print Screen klavišo, `Super + Ctrl + Alt + C` padaro tą pačią ekrano kopiją, o `Super + Ctrl + C` atidaro visą rinkinį kaip meniu.

| Spartusis klavišas | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrano kopija |
| `Super + Ctrl + Alt + C` | Ekrano kopija |
| `Alt + Print Screen` | Ekrano įrašymas (arba sustabdyti vykstantį) |
| `Super + Print Screen` | Spalvų rinkiklis |
| `Super + Ctrl + Print Screen` | Ištraukti tekstą iš srities |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Super + Ctrl + .` | Konvertuoti paveikslėlį arba vaizdo įrašą |

## Ekrano kopijos

Paspauskite `Print Screen` (arba `Super + Ctrl + Alt + C`) ir Omasnap užfiksuos aktyvų monitorių dar prieš pasirodant jo perdangai, todėl kol taikotės, po jumis niekas nepasislinks. Vilkite laisvos formos sritį, spustelėkite langą, kad jį užfiksuotumėte, arba spustelėkite tuščią vietą, kad užfiksuotumėte visą monitorių. Prieš brėždami paspauskite `S`, kad užfiksuotumėte slenkančią sritį. Apsigalvojote? Paspauskite tą patį klavišą dar kartą, kad uždarytumėte Omasnap.

Kai pasirenkate sritį, Omasnap išsaugo kopiją, nukopijuoja ją į iškarpinę ir parodo pranešimą su jos miniatiūra, kaip tai daro išsaugotas ekrano įrašas. Pasirinkite Atidaryti, kad peržiūrėtumėte išsaugotą kopiją savo paveikslėlių peržiūros programoje, arba Redaguoti, kad ją anotuotumėte.

Anotacijų redaktorius gali piešti rodykles, linijas, figūras, paryškinimus, sunumeruotus žymeklius, tekstą ir saugias redakcijas; apkarpyti arba iškirpti dalį paveikslėlio; OCR būdu atpažinti jo tekstą; ir pridėti foną. Redaktoriuje paspauskite `Enter`, kad nukopijuotumėte ir išsaugotumėte baigtą PNG, `Ctrl + C`, kad nukopijuotumėte jo neišsaugodami, arba `Ctrl + S`, kad išsaugotumėte jo nekopijuodami.

Išsaugotos ekrano kopijos pagal numatytuosius nustatymus patenka į `~/Pictures/Screenshots`, su tokiu pavadinimu kaip `screenshot-2026-08-13_14-22-05-firefox.png`. Nustatykite `OMASNAP_SCREENSHOT_DIR`, kad naudotumėte kitą katalogą — žr. [DUK](46-faq.md), kur dėti sesijos aplinkos kintamuosius. Omasnap sukuria katalogą, kai išsaugo pirmąją kopiją. Nustatykite `[output] autosave = false` faile `~/.config/omasnap/omasnap.conf`, kad išjungtumėte automatinį išsaugojimą; tada kopijos tik nukopijuojamos ir 10 sekundžių rodomos peržiūroje, kurią galite palikti ekrane jos prisegimo mygtuku arba `Ctrl + P`.

Iš terminalo `omarchy screenshot` atidaro tą pačią perdangą, ir galite pasirinkti jos pradinį režimą: `omarchy capture screenshot region`, `windows`, `fullscreen` arba `scroll`. Antras argumentas `copy` arba `save` nusiunčia kopiją tiesiai į tą paskirtį. Kad prieš išvesdami redaguotumėte, naudokite `omarchy screenshot --editor=overlay` viso ekrano redaktoriui arba `omarchy screenshot --editor=window` atskiram langui.

### Parinkiklio valdymas klaviatūra

Kol parinkimas atidarytas, pelės jums išvis nereikia:

| Klavišas | Funkcija |
| --- | -------- |
| `S` | Perjungti slenkančios srities režimą |
| `Super + Arrow keys` | Judėti tarp langų langų režime |
| `Return` | Užfiksuoti paryškintą langą |
| `Ctrl + A` | Užfiksuoti visą aktyvų monitorių |
| `R` | Atkurti paskutinę šioje sesijoje nubrėžtą sritį |
| `Esc` | Uždaryti Omasnap |

Šie susiejimai egzistuoja tik kol Omasnap atidarytas, todėl jie negali susidurti su niekuo jūsų pačių konfigūracijoje.

## Ekrano įrašymas

`Alt + Print Screen` atidaro _Trigger > Capture > Screenrecord_, kuris paklausia, ko norite garso takelyje: jokio garso, darbalaukio garso, darbalaukio ir mikrofono arba darbalaukio, mikrofono ir vaizdo kameros. Tas paskutinis rodomas tik jei iš tikrųjų turite prijungtą kamerą. Pasirinkite vieną ir Omarchy įrašymo parinkiklis leis jums vilkti sritį arba spustelėti langą ar monitorių.

Įrašymas veikia su gpu-screen-recorder, kuris koduoja GPU 60fps ir, jei turi, grįžta prie CPU. Rezultatas yra MP4 faile `~/Videos`, pavadintas `screenrecording-2026-08-13_14-22-05.mp4`. Nustatykite `OMARCHY_SCREENRECORD_DIR`, kad tai pakeistumėte — bet atkreipkite dėmesį, kad, skirtingai nei ekrano kopijų katalogas, šis turi jau egzistuoti, kitaip įrašymas atsisakys prasidėti.

Kol įrašinėjate, juostoje pasirodo mažas indikatorius. Spustelėkite jį, kad sustabdytumėte. Taip pat galite sustabdyti dar kartą paspaudę `Alt + Print Screen` arba įrašu _Stop Screenrecording_ skiltyje _Trigger > Capture > Screenrecord_, kuris pasirodo tik kol kas nors iš tikrųjų įrašinėjama.

Stabdymas prieš atiduodamas jums failą šiek tiek sutvarko: pirmas kadras apkarpomas, o jei yra garsas, jis normalizuojamas iki -14 LUFS, o PipeWire fiksavimo spragtelėjimas pačioje pradžioje nutildomas. Tada pasirodo pranešimas su miniatiūra iš įrašo. Spustelėkite jį, kad paleistumėte failą Omaview.

### Vaizdo kameros perdanga

Kai įrašinėjate su vaizdo kamera, kamera pasirodo kaip prisegtas, apkarpytas portretinis langas apatiniame dešiniajame to, ką įrašinėjate, kampe. Jei ji sėdi ant kažko, ko jums reikia, keiskite jos dydį skrydžio metu:

| Spartusis klavišas | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Sumažinti vaizdo kameros perdangą |
| `Super + Alt + ]` | Padidinti vaizdo kameros perdangą |

Yra trys dydžiai — mažas, vidutinis ir didelis — ir spartieji klavišai žingsniuoja tarp jų. Vidutinis yra numatytasis. Jie proporcingi įrašui, todėl kamera užima tą pačią kadro dalį, nesvarbu, ar įrašinėjate 1080p monitorių, ar 6K. O jei įrašėte sritį, o ne visą ekraną, perdanga prisitvirtina prie tos srities kampo, o ne monitoriaus, todėl lieka kadre.

Taip pat galite ją iškviesti tiesiogiai su `omarchy-capture-webcam-resize small` arba `reset`, kad grįžtumėte prie vidutinio.

## Tekstas, QR kodai ir spalvos

`Super + Ctrl + Print Screen` pasirenka sritį ir OCR būdu perkelia ją į iškarpinę. Tai tinkamai aptarta skyriuje [Teksto ištraukimas ir diktavimas](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ daro tą patį triuką su QR kodais. Pasirinkite sritį su kodu joje, ir iššifruota reikšmė patenka į iškarpinę. Jis ieško tik QR kodų — tankus ekrano turinys kitais atvejais turi polinkį būti klaidingai atpažintas kaip brūkšninis kodas. Verta žinoti: iššifruota reikšmė patenka į iškarpinę ir niekur kitur. Ji nespausdinama, jos nėra pranešime ir ji pažymėta kaip slapta, todėl neužsilieka [iškarpinės istorijoje](08-unified-clipboard-history.md). QR kodai įprastai neša paslaptis — pavyzdžiui, `otpauth://` URI už 2FA nustatymo kodo — ir jūs nenorite to žurnale. Įklijavimas vis tiek veikia puikiai.

`Super + Print Screen` (arba _Trigger > Capture > Color_) paverčia žymeklį pipete. Spustelėkite bet ką ekrane ir spalva patenka į iškarpinę. Paspauskite spartųjį klavišą dar kartą, kad pasitrauktumėte nieko nepasirinkę.

## Konvertavimas prieš bendrinant

4K ekrano įrašas arba neapdorotas HEIC iš jūsų telefono dažnai yra per didelis, kad tiesiog nusiųstumėte. `Super + Ctrl + .` (arba _Trigger > Transcode_) tai sutvarko. Jis pasiūlo jums neryškų failų parinkiklį per `~/Pictures` ir `~/Videos`, tada paklausia formato ir dydžio.

Paveikslėliai keliauja į jpg arba png aukšta, vidutine arba žema kokybe, kurios riboja plotį iki 3160, 2160 ir 1080 pikselių. Vaizdo įrašai keliauja į mp4 arba animuotą gif 4k, 1080p arba 720p. Konvertuotas failas įrašomas šalia originalo su skiriamąja geba pavadinime — `demo-1080p.mp4` — ir kelias nukopijuojamas į iškarpinę kaip failo URI, todėl galite jį įklijuoti tiesiai į programą, kuri priima numestus failus.

Tai veikia ir iš terminalo, jei jau žinote, ko norite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Taip pat yra `omarchy transcode ascii`, kuris paverčia paveikslėlį ASCII menu — tas dažniausiai skirtas [prekės ženklui](41-branding.md).

## Siuntimas kitur

Kai jau turite failą, `Super + Ctrl + S` atidaro bendrinimo meniu ir nusiunčia jį į kitą jūsų tinklo įrenginį per LocalSend. Apie tai žr. [GUIs](22-guis.md).
