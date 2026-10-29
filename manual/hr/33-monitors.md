# Monitori

Omarchy prema zadanim postavkama pretpostavlja da koristite zaslon klase retina s mogućnošću skaliranja 2x. To vam je potrebno da biste dobili one lijepe, oštre programerske fontove. Za to su optimizirana gotovo sva nova premium prijenosna računala sa zaslonima visoke razlučivosti. To biste htjeli koristiti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristite zaslon s PPI-jem od 218 ili višim, poželjet ćete promijeniti postavke monitora. Na primjer, ako imate 27" ili 32" 4K, možete koristiti frakcijsko skaliranje tako da otvorite `~/.config/hypr/monitors.lua` (putem _Postavke > Monitori_ u izborniku Omarchy) i prebacite se na preporuku za tu kombinaciju:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ako koristite zaslon od 1080p ili 1440p, vjerojatno ćete samo htjeti koristiti skaliranje 1x, pa možete upotrijebiti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Promjene vrijednosti `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa je zadržite na najbližem cijelom broju vašeg skaliranja monitora). Zato obavezno zatvorite prozore koje imate, a koji su preveliki nakon promjene (ili zatvorite sve prozore pomoću `Ctrl + Alt + Del`!).

Također možete brzo prolaziti kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) pomoću `Super + /` za povećavanje i `Super + Alt + /` za smanjivanje, ili odabrati jedan s ploče monitora na gornjoj traci. Time se mijenja samo monitor na koji ste fokusirani, pa zaslon prijenosnog računala i vanjski zaslon mogu svaki imati vlastito skaliranje. Odabir se sprema u `~/.config/hypr/monitors.lua` kao pravilo `hl.monitor` za taj monitor, pa ostaje sačuvan nakon ponovnog pokretanja i ima prednost pred `omarchy_monitor_scale`, koji ostaje skaliranje za svaki monitor koji nema vlastito pravilo. Budući da je `GDK_SCALE` jedna vrijednost za sve zaslone, ove promjene postavljaju je prema monitoru s najmanjim skaliranjem, pa X11 aplikacije ispadnu malo premale na gušćem zaslonu, a ne prevelike na drugom.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želite samo veći ili manji _tekst_, za to postoji jedna jedina postavka:

```
omarchy display text size 14
```

Time se unosi veličina u pikselima između 9 i 20 i zajedno se pomiče ljuska Omarchy, GTK aplikacije i vaš terminal, pa cijela radna površina ostaje u proporciji. Pokrenite je bez argumenta da biste vidjeli gdje ste trenutačno, a `omarchy display text size reset` da biste se vratili na zadanu vrijednost. Foot je jedini koji zaostaje: nema načina za ponovno učitavanje svoje konfiguracije, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvorite novi.

### Proširivanje i zrcaljenje zaslona prijenosnih računala

Kada na prijenosno računalo povežete vanjski zaslon, prikaz se automatski proširuje. Ali to možete promijeniti u zrcaljenje pomoću _Okidač > Hardver_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. To je posebno korisno ako je taj vanjski zaslon projektor, a želite nešto pokazati dok radite.

Kada proširujete, zatvaranje poklopca prijenosnog računala automatski će isključiti interni zaslon. Otvaranje poklopca ponovno će ga uključiti. To možete i ručno kontrolirati pomoću _Okidač > Hardver_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

### Raspoređivanje više zaslona

Hyprland odlično radi s više zaslona. Više o tome kako ih rasporediti pročitajte u [dokumentaciji Hyprlanda o monitorima](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju oni idu u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka se isporučuje s komentiranim primjerima za fiksiranje određenog monitora na razlučivost, položaj i rotaciju.

Svaki monitor ima vlastite radne prostore od 1 do 10, pa `Super + 1` uvijek znači prvi radni prostor monitora na kojem se nalazite. Iza kulisa Hyprland i dalje numerira radne prostore preko svih monitora: zaslon vašeg prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kada ga priključite. Koristite te brojeve ako pišete [pravila za radne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila za prozore za određeni monitor, pa je radni prostor 12 drugi radni prostor vašeg drugog monitora. `~/.local/state/omarchy/monitor-workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji dijele rub u vašem rasporedu. Zasloni koji se dodiruju samo u kutu, ili između kojih postoji razmak, nisu susjedi, pa za prelazak između njih koristite `Ctrl + Alt + Tab`.

| Prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Premješta fokus na monitor s te strane nakon što u tom smjeru više nema prozora |
| `Super + Shift + Arrow` | Zamjenjuje s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Premješta prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Premješta prozor na monitor s te strane, na radni prostor koji prikazuje |
| `Super + Shift + Alt + Arrow` | Premješta radni prostor na monitor s te strane, zadržavajući njegov broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premješta fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem se nalazite |

Možete pogledati i [Hyprmon](https://github.com/erans/hyprmon/), ako želite TUI koji će vam pomoći pri pozicioniranju više zaslona.

### Kontroliranje svjetline

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako držite Shift dok pritiskate te tipke, otići ćete na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom na koji ste fokusirani, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao zaslon prijenosnog računala.

### Apple zasloni

Ako koristite Apple zaslon, uobičajene tipke za svjetlinu na tipkovnici također će automatski raditi ako ste fokusirani na Apple zaslon. To se radi putem naredbe `asdcontrol`.

Imajte na umu da, ako koristite Apple 6K XDR zaslon, možda ćete vidjeti fantomski zaslon u popisu `hyprctl monitors`. Možete ga isključiti nečim poput `hl.monitor({ output = "DP-2", disabled = true })` putem _Postavke > Monitori_.

Na Intel računalima Apple zaslone trebali biste povezivati običnim Thunderbolt kabelom. Na drugim računalima bez Thunderbolta obično ćete morati koristiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) da bi to radilo.
