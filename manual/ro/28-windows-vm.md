# Windows VM

Omarchy oferă o modalitate simplă de a rula Windows printr-un VM Docker pe mașini x86_64. Îl poți instala folosind _Instalare > Windows_ din meniul Omarchy (`Super + Space`).

Mașina ta are nevoie de virtualizare KVM pentru asta, ceea ce majoritatea au — dar uneori este dezactivată în BIOS, iar programul de instalare îți va spune dacă este cazul. Îți va trebui și spațiu pe disc: cât îi dai lui Windows, plus aproximativ 10GB pentru imaginea în sine.

Programul de instalare te întreabă câtă RAM, câte nuclee CPU și cât spațiu pe disc să îi aloci (64GB sau mai mult este limita minimă rezonabilă), apoi un nume de utilizator și o parolă pentru Windows. Lasă-le necompletate și primești `docker` / `admin`. Descărcarea durează ceva — 10-15 minute este normal — și poți urmări progresul în browser la `http://127.0.0.1:8006`. Browserul solicită același nume de utilizator și aceeași parolă înainte de a deschide consola.

 ![windows-vm](images/windows-vm.webp)

## Utilizare

Odată instalat, lansează _Windows_ din lansatorul de aplicații. Asta pornește VM-ul dacă nu rulează deja și te conectează prin RDP, pe tot ecranul. Acordă-i 15-30 de secunde la o pornire la rece.

Sesiunea RDP transportă sunetul, microfonul tău și un clipboard partajat, așa că copierea textului între Linux și Windows funcționează pur și simplu. Rezoluția urmează fereastra ta, iar Omarchy transmite scalarea ecranului tău, așa că nu este o mizerie neclară pe un ecran HiDPI.

Când închizi fereastra RDP, VM-ul se oprește automat. Dacă preferi să îl lași pornit — să zicem că ai ceva care lucrează acolo — lansează-l în schimb cu `omarchy windows vm launch --keep-alive`.

Restul comenzilor de control sunt pe aceeași comandă:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Partajarea fișierelor

Directorul `~/Windows` din directorul tău personal este partajat automat cu VM-ul. Pune fișiere acolo dacă vrei să fie accesibile pentru Windows. VM-ul nu are acces la nicio altă parte a sistemului tău de fișiere, așa că ești protejat de orice lucru urât din partea Windows. Propriul său disc virtual este disponibil la `~/.windows`.

Acele căi familiare din directorul personal rămân pe propriile lor sisteme de fișiere. Pot fi și symlink-uri către directoare pe care le deții, ceea ce este util când discul virtual se află pe o unitate mai mare. Programul de instalare măsoară spațiul liber de pe sistemul de fișiere care conține efectiv `~/.windows`, nu neapărat sistemul de fișiere care conține directorul tău personal.

Păstrează căile discului și căile partajate ca directoare separate, care nu se suprapun. Eliminarea golește în mod deliberat directorul discului, dar păstrează directorul partajat. Imediat înainte de ștergere, Omarchy efectuează o verificare de izolare cu durată limitată și refuză să elimine orice dacă acea verificare expiră sau nu poate dovedi că cei doi arbori sunt separați.

Înainte ca VM-ul să pornească, Omarchy deschide și fixează acele două directoare, apoi montează prin bind-mount inode-urile exacte ale directoarelor pe ancore private, per utilizator, sub `/var/lib/omarchy/windows/mounts`. Docker vede doar acele ancore protejate de root. Asta păstrează locațiile personalizate ale discului, împiedicând în același timp un alt proces care rulează ca tine să înlocuiască o cale verificată înainte ca containerul privilegiat să o consume. Directoarele existente ale discului și cele partajate sunt restrânse la modul `0700` în timpul migrării, astfel încât alte conturi locale să nu le poată răsfoi conținutul.

Porturile VM-ului sunt legate doar de localhost, așa că nimic din rețeaua ta nu poate ajunge la mașina Windows. Consola web necesită, de asemenea, numele de utilizator și parola Windows configurate, împiedicând un alt cont local să controleze VM-ul prin portul 8006.

## Limite și licențiere

Nu există GPU passthrough cu această configurație, așa că nu este potrivit pentru jocuri sau editare video. Este o modalitate excelentă de a rula Microsoft Office sau orice altceva îți trebuie neapărat.

Versiunea instalată este Windows 11 Pro, neactivată. Vei avea nevoie de propria ta cheie de licență pentru a folosi funcțiile restricționate.

Dacă acest computer a fost livrat cu Windows, cheia OEM este încă în firmware chiar și după instalarea Omarchy. Afișeaz-o cu `omarchy windows key`. Acea cheie este legată de această mașină — va activa Windows reinstalat pe acest hardware, dar de obicei nu va activa VM-ul.

Poți modifica ulterior alocarea resurselor rulând `omarchy windows vm install` într-un terminal, ceea ce rescrie configurația VM-ului pe baza răspunsurilor tale. Fișierul compose în sine se află acum la `/var/lib/omarchy/windows/docker-compose.yml` și este deținut de root — acest lucru este deliberat, pentru ca un proces care rulează ca tine să nu îl poată rescrie și să facă pornirea privilegiată să monteze întregul tău disc în container. Dacă trebuie să îl editezi manual (de exemplu pentru a monta un dispozitiv USB), editează-l cu `sudo` și vezi toate opțiunile pe [proiectul Dockur Windows](https://github.com/dockur/windows).

Pentru a scăpa de tot, folosește _Eliminare > Windows_ din meniul Omarchy. Asta șterge discul VM-ului din `~/.windows` și tot ce este instalat în Windows, așa că copiază mai întâi din VM tot ce îți trebuie. Directorul tău partajat `~/Windows` este lăsat în pace.
