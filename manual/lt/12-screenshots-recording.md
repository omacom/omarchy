# Ekrano nuotraukos ir įrašymas

Viskas, ką galite paimti iš ekrano, kabo ant Print Screen klavišo. Vienas klavišas pats daro nuotrauką, o modifikatoriai daro įrašą, spalvą arba tekstą srities viduje. Jei jūsų klaviatūra visai neturi Print Screen klavišo, `Super + Ctrl + C` atidaro tą patį rinkinį kaip meniu.

| Spartusis klavišas | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrano nuotrauka |
| `Alt + Print Screen` | Ekrano įrašas (arba sustabdyti veikiantį) |
| `Super + Print Screen` | Spalvos parinkiklis |
| `Super + Ctrl + Print Screen` | Išgauti tekstą iš srities |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Super + Ctrl + .` | Perkoduoti paveikslėlį arba vaizdo įrašą |

## Ekrano nuotraukos

Paspauskite `Print Screen` ir Omasnap užfiksuoja sufokusuotą monitorių prieš pasirodant jo perdangai, todėl niekas po jumis nepasislenka, kol taikotės. Vilkite laisvos formos sritį, spustelėkite langą, kad jį užfiksuotumėte, arba spustelėkite atvirą vietą, kad užfiksuotumėte visą monitorių. Prieš braižydami paspauskite `S`, kad užfiksuotumėte slenkančią sritį. Persigalvojote? Paspauskite `Print Screen` dar kartą, kad atšauktumėte Omasnap.

Kai pasirenkate sritį, Omasnap išsaugo fiksavimą, nukopijuoja jį į iškarpinę ir 10 sekundžių rodo peržiūrą. Naudokite peržiūros prisegimo mygtuką arba `Ctrl + P`, kad ji liktų ekrane, arba rinkitės Redaguoti, kad ją anotuotumėte.

Anotacijų redaguoklis gali piešti rodykles, linijas, figūras, paryškinimus, sunumeruotus žymeklius, tekstą ir saugias redakcijas; apkarpyti arba iškirpti dalį paveikslėlio; atlikti jo teksto OCR; ir pridėti foną. Redaguoklyje paspauskite `Enter`, kad kopijuotumėte ir išsaugotumėte baigtą PNG, `Ctrl + C`, kad kopijuotumėte jo neišsaugodami, arba `Ctrl + S`, kad išsaugotumėte jo nekopijuodami.

Išsaugotos ekrano nuotraukos pagal numatytuosius nustatymus patenka į `~/Pictures/Screenshots` su pavadinimu, pavyzdžiui, `screenshot-2026-08-13_14-22-05-firefox.png`. Nustatykite `OMASNAP_SCREENSHOT_DIR`, kad naudotumėte kitą katalogą — kur dėti sesijos aplinkos kintamuosius, žr. [DUK](46-faq.md). Omasnap sukuria katalogą, kai išsaugo pirmą kadrą. `~/.config/omasnap/omasnap.conf` nustatykite `[output] autosave = false`, kad išjungtumėte automatinį išsaugojimą.

Iš terminalo `omarchy screenshot` atidaro tą pačią perdangą ir galite pasirinkti jos pradinį režimą: `omarchy capture screenshot region`, `windows`, `fullscreen` arba `scroll`. Antras argumentas `copy` arba `save` praleidžia peržiūrą ir siunčia kadrą tiesiai į tą paskirties vietą. Norėdami redaguoti prieš išvestį, naudokite `omarchy screenshot --editor=overlay` viso ekrano redaguokliui arba `omarchy screenshot --editor=window` atskiram langui.

### Parinkiklio valdymas iš klaviatūros

Kol pasirinkimas yra atidarytas, jums visai nereikia naudoti pelės:

| Klavišas | Funkcija |
| --- | -------- |
| `S` | Perjungti slenkančios srities režimą |
| `Super + Arrow keys` | Judėti tarp langų Window režime |
| `Return` | Užfiksuoti paryškintą langą |
| `Ctrl + A` | Užfiksuoti visą sufokusuotą monitorių |
| `R` | Atkurti paskutinę šioje sesijoje nubrėžtą sritį |
| `Esc` | Atšaukti Omasnap |

Šie susiejimai egzistuoja tik kol Omasnap atidarytas, todėl jie negali susikirsti su niekuo jūsų pačių konfigūracijoje.

## Ekrano įrašymas

`Alt + Print Screen` atidaro _Veiksmai > Fiksuoti > Ekrano įrašas_, kuris paklausia, ko norite garso takelyje: be garso, darbalaukio garsas, darbalaukis plius mikrofonas arba darbalaukis plius mikrofonas plius kamera. Tas paskutinis pasirodo tik jei iš tikrųjų turite prijungtą kamerą. Pasirinkite vieną ir Omarchy įrašymo parinkiklis leidžia vilkti sritį arba spustelėti langą ar monitorių.

Įrašymas veikia ant gpu-screen-recorder, kuris koduoja GPU 60fps ir, jei reikia, grįžta prie CPU. Rezultatas yra MP4 `~/Videos`, pavadintas `screenrecording-2026-08-13_14-22-05.mp4`. Nustatykite `OMARCHY_SCREENRECORD_DIR`, kad tai pakeistumėte — bet atkreipkite dėmesį, kad, skirtingai nei ekrano nuotraukų katalogas, šis turi jau egzistuoti, kitaip įrašymas atsisako prasidėti.

Kol įrašote, juostoje pasirodo mažas indikatorius. Spustelėkite jį, kad sustabdytumėte. Taip pat galite sustabdyti dar kartą su `Alt + Print Screen` arba su įrašu _Stabdyti įrašą_ po _Veiksmai > Fiksuoti > Ekrano įrašas_, kuris pasirodo tik kol kažkas iš tikrųjų įrašo.

Sustabdymas šiek tiek sutvarko, prieš perduodamas jums failą: pirmas kadras apkarpomas ir, jei yra garsas, jis normalizuojamas iki -14 LUFS, o PipeWire fiksavimo pokštelėjimas pačioje pradžioje nutildomas. Tada pasirodo pranešimas su miniatiūra iš įrašo. Spustelėkite jį, kad failą paleistumėte mpv.

### Kameros perdanga

Kai įrašote su kamera, kamera pasirodo kaip prisegtas, apkarpytas portretinis langas apatiniame dešiniajame to, ką įrašote, kampe. Jei ji yra ant kažko, ko jums reikia, keiskite jos dydį skrydžio metu:

| Spartusis klavišas | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Padaryti kameros perdangą mažesnę |
| `Super + Alt + ]` | Padaryti kameros perdangą didesnę |

Yra trys dydžiai — mažas, vidutinis ir didelis — ir spartieji klavišai žingsniuoja tarp jų. Vidutinis yra numatytasis. Jie proporcingi įrašui, todėl kamera užima tą pačią kadro dalį, nesvarbu, ar įrašote 1080p monitorių, ar 6K. Ir jei įrašėte sritį, o ne visą ekraną, perdanga tvirtinasi prie tos srities kampo, o ne monitoriaus, todėl ji lieka kadro viduje.

Taip pat galite ją iškviesti tiesiogiai su `omarchy-capture-webcam-resize small` arba `reset`, kad grįžtumėte į vidutinę.

## Tekstas, QR kodai ir spalvos

`Super + Ctrl + Print Screen` pasirenka sritį ir atlieka jos OCR į iškarpinę. Tai tinkamai aptarta [Teksto išgavimas ir diktavimas](11-text-extraction-dictation.md).

_Veiksmai > Fiksuoti > QR Code_ daro tą patį triuką QR kodams. Pasirinkite sritį su kodu joje ir iššifruota reikšmė patenka į iškarpinę. Ji ieško tik QR kodų — tankus ekrano turinys kitaip turi įprotį klaidingai būti aptinkamas kaip brūkšninis kodas. Verta žinoti: iššifruota reikšmė patenka į iškarpinę ir niekur kitur. Ji neatspausdinama, jos nėra pranešime ir ji pažymėta kaip jautri, todėl neužsilieka [iškarpinės istorijoje](08-unified-clipboard-history.md). QR kodai įprastai neša paslaptis — pavyzdžiui, `otpauth://` URI už 2FA sąrankos kodo — ir jūs nenorite to žurnale. Įklijavimas vis tiek gerai veikia.

`Super + Print Screen` (arba _Veiksmai > Fiksuoti > Spalva_) paverčia žymeklį pipete. Spustelėkite bet ką ekrane ir spalva patenka į iškarpinę. Paspauskite spartųjį klavišą dar kartą, kad išeitumėte nepasirinkę.

## Perkodavimas prieš dalijimąsi

4K ekrano įrašas arba neapdorotas HEIC iš jūsų telefono dažnai yra per didelis, kad jį tiesiog siųstumėte. `Super + Ctrl + .` (arba _Veiksmai > Perkoduoti_) tai sutvarko. Jis pasiūlo jums fuzzy failų parinkiklį per `~/Pictures` ir `~/Videos`, tada paklausia formato ir dydžio.

Paveikslėliai eina į jpg arba png aukšta, vidutine arba žema kokybe, kuri riboja plotį iki 3160, 2160 ir 1080 pikselių. Vaizdo įrašai eina į mp4 arba animuotą gif 4k, 1080p arba 720p. Konvertuotas failas įrašomas šalia originalo su skyra pavadinime — `demo-1080p.mp4` — o kelias nukopijuojamas į iškarpinę kaip failo URI, todėl galite jį įklijuoti tiesiai į programą, kuri priima failų numetimus.

Tai veikia ir iš terminalo, jei jau žinote, ko norite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Taip pat yra `omarchy transcode ascii`, kuris paveikslėlį paverčia ASCII menu — tas daugiausia skirtas [prekės ženklui](41-branding.md).

## Siuntimas kur nors

Kai turite failą, `Super + Ctrl + S` atidaro Dalytis meniu ir siunčia jį į kitą jūsų tinklo įrenginį per LocalSend. Apie tai žr. [GUI](22-guis.md).
