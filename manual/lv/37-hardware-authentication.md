# Aparatūras autentifikācija

### Pirksta nospieduma autentifikācija

Daudziem klēpjdatoriem ir pirksta nospieduma sensors autentifikācijai. Omarchy to varat izmantot, palaižot _Setup > Security > Fingerprint_ Omarchy izvēlnē (`Super + Space`).

Tas atvērs pilnekrāna pirksta nospiedumu, kas aizpildās, pieskaroties sensoram. Fonā Omarchy instalēs pirksta nospieduma pakotni, ievāks jūsu nospiedumu, pārbaudīs to, un viss būs gatavs, lai ar pirksta nospiedumu atbloķētu datoru no bloķēšanas ekrāna (ko varat izsaukt ar `Super + Ctrl + L`), ieietu sudo režīmā un autorizētu sistēmas uzvednes.

Tiklīdz bloķēšanas ekrāns ir izslēdzis displeju, sensors atpūšas, lai taupītu enerģiju, tāpēc pirms pieskaršanās tam pamodiniet ekrānu ar jebkuru taustiņu vai skārienpaliktni.

Kad klēpjdatora vāks ir aizvērts, pirksta nospieduma uzvedne tiek automātiski izlaista, tāpēc uzreiz nonāksiet pie paroles uzvednes, nevis gaidīsiet sensoru, kuram nevarat piekļūt. Ja citādi jāstrādā ar ārējo tastatūru, kurai nav sensora, vienkārši nospiediet `CTRL + C`, kad `sudo` laikā tiekat aicināts izmantot pirksta nospiedumu.

Pirksta nospieduma autentifikāciju varat noņemt sadaļā _Remove > Security > Fingerprint_ Omarchy izvēlnē.

### Fido2 autentifikācija

Ja izmantojat Fido2 ierīci, varat to iestatīt `sudo` autentifikācijai, izmantojot _Setup > Security > Fido2_ Omarchy izvēlnē (`Super + Space`). Taču tā attiecas uz `sudo` un sistēmas autorizācijas uzvednēm, nevis uz datora atbloķēšanu.

Fido2 autentifikāciju varat noņemt sadaļā _Remove > Security > Fido2_ Omarchy izvēlnē.
