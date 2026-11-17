# Riistvara autentimine

### Sõrmejälje autentimine

Paljudel sülearvutitel on autentimiseks sõrmejäljesensor. Saad seda Omarchyga kasutada, kui käivitad Omarchy menüüs (`Super + Space`) valiku _Setup > Security > Fingerprint_.

See installib sõrmejälje paketi, salvestab su jälje, kontrollib selle üle ja ongi kõik valmis, et saaksid sõrmejälge kasutada lukustuskuvalt avamiseks (mille saad esile kutsuda klahvidega `Super + Ctrl + L`), sudo režiimi sisenemiseks ja süsteemi päringute autoriseerimiseks.

Kui lukustuskuva on ekraani välja lülitanud, puhkab sensor energia säästmiseks, seega ärata ekraan enne selle puudutamist mis tahes klahvi või puuteplaadiga.

Kui su sülearvuti kaas on suletud, jäetakse sõrmejälje päring automaatselt vahele, nii et jõuad otse parooli päringu juurde, selle asemel et oodata sensori taga, milleni sa ei ulatu. Kui pead muul juhul töötama välise klaviatuuriga, millel sensorit ei ole, vajuta lihtsalt `CTRL + C`, kui sult küsitakse `sudo` ajal sõrmejälge.

Sõrmejälje autentimise saad eemaldada Omarchy menüüs valiku _Remove > Security > Fingerprint_ alt.

### Fido2 autentimine

Kui kasutad Fido2 seadet, saad selle seadistada `sudo` autentimiseks Omarchy menüüs (`Super + Space`) valiku _Setup > Security > Fido2_ abil. See katab siiski `sudo` ja süsteemi autoriseerimise päringud, mitte arvuti avamist.

Saad fido2 autentimise eemaldada Omarchy menüüs valiku _Remove > Security > Fido2_ alt.
