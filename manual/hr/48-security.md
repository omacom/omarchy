# Sigurnost

Omarchy sigurnost shvaća iznimno ozbiljno. Ovo je zamišljeno kao operativni sustav koji možete koristiti za _Pravi Posao_ u _Stvarnom Svijetu_. Gdje gubitak prijenosnog računala ne može dovesti do sigurnosne krize. Evo što radimo:

1. *Šifriranje cijelog diska je obavezno*: Ovo je najvažniji korak za fizičku zaštitu vaših podataka. Ako se vaše računalo izgubi ili ga ukradu, podaci su u potpunosti šifrirani standardnim LUKS-om (Linux Unified Key Setup).
2. *Vatrozid je omogućen prema zadanim postavkama*: Sav dolazni promet prema zadanim je postavkama blokiran, osim porta 53317 za [LocalSend](https://localsend.org/). Čak je i ssh isključen dok ga ne uključite putem _Setup > Security > SSHD_, što u sklopu postavljanja otvara port 22 (s ograničenjem brzine protiv napada grubom silom). Čak i pristup Dockeru zaključavamo postavkama [ufw-docker](https://github.com/chaifeng/ufw-docker) kako bismo spriječili da vaši kontejneri slučajno budu izloženi svijetu.
3. *Arch uvijek ima najnovija ažuriranja*: Arch, temeljna distribucija na kojoj je Omarchy izgrađen, distribucija je s neprekidnim ažuriranjima. To znači da je svaka otkrivena i zakrpana sigurnosna ranjivost u bilo kojem paketu brzo dostupna za instalaciju pomoću `omarchy-update`. Na taj način uvijek koristite najnovije, najsigurnije inačice svega.
4. *Omarchy održava vlastite pakete i zrcalo*: Omarchy se prema zadanim postavkama oslanja samo na pakete iz Archovih vlastitih repozitorija core/extra/multilib i vlastitog Omarchy Package Repository. Softver možete instalirati izravno iz AUR-a, ali osnovna instalacija to ne čini — samo nekoliko neobaveznih instalacija, poput preglednika trećih strana, povlači pakete iz AUR-a.
5. *Cloudflare nas štiti od DDoS-a*: Omarchyjeva distribucijska infrastruktura — ISO-i, Omarchyjevi paketi, Archovo zrcalo — zaštićena je Cloudflareovim snažnim štitom od DDoS-a i smještena na njihovom CDN-u. To pruža izvrsnu dostupnost.

## Promjena vaših lozinki

Na šifriranoj instalaciji imate dvije lozinke: onu koja otključava disk pri pokretanju i onu kojom se prijavljujete i koristite `sudo`. Postavljanje ih čini istima. Obje se mogu promijeniti pod _Update > Password_ u Omarchyjevom izborniku — _Drive Encryption_ za prvu, _User_ za drugu. Za promjenu lozinke diska najprije se traži trenutačna lozinka, pa je imajte pri ruci. Ako se promjena prekine, ponovno pokrenite _Drive Encryption_: tražit će lozinku koja trenutačno otključava disk i dovršiti promjenu.

## Predaja računala koje ste već koristili

Ako svoje računalo predajete nekom drugom, ne morate ga ponovno instalirati. Pokrenite _Setup > Reset Computer_ u Omarchyjevom izborniku, upišite `reset` za potvrdu i ponovno pokrenite računalo. Time se brišu svi korisnički računi i sve u `/home`, uklanjaju svi paketi i promjene sustava koje ste napravili od instalacije te se briše identitet računala — mrežne veze, ključevi domaćina i sve ostalo. Nakon ponovnog pokretanja dočekat će vas čarobnjak za postavljanje s prvog pokretanja, spreman da novi vlasnik unese svoje ime, lozinku i lozinku za šifriranje.

Radi tako da vraća osnovnu snimku koju napravi instalacijski program, pa je dostupno samo na računalima instaliranim s Omarchy ISO-a. A na disku bez šifriranja resetiranje je brisanje, a ne sigurno brisanje, pa ako su podaci bili osjetljivi, umjesto toga napravite svježu instalaciju.

## sudo bez lozinke

Ponekad želite da `sudo` prestane tražiti lozinku, najčešće kada AI agent za vas obavlja dugačak niz poslova na sustavu. _Setup > Security > Passwordless Sudo_ pita koliko dugo želite dopustiti pristup: **15 minuta**, **1 sat**, **1 dan** ili **Trajno**. Dok je pristup aktivan, pokraj ostalih pokazatelja na traci izbornika pojavljuje se crvena ikona upozorenja. Kliknite je ili ponovno pokrenite naredbu da biste isključili pristup. Možete i proslijediti vlastiti broj minuta (od 1 do 1440) pomoću `omarchy-sudo-passwordless 30` ili upotrijebiti `omarchy-sudo-passwordless permanent`.

Vremenski ograničen pristup automatski istječe, uključujući odmah nakon buđenja iz mirovanja koje je prešlo rok. Ponovno pokretanje računala završava ga ranije. Trajni pristup preživljava ponovna pokretanja i ostaje omogućen dok ga ne onemogućite.

Ažuriranje ili uklanjanje Omarchyjeva paketa s postavkama završava svako privremeno odobrenje prije nego što se promijeni njegova podrška za istek. Ako naredba prijavi pogrešku autorizacije ili čišćenja, riješite je prije nego što pokušate omogućiti drugo odobrenje; pogreška ne znači da pristup bez lozinke nije aktivan.

Budite potpuno svjesni ovoga: dok je uključen, sve što se izvodi kao vaš korisnik može kao root činiti bilo što, a da ga se ne pita. U tome je cijela poanta, ali i cijeli rizik.

## Ključevi za potpisivanje

Javni ključ za sve potpise ISO-a i pakete Omarchy repozitorija je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([provjerite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` također ga sadrži i koristit će se za besprijekorno uvođenje svih mogućih ažuriranja.

Potpis za bilo koje izdanje ISO-a možete pronaći dodavanjem `.sig` njegovu URL-u, poput `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
