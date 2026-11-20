# Securitate

Omarchy tratează securitatea extrem de serios. Acesta este menit să fie un sistem de operare pe care îl poți folosi pentru a face _Muncă Reală_ în _Lumea Reală_. Unde pierderea unui laptop nu poate duce la o urgență de securitate. Deci iată ce facem:

1. *Criptarea completă a discului este activată în mod implicit*: Acesta este cel mai important pas pentru securizarea protecției fizice a datelor tale. Dacă computerul tău este pierdut sau furat, datele sunt complet criptate folosind LUKS standard (Linux Unified Key Setup). Programul de instalare îți permite să renunți la aceasta pentru mașini de unică folosință (vezi [Primii pași](02-getting-started.md)); o instalare fără criptare nu are nimic din această protecție, iar oricine deține unitatea o poate citi.
2. *Firewall-ul este activat în mod implicit*: Tot traficul de intrare este blocat în mod implicit, cu câteva excepții: portul 53317 pentru [LocalSend](https://localsend.org/); interogări DNS către propriul resolver al computerului, la adresa podului Docker (172.17.0.1), acceptate din intervalele de adrese private pe care Docker le oferă containerelor sale; și DNS multicast (portul 5353), care permite imprimantelor și altor dispozitive din rețeaua ta să se găsească reciproc și, de asemenea, anunță acolo numele computerului tău. Pe lângă acestea, firewall-ul păstrează permisiunile standard ale UFW pentru ping, obținerea unei adrese de la routerul tău (DHCP) și descoperirea UPnP. Chiar și ssh este dezactivat până când îl activezi prin _Setup > Security > SSHD_, ceea ce deschide portul 22 (limitat ca rată împotriva atacurilor prin forță brută) ca parte a configurării. Blocăm chiar și accesul Docker folosind configurația [ufw-docker](https://github.com/chaifeng/ufw-docker) pentru a împiedica expunerea accidentală a containerelor tale către lume.
3. *Arch are întotdeauna cele mai recente actualizări*: Arch, distribuția de bază pe care este construit Omarchy, este o distribuție rolling. Aceasta înseamnă că orice vulnerabilitate de securitate descoperită și reparată în orice pachet devine rapid disponibilă pentru instalare folosind `omarchy-update`. În acest fel rulezi întotdeauna cele mai recente și mai sigure versiuni ale tuturor lucrurilor.
4. *Omarchy își întreține propriile pachete și propriul mirror*: Omarchy se bazează în mod implicit doar pe pachete din propriile depozite core/extra/multilib ale Arch și din propriul său Omarchy Package Repository. Poți instala software direct din AUR, dar instalarea de bază nu face acest lucru — doar câteva instalări opționale, cum ar fi browserele terțe, preiau din AUR.
5. *Cloudflare ne protejează de DDoS*: Infrastructura de distribuție Omarchy — ISO-urile, pachetele Omarchy, mirror-ul Arch — este protejată în spatele formidabilului scut DDoS al Cloudflare și găzduită pe CDN-ul lor. Acest lucru oferă o disponibilitate superbă.

## Schimbarea parolelor tale

Pe o instalare criptată ai două parole: cea care deblochează unitatea la pornire și cea cu care te autentifici și pe care o folosești cu `sudo`. Configurarea le face să fie aceeași. Ambele pot fi schimbate sub _Update > Password_ în meniul Omarchy — _Drive Encryption_ pentru prima, _User_ pentru a doua. Schimbarea parolei unității îți cere mai întâi parola curentă, așa că ai-o la îndemână. Dacă o schimbare este întreruptă, rulează din nou _Drive Encryption_: îți cere parola care deblochează unitatea acum și finalizează schimbarea.

## Predarea unei mașini pe care ai folosit-o deja

Dacă predai mașina ta altcuiva, nu trebuie să o reinstalezi. Rulează _Remove > Factory Reset_ în meniul Omarchy, tastează `reset` pentru a confirma și repornește. Acest lucru șterge fiecare cont de utilizator și tot ce se află în `/home`, aruncă toate pachetele și modificările de sistem pe care le-ai făcut de la instalare și șterge identitatea mașinii — conexiuni de rețea, chei de gazdă și tot. Ce revine la pornire este expertul de configurare de la prima pornire, gata ca noul proprietar să își introducă propriul nume, propria parolă și propria parolă de criptare.

Funcționează prin restaurarea instantaneului de bază pe care îl face programul de instalare, așa că este disponibil doar pe mașinile instalate de pe ISO-ul Omarchy. Iar pe o unitate fără criptare, o resetare înseamnă ștergere, nu ștergere sigură, așa că, dacă datele au fost sensibile, fă în schimb o instalare proaspătă.

## sudo fără parolă

Uneori vrei ca `sudo` să nu te mai întrebe, cel mai adesea atunci când un agent AI face o perioadă lungă de lucru de sistem pentru tine. _Setup > Security > Passwordless Sudo_ te întreabă cât timp să permiți accesul: **15 minutes**, **1 Hour**, **1 Day** sau **Permanently**. O pictogramă roșie de avertizare apare lângă ceilalți indicatori din bara de meniu cât timp accesul este activ. Dă clic pe ea sau rulează din nou comanda pentru a dezactiva accesul. Poți, de asemenea, să treci propriul număr de minute (de la 1 la 1440) cu `omarchy-sudo-passwordless 30` sau să folosești `omarchy-sudo-passwordless permanent`.

Accesul temporizat expiră automat, inclusiv imediat după reluarea dintr-o suspendare care a depășit termenul limită. Repornirea computerului îl încheie mai devreme. Accesul permanent supraviețuiește repornirilor și rămâne activat până când îl dezactivezi.

Actualizarea sau eliminarea pachetului de setări al Omarchy încheie orice acordare temporară înainte ca suportul său de expirare să se schimbe. Dacă comanda raportează o eroare de autorizare sau de curățare, rezolv-o înainte de a încerca să activezi o altă acordare; o eroare nu înseamnă că accesul fără parolă este inactiv.

Fii lucid în privința acestui lucru: cât timp este activat, orice rulează sub utilizatorul tău poate face orice ca root fără să fie întrebat. Acesta este întregul scop și este, de asemenea, întregul risc.

## Chei de semnare

Cheia publică pentru toate semnăturile ISO și pentru pachetul din depozitul Omarchy este `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifică la openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pachetul `omarchy/omarchy-keyring` o conține, de asemenea, și va fi folosit pentru a distribui fără probleme orice eventuale actualizări.

Poți găsi semnătura pentru orice versiune ISO adăugând `.sig` la URL-ul său, cum ar fi `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
