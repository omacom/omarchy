# Riistvaraline autentimine

### Sõrmejälje autentimine

Paljudel sülearvutitel on autentimiseks sõrmejäljesensor. Saad seda Omarchyga kasutada, käivitades Omarchy menüüs (`Super + Space`) valiku _Seadistus > Turvalisus > Sõrmejälg_.

See avab täisekraanil sõrmejälje, mis täitub sensorit puudutades. Taustal installib Omarchy sõrmejälje paketi, kogub sinu jälje, kontrollib selle üle ja oledki valmis kasutama oma sõrmejälge lukustuskuvalt avamiseks (mille saad käivitada klahvikombinatsiooniga `Super + Ctrl + L`), `sudo` režiimi sisenemiseks ja süsteemiviipade autoriseerimiseks.

Kui lukustuskuva on ekraani välja lülitanud, puhkab sensor energia säästmiseks, nii et ärata ekraan enne selle puudutamist mis tahes klahvi või puuteplaadiga.

Kui su sülearvuti kaas on suletud, jäetakse sõrmejäljeviip automaatselt vahele, nii et jõuad otse parooliviiba juurde, selle asemel et oodata sensori järgi, milleni sa ei ulatu. Kui sul on muidu vaja töötada välise klaviatuuriga, millel sensorit pole, vajuta lihtsalt `CTRL + C`, kui sinult küsitakse `sudo` ajal sõrmejälge.

Sõrmejälje autentimise saad eemaldada Omarchy menüüs valiku _Eemalda > Turvalisus > Sõrmejälg_ alt.

### Fido2 autentimine

Kui kasutad Fido2 seadet, saad selle seadistada `sudo` autentimiseks Omarchy menüüs (`Super + Space`) valiku _Seadistus > Turvalisus > Fido2_ abil. See hõlmab küll `sudo` ja süsteemi autoriseerimisviipasid, kuid mitte arvuti avamist.

Fido2 autentimise saad eemaldada Omarchy menüüs valiku _Eemalda > Turvalisus > Fido2_ alt.
