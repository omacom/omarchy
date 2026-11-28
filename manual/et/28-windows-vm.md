# Windowsi VM

Omarchy pakub lihtsat viisi Windowsi käitamiseks Docker VM-i kaudu x86_64 masinatel. Saad selle paigaldada Omarchy menüüst (`Super + Space`) valiku _Paigalda > Windows_ kaudu.

Sinu masin vajab selleks KVM virtualiseerimist, mida enamik masinaid toetab — kuid see on vahel BIOS-is välja lülitatud ja paigaldaja annab sulle teada, kui see nii on. Sul läheb vaja ka kettaruumi: nii palju, kui annad Windowsile, pluss veel umbes 10GB kujutise enda jaoks.

Paigaldaja küsib, kui palju RAM-i, mitu CPU tuuma ja kui palju kettaruumi üle anda (64GB või rohkem on mõistlik alampiir), seejärel Windowsi kasutajanime ja parooli. Jäta need tühjaks ja saad `docker` / `admin`. Allalaadimine võtab aega — 10-15 minutit on normaalne — ja saad edenemist jälgida brauseris aadressil `http://127.0.0.1:8006`. Brauser küsib enne konsooli avamist sama kasutajanime ja parooli.

 ![windows-vm](images/windows-vm.webp)

## Kasutamine

Kui see on paigaldatud, käivita rakenduste käivitajast _Windows_. See käivitab VM-i, kui see veel ei tööta, ja ühendab sind RDP kaudu täisekraanil. Külmkäivituse puhul anna sellele 15-30 sekundit.

RDP seanss kannab heli, sinu mikrofoni ja jagatud lõikelauda, nii et teksti kopeerimine Linuxi ja Windowsi vahel lihtsalt töötab. Eraldusvõime järgib sinu akent ja Omarchy annab sinu ekraani skaleerimise edasi, nii et see ei ole HiDPI ekraanil udune jama.

Kui sulged RDP akna, lülitub VM automaatselt välja. Kui eelistad selle jooksma jätta — ütleme, et sul on seal midagi tööd tegemas — käivita see hoopis käsuga `omarchy windows vm launch --keep-alive`.

Ülejäänud juhtelemendid on samal käsul:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Failide jagamine

Sinu kodukataloogis olev kataloog `~/Windows` jagatakse automaatselt VM-iga. Pane failid sinna, kui soovid, et need oleksid Windowsile ligipääsetavad. VM-il ei ole juurdepääsu ühelegi teisele sinu failisüsteemi osale, nii et oled kaitstud kõige vastiku eest Windowsi poolel. Selle enda virtuaalketas on saadaval asukohas `~/.windows`.

Need tuttavad koduteed jäävad oma failisüsteemidele. Need võivad olla ka sümbolilingid sinule kuuluvatele kataloogidele, mis on kasulik, kui virtuaalketas asub suuremal draivil. Paigaldaja mõõdab vaba ruumi failisüsteemil, mis tegelikult sisaldab kausta `~/.windows`, mitte tingimata failisüsteemil, mis sisaldab sinu kodukataloogi.

Hoia ketta- ja jagatud teed eraldi, mitte-kattuvate kataloogidena. Eemaldamine tühjendab teadlikult kettakataloogi, kuid säilitab jagatud kataloogi. Vahetult enne kustutamist teeb Omarchy piiratud sisaldumiskontrolli ja keeldub midagi eemaldamast, kui see kontroll aegub või ei suuda tõendada, et kaks puud on eraldi.

Enne VM-i käivitamist avab ja kinnistab Omarchy need kaks kataloogi, seejärel bind-monteerib täpsed kataloogi inode'id privaatsetele kasutajapõhistele ankrutele asukoha `/var/lib/omarchy/windows/mounts` all. Docker näeb ainult neid root'i poolt kaitstud ankruid. See säilitab kohandatud kettaasukohad, takistades samal ajal teisel sinuna töötaval protsessil kontrollitud tee väljavahetamist enne, kui privilegeeritud konteiner selle ära kasutab. Olemasolevad ketta- ja jagatud kataloogid karmistatakse migratsiooni ajal režiimi `0700`, et teised kohalikud kontod ei saaks nende sisu sirvida.

VM-i pordid on seotud ainult localhost'iga, nii et miski sinu võrgus ei pääse Windowsi masinale ligi. Veebikonsool nõuab ka konfigureeritud Windowsi kasutajanime ja parooli, takistades teisel kohalikul kontol VM-i pordi 8006 kaudu juhtimast.

## Piirangud ja litsentsimine

Selle seadistusega ei ole GPU läbipääsu, nii et see ei sobi mängimiseks ega videotöötluseks. See on suurepärane viis Microsoft Office'i või mille iganes muu käitamiseks, mis sul tingimata olema peab.

Paigaldatud versioon on Windows 11 Pro, aktiveerimata. Piiratud funktsioonide kasutamiseks vajad oma litsentsivõtit.

Kui see arvuti tarniti Windowsiga, on OEM võti püsivaras alles ka pärast Omarchy paigaldamist. Prindi see käsuga `omarchy windows key`. See võti on seotud selle masinaga — see aktiveerib sellele riistvarale uuesti paigaldatud Windowsi, kuid tavaliselt ei aktiveeri VM-i.

Saad ressursside jaotust hiljem muuta, käivitades terminalis käsu `omarchy windows vm install`, mis kirjutab VM-i konfiguratsiooni sinu vastuste põhjal uuesti. Compose fail ise asub nüüd asukohas `/var/lib/omarchy/windows/docker-compose.yml` ja kuulub root'ile — see on teadlik, et sinuna töötav protsess ei saaks seda ümber kirjutada ja lasta privilegeeritud käivitamisel monteerida kogu sinu ketas konteinerisse. Kui pead seda käsitsi muutma (näiteks USB seadme monteerimiseks), muuda seda `sudo` abil ja vaata kõiki valikuid [Dockuri Windowsi projektist](https://github.com/dockur/windows).

Kogu asjast vabanemiseks kasuta Omarchy menüüst valikut _Eemalda > Windows_. See kustutab VM-i ketta kaustas `~/.windows` ja kõik Windowsi sisse paigaldatu, nii et kopeeri kõik vajalik enne VM-ist välja. Sinu jagatud `~/Windows` kaust jäetakse rahule.
