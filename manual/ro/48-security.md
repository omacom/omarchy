# Securitate

Omarchy tratează securitatea extrem de serios. Acesta este menit să fie un sistem de operare pe care îl poți folosi pentru a face _Muncă Adevărată_ în _Lumea Reală_. Unde pierderea unui laptop nu poate duce la o urgență de securitate. Așadar, iată ce facem:

1. *Criptarea completă a discului este activată implicit*: Acesta este cel mai important pas pentru a asigura protecția fizică a datelor tale. Dacă îți pierzi computerul sau ți se fură, datele sunt complet criptate folosind standardul LUKS (Linux Unified Key Setup). Programul de instalare îți permite să renunți la ea pentru computerele de sacrificiu (vezi [Noțiuni introductive](02-getting-started.md)); o instalare fără criptare nu are deloc această protecție, iar oricine pune mâna pe disc îl poate citi.
2. *Firewallul este activat implicit*: Tot traficul de intrare este blocat implicit, cu câteva excepții: portul 53317 pentru [LocalSend](https://localsend.org/); interogările DNS către resolverul propriu al computerului, la adresa bridge-ului Docker (172.17.0.1), acceptate din intervalele de adrese private pe care Docker le atribuie containerelor sale; și DNS multicast (portul 5353), care le permite imprimantelor și altor dispozitive din rețeaua ta să se găsească reciproc și anunță acolo și numele computerului tău. Pe lângă acestea, firewallul păstrează permisiunile standard ale UFW pentru ping, pentru obținerea unei adrese de la routerul tău (DHCP) și pentru descoperirea UPnP. Chiar și ssh este dezactivat până când îl activezi prin _Setup > Security > SSHD_, care deschide portul 22 (cu limitare a ratei împotriva atacurilor prin forță brută) ca parte a configurării. Blocăm chiar și accesul Docker folosind configurația [ufw-docker](https://github.com/chaifeng/ufw-docker), pentru a împiedica expunerea accidentală a containerelor tale către lume.
3. *Arch are întotdeauna cele mai recente actualizări*: Arch, distribuția subiacentă pe care este construit Omarchy, este o distribuție rolling. Asta înseamnă că orice vulnerabilitate de securitate descoperită și reparată în orice pachet devine rapid disponibilă pentru instalare folosind `omarchy-update`. Astfel rulezi mereu cele mai recente și mai sigure versiuni ale tuturor lucrurilor.
4. *Omarchy își întreține propriile pachete și mirror*: Implicit, Omarchy se bazează doar pe pachete din depozitele proprii Arch core/extra/multilib și din propriul său Omarchy Package Repository. Poți instala software direct din AUR, dar instalarea de bază nu o face — doar câteva instalări opționale, cum ar fi browserele terțe, preiau din AUR.
5. *Cloudflare ne protejează de DDoS*: Infrastructura de distribuție Omarchy — imaginile ISO, pachetele Omarchy, mirrorul Arch — este protejată în spatele formidabilului scut DDoS al Cloudflare și găzduită pe CDN-ul lor. Acest lucru oferă o disponibilitate excelentă.

## Schimbarea parolelor tale

Pe o instalare criptată ai două parole: cea care deblochează discul la pornire și cea cu care te autentifici și pe care o folosești cu `sudo`. Configurarea le face să fie aceleași. Ambele pot fi schimbate din _Update > Password_ în meniul Omarchy — _Drive Encryption_ pentru prima, _User_ pentru a doua. Schimbarea parolei discului îți cere mai întâi parola actuală, așa că ai-o la îndemână. Dacă o schimbare este întreruptă, rulează din nou _Drive Encryption_: îți cere parola care deblochează acum discul și finalizează schimbarea.

## Predarea unui computer pe care l-ai folosit deja

Dacă îi predai computerul tău altcuiva, nu trebuie să îl reinstalezi. Rulează _Setup > Reset Computer_ în meniul Omarchy, tastează `reset` pentru confirmare și repornește. Asta șterge fiecare cont de utilizator și tot ce se află în `/home`, aruncă toate pachetele și modificările de sistem pe care le-ai făcut de la instalare și șterge identitatea computerului — conexiuni de rețea, chei de gazdă, tot. Ceea ce pornește apoi este asistentul de configurare de la prima pornire, gata ca noul proprietar să își introducă propriul nume, propria parolă și propria parolă de criptare.

Funcționează prin restaurarea instantaneului de bază pe care îl face programul de instalare, așa că este disponibil doar pe computerele instalate din imaginea ISO Omarchy. Iar pe un disc fără criptare, o resetare este o ștergere, nu o ștergere sigură, așa că, dacă datele au fost sensibile, fă în schimb o instalare proaspătă.

## Sudo fără parolă

Uneori vrei ca `sudo` să nu te mai întrebe, cel mai adesea atunci când un agent AI face pentru tine o perioadă lungă de lucru asupra sistemului. _Setup > Security > Passwordless Sudo_ te întreabă cât timp să permiți accesul: **15 minutes**, **1 Hour**, **1 Day** sau **Permanently**. O pictogramă roșie de avertizare apare lângă ceilalți indicatori din bara de meniu cât timp accesul este activ. Dă clic pe ea sau rulează din nou comanda pentru a dezactiva accesul. Poți, de asemenea, să treci propriul număr de minute (de la 1 la 1440) cu `omarchy-sudo-passwordless 30`, sau să folosești `omarchy-sudo-passwordless permanent`.

Accesul temporizat expiră automat, inclusiv imediat după revenirea dintr-o suspendare care a depășit termenul-limită. Repornirea computerului îl încheie mai devreme. Accesul permanent supraviețuiește repornirilor și rămâne activat până când îl dezactivezi.

Actualizarea sau eliminarea pachetului de setări Omarchy încheie orice acordare temporară înainte ca suportul său pentru expirare să se schimbe. Dacă acea comandă raportează o eroare de autorizare sau de curățare, rezolv-o înainte de a încerca să activezi o altă acordare; o eroare nu înseamnă că accesul fără parolă este inactiv.

Fii lucid cu privire la asta: cât timp este activat, orice rulează sub utilizatorul tău poate face orice ca root fără să fie întrebat. Acesta este tot scopul și este, de asemenea, tot riscul.

## Chei de semnare

Cheia publică pentru toate semnăturile ISO și pachetele din depozitul Omarchy este `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifică pe openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pachetul `omarchy/omarchy-keyring` o conține, de asemenea, și va fi folosit pentru a distribui fără probleme orice posibile actualizări.

Poți găsi semnătura pentru orice versiune ISO adăugând `.sig` la URL-ul ei, cum ar fi `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
