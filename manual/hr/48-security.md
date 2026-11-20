# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo je zamišljeno kao operativni sustav koji možete koristiti za _Stvarni posao_ u _Stvarnom svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne uzbune. Evo što radimo:

1. *Potpuno šifriranje diska uključeno je prema zadanim postavkama*: Ovo je najvažniji korak za fizičku zaštitu vaših podataka. Ako se vaše računalo izgubi ili ga ukradu, podaci su u potpunosti šifrirani standardnim LUKS-om (Linux Unified Key Setup). Instalacijski program dopušta vam da to isključite za računala za jednokratnu uporabu (pogledajte [Početak rada](02-getting-started.md)); instalacija bez šifriranja nema ovu zaštitu i svatko tko drži disk može ga pročitati.
2. *Vatrozid je omogućen prema zadanim postavkama*: Sav dolazni promet prema zadanim je postavkama blokiran, uz nekoliko iznimaka: priključak 53317 za [LocalSend](https://localsend.org/); DNS upiti prema vlastitom razrješivaču računala na adresi Docker bridgea (172.17.0.1), prihvaćeni iz privatnih raspona adresa koje Docker daje svojim spremnicima; i multicast DNS (priključak 5353), koji pisačima i drugim uređajima na vašoj mreži omogućuje da se međusobno pronađu i ondje objavljuje i ime vašeg računala. Povrh toga, vatrozid zadržava standardna UFW dopuštenja za ping, dohvaćanje adrese od vašeg usmjerivača (DHCP) i otkrivanje UPnP-a. Čak je i ssh isključen dok ga ne uključite putem _Postavljanje > Sigurnost > SSHD_, što autorizira vaš SSH ključ, isključuje prijave lozinkom i tek zatim otvara priključak 22 (s ograničenjem brzine protiv napada grubom silom). Čak i pristup Dockeru zaključavamo postavkama [ufw-docker](https://github.com/chaifeng/ufw-docker) kako bismo spriječili da vaši spremnici slučajno budu izloženi svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je izgrađen Omarchy, distribucija je s kontinuiranim izdanjima. To znači da je svaka sigurnosna ranjivost koja se otkrije i zakrpa u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek koristite najnovije, najsigurnije inačice svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib (na ARM računalima Arch Linux ARM, plus Asahi ALARM na Apple Siliconu) i na vlastiti Omarchy Package Repository. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko neobaveznih instalacija, poput preglednika trećih strana, povlači iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Distribucijska infrastruktura Omarchyja — ISO-ovi, paketi Omarchyja, Archovo zrcalo — zaštićena je iza Cloudflareova moćnog DDoS štita i poslužuje se na njihovom CDN-u. To pruža vrhunsku dostupnost.

## Mijenjanje lozinki

Imate dvije lozinke na šifriranoj instalaciji: onu koja otključava disk pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini istima. Obje se mogu promijeniti pod _Ažuriranje > Lozinka_ u izborniku Omarchy — _Šifriranje diska_ za prvu, _Korisnik_ za drugu. Za promjenu lozinke diska prvo se traži trenutačna, pa je imajte pri ruci. Ako se promjena prekine, ponovno pokrenite _Šifriranje diska_: traži lozinku koja sada otključava disk i dovršava promjenu.

## Predaja računala koje ste već koristili

Ako svoje računalo predajete nekom drugom, ne morate ga ponovno instalirati. Pokrenite _Ukloni > Vraćanje na tvorničke postavke_ u izborniku Omarchy, upišite `reset` za potvrdu, unesite lozinku za šifriranje diska ako se to zatraži i ponovno pokrenite računalo. Time se brišu svi korisnički računi i sve u `/home`, odbacuju se svi paketi i promjene sustava koje ste napravili od instalacije i briše se identitet računala — mrežne veze, ključevi domaćina i sve. Ono što se ponovno pokrene čarobnjak je za postavljanje s prvog pokretanja, spreman da njegov novi vlasnik unese vlastito ime, lozinku i lozinku za šifriranje.

Djeluje tako da vraća osnovnu snimku koju instalacijski program napravi, pa je dostupno samo na računalima instaliranima s Omarchy ISO-a. A na disku bez šifriranja vraćanje je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite novu instalaciju.

## Sudo bez lozinke

Ponekad želite da `sudo` prestane pitati, najčešće kada AI agent za vas obavlja dugačak dio posla na sustavu. _Postavljanje > Sigurnost > Sudo bez lozinke_ pita koliko dugo dopustiti pristup: **15 minuta**, **1 sat**, **1 dan** ili **Trajno**. Crvena ikona upozorenja pojavljuje se pokraj ostalih pokazatelja na traci izbornika dok je pristup aktivan. Kliknite je ili ponovno pokrenite naredbu da biste isključili pristup. Možete proslijediti i vlastiti broj minuta (od 1 do 1440) s `omarchy-sudo-passwordless 30` ili upotrijebiti `omarchy-sudo-passwordless permanent`.

Vremenski ograničen pristup istječe automatski, uključujući odmah nakon nastavka iz stanja mirovanja koje je prešlo rok. Ponovno pokretanje računala završava ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje Omarchyjeva paketa postavki završava svako privremeno dopuštenje prije nego što se promijeni njegova podrška za istjecanje. Ako naredba prijavi pogrešku autorizacije ili čišćenja, riješite je prije nego što pokušate omogućiti drugo dopuštenje; pogreška ne znači da je pristup bez lozinke neaktivan.

Budite trezveni oko ovoga: dok je uključeno, sve što se izvodi kao vaš korisnik može učiniti bilo što kao root bez pitanja. To je cijela poanta, a to je i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve potpise ISO-a i pakete repozitorija Omarchyja je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za neometano uvođenje svih mogućih ažuriranja.

Potpis za svako izdanje ISO-a možete pronaći dodavanjem `.sig` njegovu URL-u, kao što je `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
