# Monitori

Omarchy prema zadanim postavkama pretpostavlja da radiš na zaslonu retina klase koji podržava 2x skaliranje. To ti treba da dobiješ one lijepe, oštre programerske fontove. Za to su optimizirana gotovo sva nova premium prijenosna računala sa zaslonima visoke razlučivosti. To bi htio koristiti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristiš zaslon s PPI-jem od 218 ili više, htjet ćeš promijeniti postavke monitora. Na primjer, ako imaš 27" ili 32" 4K, za njega možeš odabrati djelomično skaliranje s ploče monitora u gornjoj traci ili postaviti zadanu vrijednost za svaki monitor tako da otvoriš `~/.config/hypr/monitors.lua` i prijeđeš na preporuku za tu kombinaciju:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ako koristiš zaslon od 1080p ili 1440p, vjerojatno ćeš jednostavno htjeti koristiti 1x skaliranje, a isto i za GTK i X11 aplikacije, pa možeš koristiti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Promjene postavke `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa je drži na najbližem cijelom broju skaliranja tvog monitora). Zato obavezno zatvori prozore koje imaš, a koji su nakon promjene preveliki (ili zatvori sve prozore pomoću `Ctrl + Alt + Del`!).

Također možeš brzo prolaziti kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) pomoću `Super + /` za veće i `Super + Alt + /` za manje, ili odabrati jedan s ploče monitora u gornjoj traci. Time se mijenja samo monitor na koji si fokusiran, pa zaslon prijenosnog računala i vanjski zaslon mogu svaki imati svoje skaliranje. Ploča također postavlja razlučivost, brzinu osvježavanja i rotaciju svakog monitora. Tvoji se odabiri spremaju za taj fizički monitor u `~/.local/state/omarchy/monitors/settings`, pa ostaju i nakon ponovnog pokretanja i prate monitor na koji god priključak ili dock da ga sljedeći put uključiš. Imaju prednost pred bilo kojim pravilom za isti monitor u `~/.config/hypr/monitors.lua`, koji Omarchy nikada ne uređuje. Ako radije monitore u potpunosti postavljaš u toj datoteci, dodaj joj `omarchy_monitor_panel_settings = false` i promjene s ploče trajat će samo dok se Hyprland ponovno ne učita. Budući da je `GDK_SCALE` jedna vrijednost za sve zaslone, odabrano skaliranje postavlja je prema monitoru s najmanjim skaliranjem, pa X11 aplikacije ispadnu malo male na gušćem zaslonu, a ne prevelike na drugom.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želiš samo veći ili manji _tekst_, za to postoji samo jedna postavka:

```
omarchy display text size 14
```

Prima veličinu u pikselima između 9 i 20 i zajedno pomiče Omarchy ljusku, GTK aplikacije i tvoj terminal, pa cijela radna površina ostaje u proporciji. Pokreni je bez argumenta da vidiš gdje si sada, a `omarchy display text size reset` da se vratiš na zadanu vrijednost. Foot je jedini koji zaostaje: nema načina da ponovno učita svoju konfiguraciju, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvoriš novi.

### Proširivanje i zrcaljenje zaslona prijenosnog računala

Kada na prijenosno računalo spojiš vanjski zaslon, prikaz se automatski proširuje. Ali to možeš promijeniti u zrcaljenje pomoću _Proširi_ | _Zrcali_ na ploči monitora u gornjoj traci, _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. Ovo je posebno korisno ako je taj vanjski zaslon projektor, a želiš nešto pokazati dok radiš.

Kada proširuješ, zatvaranje poklopca prijenosnog računala automatski će isključiti unutarnji zaslon. Otvaranje poklopca ponovno će ga uključiti. Time možeš upravljati i ručno pomoću _Trigger > Hardware_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

### Raspored više zaslona

Hyprland odlično radi s više zaslona. Ploča monitora u gornjoj traci crta ih ondje gdje se nalaze: povuci jedan uz rub drugog da ga premjestiš onamo i raspored se sprema zajedno s ostalim postavkama svakog monitora. Za sve što ploča ne pokriva, više o tome kako ih rasporediti pročitaj u [dokumentaciji o monitorima za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju one idu u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za isključivanje monitora, načine koje ploča ne nudi, 10-bitnu boju i promjenjivu brzinu osvježavanja.

Svaki monitor ima vlastitih radnih prostora od 1 do 10, pa `Super + 1` uvijek znači prvi radni prostor monitora na kojem se nalaziš. Iza kulisa Hyprland i dalje numerira radne prostore preko svih monitora: zaslon tvog prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kada ga uključiš. Koristi te brojeve ako pišeš [pravila radnih prostora](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila prozora za određeni monitor, pa je radni prostor 12 drugi radni prostor tvog drugog monitora. `~/.local/state/omarchy/monitors/workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji u tvom rasporedu dijele rub. Zasloni koji se dodiruju samo u kutu ili između kojih postoji razmak nisu susjedi, pa za prelazak među njima koristi `Ctrl + Alt + Tab`.

| Prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Pomiče fokus na monitor s te strane kada u tom smjeru više nema prozora |
| `Super + Shift + Arrow` | Zamjenjuje se s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Pomiče prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Pomiče prozor na monitor s te strane, na radni prostor koji prikazuje |
| `Super + Shift + Alt + Arrow` | Pomiče radni prostor na monitor s te strane, zadržavajući njegov broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pomiče fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem se nalaziš |

Pogledaj i [Hyprmon](https://github.com/erans/hyprmon/) ako želiš TUI koji će ti pomoći pri pozicioniranju više zaslona.

### Upravljanje svjetlinom

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako držiš Shift dok ih pritišćeš, otići ćeš na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom na koji si fokusiran, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao i zaslon prijenosnog računala.

### Apple zasloni

Ako koristiš Apple zaslon, uobičajene tipke za svjetlinu na tipkovnici također će automatski raditi ako si fokusiran na Apple zaslon. To se radi putem naredbe `asdcontrol`.

Imaj na umu da, ako koristiš Apple 6K XDR zaslon, možda ćeš u ispisu `hyprctl monitors` vidjeti fantomski zaslon. To možeš isključiti nečim poput `hl.monitor({ output = "DP-2", disabled = true })` u `~/.config/hypr/monitors.lua`.

Na Intel računalima Apple zaslone trebaš spajati običnim Thunderbolt kabelom. Na drugim računalima bez Thunderbolta obično ćeš morati koristiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) da bi to radilo.
