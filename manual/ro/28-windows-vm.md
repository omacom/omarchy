# Mașină virtuală Windows

Omarchy oferă o cale ușoară de a rula Windows printr-o mașină virtuală Docker. O poți instala folosind _Instalează > Windows_ din meniul Omarchy (`Super + Space`).

Mașina ta are nevoie de virtualizare KVM pentru asta, ceea ce majoritatea au — dar uneori este dezactivată în BIOS, iar programul de instalare îți va spune dacă este cazul. Vei vrea și spațiul pe disc: orice îi dai lui Windows, plus cam 10 GB pentru imaginea în sine.

Programul de instalare întreabă cât RAM, câte nuclee CPU și cât disc să predea (64 GB sau mai mult este pragul sensibil), apoi un nume de utilizator și o parolă Windows. Lasă-le necompletate și primești `docker` / `admin`. Descărcarea durează un timp — 10-15 minute este normal — și poți urmări progresul în browser la `http://127.0.0.1:8006`. Browserul cere același nume de utilizator și aceeași parolă înainte să deschidă consola.

 ![windows-vm](images/windows-vm.webp)

## Folosirea ei

Odată ce este instalată, lansează _Windows_ din lansatorul de aplicații. Asta pornește mașina virtuală dacă nu rulează deja și te conectează prin RDP, pe tot ecranul. Dă-i 15-30 de secunde la o pornire la rece.

Sesiunea RDP transportă sunet, microfonul tău și un clipboard partajat, așa că copierea textului între Linux și Windows pur și simplu funcționează. Rezoluția urmează fereastra ta, iar Omarchy îți trece scalarea afișajului, așa că nu este o mizerie încețoșată pe un ecran HiDPI.

Când închizi fereastra RDP, mașina virtuală se oprește automat. Dacă ai prefera să o lași rulând — să zicem că ai ceva care lucrează acolo — lanseaz-o în schimb cu `omarchy windows vm launch --keep-alive`.

Restul controalelor sunt pe aceeași comandă:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Partajarea fișierelor

Directorul `~/Windows` din directorul tău home este partajat automat cu mașina virtuală. Pune fișiere acolo dacă vrei ca ele să fie accesibile lui Windows. Mașina virtuală nu are acces la nicio altă parte a sistemului tău de fișiere, așa că ești în siguranță față de orice lucru urât de pe partea Windows. Discul ei virtual propriu este disponibil la `~/.windows`.

Acele căi home familiare rămân pe propriile lor sisteme de fișiere. Ele pot fi și legături simbolice către directoare pe care le deții, ceea ce este util atunci când discul virtual trăiește pe o unitate mai mare. Programul de instalare măsoară spațiul liber pe sistemul de fișiere care conține de fapt `~/.windows`, nu neapărat sistemul de fișiere care conține directorul tău home.

Păstrează căile pentru disc și pentru partajare ca directoare separate, care nu se suprapun. Eliminarea golește în mod deliberat directorul discului, dar păstrează directorul partajat. Imediat înainte de ștergere, Omarchy efectuează o verificare mărginită de izolare și refuză să elimine orice dacă acea verificare expiră sau nu poate dovedi că cei doi arbori sunt separați.

Înainte ca mașina virtuală să pornească, Omarchy deschide și fixează acele două directoare, apoi montează prin bind inode-urile exacte ale directoarelor pe ancore private per utilizator sub `/var/lib/omarchy/windows/mounts`. Docker vede numai acele ancore protejate de root. Asta păstrează locațiile personalizate ale discului, împiedicând în același timp alt proces care rulează ca tine să schimbe o cale verificată înainte ca recipientul privilegiat să o consume. Directoarele existente pentru disc și partajare sunt închise la modul `0700` în timpul migrării, astfel încât alte conturi locale să nu le poată răsfoi conținutul.

Porturile mașinii virtuale sunt legate numai de localhost, așa că nimic din rețeaua ta nu poate ajunge la mașina Windows. Consola web cere și numele de utilizator și parola Windows configurate, împiedicând alt cont local să conducă mașina virtuală prin portul 8006.

## Limite și licențiere

Nu există trecere GPU cu această configurație, așa că nu este potrivită pentru jocuri sau editare video. Este o cale excelentă de a rula Microsoft Office sau orice altceva de care trebuie neapărat să dispui.

Versiunea instalată este Windows 11 Pro, neactivată. Vei avea nevoie de propria cheie de licență ca să folosești funcțiile restricționate.

Dacă acest computer a venit cu Windows, cheia OEM este încă în firmware, chiar și după instalarea Omarchy. Afișeaz-o cu `omarchy windows key`. Acea cheie este legată de această mașină — va activa Windows reinstalat pe acest hardware, dar de obicei nu va activa mașina virtuală.

Poți schimba alocarea de resurse mai târziu rulând din nou `omarchy-windows-vm install`, ceea ce rescrie configurația mașinii virtuale din răspunsurile tale. Fișierul compose însuși trăiește acum la `/var/lib/omarchy/windows/docker-compose.yml` și este deținut de root — asta este deliberat, astfel încât un proces care rulează ca tine să nu îl poată rescrie și să facă pornirea privilegiată să-ți monteze întregul disc în container. Dacă trebuie să-l editezi manual (de exemplu ca să montezi un dispozitiv USB), editează-l cu `sudo` și vezi toate opțiunile pe [proiectul Dockur Windows](https://github.com/dockur/windows).

Ca să scapi de tot, folosește _Elimină > Windows_ din meniul Omarchy. Asta șterge discul mașinii virtuale și toate datele lui, așa că asigură-te că orice îți pasă este afară din `~/Windows` mai întâi.
