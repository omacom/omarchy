# Ekrano kopijos ir įrašymas

Viskas, ką galite pagriebti iš ekrano, kabo ant Print Screen klavišo. Vienas klavišas pats savaime padaro nuotrauką, o modifikatoriai daro įrašą, ima spalvą arba tekstą regiono viduje. Jei jūsų klaviatūra apskritai neturi Print Screen klavišo, `Super + Ctrl + Alt + C` padaro tą pačią ekrano kopiją, o `Super + Ctrl + C` atveria visą rinkinį kaip meniu.

| Spartusis klavišas | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrano kopija |
| `Super + Ctrl + Alt + C` | Ekrano kopija |
| `Alt + Print Screen` | Ekrano įrašymas (arba sustabdyti jau vykstantį) |
| `Super + Print Screen` | Spalvos parinkiklis |
| `Super + Ctrl + Print Screen` | Išgauti tekstą iš regiono |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Super + Ctrl + .` | Perkoduoti paveikslėlį arba vaizdo įrašą |

## Ekrano kopijos

Paspauskite `Print Screen` (arba `Super + Ctrl + Alt + C`) ir Omasnap užfiksuoja fokusuotą monitorių dar prieš pasirodant jo perdangai, todėl niekas nepasislenka po jumis, kol taikotės. Vilkite laisvos formos regioną, spustelėkite langą, kad jį užfiksuotumėte, arba spustelėkite tuščią vietą, kad užfiksuotumėte visą monitorių. Paspauskite `S` prieš braižydami, kad užfiksuotumėte slenkantį regioną. Persigalvojote? Paspauskite tą patį klavišą dar kartą, kad atšauktumėte Omasnap.

Po to, kai pasirenkate sritį, Omasnap išsaugo kadrą, nukopijuoja jį į iškarpinę ir parodo pranešimą su jo miniatiūra, kaip tai daro išsaugotas ekrano įrašas. Pasirinkite Open, kad peržiūrėtumėte išsaugotą kadrą savo paveikslėlių peržiūros programoje, arba Edit, kad jį anotuotumėte.

Anotacijų redaktorius gali piešti rodykles, linijas, figūras, paryškinimus, sunumeruotus žymeklius, tekstą ir saugius redagavimus; apkirpti arba iškirpti dalį paveikslėlio; OCR būdu atpažinti jo tekstą; ir pridėti foną. Redaktoriuje paspauskite `Enter`, kad nukopijuotumėte ir išsaugotumėte baigtą PNG, `Ctrl + C`, kad nukopijuotumėte neišsaugodami, arba `Ctrl + S`, kad išsaugotumėte nekopijuodami.

Išsaugotos ekrano kopijos pagal numatytuosius nustatymus patenka į `~/Pictures/Screenshots`, su pavadinimu, pavyzdžiui, `screenshot-2026-08-13_14-22-05-firefox.png`. Nustatykite `OMASNAP_SCREENSHOT_DIR`, kad naudotumėte kitą katalogą — žr. [DUK](46-faq.md), kur dėti seanso aplinkos kintamuosius. Omasnap sukuria katalogą, kai išsaugo pirmąjį kadrą. Nustatykite `[output] autosave = false` faile `~/.config/omasnap/omasnap.conf`, kad išjungtumėte automatinį išsaugojimą; kadrai tada tik nukopijuojami ir 7 sekundes rodomi peržiūroje, kurią galite palikti ekrane jos prisegimo mygtuku arba `Ctrl + P`.

Iš terminalo `omarchy screenshot` atveria tą pačią perdangą, ir galite pasirinkti jos pradinį režimą: `omarchy capture screenshot region`, `windows`, `fullscreen` arba `scroll`. Antras argumentas `copy` arba `save` siunčia kadrą tiesiai į tą paskirtį. Kad redaguotumėte prieš išvestį, naudokite `omarchy screenshot --editor=overlay` viso ekrano redaktoriui arba `omarchy screenshot --editor=window` atskiram langui.

### Parinkiklio valdymas klaviatūra

Kol pasirinkimas rodomas, pelės naudoti visai nereikia:

| Klavišas | Funkcija |
| --- | -------- |
| `S` | Įjungti / išjungti slenkančio regiono režimą |
| `Super + Arrow keys` | Judėti tarp langų langų režime |
| `Return` | Užfiksuoti paryškintą langą |
| `Ctrl + A` | Užfiksuoti visą fokusuotą monitorių |
| `R` | Atkurti paskutinį šio seanso metu nubrėžtą regioną |
| `Esc` | Atšaukti Omasnap |

Šie susiejimai egzistuoja tik kol Omasnap atviras, todėl jie negali susidurti su niekuo jūsų pačių konfigūracijoje.

## Ekrano įrašymas

`Alt + Print Screen` atveria _Trigger > Capture > Screenrecord_, kuris paklausia, ko norite garso takelyje: be garso, darbalaukio garso, darbalaukio ir mikrofono, arba darbalaukio, mikrofono ir internetinės kameros. Tas paskutinis variantas pasirodo tik jei iš tikrųjų turite prijungtą kamerą. Pasirinkite vieną ir Omarchy įrašymo parinkiklis leis jums vilkti regioną arba spustelėti langą ar monitorių.

Įrašymas veikia su gpu-screen-recorder, kuris koduoja GPU aparatinėje įrangoje 60fps greičiu ir, jei reikia, grįžta prie CPU; GPU, kurių jis nepalaiko, pavyzdžiui, Apple Silicon, atveju Omarchy vietoj to įrašo su wf-recorder. Rezultatas yra MP4 faile `~/Videos`, pavadintas `screenrecording-2026-08-13_14-22-05.mp4`. Nustatykite `OMARCHY_SCREENRECORD_DIR`, kad tai pakeistumėte — bet atkreipkite dėmesį, kad, skirtingai nei ekrano kopijų katalogas, šis turi jau egzistuoti, kitaip įrašymas atsisakys prasidėti.

Kol įrašote, juostoje pasirodo mažas indikatorius. Spustelėkite jį, kad sustabdytumėte. Taip pat galite sustabdyti dar kartą paspaudę `Alt + Print Screen` arba naudodami _Stop Screenrecording_ įrašą po _Trigger > Capture > Screenrecord_, kuris pasirodo tik kol kas nors iš tikrųjų įrašoma.

Sustabdymas šiek tiek sutvarko reikalus prieš atiduodamas jums failą: pirmasis kadras apkarpomas, o jei yra garsas, jis normalizuojamas iki -14 LUFS, o PipeWire fiksavimo spragtelėjimas pačioje pradžioje nutildomas. Tada pasirodo pranešimas su miniatiūra iš įrašo. Pasirinkite _Open_, kad paleistumėte failą Omaview, arba _Cut_, kad apkarpytumėte jį Omacut.

### Internetinės kameros perdanga

Kai įrašote su internetine kamera, kamera pasirodo kaip prisegtas, apkirptas portretinis langas apatiniame dešiniajame to, ką įrašote, kampe. Jei ji guli ant ko nors, ko jums reikia, keiskite jos dydį skrydžio metu:

| Spartusis klavišas | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą |

Yra trys dydžiai — mažas, vidutinis ir didelis — o spartieji klavišai žingsniuoja tarp jų. Vidutinis yra numatytasis. Jie proporcingi įrašui, todėl kamera užima tą pačią kadro dalį, nesvarbu, ar įrašote 1080p monitorių, ar 6K. O jei įrašėte regioną, o ne visą ekraną, perdanga prisitvirtina prie to regiono kampo, o ne prie monitoriaus, todėl ji lieka kadro viduje.

Taip pat galite iškviesti tai tiesiogiai su `omarchy-capture-webcam-resize small` arba `reset`, kad grįžtumėte prie vidutinio.

## Tekstas, QR kodai ir spalvos

`Super + Ctrl + Print Screen` pasirenka regioną ir OCR būdu perkelia jį į iškarpinę. Tai tinkamai aptarta skyriuje [Teksto išgavimas ir diktavimas](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ daro tą patį triuką su QR kodais. Pasirinkite regioną su kodu jame, ir dekoduota reikšmė nukeliauja į iškarpinę. Jis ieško tik QR kodų — tankus ekrano turinys kitaip turi polinkį klaidingai suveikti kaip brūkšninis kodas. Verta žinoti: dekoduota reikšmė nukeliauja į iškarpinę ir niekur kitur. Ji nespausdinama, jos nėra pranešime, ir ji pažymima kaip jautri, kad neužsibūtų [iškarpinės istorijoje](08-unified-clipboard-history.md). QR kodai reguliariai neša paslaptis — pavyzdžiui, `otpauth://` URI už 2FA sąrankos kodo — ir jūs nenorite to žurnale. Įklijavimas vis tiek veikia puikiai.

`Super + Print Screen` (arba _Trigger > Capture > Color_) paverčia žymeklį lašintuvu. Spustelėkite bet ką ekrane ir spalva nusileis į iškarpinę. Paspauskite spartųjį klavišą dar kartą, kad atsitrauktumėte nieko neparinkę.

## Perkoduavimas prieš bendrinant

4K ekrano įrašas arba neapdorotas HEIC iš jūsų telefono dažnai yra per didelis, kad tiesiog nusiųstumėte. `Super + Ctrl + .` (arba _Trigger > Transcode_) tai išsprendžia. Jis pasiūlo jums miglotos paieškos failų parinkiklį per `~/Pictures` ir `~/Videos`, tada paklausia formato ir dydžio.

Paveikslėliai virsta jpg arba png aukštu, vidutiniu arba žemu, kurie riboja plotį iki 3160, 2160 ir 1080 pikselių. Vaizdo įrašai virsta mp4 arba animuotu gif 4k, 1080p arba 720p raiška. Konvertuotas failas įrašomas šalia originalo su raiška pavadinime — `demo-1080p.mp4` — o kelias nukopijuojamas į iškarpinę kaip failo URI, todėl galite jį įklijuoti tiesiai į programą, kuri priima failų numetimus.

Tai veikia ir iš terminalo, jei jau žinote, ko norite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Taip pat yra `omarchy transcode ascii`, kuris paverčia paveikslėlį ASCII menu — tas dažniausiai skirtas [prekės ženklo kūrimui](41-branding.md).

## Siuntimas kažkur

Kai turite failą, `Super + Ctrl + S` atveria Share meniu ir siunčia jį į kitą įrenginį jūsų tinkle per LocalSend. Žr. [GUIs](22-guis.md) dėl to.
