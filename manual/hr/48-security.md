# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo je zamišljeno kao operativni sustav koji možete koristiti za _Stvarni rad_ u _Stvarnom svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne krize. Evo što radimo:

1. *Šifriranje cijelog diska uključeno je prema zadanim postavkama*: Ovo je najvažniji korak za osiguravanje fizičke zaštite vaših podataka. Ako se vaše računalo izgubi ili ga ukradu, podaci su u potpunosti šifrirani pomoću standardnog LUKS-a (Linux Unified Key Setup). Instalacijski program omogućuje vam da to isključite za računala za jednokratnu uporabu (pogledajte [Početak rada](02-getting-started.md)); instalacija bez šifriranja nema ovu zaštitu i svatko tko drži disk može ga pročitati.
2. *Vatrozid je omogućen prema zadanim postavkama*: Sav dolazni promet prema zadanim postavkama je blokiran, uz nekoliko iznimaka: port 53317 za [LocalSend](https://localsend.org/); DNS upiti prema vlastitom razrješivaču računala na Docker bridge adresi (172.17.0.1), prihvaćeni iz raspona privatnih adresa koje Docker dodjeljuje svojim kontejnerima; i multicast DNS (port 5353), koji pisačima i drugim uređajima na vašoj mreži omogućuje da se međusobno pronađu, a tamo objavljuje i ime vašeg računala. Povrh toga, vatrozid zadržava standardna UFW dopuštenja za ping, dobivanje adrese od vašeg usmjerivača (DHCP) i UPnP otkrivanje. Čak je i ssh isključen dok ga ne uključite putem _Postavljanje > Sigurnost > SSHD_, što kao dio postavljanja otvara port 22 (s ograničenjem brzine protiv napada grubom silom). Čak zaključavamo i pristup Dockeru pomoću postavke [ufw-docker](https://github.com/chaifeng/ufw-docker) kako bismo spriječili da vaši kontejneri slučajno budu izloženi svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je izgrađen Omarchy, distribucija je s kontinuiranim izdanjima. To znači da je svaka sigurnosna ranjivost koja se otkrije i zakrpa u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek koristite najnovije, najsigurnije verzije svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib i vlastitog repozitorija paketa Omarchy Package Repository. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko neobaveznih instalacija, poput preglednika trećih strana, povlači pakete iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Infrastruktura za distribuciju Omarchyja — ISO-ovi, paketi Omarchyja, Archovo zrcalo — zaštićena je iza Cloudflareova snažnog DDoS štita i smještena na njihovom CDN-u. To pruža izvrsnu dostupnost.

## Mijenjanje lozinki

Imate dvije lozinke na šifriranoj instalaciji: onu koja otključava disk pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini istima. Obje se mogu promijeniti pod _Ažuriranje > Lozinka_ u izborniku Omarchy — _Šifriranje diska_ za prvu, _Korisnik_ za drugu. Za promjenu lozinke diska najprije se traži trenutačna, pa je imajte pri ruci. Ako se promjena prekine, ponovno pokrenite _Šifriranje diska_: traži lozinku koja sada otključava disk i dovršava promjenu.

## Predaja računala koje ste već koristili

Ako svoje računalo predajete nekome drugome, ne morate ga ponovno instalirati. Pokrenite _Uklanjanje > Vraćanje na tvorničke postavke_ u izborniku Omarchy, upišite `reset` za potvrdu i ponovno pokrenite računalo. To briše svaki korisnički račun i sve u `/home`, odbacuje sve pakete i promjene sustava koje ste napravili od instalacije te briše identitet računala — mrežne veze, ključeve hosta i sve ostalo. Ono što se ponovno pokrene jest čarobnjak za postavljanje s prvog pokretanja, spreman da novi vlasnik unese vlastito ime, lozinku i lozinku za šifriranje.

Radi tako da vraća osnovnu snimku koju napravi instalacijski program, pa je dostupno samo na računalima instaliranima s ISO-a Omarchyja. A na disku bez šifriranja vraćanje je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite svježu instalaciju.

## sudo bez lozinke

Ponekad želite da `sudo` prestane pitati, najčešće kada AI agent za vas obavlja dugačak dio posla na sustavu. _Postavljanje > Sigurnost > sudo bez lozinke_ pita koliko dugo dopustiti pristup: **15 minuta**, **1 sat**, **1 dan** ili **Trajno**. Crvena ikona upozorenja pojavljuje se pokraj ostalih pokazatelja na traci izbornika dok je pristup aktivan. Kliknite je ili ponovno pokrenite naredbu da biste isključili pristup. Možete proslijediti i vlastiti broj minuta (od 1 do 1440) pomoću `omarchy-sudo-passwordless 30` ili upotrijebiti `omarchy-sudo-passwordless permanent`.

Vremenski ograničen pristup automatski istječe, uključujući odmah nakon nastavka iz obustave koja je prešla rok. Ponovno pokretanje računala završava ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje paketa postavki Omarchyja završava svako privremeno odobrenje prije nego što se promijeni njegova podrška za istek. Ako naredba prijavi pogrešku autorizacije ili čišćenja, riješite je prije nego što pokušate omogućiti drugo odobrenje; pogreška ne znači da pristup bez lozinke nije aktivan.

Gledajte na ovo otvorenih očiju: dok je uključeno, sve što radi kao vaš korisnik može činiti bilo što kao root, a da ga se ne pita. To je cijela poanta, a to je i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve potpise ISO-a i pakete repozitorija Omarchyja je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za neprimjetno uvođenje svih mogućih ažuriranja.

Potpis za bilo koje ISO izdanje možete pronaći dodavanjem `.sig` njegovom URL-u, poput `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
