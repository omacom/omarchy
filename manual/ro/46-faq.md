# Întrebări frecvente

### Cum schimb între schemele de tastatură?

Editează fișierul `~/.config/hypr/input.lua` și adaugă asta pentru a schimba între scheme cu `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bara va afișa automat schema curentă de tastatură odată ce ai configurat mai multe scheme (și poți da clic pe ea ca să schimbi și așa).

### Cum schimb formatul ceasului la 12 ore?

Fă clic dreapta pe ceasul din bară pentru a parcurge formatele uzuale, inclusiv cele cu 12 ore. Poți seta formatul și direct:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Asta va afișa Duminică 10:55 AM.

### Cum îmi schimb fusul orar?

Rulează _Setup > Region > Timezone_ în meniul Omarchy și alege din listă. Dacă fusul orar este corect, dar ceasul în sine a rămas în urmă, _Update > Time_ repornește sincronizarea orei pentru tine.

### Cum îmi schimb DNS-ul, cum îmi partajez Wi-Fi-ul sau cum îmi verific viteza conexiunii?

Toate acestea se află în [rețea](35-networking.md).

### Cum verific cât de rapid este discul meu?

_Trigger > Speed Test > Disk Speed Test_ măsoară în timp real viteza de citire și de scriere pe unitatea ta, sau `omarchy disk speedtest` din terminal.

### Cum adaug o imprimantă?

Tipărirea este configurată și funcționează din start, iar fiecare imprimantă o adaugi singur din _Print Settings_ în lansatorul de aplicații (`Super + Alt + Space`).

Alege _Add_ și așteaptă puțin să caute: o imprimantă conectată prin USB și majoritatea imprimantelor de rețea sunt găsite pentru tine. Dacă a ta nu este în listă, alege _Network Printer > Internet Printing Protocol (ipp)_ și introdu adresa ei — ecranul propriu al imprimantei sau pagina ei web îți vor spune care este, de obicei ceva de genul `192.168.1.50` cu o coadă de `ipp/print`. _Forward_ îți oferă apoi un driver, unde o imprimantă modernă merge cel mai bine cu profilul fără driver _IPP Everywhere_, iar una mai veche vrea driverul propriu al modelului.

Fă clic dreapta pe o imprimantă și alege _Set as Default_ pentru a alege pe care o folosesc aplicațiile tale prima dată și _Properties_ pentru a seta dimensiunea hârtiei, duplexul și calitatea.

Descoperirea automată, prin care imprimantele din rețea apar fără să fie adăugate, este oprită temporar cât timp este regândită, motiv pentru care primul pas de mai sus îți aparține ție, nu este automat. Tipărirea într-un fișier PDF funcționează fără nicio imprimantă.

### Cum schimb unde se salvează capturile de ecran sau înregistrările de ecran?

Capturile de ecran salvate merg în `~/Pictures/Screenshots` în mod implicit. Pentru a folosi alt director, adaugă asta într-un fișier de sub `~/.config/uwsm/env.d/` (cum ar fi `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Poți face la fel pentru înregistrările de ecran folosind `OMARCHY_SCREENRECORD_DIR`.

Omasnap își creează automat directorul pentru capturi de ecran. Creează-ți singur directorul pentru înregistrări de ecran, apoi repornește Omarchy pentru ca oricare dintre modificările de mediu să intre în vigoare.

### Cum fac să funcționeze difuzoarele + webcamul pe Apple Studio Display-ul meu?

Te-ai gândi că totul ar trebui să meargă doar conectând USB C, dar, din păcate, nu este cazul. Soluția pe care am găsit-o ca să meargă fiabil este folosirea [cablului WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Apoi difuzoarele și webcamul merg ca unse.

Reține că ai control integrat al luminozității în Omarchy pentru ecranele Apple (atât Studio, cât și XDR), folosind butoanele obișnuite de luminozitate de pe tastatură.

### Cum scap de tot software-ul în plus?

Dacă nu vrei programe ca Obsidian sau LibreOffice sau orice altceva preinstalat, îl poți elimina foarte ușor.

Rulează _Remove > Package_ pentru a vedea fiecare pachet instalat. Apoi poți selecta orice pachet pe care vrei să-l elimini cu tab și poți începe să elimini tot ce ai selectat cu return.

Și poți folosi _Remove > Web App_ din meniul Omarchy pentru a elimina orice aplicație web preinstalată pe care nu o vrei.

Sau rulează _Remove > Preinstalls_ pentru a mătura dintr-o lovitură toate extraurile preinstalate — aplicații web, TUI-uri și aplicații opționale. Scurtăturile care le lansau dispar odată cu ele, așa că rămâi cu o tablă curată de combinații pe care să o umpli cu ale tale în `~/.config/hypr/bindings.lua`.

---

Pentru erori și părți stricate, vezi [secțiunea de depanare](45-troubleshooting.md).
