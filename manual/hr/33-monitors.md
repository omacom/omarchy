# Monitori

Omarchy prema zadanim postavkama pretpostavlja da koristite zaslon klase retina s mogućnošću skaliranja 2x. To vam je potrebno za one lijepe, oštre programerske fontove. Za to su optimizirani gotovo svi novi premium prijenosnici s zaslonima visoke razlučivosti. To biste htjeli koristiti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristite zaslon s PPI-jem od 218 ili više, htjet ćete promijeniti postavke monitora. Na primjer, ako imate 27" ili 32" 4K, možete odabrati frakcijsko skaliranje za njega na ploči za monitore u gornjoj traci ili postaviti zadanu vrijednost za svaki monitor otvaranjem `~/.config/hypr/monitors.lua` i prebacivanjem na preporuku za tu kombinaciju:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ako koristite zaslon od 1080p ili 1440p, vjerojatno ćete htjeti koristiti skaliranje 1x, a isto vrijedi i za GTK i X11 aplikacije, pa možete upotrijebiti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Promjene za `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa ga držite na najbližem cijelom broju skaliranja vašeg monitora). Stoga svakako zatvorite prozore koji su vam nakon promjene preveliki (ili zatvorite sve prozore s `Ctrl + Alt + Del`!).

Također možete brzo proći kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) koristeći `Super + /` za veće i `Super + Alt + /` za manje ili odabrati jedan na ploči za monitore u gornjoj traci. Time se mijenja samo monitor na koji ste fokusirani, pa zaslon prijenosnog računala i vanjski zaslon mogu svaki imati svoje skaliranje. Ploča također postavlja razlučivost, brzinu osvježavanja i rotaciju svakog monitora. Vaši izbori spremaju se za taj fizički monitor u `~/.local/state/omarchy/monitors/settings`, pa ostaju i nakon ponovnog pokretanja i prate monitor do bilo kojeg priključka ili priključne stanice na koju ga sljedeći put priključite. Imaju prednost nad bilo kojim pravilom za isti monitor u `~/.config/hypr/monitors.lua`, koji Omarchy nikada ne uređuje. Ako radije postavite svoje monitore u potpunosti u toj datoteci, dodajte joj `omarchy_monitor_panel_settings = false`, a promjene s ploče trajat će samo dok se Hyprland ponovno ne učita. Budući da je `GDK_SCALE` jedna vrijednost za sve zaslone, odabrano skaliranje postavlja ga prema monitoru s najmanjim skaliranjem, pa X11 aplikacije ispadnu malo premale na gušćem zaslonu, a ne prevelike na drugom.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želite samo veći ili manji _tekst_, za to postoji jedan jedini gumb:

```
omarchy display text size 14
```

To uzima veličinu u pikselima između 9 i 20 i pomiče Omarchy ljusku, GTK aplikacije i vaš terminal zajedno, pa cijela radna površina ostaje u proporciji. Pokrenite to bez argumenta da vidite gdje ste, a `omarchy display text size reset` da se vratite na zadanu vrijednost. Foot je jedini zaostali: nema načina za ponovno učitavanje svoje konfiguracije, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvorite novi.

### Proširivanje i zrcaljenje zaslona prijenosnih računala

Kada na prijenosno računalo priključite vanjski zaslon, prikaz se automatski proširuje. Ali to možete promijeniti u zrcaljenje pomoću _Extend_ | _Mirror_ na ploči za monitore u gornjoj traci, _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. To je posebno korisno ako je taj vanjski zaslon projektor, a želite nešto pokazati dok radite.

Kad proširujete, zatvaranje poklopca prijenosnog računala automatski će isključiti unutarnji zaslon. Otvaranje poklopca ponovno će ga uključiti. To također možete ručno kontrolirati pomoću _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

Dok je prijenosno računalo priključeno na napajanje, zatvaranje poklopca nikada ga ne uspavljuje, pa prijenosno računalo na priključnoj stanici ostaje budno čak i ako se vanjski zaslon nakratko odspoji. Kad nije priključen nijedan vanjski zaslon, zatvaranje poklopca dok je na napajanju samo ga zaključava. Na bateriji zatvaranje poklopca uspavljuje ga kao i obično.

### Raspoređivanje više zaslona

Hyprland odlično radi s više zaslona. Ploča za monitore u gornjoj traci crta ih ondje gdje se nalaze: povucite jedan uz bok drugoga da ga premjestite onamo, a raspored se sprema s ostalim postavkama svakog monitora. Za sve što ploča ne pokriva, pročitajte više o tome kako ih rasporediti u [dokumentaciji o monitorima za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju to ide u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za držanje monitora isključenim, načine koje ploča ne nudi, 10-bitnu boju i promjenjivu brzinu osvježavanja.

Svaki monitor ima svoje radne prostore od 1 do 10, pa `Super + 1` uvijek znači prvi radni prostor monitora na kojem ste. Iza kulisa Hyprland i dalje numerira radne prostore preko svih monitora: zaslon vašeg prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kad ga priključite. Koristite te brojeve ako pišete [pravila za radne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila za prozore za određeni monitor, pa je radni prostor 12 drugi radni prostor vašeg drugog monitora. `~/.local/state/omarchy/monitors/workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji dijele rub u vašem rasporedu. Zasloni koji se dodiruju samo u kutu ili između kojih postoji razmak nisu susjedi, pa koristite `Ctrl + Alt + Tab` da prijeđete između njih.

| Tipkovni prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Pomiče fokus na monitor s te strane kad u tom smjeru više nema prozora |
| `Super + Shift + Arrow` | Zamjenjuje s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Pomiče prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Pomiče prozor na monitor s te strane, na radni prostor koji prikazuje |
| `Super + Shift + Alt + Arrow` | Pomiče radni prostor na monitor s te strane, zadržavajući njegov broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pomiče fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem ste |

Možete pogledati i [Hyprmon](https://github.com/erans/hyprmon/), ako želite TUI koji će vam pomoći pri pozicioniranju više zaslona.

### Upravljanje svjetlinom

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako držite Shift dok ih pritišćete, otići ćete na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom na koji ste fokusirani, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao zaslon prijenosnog računala.

### Apple zasloni

Ako koristite Apple zaslon, uobičajene tipke za svjetlinu na tipkovnici također će automatski raditi ako ste fokusirani na Apple zaslon. To se radi putem naredbe `asdcontrol`.

Imajte na umu da, ako koristite Apple 6K XDR zaslon, možete vidjeti fantomski zaslon na svom popisu `hyprctl monitors`. To možete isključiti nečim poput `hl.monitor({ output = "DP-2", disabled = true })` u `~/.config/hypr/monitors.lua`.

Na Intel računalima trebali biste se na Apple zaslone povezivati običnim Thunderbolt kabelom. Na drugim računalima bez Thunderbolta obično ćete morati koristiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) da to proradi.
