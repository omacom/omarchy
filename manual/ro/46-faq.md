# Întrebări frecvente

### Cum comut între aranjările tastaturii?

Editează fișierul `~/.config/hypr/input.lua` și adaugă asta ca să comuți între aranjări pe `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bara va afișa automat aranjarea curentă a tastaturii odată ce ai mai multe aranjări configurate (și poți face clic pe ea ca să comuți și așa).

### Cum schimb formatul ceasului la 12 ore?

Fă clic dreapta pe ceasul din bară ca să parcurgi formatele obișnuite, inclusiv cele de 12 ore. Poți seta formatul și direct:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Asta va afișa Sunday 10:55 AM.

### Cum îmi schimb fusul orar?

Rulează _Actualizează > Fus orar_ în meniul Omarchy și alege din listă. Dacă fusul orar este corect, dar ceasul însuși a deviat, _Actualizează > Ora_ repornește sincronizarea orei pentru tine.

### Cum îmi schimb DNS-ul, cum îmi partajez rețeaua Wi-Fi sau cum îmi verific viteza conexiunii?

Toate acestea trăiesc în [rețea](35-networking.md).

### Cum verific cât de rapid este discul meu?

_Declanșator > Test viteză > Test viteză disc_ măsoară viteza live de citire și scriere pe unitatea ta, sau `omarchy disk speedtest` din terminal.

### De ce nu mă pot conecta la contul meu Google în Chromium?

Versiunea simplă, cu sursă deschisă, a Chromium nu vine cu acreditările OAuth pe care Google le cere pentru conectarea la cont. Rulează _Instalează > Serviciu > Cont Chromium_ în meniul Omarchy ca să le adaugi, repornește browserul, iar conectarea va reuși.

### Cum adaug o imprimantă?

Imprimarea este configurată și funcționează imediat, iar tu adaugi singur fiecare imprimantă din _Print Settings_ în lansatorul de aplicații (`Super + Space`).

Alege _Add_ și acordă-i un moment ca să caute: o imprimantă conectată prin USB și majoritatea imprimantelor de rețea sunt găsite pentru tine. Dacă a ta nu este în listă, alege _Network Printer > Internet Printing Protocol (ipp)_ și introdu adresa ei — afișajul propriu al imprimantei sau pagina ei web îți va spune ce este, de obicei ceva precum `192.168.1.50` cu o coadă `ipp/print`. _Forward_ oferă apoi un driver, unde o imprimantă modernă funcționează cel mai bine pe profilul fără driver _IPP Everywhere_, iar una mai veche vrea driverul propriu al modelului.

Fă clic dreapta pe o imprimantă și alege _Set as Default_ ca să alegi la care ajung mai întâi aplicațiile tale și _Properties_ ca să setezi dimensiunea hârtiei, duplexul și calitatea.

Descoperirea automată, prin care imprimantele din rețea apar fără să fie adăugate, este dezactivată temporar cât timp este refăcută, motiv pentru care primul pas de mai sus este al tău, nu automat. Imprimarea într-un fișier PDF funcționează fără nicio imprimantă.

### Cum schimb unde sunt salvate capturile de ecran sau înregistrările de ecran?

Capturile de ecran salvate merg implicit în `~/Pictures/Screenshots`. Ca să folosești alt director, adaugă asta într-un fișier sub `~/.config/uwsm/env.d/` (precum `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Poți face același lucru pentru înregistrările de ecran folosind `OMARCHY_SCREENRECORD_DIR`.

Omasnap își creează automat directorul de capturi de ecran. Creează-ți singur directorul de înregistrări de ecran, apoi repornește Omarchy pentru ca oricare dintre schimbările de mediu să intre în vigoare.

### Cum fac difuzoarele + webcamul să funcționeze pe Apple Studio Display al meu?

Ai crede că totul ar trebui să funcționeze doar conectând USB C, dar, din păcate, nu este cazul. Soluția pe care am găsit-o ca să funcționeze fiabil este utilizarea [cablului WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Apoi difuzoarele și webcamul funcționează de minune.

Amintește-ți că ai control integrat al luminozității în Omarchy pentru afișajele Apple (atât Studio, cât și XDR) folosind butoanele obișnuite de luminozitate de pe tastatură.

### Cum scap de tot software-ul suplimentar?

Dacă nu vrei programe precum Obsidian sau LibreOffice sau oricare dintre celelalte lucruri preinstalate, le poți elimina foarte ușor.

Rulează _Elimină > Pachet_ ca să vezi fiecare pachet instalat. Apoi poți selecta orice pachet pe care ai vrea să îl elimini cu tab și poți începe să elimini tot ce ai selectat cu return.

Și poți folosi _Elimină > Aplicație web_ din meniul Omarchy ca să elimini oricare dintre aplicațiile web preinstalate pe care nu le vrei.

Sau rulează _Elimină > Preinstalate_ ca să mături toate extraurile preinstalate — aplicații web, TUI-uri și aplicații opționale — dintr-o singură mișcare. Scurtăturile care le lansau dispar odată cu ele, astfel încât rămâi cu o tablă curată de legături pe care să o umpli cu ale tale în `~/.config/hypr/bindings.lua`.

---

Pentru erori și bucăți stricate, vezi [secțiunea Depanare](45-troubleshooting.md).
