# Hardverska autentifikacija

### Autentifikacija otiskom prsta

Mnoga prijenosna računala dolaze sa senzorom otiska prsta za autentifikaciju. To možete koristiti s Omarchyjem pokretanjem _Postavljanje > Sigurnost > Otisak prsta_ u izborniku Omarchy (`Super + Space`).

Time će se instalirati paket za otisak prsta, zabilježiti vaš otisak i provjeriti ga, pa ćete biti spremni koristiti otisak prsta za otključavanje sa zaslona zaključavanja (koji možete pokrenuti sa `Super + Ctrl + L`), za ulazak u sudo način rada i za autorizaciju upita sustava.

Kada zaslon zaključavanja isključi zaslon, senzor miruje kako bi uštedio energiju, pa probudite zaslon bilo kojom tipkom ili dodirnom pločicom prije nego što ga dodirnete.

Kada je poklopac vašeg prijenosnog računala zatvoren, upit za otisak prsta automatski se preskače, pa idete ravno na upit za lozinku umjesto da čekate senzor do kojeg ne možete doći. Ako inače morate raditi na vanjskoj tipkovnici koja nema senzor, samo pritisnite `CTRL + C` kada se od vas zatraži otisak prsta tijekom `sudo`.

Autentifikaciju otiskom prsta možete ukloniti pod _Ukloni > Sigurnost > Otisak prsta_ u izborniku Omarchy.

### Fido2 autentifikacija

Ako koristite Fido2 uređaj, možete ga postaviti za `sudo` autentifikaciju pomoću _Postavljanje > Sigurnost > Fido2_ u izborniku Omarchy (`Super + Space`). To međutim pokriva `sudo` i upite za autorizaciju sustava, a ne otključavanje vašeg računala.

Fido2 autentifikaciju možete ukloniti pod _Ukloni > Sigurnost > Fido2_ u izborniku Omarchy.
