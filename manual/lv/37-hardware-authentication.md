# Aparatūras autentifikācija

### Pirksta nospieduma autentifikācija

Daudziem klēpjdatoriem ir pirksta nospieduma sensors autentifikācijai. To vari izmantot ar Omarchy, Omarchy izvēlnē (`Super + Space`) palaižot _Iestatīšana > Drošība > Pirksta nospiedums_.

Tas instalēs pirksta nospieduma pakotni, nolasīs tavu nospiedumu, pārbaudīs to, un tu būsi gatavs ar pirksta nospiedumu atbloķēt datoru no bloķēšanas ekrāna (kuru vari izsaukt ar `Super + Ctrl + L`), ieiet sudo režīmā un apstiprināt sistēmas pieprasījumus.

Kad bloķēšanas ekrāns ir izslēdzis displeju, sensors atpūšas, lai taupītu enerģiju, tāpēc pirms pieskaršanās tam pamodini ekrānu ar jebkuru taustiņu vai skārienpaliktni.

Kad tava klēpjdatora vāks ir aizvērts, pirksta nospieduma pieprasījums tiek automātiski izlaists, tāpēc tu nonāksi tieši pie paroles ievades, nevis gaidīsi sensoru, kuram nevari tikt klāt. Ja citādi tev jāstrādā ar ārējo tastatūru, kurai nav sensora, vienkārši nospied `CTRL + C`, kad `sudo` laikā tev tiek prasīts pirksta nospiedums.

Pirksta nospieduma autentifikāciju vari noņemt Omarchy izvēlnē zem _Noņemt > Drošība > Pirksta nospiedums_.

### Fido2 autentifikācija

Ja izmanto Fido2 ierīci, vari to iestatīt `sudo` autentifikācijai, Omarchy izvēlnē (`Super + Space`) izmantojot _Iestatīšana > Drošība > Fido2_. Taču tā attiecas uz `sudo` un sistēmas autorizācijas pieprasījumiem, nevis uz tava datora atbloķēšanu.

Fido2 autentifikāciju vari noņemt Omarchy izvēlnē zem _Noņemt > Drošība > Fido2_.
