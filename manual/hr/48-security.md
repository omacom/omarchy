# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo treba biti operativni sustav koji možete koristiti za _Pravi posao_ u _Stvarnom svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne krize. Evo što radimo:

1. *Šifriranje cijelog diska je obavezno*: Ovo je najvažniji korak za fizičku zaštitu vaših podataka. Ako se vaše računalo izgubi ili ga ukradu, podaci su u potpunosti šifrirani standardnim LUKS-om (Linux Unified Key Setup).
2. *Vatrozid je omogućen prema zadanim postavkama*: Sav dolazni promet blokiran je prema zadanim postavkama, osim porta 53317 za [LocalSend](https://localsend.org/). Čak je i ssh isključen dok ga ne uključite putem _Postavljanje > Sigurnost > SSHD_, što kao dio postavljanja otvara port 22 (s ograničenom brzinom protiv napada grubom silom). Čak zaključavamo i pristup Dockeru pomoću postavki [ufw-docker](https://github.com/chaifeng/ufw-docker), kako bismo spriječili da vaši kontejneri slučajno budu izloženi svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je izgrađen Omarchy, distribucija je s kontinuiranim izdanjima. To znači da je svaka sigurnosna ranjivost koja se otkrije i zakrpa u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek koristite najnovije, najsigurnije verzije svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib i vlastitog Omarchy Package Repositoryja. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko neobaveznih instalacija, poput preglednika trećih strana, povlači pakete iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Infrastruktura za distribuciju Omarchyja — ISO-i, paketi Omarchyja, Archovo zrcalo — zaštićena je iza Cloudflareova snažnog štita od DDoS-a i smještena na njihovom CDN-u. To pruža izvrsnu dostupnost.

## Promjena lozinki

Na šifriranoj instalaciji imate dvije lozinke: onu koja otključava pogon pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini istima. Obje se mogu promijeniti pod _Ažuriranje > Lozinka_ u izborniku Omarchy — _Šifriranje pogona_ za prvu, _Korisnik_ za drugu. Promjena lozinke pogona prvo traži trenutnu lozinku, pa je imajte pri ruci. Ako se promjena prekine, ponovno pokrenite _Šifriranje pogona_: tražit će lozinku koja sada otključava pogon i dovršiti promjenu.

## Predaja računala koje ste već koristili

Ako svoje računalo predajete nekome drugome, ne morate ga ponovno instalirati. Pokrenite _Postavljanje > Ponovno postavljanje računala_ u izborniku Omarchy, upišite `reset` za potvrdu i ponovno pokrenite računalo. To briše svaki korisnički račun i sve u `/home`, odbacuje sve pakete i promjene sustava koje ste napravili od instalacije te briše identitet računala — mrežne veze, ključeve domaćina i sve. Ono što se ponovno pokrene čarobnjak je za postavljanje od prvog pokretanja, spreman da njegov novi vlasnik unese vlastito ime, lozinku i lozinku za šifriranje.

Radi tako da vraća osnovnu snimku koju napravi instalacijski program, pa je dostupno samo na računalima instaliranima s Omarchy ISO-a. A na pogonu bez šifriranja ponovno postavljanje je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite svježu instalaciju.

## sudo bez lozinke

Ponekad želite da `sudo` prestane tražiti lozinku, najčešće kada AI agent za vas obavlja dugotrajan posao na sustavu. _Postavljanje > Sigurnost > sudo bez lozinke_ pita koliko dugo dopustiti pristup: **15 minuta**, **1 sat**, **1 dan** ili **Trajno**. Crvena ikona upozorenja pojavljuje se uz ostale pokazatelje na traci izbornika dok je pristup aktivan. Kliknite je ili ponovno pokrenite naredbu da biste isključili pristup. Možete i proslijediti vlastiti broj minuta (od 1 do 1440) pomoću `omarchy-sudo-passwordless 30` ili upotrijebiti `omarchy-sudo-passwordless permanent`.

Vremenski ograničen pristup automatski istječe, uključujući odmah nakon nastavka rada iz obustave koja je prešla rok. Ponovno pokretanje računala završava ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje Omarchyjeva paketa postavki završava svaku privremenu dozvolu prije nego što se promijeni njezina podrška za istek. Ako naredba prijavi pogrešku autorizacije ili čišćenja, riješite je prije nego što pokušate omogućiti drugu dozvolu; pogreška ne znači da pristup bez lozinke nije aktivan.

Budite potpuno svjesni ovoga: dok je uključen, sve što se izvodi kao vaš korisnik može učiniti bilo što kao root bez ikakvog pitanja. To je cijela poanta, a to je i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve potpise ISO-a i pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za neprimjetno uvođenje svih mogućih ažuriranja.

Potpis za bilo koje izdanje ISO-a možete pronaći dodavanjem .sig URL-u. Poput https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
