# Întrebări frecvente

### Cum comut între aspectele de tastatură?

Editează fișierul `~/.config/hypr/input.lua` și adaugă asta pentru a comuta între aspecte cu `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bara va afișa automat aspectul curent de tastatură odată ce ai configurate mai multe aspecte (și poți da clic pe el ca să comuți și așa).

### Cum schimb formatul ceasului la 12 ore?

Dă clic dreapta pe ceasul din bară pentru a parcurge formatele uzuale, inclusiv pe cele de 12 ore. Poți seta formatul și direct:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Aceasta va afișa Duminică 10:55 AM.

### Cum îmi schimb fusul orar?

Rulează _Update > Timezone_ în meniul Omarchy și alege din listă. Dacă fusul orar este corect, dar ceasul în sine s-a decalat, _Update > Time_ repornește sincronizarea orei pentru tine.

### Cum îmi schimb DNS-ul, cum îmi partajez Wi-Fi-ul sau cum îmi verific viteza conexiunii?

Toate acestea se găsesc în [rețele](35-networking.md).

### Cum verific cât de rapid este discul meu?

_Trigger > Speed Test > Disk Speed Test_ măsoară în timp real viteza de citire și scriere pe discul tău, sau `omarchy disk speedtest` din terminal.

### Cum adaug o imprimantă?

Tipărirea este configurată și funcționează din start, iar fiecare imprimantă o adaugi singur din _Print Settings_ în lansatorul de aplicații (`Super + Space`).

Alege _Add_ și așteaptă un moment cât caută: o imprimantă conectată prin USB și majoritatea imprimantelor de rețea sunt găsite pentru tine. Dacă a ta nu este în listă, alege _Network Printer > Internet Printing Protocol (ipp)_ și introdu adresa ei — ecranul imprimantei sau pagina ei web îți va spune care este, de obicei ceva de genul `192.168.1.50` cu o coadă `ipp/print`. _Forward_ îți oferă apoi un driver, unde o imprimantă modernă funcționează cel mai bine cu profilul fără driver _IPP Everywhere_, iar una mai veche vrea driverul propriu al modelului.

Dă clic dreapta pe o imprimantă și alege _Set as Default_ pentru a selecta pe care o folosesc aplicațiile tale prima, și _Properties_ pentru a seta dimensiunea hârtiei, duplexul și calitatea.

Descoperirea automată, prin care imprimantele din rețea apar fără să fie adăugate, este dezactivată temporar cât este refăcută, motiv pentru care primul pas de mai sus îți aparține ție, nu este automat. Tipărirea într-un fișier PDF funcționează fără nicio imprimantă.

### Cum schimb unde se salvează capturile de ecran sau înregistrările de ecran?

Capturile de ecran salvate merg implicit în `~/Pictures/Screenshots`. Pentru a folosi alt director, adaugă asta într-un fișier din `~/.config/uwsm/env.d/` (de exemplu `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Poți face același lucru pentru înregistrările de ecran folosind `OMARCHY_SCREENRECORD_DIR`.

Omasnap își creează automat directorul pentru capturi de ecran. Creează-ți singur directorul pentru înregistrări de ecran, apoi repornește Omarchy pentru ca oricare dintre modificările de mediu să intre în vigoare.

### Cum fac să funcționeze difuzoarele + camera web pe Apple Studio Display-ul meu?

Ai crede că totul ar trebui să funcționeze pur și simplu conectând USB C, dar din păcate nu este cazul. Soluția pe care am găsit-o pentru ca totul să funcționeze fiabil este folosirea [cablului WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Apoi difuzoarele și camera web funcționează ca unse.

Ține minte că ai control integrat al luminozității în Omarchy pentru ecranele Apple (atât Studio, cât și XDR) folosind butoanele obișnuite de luminozitate de pe tastatură.

### Cum scap de tot software-ul suplimentar?

Dacă nu vrei programe ca Obsidian sau LibreOffice sau oricare altceva preinstalat, îl poți elimina foarte ușor.

Rulează _Remove > Package_ pentru a vedea fiecare pachet instalat. Apoi poți selecta orice pachet vrei să-l elimini cu tab și poți începe eliminarea a tot ce ai selectat cu return.

Și poți folosi _Remove > Web App_ din meniul Omarchy pentru a elimina orice aplicație web preinstalată pe care nu o vrei.

Sau rulează _Remove > Preinstalls_ pentru a mătura toate extraurile preinstalate — aplicații web, TUIs și aplicații opționale — dintr-o singură mișcare. Scurtăturile de tastatură care le lansau dispar odată cu ele, așa că rămâi cu o tablă curată de combinații pe care să le umpli cu ale tale în `~/.config/hypr/bindings.lua`.

---

Pentru erori și lucruri stricate, vezi [secțiunea Depanare](45-troubleshooting.md).
