# Monitori

Omarchy prema zadanim postavkama pretpostavlja da koristite zaslon klase retina s podrškom za 2x. To vam je potrebno za one lijepe, oštre programerske fontove. Za to su optimizirani gotovo svi novi premium prijenosnici s ekranima visoke razlučivosti. To biste htjeli koristiti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristite zaslon s PPI-jem od 218 ili višim, htjet ćete promijeniti postavke monitora. Na primjer, ako imate 27" ili 32" 4K, možete odabrati djelomično skaliranje za njega na ploči monitora u gornjoj traci ili postaviti zadanu vrijednost za svaki monitor otvaranjem `~/.config/hypr/monitors.lua` i prebacivanjem na preporuku za tu kombinaciju:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ako koristite zaslon od 1080p ili 1440p, vjerojatno ćete jednostavno htjeti koristiti skaliranje 1x, a isto i za GTK i X11 aplikacije, pa možete upotrijebiti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Promjene `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa ga držite na najbližem cijelom broju skaliranja vašeg monitora). Zato obavezno zatvorite prozore koje imate, a koji su nakon promjene preveliki (ili zatvorite sve prozore pomoću `Ctrl + Alt + Del`!).

Također možete brzo prolaziti kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) koristeći `Super + /` za veće i `Super + Alt + /` za manje, ili odabrati jedan na ploči monitora u gornjoj traci. Time se mijenja samo monitor na koji ste fokusirani, pa ekran prijenosnog računala i vanjski zaslon mogu svaki imati vlastito skaliranje. Ploča također postavlja razlučivost svakog monitora. Vaši se odabiri spremaju za taj fizički monitor u `~/.local/state/omarchy/monitors/settings`, pa ostaju i nakon ponovnog pokretanja i prate monitor na koji god priključak ili dock ga sljedeći put priključite. Imaju prednost pred bilo kojim pravilom za isti monitor u `~/.config/hypr/monitors.lua`, koji Omarchy nikada ne uređuje. Ako radije monitore u potpunosti postavljate u toj datoteci, dodajte joj `omarchy_monitor_panel_settings = false` i promjene s ploče trajat će samo dok se Hyprland ponovno ne učita. Budući da je `GDK_SCALE` jedna vrijednost za sve ekrane, odabrano skaliranje postavlja ga prema monitoru s najmanjim skaliranjem, pa X11 aplikacije ispadnu malo premale na gušćem ekranu umjesto prevelike na drugom.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želite samo veći ili manji _tekst_, za to postoji jedna jedina postavka:

```
omarchy display text size 14
```

Prihvaća veličinu u pikselima između 9 i 20 i zajedno pomiče Omarchy ljusku, GTK aplikacije i vaš terminal, pa cijela radna površina ostaje u proporciji. Pokrenite je bez argumenta da vidite gdje ste, a `omarchy display text size reset` za povratak na zadanu vrijednost. Foot je jedini zaostali: nema načina za ponovno učitavanje svoje konfiguracije, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvorite novi.

### Proširivanje i zrcaljenje zaslona prijenosnog računala

Kad na prijenosno računalo priključite vanjski ekran, zaslon se automatski proširuje. Ali to možete promijeniti u zrcaljenje pomoću _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. To je posebno korisno ako je taj vanjski ekran projektor, a želite nešto prikazati dok radite.

Kad proširujete, zatvaranje poklopca prijenosnog računala automatski će isključiti interni ekran. Otvaranje poklopca ponovno će ga uključiti. Time možete upravljati i ručno pomoću _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

### Raspored više ekrana

Hyprland odlično radi s više ekrana. Ploča monitora u gornjoj traci crta ih ondje gdje se nalaze: povucite jedan uz bok drugoga da ga tamo premjestite, a raspored se sprema s ostalim postavkama svakog monitora. Za sve što ploča ne pokriva, pročitajte više o tome kako ih rasporediti u [dokumentaciji Hyprlanda o monitorima](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju one idu u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za fiksiranje određenog monitora na razlučivost, položaj i rotaciju.

Svaki monitor ima vlastite radne prostore od 1 do 10, pa `Super + 1` uvijek znači prvi radni prostor monitora na kojem se nalazite. U pozadini Hyprland i dalje numerira radne prostore preko svih monitora: ekran vašeg prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kad ga priključite. Koristite te brojeve ako pišete [pravila radnih prostora](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila prozora za određeni monitor, pa je radni prostor 12 drugi radni prostor vašeg drugog monitora. `~/.local/state/omarchy/monitors/workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji u vašem rasporedu dijele brid. Ekrani koji se dodiruju samo u kutu ili između kojih postoji razmak nisu susjedi, pa za prelazak među njima koristite `Ctrl + Alt + Tab`.

| Prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Premješta fokus na monitor s te strane kad u tom smjeru više nema prozora |
| `Super + Shift + Arrow` | Zamjenjuje se s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Premješta prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Premješta prozor na monitor s te strane, na radni prostor koji prikazuje |
| `Super + Shift + Alt + Arrow` | Premješta radni prostor na monitor s te strane, zadržavajući njegov broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premješta fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem se nalazite |

Pogledajte i [Hyprmon](https://github.com/erans/hyprmon/), ako želite TUI koji će vam pomoći pri postavljanju više ekrana.

### Upravljanje svjetlinom

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako pri pritiskanju ovih tipki držite shift, prijeći ćete na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom na koji ste fokusirani, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao i ekran prijenosnog računala.

### Apple zasloni

Ako koristite Apple zaslon, redovne tipke za svjetlinu na tipkovnici također će automatski raditi, ako ste fokusirani na Apple zaslon. To se radi putem naredbe `asdcontrol`.

Imajte na umu da, ako koristite Apple 6K XDR zaslon, u svom ispisu `hyprctl monitors` možete vidjeti fantomski ekran. To možete isključiti nečim poput `hl.monitor({ output = "DP-2", disabled = true })` u `~/.config/hypr/monitors.lua`.

Na Intel strojevima na Apple zaslone trebali biste se povezivati običnim Thunderbolt kabelom. Na drugim strojevima bez Thunderbolta obično ćete morati upotrijebiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) da bi to radilo.
