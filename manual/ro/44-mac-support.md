# Suport pentru Mac

## Omarchy pentru Apple Silicon

Omarchy pentru Apple Silicon este o soluție oficială Omacom, lansată prima dată odată cu Omarchy 4.5. Se instalează alături de macOS, iar tu alegi între cele două când pornește Mac-ul tău.

Ai primit o notificare despre Omarchy Mac? Mergi la [Dacă vii de la Omarchy Mac](#coming-from-omarchy-mac).

Funcționează pe aceste Mac-uri:

| Mac | Cipuri |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Mac-urile cu M4 și mai noi nu sunt încă acceptate. Suportul pentru M4 este în testare pe canalul edge și urmează. Programul de instalare îți verifică Mac-ul înainte să schimbe ceva.

Pe orice Mac cu Apple Silicon, inclusiv M4 și mai noi, poți rula Omarchy într-o mașină virtuală cu [Try Omarchy](https://github.com/omacom/try-omarchy).

### De ce ai nevoie

- macOS 15 Sequoia sau mai nou și un cont de administrator
- Spațiu liber pe disc pentru Omarchy. Programul de instalare sugerează o dimensiune și te lasă să o schimbi.
- O copie de rezervă a Mac-ului tău, alimentare și o conexiune la internet. Instalarea descarcă mai mulți gigaocteți.

### Instalarea

Instalezi din macOS. Instalează Omarchy Installer cu [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Sau descarcă cel mai nou Omarchy Installer de pe [pagina sa de versiuni](https://github.com/omacom/omarchy-mac-installer/releases) și deschide-l.

Programul de instalare îți verifică Mac-ul, îți arată planul și face loc pentru Omarchy micșorând partiția macOS. macOS rămâne pe disc și nu ai nevoie de o unitate USB. Când prima etapă este gata, te ghidează să termini configurarea în macOS Recovery: închide, ține apăsat butonul de pornire până apare "Loading startup options", alege Omarchy și urmează pașii.

La prima pornire, Omarchy îți cere o parolă care îi criptează discul. Nu există cheie de recuperare: dacă uiți parola, fișierele tale Omarchy nu pot fi recuperate.

Pentru a comuta între Omarchy și macOS mai târziu, închide, apoi ține apăsat butonul de pornire până apar opțiunile de pornire și alege una.

### Dacă vii de la Omarchy Mac

Omarchy Mac face acum parte din Omarchy pentru Apple Silicon, iar fiecare Mac care l-a rulat este acceptat. Instalarea ta actuală continuă să funcționeze, iar pachetele sale de sistem se actualizează în continuare, dar nu mai primește actualizări Omarchy. Nu există un termen-limită și nici o actualizare pe loc: faci copie de rezervă, elimini instalarea veche, instalezi de la zero și restaurezi. Pașii de la 2 la 5 au loc în macOS, așa că deschide această pagină pe telefon înainte să repornești.

1. **Fă copie de rezervă din Omarchy, în afara Mac-ului.** Eliminarea instalării vechi o șterge, iar macOS nu poate citi discul Omarchy. Copiază-ți folderul personal pe o unitate externă sau pe alt computer, inclusiv cheile SSH și GPG, profilurile browserului și munca pentru care nu ai făcut push. Salvează-ți lista de pachete cu `pacman -Qqe > ~/packages.txt`. Fă copie de rezervă și pentru macOS, deoarece atât eliminarea, cât și instalarea îi redimensionează discul.
2. **Pornește-ți Mac-ul în macOS.** Închide, ține apăsat butonul de pornire până apar opțiunile de pornire și alege macOS.
3. **Instalează Omarchy Installer** așa cum se arată în [Instalarea](#installing).
4. **Elimină instalarea veche.** Deschide Omarchy Installer și alege Installation > Remove Omarchy. Îți arată ce va șterge și returnează spațiul către macOS. Dacă nu îți recunoaște instalarea, se oprește fără să schimbe discul. Cere ajutor în [Discord](https://discord.gg/tXFUdasqhY) mai degrabă decât să ștergi partiții manual, ceea ce poate șterge macOS.
5. **Instalează Omarchy pentru Apple Silicon** cu programul de instalare.
6. **Restaurează-ți fișierele.** Readu-ți setările pe rând, bucată cu bucată, mai degrabă decât să copiezi tot `~/.config` peste valorile implicite noi, deoarece setările vechi le pot suprascrie.

### Bine de știut

- Pe MacBook-urile cu M1 și M2, trezește-l din repaus deschizând capacul sau apăsând butonul de pornire.
- Întrebări sau probleme: întreabă în [Discord](https://discord.gg/tXFUdasqhY)-ul nostru.

[Fișierul README al programului de instalare](https://github.com/omacom/omarchy-mac-installer#readme) acoperă canalele de lansare, actualizarea programului de instalare și eliminarea Omarchy.

## Mac-uri Intel

Într-un test simplu, am reușit să obținem câștiguri de performanță de 36% pe un MacBook Pro din 2019 doar instalând Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalarea Omarchy pe Mac

Momentan, Omarchy acceptă doar să fie **singurul** sistem de operare instalat. În timpul instalării, unitatea va fi ștearsă, iar MacOS nu va mai putea porni.

Îl poți restaura totuși mai târziu prin Internet Recovery, dacă vrei.

Pentru această parte, vom presupune că ai parcurs deja [Primii pași](02-getting-started.md) și ai unitatea USB pregătită. Dacă nu, mergi și fă asta acum.

#### Dezactivează Secure Boot

Este necesar să dezactivezi Secure Boot de la Apple pentru a porni de pe USB-ul bootabil, precum și sistemul de operare. Pentru a-l dezactiva, fă următoarele:

1. Oprește-ți Mac-ul
2. Pornește-l și apasă și ține apăsat _imediat_ Command-R până vezi că apare ecranul de încărcare
3. Selectează-ți utilizatorul și introdu parola dacă ți se cere
4. Odată ajuns în ecranul de recuperare, alege **Utilities > Startup Security Utility** din bara de meniu
5. Introdu parola când ți se cere să te autentifici
6. Alege "No Security" din opțiunile Secure Boot
7. Alege "Allow booting from external or removable media" din opțiunile External Boot

#### Începe instalarea

1. Introdu unitatea USB
2. Repornește-ți Mac-ul și apasă și ține apăsat _imediat_ Option până vezi un ecran cu dispozitive de pornire
3. Selectează dispozitivul portocaliu EFI Boot
4. Continuă cu [instalarea ca de obicei](02-getting-started.md)

Programul de instalare detectează hardware-ul Mac și aplică automat corecțiile necesare: driverele și firmware-ul Broadcom Wi-Fi, driverul de tastatură SPI pe modelele MacBook care au nevoie de el și o corecție pentru suspendarea NVMe pentru aceleași modele.

### Limitări cunoscute

Membrii comunității lucrează constant la soluții pentru aceste provocări, așa că, dacă acestea sunt problematice pentru tine, vino în #omarchy-on-other în [Discord](https://discord.gg/tXFUdasqhY)-ul nostru și vezi dacă există metode actualizate pentru a le rezolva.

#### Dispozitive cu cip T1

Cipul Apple T1 a fost introdus la sfârșitul anului 2016 și folosit exclusiv în modelele MacBook Pro de prima generație cu Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Probleme cunoscute

- Touch Bar nu funcționează
- Sunetul nu funcționează

#### Dispozitive cu cip T2

Cipul de securitate Apple T2 a fost introdus în 2017. Cipul T2 a fost întrerupt odată cu tranziția la Apple silicon (cipurile din seria M) începând din 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Pe aceste modele, programul de instalare configurează automat nucleul `linux-t2` cu patch-uri, configurația audio T2, firmware-ul Broadcom Wi-Fi/Bluetooth de la Apple și controlul ventilatoarelor prin `t2fanrd`. Touch Bar funcționează pe suportul în stil Boot Camp încorporat în nucleu.

#### iMac Retina 5K (2017)

IMac-ul de 27 de inchi din 2017 nu are cip T2, așa că programul de instalare îl configurează ca pe celelalte Mac-uri Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Probleme cunoscute

- Ecranul nu rulează la rezoluția sa nativă 5120×2880: panoul este format din două dale, iar driverul standard aprinde doar una
- Sunetul nu funcționează
- Controlul luminozității nu are niciun efect
- Repausul blochează mașina; doar oprirea și repornirea o recuperează

Un program de patch-uri al comunității pentru acest model repară ecranul, sunetul și luminozitatea: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
