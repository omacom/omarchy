# Monitori

Omarchy prema zadanim postavkama pretpostavlja da koristite zaslon klase retina koji podržava 2x skaliranje. To vam je potrebno za one lijepe, oštre programerske fontove. To je ono za što su optimizirani gotovo svi novi premium prijenosni računali s zaslonima visoke razlučivosti. To je ono što biste htjeli koristiti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

No ako ne koristite zaslon s PPI-jem od 218 ili višim, htjet ćete promijeniti postavke monitora. Primjerice, ako imate 27" ili 32" 4K, možete koristiti frakcijsko skaliranje tako da otvorite `~/.config/hypr/monitors.lua` (putem _Postavke > Monitori_ u izborniku Omarchy) i prebacite se na preporuku za tu kombinaciju:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ako koristite zaslon od 1080p ili 1440p, vjerojatno ćete jednostavno htjeti koristiti 1x skaliranje, pa možete koristiti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Promjene za `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa ga držite na najbližem cijelom broju vašeg skaliranja monitora). Zato svakako zatvorite prozore koje imate, a koji su nakon promjene preveliki (ili zatvorite sve prozore pomoću `Ctrl + Alt + Del`!).

Također možete brzo prolaziti kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) koristeći `Super + /` za više i `Super + Alt + /` za niže. Ako imate zadanu konfiguraciju, te će promjene opstati i nakon ponovnog pokretanja.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želite samo veći ili manji _tekst_, za to postoji jedna jedina postavka:

```
omarchy display text size 14
```

Ona prima veličinu u pikselima između 9 i 20 i zajedno pomiče Omarchy ljusku, GTK aplikacije i vaš terminal, tako da cijela radna površina ostaje u proporciji. Pokrenite je bez argumenta da vidite na čemu ste, a `omarchy display text size reset` za povratak na zadanu vrijednost. Foot je jedini koji zaostaje: nema načina za ponovno učitavanje svoje konfiguracije, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvorite novi.

### Proširivanje i zrcaljenje zaslona prijenosnog računala

Kada na prijenosno računalo spojite vanjski zaslon, prikaz se automatski proširuje. No to umjesto toga možete promijeniti u zrcaljenje koristeći _Okidač > Hardver_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. To je osobito korisno ako je taj vanjski zaslon projektor, a želite nešto prikazati dok radite.

Kada proširujete, zatvaranje poklopca prijenosnog računala automatski će isključiti unutarnji zaslon. Otvaranje poklopca ponovno će ga uključiti. Time možete upravljati i ručno koristeći _Okidač > Hardver_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

### Raspored više zaslona

Hyprland odlično radi s više zaslona. Više o tome kako ih rasporediti pročitajte u [dokumentaciji o monitorima za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju one idu u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za prikvačivanje određenog monitora na razlučivost, položaj i rotaciju.

Svaki monitor ima vlastite radne prostore od 1 do 10, pa `Super + 1` uvijek znači prvi radni prostor monitora na kojem se nalazite. Iza kulisa Hyprland i dalje numerira radne prostore preko svih monitora: zaslon vašeg prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kada ga priključite. Koristite te brojeve ako pišete [pravila za radne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila za prozore za određeni monitor, pa je radni prostor 12 drugi radni prostor vašeg drugog monitora. `~/.local/state/omarchy/monitor-workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji u vašem rasporedu dijele rub. Zasloni koji se dodiruju samo u kutu ili između kojih postoji razmak nisu susjedi, pa za prelazak između njih koristite `Ctrl + Alt + Tab`.

| Tipkovni prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Pomiče fokus na monitor s te strane kada u tom smjeru više nema prozora |
| `Super + Shift + Arrow` | Zamjenjuje s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Pomiče prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Pomiče prozor na monitor s te strane, na radni prostor koji on prikazuje |
| `Super + Shift + Alt + Arrow` | Pomiče radni prostor na monitor s te strane, zadržavajući njegov broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pomiče fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem se nalazite |

Možete pogledati i [Hyprmon](https://github.com/erans/hyprmon/), ako želite TUI koji će vam pomoći pri pozicioniranju više zaslona.

### Upravljanje svjetlinom

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako pri pritisku tih tipki držite Shift, otići ćete na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom na koji ste fokusirani, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao zaslon prijenosnog računala.

### Apple zasloni

Ako koristite Apple zaslon, uobičajene tipke na tipkovnici za svjetlinu također će automatski raditi, ako ste fokusirani na Apple zaslon. To se radi putem naredbe `asdcontrol`.

Imajte na umu da, ako koristite Apple 6K XDR zaslon, u svom popisu `hyprctl monitors` možete vidjeti fantomski zaslon. To možete isključiti nečim poput `hl.monitor({ output = "DP-2", disabled = true })` putem _Postavke > Monitori_.

Na Intel računalima na Apple zaslone biste se trebali spajati običnim Thunderbolt kabelom. Na drugim računalima bez Thunderbolta obično ćete za to morati koristiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N).
