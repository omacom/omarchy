# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo treba biti operativni sustav koji možete koristiti za _Pravi posao_ u _Stvarnom svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne krize. Evo što radimo:

1. *Šifriranje cijelog diska uključeno je prema zadanim postavkama*: Ovo je najvažniji korak za osiguravanje fizičke zaštite vaših podataka. Ako se vaše računalo izgubi ili ga ukradu, podaci su potpuno šifrirani standardnim LUKS-om (Linux Unified Key Setup). Instalacijski program omogućuje vam da to isključite za računala za jednokratnu upotrebu (pogledajte [Početak rada](02-getting-started.md)); instalacija bez šifriranja nema ništa od ove zaštite i svatko tko drži disk može ga pročitati.
2. *Vatrozid je omogućen prema zadanim postavkama*: Sav dolazni promet blokiran je prema zadanim postavkama, uz nekoliko iznimaka: port 53317 za [LocalSend](https://localsend.org/); DNS upiti prema vlastitom razrješitelju računala na adresi Docker bridgea (172.17.0.1), prihvaćeni iz privatnih raspona adresa koje Docker daje svojim spremnicima; i multicast DNS (port 5353), koji pisačima i drugim uređajima na vašoj mreži omogućuje da se međusobno pronađu, a tamo objavljuje i ime vašeg računala. Povrh toga, vatrozid zadržava standardne UFW-ove dozvole za ping, dobivanje adrese od vašeg usmjerivača (DHCP) i UPnP otkrivanje. Čak je i ssh isključen dok ga ne uključite putem _Postavljanje > Sigurnost > SSHD_, što autorizira vaš SSH ključ, isključuje prijave lozinkom i tek tada otvara port 22 (s ograničenjem brzine protiv napada grubom silom). Čak smo i pristup Dockeru zaključali pomoću postavki [ufw-docker](https://github.com/chaifeng/ufw-docker) kako bismo spriječili da vaši spremnici slučajno budu izloženi svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je izgrađen Omarchy, rolling je distribucija. To znači da je svaka sigurnosna ranjivost koja se otkrije i zakrpa u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek koristite najnovije, najsigurnije verzije svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib (na ARM računalima iz repozitorija Arch Linux ARM, plus Asahi ALARM na Apple Siliconu) i na vlastiti Omarchy Package Repository. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko opcionalnih instalacija, poput preglednika trećih strana, povlači pakete iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Infrastruktura za distribuciju Omarchyja — ISO-i, paketi Omarchyja, Archovo zrcalo — zaštićena je iza Cloudflareova moćnog štita od DDoS-a i smještena na njihovom CDN-u. To pruža izvrsnu dostupnost.

## Promjena vaših lozinki

Na šifriranoj instalaciji imate dvije lozinke: onu koja otključava disk pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini jednakima. _Ažuriranje > Lozinka_ u izborniku Omarchyja mijenja obje odjednom, pa ostaju jednake: traži trenutnu lozinku diska, zatim novu, mijenja lozinku diska i zatim postavlja vašu lozinku za prijavu da se podudara s njom. Bez šifriranja diska mijenja samo vašu lozinku za prijavu. Ako se promjena prekine, ponovno pokrenite _Ažuriranje > Lozinka_: tražit će lozinku koja sada otključava disk, dovršiti promjenu i postaviti vašu lozinku za prijavu na nju. Za promjenu lozinke drugog šifriranog diska pokrenite `omarchy-drive-password` u terminalu.

## Predavanje računala koje ste već koristili

Ako svoje računalo predajete nekom drugom, ne morate ga ponovno instalirati. Pokrenite _Uklanjanje > Vraćanje na tvorničke postavke_ u izborniku Omarchyja, upišite `reset` za potvrdu, unesite lozinku za šifriranje diska ako se to od vas zatraži i ponovno pokrenite računalo. To briše svaki korisnički račun i sve u `/home`, odbacuje sve pakete i promjene sustava koje ste napravili od instalacije te briše identitet računala — mrežne veze, host ključeve i sve ostalo. Nakon ponovnog pokretanja pojavljuje se čarobnjak za postavljanje s prvog pokretanja, spreman da novi vlasnik unese svoje ime, lozinku i lozinku za šifriranje.

Radi tako da vraća osnovnu snimku koju instalacijski program napravi, pa je dostupno samo na računalima instaliranim s Omarchy ISO-a. A na disku bez šifriranja vraćanje na tvorničke postavke je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite svježu instalaciju.

## sudo bez lozinke

Ponekad želite da `sudo` prestane tražiti lozinku, najčešće kada AI agent za vas obavlja dugačak dio posla na sustavu. _Postavljanje > Sigurnost > sudo bez lozinke_ pita koliko dugo želite dopustiti pristup: **15 minuta**, **1 sat**, **1 dan** ili **Trajno**. Dok je pristup aktivan, pokraj ostalih pokazatelja na traci izbornika pojavljuje se crvena ikona upozorenja. Kliknite je ili ponovno pokrenite naredbu da biste isključili pristup. Možete i proslijediti vlastiti broj minuta (od 1 do 1440) pomoću `omarchy-sudo-passwordless 30` ili upotrijebiti `omarchy-sudo-passwordless permanent`.

Vremenski ograničen pristup automatski istječe, uključujući odmah nakon nastavljanja iz obustave koja je prešla rok. Ponovno pokretanje računala završava ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje Omarchyjeva paketa postavki završava svako privremeno odobrenje prije nego što se promijeni njegova podrška za istek. Ako naredba prijavi pogrešku autorizacije ili čišćenja, riješite je prije nego što pokušate omogućiti drugo odobrenje; pogreška ne znači da je pristup bez lozinke neaktivan.

Budite potpuno svjesni ovoga: dok je uključeno, sve što se izvodi kao vaš korisnik može kao root učiniti bilo što, a da ga se to ne pita. To je cijela poanta, a to je i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve ISO potpise i paket repozitorija Omarchyja je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za besprijekorno uvođenje svih mogućih ažuriranja.

Potpis za bilo koje ISO izdanje možete pronaći dodavanjem `.sig` na njegov URL, poput `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
