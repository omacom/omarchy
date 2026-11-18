# Monitori

Omarchy prema zadanim postavkama pretpostavlja da koristite zaslon klase retina s mogućnošću skaliranja 2x. To vam je potrebno da dobijete one lijepe, oštre programerske fontove. Za to su optimizirana gotovo sva nova premium prijenosna računala sa zaslonima visoke razlučivosti. Takav biste zaslon htjeli koristiti uz 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristite zaslon s PPI-jem od 218 ili većim, poželjet ćete promijeniti postavke monitora. Na primjer, ako imate 27" ili 32" 4K, možete mu odabrati frakcijsku skalu na ploči za monitore u gornjoj traci ili postaviti zadanu vrijednost za svaki monitor tako da otvorite `~/.config/hypr/monitors.lua` i prebacite se na preporuku za tu kombinaciju:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ako koristite zaslon od 1080p ili 1440p, vjerojatno ćete jednostavno htjeti koristiti skaliranje 1x, a isto tako i za GTK i X11 aplikacije, pa možete koristiti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Promjene vrijednosti `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa je držite na najbližem cijelom broju skale vašeg monitora). Dakle, obavezno zatvorite prozore koje imate, a koji su nakon promjene preveliki (ili zatvorite sve prozore kombinacijom `Ctrl + Alt + Del`!).

Glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) možete brzo proći i tipkama `Super + /` za veću vrijednost i `Super + Alt + /` za manju vrijednost ili odabrati jedan na ploči za monitore u gornjoj traci. Time se mijenja samo monitor koji je u fokusu, pa zaslon prijenosnog računala i vanjski zaslon mogu svaki imati svoju skalu. Ploča postavlja i razlučivost, brzinu osvježavanja i rotaciju svakog monitora. Vaši se odabiri za taj fizički monitor spremaju u `~/.local/state/omarchy/monitors/settings`, pa opstaju nakon ponovnog pokretanja i prate monitor na koji god priključak ili dock da ga sljedeći put priključite. Imaju prednost pred bilo kojim pravilom za isti monitor u `~/.config/hypr/monitors.lua`, koju Omarchy nikad ne uređuje. Ako radije monitore u cijelosti postavljate u toj datoteci, dodajte joj `omarchy_monitor_panel_settings = false` i promjene s ploče trajat će samo dok Hyprland ponovno ne učita konfiguraciju. Budući da je `GDK_SCALE` jedna vrijednost za sve zaslone, odabrana skala postavlja je prema monitoru s najnižom skalom, pa X11 aplikacije ispadnu malo premale na gušćem zaslonu, umjesto prevelike na onom drugom.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želite samo veći ili manji _tekst_, za to postoji samo jedan gumb:

```
omarchy display text size 14
```

Prima veličinu u pikselima između 9 i 20 i zajedno pomiče Omarchy shell, GTK aplikacije i vaš terminal, pa cijela radna površina ostaje u proporciji. Pokrenite je bez argumenta da vidite gdje ste trenutačno, a `omarchy display text size reset` da se vratite na zadanu vrijednost. Foot je jedini koji zaostaje: nema načina za ponovno učitavanje svoje konfiguracije, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvorite novi.

### Proširivanje i zrcaljenje zaslona prijenosnog računala

Kad na prijenosno računalo povežete vanjski zaslon, zaslon se automatski proširuje. Ali to umjesto toga možete promijeniti u zrcaljenje pomoću _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. To je osobito korisno ako je taj vanjski zaslon projektor, a želite nešto pokazati dok radite.

Kad koristite proširivanje, zatvaranjem poklopca prijenosnog računala automatski će se isključiti unutarnji zaslon. Otvaranjem poklopca ponovno će se uključiti. Time možete upravljati i ručno pomoću _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

### Raspored više zaslona

Hyprland odlično radi s više zaslona. Ploča za monitore u gornjoj traci crta ih ondje gdje se nalaze: povucite jedan uz bok drugoga da ga pomaknete onamo i raspored se sprema zajedno s ostalim postavkama svakog monitora. Za sve što ploča ne pokriva pročitajte više o tome kako ih rasporediti u [dokumentaciji za monitore Hyprlanda](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju te postavke idu u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za držanje monitora isključenim, načine rada koje ploča ne nudi, 10-bitnu boju i promjenjivu brzinu osvježavanja.

Svaki monitor ima vlastitih radnih površina od 1 do 10, pa `Super + 1` uvijek znači prvu radnu površinu monitora na kojem se nalazite. Iza kulisa Hyprland i dalje numerira radne površine preko svih monitora: zaslon vašeg prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kad ga priključite. Te brojeve upotrijebite ako pišete [pravila za radne površine](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila za prozore za određeni monitor, pa je radna površina 12 druga radna površina vašeg drugog monitora. `~/.local/state/omarchy/monitors/workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji u vašem rasporedu dijele rub. Zasloni koji se dodiruju samo u kutu ili među kojima postoji razmak nisu susjedi, pa za prelazak među njima upotrijebite `Ctrl + Alt + Tab`.

| Tipkovni prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Pomakne fokus na monitor s te strane kad u tom smjeru više nema prozora |
| `Super + Shift + Arrow` | Zamijeni se s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Pomakne prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Pomakne prozor na monitor s te strane, na radnu površinu koju prikazuje |
| `Super + Shift + Alt + Arrow` | Pomakne radnu površinu na monitor s te strane, zadržavajući njezin broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pomakne fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem se nalazite |

Možete pogledati i [Hyprmon](https://github.com/erans/hyprmon/), ako želite TUI koji će vam pomoći pri pozicioniranju više zaslona.

### Upravljanje svjetlinom

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako pri pritiskanju tih tipki držite Shift, prijeći ćete na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom koji je u fokusu, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao i zaslon prijenosnog računala.

### Appleovi zasloni

Ako koristite Appleov zaslon, uobičajene tipke za svjetlinu na tipkovnici također će automatski raditi, ako je Appleov zaslon u fokusu. To se radi putem naredbe `asdcontrol`.

Imajte na umu da, ako koristite Appleov zaslon 6K XDR, možda ćete u ispisu `hyprctl monitors` vidjeti fantomski zaslon. To možete isključiti nečim kao što je `hl.monitor({ output = "DP-2", disabled = true })` u `~/.config/hypr/monitors.lua`.

Na Intelovim računalima Appleove zaslone trebali biste povezivati običnim Thunderbolt kabelom. Na drugim računalima bez Thunderbolta obično ćete morati upotrijebiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) da bi to radilo.
