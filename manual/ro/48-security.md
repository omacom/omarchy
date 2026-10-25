# Securitate

Omarchy tratează securitatea extrem de serios. Acesta este menit să fie un sistem de operare pe care îl poți folosi pentru a face _Muncă Adevărată_ în _Lumea Reală_. Unde pierderea unui laptop nu poate duce la o urgență de securitate. Așa că iată ce facem:

1. *Criptarea completă a discului este obligatorie*: Acesta este cel mai important pas pentru securizarea protecției fizice a datelor tale. Dacă îți pierzi computerul sau ți se fură, datele sunt complet criptate folosind LUKS (Linux Unified Key Setup) standard.
2. *Firewall-ul este activat în mod implicit*: Tot traficul de intrare este blocat în mod implicit, cu excepția portului 53317 pentru [LocalSend](https://localsend.org/). Chiar și ssh este dezactivat până când îl activezi prin _Setup > Security > SSHD_, ceea ce deschide portul 22 (limitat ca rată împotriva atacurilor brute force) ca parte a configurării. Blocăm chiar și accesul Docker folosind configurația [ufw-docker](https://github.com/chaifeng/ufw-docker) pentru a împiedica expunerea accidentală a containerelor tale către lume.
3. *Arch are întotdeauna cele mai recente actualizări*: Arch, distribuția de bază pe care este construit Omarchy, este o distribuție rolling. Asta înseamnă că orice vulnerabilitate de securitate care este descoperită și corectată în orice pachet devine rapid disponibilă pentru instalare folosind `omarchy-update`. Astfel rulezi întotdeauna cele mai recente și mai sigure versiuni ale tuturor lucrurilor.
4. *Omarchy își menține propriile pachete și mirror*: Omarchy se bazează în mod implicit doar pe pachete din depozitele core/extra/multilib proprii ale Arch și din propriul său Omarchy Package Repository. Poți instala software direct din AUR, dar instalarea de bază nu o face — doar câteva instalări opționale, cum ar fi browserele terțe, preiau din AUR.
5. *Cloudflare ne protejează împotriva DDoS*: Infrastructura de distribuție Omarchy — ISO-urile, pachetele Omarchy, mirror-ul Arch — este protejată în spatele formidabilului scut anti-DDoS al Cloudflare și găzduită pe CDN-ul lor. Acest lucru oferă o disponibilitate excelentă.

## Schimbarea parolelor tale

Ai două parole la o instalare criptată: cea care deblochează unitatea la pornire și cea cu care te autentifici și pe care o folosești cu `sudo`. Configurarea le face identice. Ambele pot fi schimbate în meniul Omarchy la _Update > Password_ — _Drive Encryption_ pentru prima, _User_ pentru a doua. Schimbarea parolei unității îți cere mai întâi parola actuală, așa că ai-o la îndemână. Dacă o schimbare este întreruptă, rulează din nou _Drive Encryption_: îți cere parola care deblochează unitatea în prezent și finalizează schimbarea.

## Predarea unui computer pe care l-ai folosit deja

Dacă predai computerul altcuiva, nu trebuie să îl reinstalezi. Rulează _Setup > Reset Computer_ în meniul Omarchy, tastează `reset` pentru a confirma și repornește. Acest lucru șterge fiecare cont de utilizator și tot ce se află în `/home`, elimină toate pachetele și modificările de sistem pe care le-ai făcut de la instalare și șterge identitatea computerului — conexiunile de rețea, cheile de gazdă și tot. Ce revine este asistentul de configurare de la prima pornire, pregătit pentru ca noul său proprietar să își introducă propriul nume, propria parolă și propria parolă de criptare.

Funcționează prin restaurarea snapshot-ului de bază pe care îl face programul de instalare, așa că este disponibil doar pe computerele instalate din ISO-ul Omarchy. Și pe o unitate fără criptare, o resetare este o ștergere, nu o ștergere securizată, așa că, dacă datele au fost sensibile, fă în schimb o instalare proaspătă.

## sudo fără parolă

Uneori vrei ca `sudo` să nu mai întrebe, cel mai adesea atunci când un agent AI face o perioadă lungă de lucru de sistem pentru tine. _Setup > Security > Passwordless Sudo_ te întreabă cât timp să permiți accesul: **15 minute**, **1 Hour**, **1 Day** sau **Permanently**. O pictogramă roșie de avertizare apare lângă ceilalți indicatori din bara de meniu cât timp accesul este activ. Fă clic pe ea sau rulează din nou comanda pentru a dezactiva accesul. Poți, de asemenea, să treci propriul număr de minute (de la 1 la 1440) cu `omarchy-sudo-passwordless 30` sau să folosești `omarchy-sudo-passwordless permanent`.

Accesul temporizat expiră automat, inclusiv imediat după reluarea dintr-o suspendare care a depășit termenul-limită. Repornirea computerului îl încheie mai devreme. Accesul permanent supraviețuiește repornirilor și rămâne activat până când îl dezactivezi.

Actualizarea sau eliminarea pachetului de setări Omarchy încheie orice acordare temporară înainte ca suportul său de expirare să se schimbe. Dacă comanda raportează o eroare de autorizare sau de curățare, rezolv-o înainte de a încerca să activezi o altă acordare; o eroare nu înseamnă că accesul fără parolă este inactiv.

Fii lucid în privința acestui lucru: cât timp este activat, orice rulează sub utilizatorul tău poate face orice ca root fără să fie întrebat. Acesta este tot rostul și este, de asemenea, tot riscul.

## Chei de semnare

Cheia publică pentru toate semnăturile ISO și pachetele din depozitul Omarchy este `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifică la openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pachetul `omarchy/omarchy-keyring` conține și el această cheie și va fi folosit pentru a distribui fără probleme orice posibile actualizări.

Poți găsi semnătura pentru orice lansare ISO adăugând .sig la URL. Cum ar fi https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
