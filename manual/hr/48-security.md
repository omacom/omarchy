# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo je zamišljeno kao operativni sustav koji možete koristiti za _pravi posao_ u _stvarnom svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne uzbune. Evo što radimo:

1. *Potpuno šifriranje diska uključeno je prema zadanim postavkama*: Ovo je najvažniji korak za fizičku zaštitu vaših podataka. Ako se vaše računalo izgubi ili ga ukradu, podaci su potpuno šifrirani standardnim LUKS-om (Linux Unified Key Setup). Instalacijski program omogućuje vam da to isključite za računala za jednokratnu upotrebu (pogledajte [Početak rada](02-getting-started.md)); instalacija bez šifriranja nema ništa od ove zaštite i svatko tko drži disk može ga pročitati.
2. *Vatrozid je omogućen prema zadanim postavkama*: Sav dolazni promet blokiran je prema zadanim postavkama, uz nekoliko iznimki: priključak 53317 za [LocalSend](https://localsend.org/); DNS upiti prema vlastitom razrješivaču računala na adresi Docker bridgea (172.17.0.1), prihvaćeni iz privatnih raspona adresa koje Docker daje svojim spremnicima; i multicast DNS (priključak 5353), koji pisačima i drugim uređajima na vašoj mreži omogućuje da se međusobno pronađu, a tamo i oglašava ime vašeg računala. Povrh toga, vatrozid zadržava standardna UFW dopuštenja za ping, dobivanje adrese od vašeg usmjerivača (DHCP) i UPnP otkrivanje. Čak je i ssh isključen dok ga ne uključite putem _Setup > Security > SSHD_, što kao dio postavljanja otvara priključak 22 (s ograničenom brzinom radi zaštite od napada grubom silom). Čak zaključavamo pristup Dockeru pomoću postavki [ufw-docker](https://github.com/chaifeng/ufw-docker) kako bismo spriječili da vaši spremnici slučajno budu izloženi svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je izgrađen Omarchy, distribucija je s neprekidnim izdanjima. To znači da je svaka sigurnosna ranjivost koja se otkrije i zakrpa u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek koristite najnovije, najsigurnije verzije svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib i vlastitog repozitorija Omarchy Package Repository. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko neobaveznih instalacija, poput preglednika trećih strana, povlači iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Infrastruktura za distribuciju Omarchyja — ISO-i, paketi Omarchyja, Archovo zrcalo — zaštićena je iza moćnog Cloudflareova DDoS štita i hostirana na njihovom CDN-u. To pruža izvrsnu dostupnost.

## Promjena vaših lozinki

Na šifriranoj instalaciji imate dvije lozinke: onu koja otključava disk pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini istima. Obje se mogu promijeniti pod _Update > Password_ u izborniku Omarchy — _Drive Encryption_ za prvu, _User_ za drugu. Promjena lozinke diska prvo traži trenutnu, pa je imajte pri ruci. Ako se promjena prekine, ponovno pokrenite _Drive Encryption_: tražit će lozinku koja sada otključava disk i dovršiti promjenu.

## Predavanje računala koje ste već koristili

Ako svoje računalo predajete nekome drugome, ne morate ga ponovno instalirati. Pokrenite _Setup > Reset Computer_ u izborniku Omarchy, upišite `reset` za potvrdu i ponovno pokrenite računalo. To briše svaki korisnički račun i sve u `/home`, odbacuje sve pakete i promjene sustava koje ste napravili od instalacije i briše identitet računala — mrežne veze, ključeve hosta i sve. Ono što se ponovno pokrene jest čarobnjak za postavljanje s prvog pokretanja, spreman da njegov novi vlasnik unese svoje ime, lozinku i lozinku za šifriranje.

Radi tako da vraća osnovnu snimku stanja koju instalacijski program napravi, pa je dostupno samo na računalima instaliranim s Omarchy ISO-a. A na disku bez šifriranja resetiranje je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite svježu instalaciju.

## sudo bez lozinke

Ponekad želite da `sudo` prestane pitati, najčešće kada AI agent za vas radi dugačak dio posla na sustavu. _Setup > Security > Passwordless Sudo_ pita koliko dugo dopustiti pristup: **15 minutes**, **1 Hour**, **1 Day** ili **Permanently**. Crvena ikona upozorenja pojavljuje se uz ostale pokazatelje na traci izbornika dok je pristup aktivan. Kliknite je ili ponovno pokrenite naredbu da biste isključili pristup. Možete proslijediti i vlastiti broj minuta (od 1 do 1440) s `omarchy-sudo-passwordless 30` ili upotrijebiti `omarchy-sudo-passwordless permanent`.

Vremenski ograničen pristup istječe automatski, uključujući odmah nakon nastavka iz obustave koja je prešla rok. Ponovno pokretanje računala završava ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje Omarchyjeva paketa postavki završava svako privremeno dopuštenje prije nego što se promijeni podrška za njegovo istjecanje. Ako naredba prijavi pogrešku autorizacije ili čišćenja, riješite je prije nego što pokušate omogućiti drugo dopuštenje; pogreška ne znači da je pristup bez lozinke neaktivan.

Gledajte na ovo otvorenih očiju: dok je uključeno, sve što radi kao vaš korisnik može kao root raditi bilo što, a da ga se ne pita. To je cijela poanta, a to je i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve potpise ISO-a i pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za neprimjetno uvođenje svih potencijalnih ažuriranja.

Potpis za bilo koje izdanje ISO-a možete pronaći dodavanjem `.sig` na njegov URL, poput `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
