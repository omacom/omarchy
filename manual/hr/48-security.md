# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo bi trebao biti operacijski sustav koji možete koristiti za obavljanje _pravog posla_ u _stvarnom svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne nužde. Pa evo što činimo:

1. *Šifriranje cijelog diska je obavezno*: Ovo je najvažniji korak u osiguravanju fizičke zaštite vaših podataka. Ako je vaše računalo izgubljeno ili ukradeno, podaci su potpuno šifrirani standardnim LUKS-om (Linux Unified Key Setup).
2. *Vatrozid je prema zadanim postavkama omogućen*: Sav dolazni promet prema zadanim je postavkama blokiran osim priključka 53317 za [LocalSend](https://localsend.org/). Čak je i ssh isključen dok ga ne uključite putem _Postavke > Security > SSHD_, što otvara priključak 22 (s ograničenjem brzine protiv napada grubom silom) kao dio postavljanja. Čak zaključavamo i Docker pristup pomoću postavke [ufw-docker](https://github.com/chaifeng/ufw-docker) kako bismo spriječili da se vaši spremnici slučajno izlože svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je Omarchy izgrađen, jest kotrljajuća distribucija. To znači da je svaka sigurnosna ranjivost koja se otkrije i zakrpa u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek pokrećete najnovije, najsigurnije inačice svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib i vlastitog Omarchy Package Repositoryja. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko opcionalnih instalacija, poput preglednika trećih strana, povlači iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Sva Omarchy distribucijska infrastruktura — ISO-i, Omarchy paketi, Arch zrcalo — zaštićena je iza Cloudflareovog snažnog DDoS štita i hostana na njihovom CDN-u. To pruža izvrsnu dostupnost.

## Promjena lozinki

Na šifriranoj instalaciji imate dvije lozinke: onu koja otključava pogon pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini istima. Obje se mogu promijeniti pod _Ažuriraj > Password_ u Omarchy izborniku — _Drive Encryption_ za prvu, _User_ za drugu. Promjena lozinke pogona prvo traži trenutačnu, pa je imajte pri ruci. Ako je promjena prekinuta, ponovno pokrenite _Drive Encryption_: traži lozinku koja sada otključava pogon i dovršava promjenu.

## Predaja računala koje ste već koristili

Ako svoje računalo predajete nekom drugom, ne morate ga ponovno instalirati. Pokrenite _Postavke > Reset Computer_ u Omarchy izborniku, upišite `reset` za potvrdu i ponovno pokrenite. Time se briše svaki korisnički račun i sve u `/home`, odbacuju svi paketi i promjene sustava koje ste napravili od instalacije te se briše identitet računala — mrežne veze, ključevi hosta i sve. Ono što se vrati jest čarobnjak za postavljanje s prvog pokretanja, spreman da novi vlasnik unese vlastito ime, lozinku i lozinku za šifriranje.

Radi vraćanjem osnovne snimke koju instalacijski program napravi, pa je dostupan samo na računalima instaliranim s Omarchy ISO-a. A na pogonu bez šifriranja resetiranje je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite svježu instalaciju.

## Sudo bez lozinke

Ponekad želite da `sudo` prestane pitati, najčešće kad AI agent za vas obavlja dugo razdoblje rada na sustavu. _Postavke > Security > Passwordless Sudo_ pita koliko dugo dopustiti pristup: **15 minutes**, **1 Hour**, **1 Day** ili **Permanently**. Crvena ikona upozorenja pojavi se pored drugih pokazatelja u traci izbornika dok je pristup aktivan. Kliknite je ili ponovno pokrenite naredbu za isključivanje pristupa. Također možete proslijediti vlastiti broj minuta (od 1 do 1440) s `omarchy-sudo-passwordless 30` ili koristiti `omarchy-sudo-passwordless permanent`.

Pristup na vrijeme istječe automatski, uključujući odmah nakon nastavka iz obustave koja je prešla rok. Ponovno pokretanje računala prekida ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje Omarchyjevog paketa postavki prekida svako privremeno dopuštenje prije nego što se promijeni njegova podrška za istek. Ako naredba prijavi pogrešku odobrenja ili čišćenja, riješite je prije nego što pokušate omogućiti drugo dopuštenje; pogreška ne znači da je pristup bez lozinke neaktivan.

Budite trezveni u ovome: dok je uključen, sve što radi kao vaš korisnik može kao root činiti bilo što bez pitanja. To je cijela poanta, a to je i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve ISO potpise i Omarchy repo pakete je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za neprimjetno uvođenje svih mogućih ažuriranja.

Potpis za svako ISO izdanje možete pronaći dodavanjem .sig URL-u. Poput https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
