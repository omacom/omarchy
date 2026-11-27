# Hardverska autentifikacija

### Autentifikacija otiskom prsta

Mnoga prijenosna računala dolaze sa senzorom otiska prsta za autentifikaciju. Možete ga koristiti s Omarchyjem pokretanjem _Setup > Security > Fingerprint_ u izborniku Omarchy (`Super + Space`).

To otvara otisak prsta preko cijelog zaslona koji se popunjava dok dodirujete senzor. U pozadini će Omarchy instalirati paket za otisak prsta, prikupiti vaš otisak, provjeriti ga i bit ćete spremni koristiti otisak prsta za otključavanje sa zaslona za zaključavanje (koji možete pokrenuti sa `Super + Ctrl + L`), ulazak u sudo način rada i autorizaciju upita sustava.

Kada zaslon za zaključavanje isključi zaslon, senzor miruje radi uštede energije, pa probudite zaslon bilo kojom tipkom ili dodirnom pločicom prije nego što ga dodirnete.

Kada je poklopac prijenosnog računala zatvoren, upit za otisak prsta automatski se preskače, pa idete izravno na upit za lozinku umjesto da čekate senzor koji ne možete dosegnuti. Ako inače morate raditi na vanjskoj tipkovnici koja nema senzor, samo pritisnite `CTRL + C` kada se od vas zatraži otisak prsta tijekom `sudo`.

Autentifikaciju otiskom prsta možete ukloniti pod _Remove > Security > Fingerprint_ u izborniku Omarchy.

### Fido2 autentifikacija

Ako koristite Fido2 uređaj, možete ga postaviti za `sudo` autentifikaciju pomoću _Setup > Security > Fido2_ u izborniku Omarchy (`Super + Space`). To ipak pokriva `sudo` i upite za autorizaciju sustava, ali ne i otključavanje računala.

Fido2 autentifikaciju možete ukloniti pod _Remove > Security > Fido2_ u izborniku Omarchy.
