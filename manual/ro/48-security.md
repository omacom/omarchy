# Securitate

Omarchy ia securitatea extrem de în serios. Acesta este menit să fie un sistem de operare pe care îl poți folosi ca să faci _Muncă Adevărată_ în _Lumea Reală_. Unde pierderea unui laptop nu poate duce la o urgență de securitate. Așa că iată ce facem:

1. *Criptarea completă a discului este obligatorie*: Acesta este cel mai important pas pentru securizarea protecției fizice a datelor tale. Dacă computerul tău este pierdut sau furat, datele sunt complet criptate folosind LUKS standard (Linux Unified Key Setup).
2. *Firewallul este activat implicit*: Tot traficul de intrare este blocat implicit, cu excepția portului 53317 pentru [LocalSend](https://localsend.org/). Chiar și ssh este oprit până când îl pornești prin _Configurare > Securitate > SSHD_, care deschide portul 22 (cu limitare a ratei împotriva forței brute) ca parte a configurării. Blocăm chiar și accesul Docker folosind configurația [ufw-docker](https://github.com/chaifeng/ufw-docker), ca să împiedicăm expunerea accidentală a containerelor tale lumii.
3. *Arch are întotdeauna cele mai recente actualizări*: Arch, distribuția subiacentă pe care este construit Omarchy, este o distribuție continuă. Asta înseamnă că orice vulnerabilitate de securitate descoperită și corectată în orice pachet este rapid disponibilă pentru instalare folosind `omarchy-update`. În felul acesta rulezi întotdeauna cele mai recente și mai sigure versiuni ale tuturor lucrurilor.
4. *Omarchy își menține propriile pachete și oglindă*: Omarchy se bazează implicit doar pe pachetele din depozitele core/extra/multilib proprii ale Arch și din propriul său Depozit de Pachete Omarchy. Poți instala software direct din AUR, dar instalarea de bază nu o face — doar câteva instalări opționale, precum browserele terțe, trag din AUR.
5. *Cloudflare ne protejează de DDoS*: Întreaga infrastructură de distribuție Omarchy — ISO-urile, pachetele Omarchy, oglinda Arch — este protejată în spatele formidabilului scut DDoS al Cloudflare și găzduită pe CDN-ul lor. Asta oferă o disponibilitate superbă.

## Schimbarea parolelor tale

Ai două parole pe o instalare criptată: cea care deblochează unitatea la pornire și cea cu care te autentifici și folosești `sudo`. Configurarea le face identice. Ambele pot fi schimbate sub _Actualizează > Parolă_ în meniul Omarchy — _Criptare disc_ pentru prima, _Utilizator_ pentru a doua. Schimbarea parolei unității cere mai întâi parola curentă, așa că ai-o la îndemână. Dacă o schimbare este întreruptă, rulează din nou _Criptare disc_: cere parola care deblochează unitatea acum și termină schimbarea.

## Predarea unei mașini pe care ai folosit-o deja

Dacă predai mașina ta altcuiva, nu trebuie să o reinstalezi. Rulează _Configurare > Resetează computerul_ în meniul Omarchy, tastează `reset` ca să confirmi și repornește. Asta șterge fiecare cont de utilizator și tot ce este în `/home`, aruncă toate pachetele și schimbările de sistem pe care le-ai făcut de la instalare și curăță identitatea mașinii — conexiuni de rețea, chei de gazdă și tot. Ce revine este asistentul de configurare de la prima pornire, pregătit ca noul său proprietar să-și introducă propriul nume, parolă și parolă de criptare.

Funcționează restaurând instantaneul de referință pe care îl ia programul de instalare, așa că este disponibil doar pe mașinile instalate din ISO-ul Omarchy. Și, pe o unitate fără criptare, o resetare este ștergere, nu o ștergere sigură, așa că, dacă datele erau sensibile, fă în schimb o instalare nouă.

## Sudo fără parolă

Uneori vrei ca `sudo` să nu mai ceară, cel mai adesea când un agent AI face o porțiune lungă de muncă de sistem pentru tine. _Configurare > Securitate > Sudo fără parolă_ întreabă cât timp să permită accesul: **15 minutes**, **1 Hour**, **1 Day** sau **Permanently**. O pictogramă roșie de avertizare apare lângă ceilalți indicatori din bara de meniu cât timp accesul este activ. Fă clic pe ea sau rulează din nou comanda ca să dezactivezi accesul. Poți transmite și propriul număr de minute (de la 1 la 1440) cu `omarchy-sudo-passwordless 30` sau poți folosi `omarchy-sudo-passwordless permanent`.

Accesul cronometrat expiră automat, inclusiv imediat după reluarea dintr-o suspendare care a depășit termenul. Repornirea computerului îl încheie mai devreme. Accesul permanent supraviețuiește repornirilor și rămâne activat până când îl dezactivezi.

Actualizarea sau eliminarea pachetului de setări al Omarchy încheie orice acordare temporară înainte ca suportul său pentru expirare să se schimbe. Dacă comanda raportează o eroare de autorizare sau de curățare, rezolv-o înainte să încerci să activezi altă acordare; o eroare nu înseamnă că accesul fără parolă este inactiv.

Fii lucid în privința acesteia: cât timp este pornită, orice rulează ca utilizatorul tău poate face orice ca root fără să fie întrebat. Ăsta este întregul scop, și este și întregul risc.

## Chei de semnare

Cheia publică pentru toate semnăturile ISO și pentru pachetul din depozitul Omarchy este `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifică la openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pachetul `omarchy/omarchy-keyring` conține și asta și va fi folosit ca să lanseze fără probleme orice actualizări potențiale.

Poți găsi semnătura pentru orice lansare ISO adăugând .sig la URL. Precum https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
