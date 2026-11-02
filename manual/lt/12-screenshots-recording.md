# Ekrano kopijos ir įrašymas

Viskas, ką galite sugriebti nuo ekrano, kabo ant `Print Screen` klavišo. Vienas klavišas pats vienas padaro nuotrauką, o modifikatoriai padaro įrašą, paima spalvą arba tekstą regiono viduje. Jei jūsų klaviatūra apskritai neturi `Print Screen` klavišo, `Super + Ctrl + Alt + C` padaro tą pačią ekrano kopiją, o `Super + Ctrl + C` atveria visą rinkinį kaip meniu.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Ekrano kopija |
| `Super + Ctrl + Alt + C` | Ekrano kopija |
| `Alt + Print Screen` | Ekrano įrašymas (arba sustabdyti jau vykstantį) |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Išgauti tekstą iš regiono |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Super + Ctrl + .` | Perkonvertuoti paveikslėlį arba vaizdo įrašą |

## Ekrano kopijos

Paspauskite `Print Screen` (arba `Super + Ctrl + Alt + C`) ir Omasnap užfiksuos sufokusuotą monitorių dar prieš pasirodant perdangai, todėl kol taikotės, niekas po jumis nepasislenka. Vilkite laisvos formos regioną, spustelėkite langą, kad jį užfiksuotumėte, arba spustelėkite tuščią vietą, kad užfiksuotumėte visą monitorių. Prieš braižydami paspauskite `S`, kad užfiksuotumėte slenkantį regioną. Apsigalvojote? Paspauskite tą patį klavišą dar kartą, kad uždarytumėte Omasnap.

Pasirinkus sritį, Omasnap išsaugo užfiksuotą vaizdą, nukopijuoja jį į iškarpinę ir parodo pranešimą su jo miniatiūra, kaip tai daro išsaugotas ekrano įrašas. Pasirinkite Open, kad peržiūrėtumėte išsaugotą kadrą savo vaizdų peržiūros programoje, arba Edit, kad jį anotuotumėte.

Anotacijų redaktorius gali piešti rodykles, linijas, figūras, paryškinimus, sunumeruotus žymeklius, tekstą ir saugias redakcijas; apkirpti arba iškirpti dalį vaizdo; atlikti jo teksto OCR; ir pridėti foną. Redaktoriuje paspauskite `Enter`, kad nukopijuotumėte ir išsaugotumėte baigtą PNG, `Ctrl + C`, kad nukopijuotumėte neišsaugodami, arba `Ctrl + S`, kad išsaugotumėte nekopijuodami.

Išsaugotos ekrano kopijos pagal numatytuosius nustatymus patenka į `~/Pictures/Screenshots`, tokiu pavadinimu kaip `screenshot-2026-08-13_14-22-05-firefox.png`. Nustatykite `OMASNAP_SCREENSHOT_DIR`, kad naudotumėte kitą katalogą — žr. [DUK](46-faq.md), kur dėti sesijos aplinkos kintamuosius. Omasnap sukuria katalogą, kai išsaugo pirmąjį kadrą. Nustatykite `[output] autosave = false` faile `~/.config/omasnap/omasnap.conf`, kad išjungtumėte automatinį išsaugojimą; tada užfiksuoti vaizdai tik nukopijuojami ir 10 sekundžių rodomi peržiūroje, kurią galite palikti ekrane jos prisegimo mygtuku arba `Ctrl + P`.

Iš terminalo `omarchy screenshot` atveria tą pačią perdangą, ir galite pasirinkti jo pradinį režimą: `omarchy capture screenshot region`, `windows`, `fullscreen` arba `scroll`. Antras argumentas `copy` arba `save` siunčia kadrą tiesiai į tą paskirties vietą. Norėdami redaguoti prieš išvestį, naudokite `omarchy screenshot --editor=overlay`, kad gautumėte viso ekrano redaktorių, arba `omarchy screenshot --editor=window`, kad gautumėte atskirą langą.

### Parinkiklio valdymas klaviatūra

Kol pasirinkimas atvertas, pelės jums visai nereikia:

| Key | Function |
| --- | -------- |
| `S` | Perjungti slenkančio regiono režimą |
| `Super + Arrow keys` | Judėti tarp langų langų režime |
| `Return` | Užfiksuoti paryškintą langą |
| `Ctrl + A` | Užfiksuoti visą sufokusuotą monitorių |
| `R` | Atkurti paskutinį šioje sesijoje nubrėžtą regioną |
| `Esc` | Uždaryti Omasnap |

Šie susiejimai egzistuoja tik kol Omasnap atvertas, todėl jie negali susidurti su niekuo jūsų pačių konfigūracijoje.

## Ekrano įrašymas

`Alt + Print Screen` atveria _Trigger > Capture > Screenrecord_, kuris paklausia, ko norite garso takelyje: jokio garso, darbalaukio garso, darbalaukio ir mikrofono arba darbalaukio, mikrofono ir internetinės kameros. Tas paskutinis variantas pasirodo tik jei iš tikrųjų turite prijungtą kamerą. Pasirinkite vieną ir Omarchy įrašymo parinkiklis leis jums vilkti regioną arba spustelėti langą ar monitorių.

Įrašymas veikia su gpu-screen-recorder, kuris koduoja GPU 60fps dažniu ir, jei reikia, grįžta prie CPU. Rezultatas yra MP4 faile `~/Videos`, pavadintame `screenrecording-2026-08-13_14-22-05.mp4`. Nustatykite `OMARCHY_SCREENRECORD_DIR`, kad tai pakeistumėte — bet atkreipkite dėmesį, kad, skirtingai nei ekrano kopijų katalogas, šis turi jau egzistuoti, kitaip įrašymas atsisakys prasidėti.

Kol įrašote, juostoje pasirodo mažas indikatorius. Spustelėkite jį, kad sustabdytumėte. Taip pat galite sustabdyti dar kartą paspaudę `Alt + Print Screen` arba įrašu _Stop Screenrecording_ skiltyje _Trigger > Capture > Screenrecord_, kuris pasirodo tik kol kas nors iš tikrųjų įrašinėjama.

Sustabdymas prieš atiduodamas jums failą šiek tiek sutvarko: apkerpamas pirmasis kadras, o jei yra garsas, jis normalizuojamas iki -14 LUFS, o PipeWire fiksavimo spragtelėjimas pačioje pradžioje nutildomas. Tada pasirodo pranešimas su miniatiūra iš įrašo. Spustelėkite jį, kad paleistumėte failą mpv.

### Internetinės kameros perdanga

Kai įrašote su internetine kamera, kamera pasirodo kaip prisegtas, apkirptas portretinis langas apatiniame dešiniajame to, ką įrašote, kampe. Jei ji guli ant ko nors, ko jums reikia, keiskite jos dydį skrydžio metu:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Padaryti internetinės kameros perdangą mažesnę |
| `Super + Alt + ]` | Padaryti internetinės kameros perdangą didesnę |

Yra trys dydžiai — mažas, vidutinis ir didelis — o spartieji klavišai žingsniuoja tarp jų. Vidutinis yra numatytasis. Jie proporcingi įrašui, todėl kamera užima tą pačią kadro dalį, nesvarbu, ar įrašote 1080p monitorių, ar 6K. O jei įrašėte regioną, o ne visą ekraną, perdanga prisitvirtina prie to regiono kampo, o ne monitoriaus, todėl lieka kadro viduje.

Taip pat galite iškviesti tai tiesiogiai su `omarchy-capture-webcam-resize small` arba `reset`, kad grįžtumėte prie vidutinio.

## Tekstas, QR kodai ir spalvos

`Super + Ctrl + Print Screen` pasirenka regioną ir atlieka jo OCR į iškarpinę. Tai tinkamai aptarta skyriuje [Teksto išgavimas ir diktavimas](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ daro tą patį triuką su QR kodais. Pasirinkite regioną su kodu jame, ir dekoduota reikšmė patenka į iškarpinę. Jis ieško tik QR kodų — tankus ekrano turinys kitaip linkęs būti klaidingai atpažįstamas kaip brūkšninis kodas. Verta žinoti: dekoduota reikšmė patenka į iškarpinę ir niekur kitur. Ji nespausdinama, jos nėra pranešime ir ji pažymima kaip jautri, todėl nelieka [iškarpinės istorijoje](08-unified-clipboard-history.md). QR kodai įprastai neša paslaptis — pavyzdžiui, `otpauth://` URI už 2FA nustatymo kodo — ir jūs nenorite to žurnale. Įklijavimas vis tiek veikia puikiai.

`Super + Print Screen` (arba _Trigger > Capture > Color_) paverčia žymeklį pipete. Spustelėkite bet ką ekrane ir spalva patenka į iškarpinę. Paspauskite spartųjį klavišą dar kartą, kad pasitrauktumėte nepasirinkę.

## Perkonvertavimas prieš bendrinant

4K ekrano įrašas arba neapdorotas HEIC iš jūsų telefono dažnai yra per didelis, kad tiesiog nusiųstumėte. `Super + Ctrl + .` (arba _Trigger > Transcode_) tai išsprendžia. Jis pasiūlo jums neaiškiosios paieškos failų parinkiklį per `~/Pictures` ir `~/Videos`, tada paklausia formato ir dydžio.

Paveikslėliai virsta jpg arba png aukšta, vidutine arba žema kokybe, kurios apriboja plotį iki 3160, 2160 ir 1080 pikselių. Vaizdo įrašai virsta mp4 arba animuotu gif 4k, 1080p arba 720p raiška. Konvertuotas failas įrašomas šalia originalo su raiška pavadinime — `demo-1080p.mp4` — o kelias nukopijuojamas į iškarpinę kaip failo URI, todėl galite įklijuoti jį tiesiai į programą, kuri priima failų numetimus.

Tai veikia ir iš terminalo, jei jau žinote, ko norite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Taip pat yra `omarchy transcode ascii`, kuris paverčia vaizdą ASCII menu — tas dažniausiai skirtas [ženklodarai](41-branding.md).

## Siuntimas kažkur

Kai turite failą, `Super + Ctrl + S` atveria Share meniu ir siunčia jį į kitą jūsų tinklo įrenginį per LocalSend. Apie tai žr. [Grafinės sąsajos](22-guis.md).
