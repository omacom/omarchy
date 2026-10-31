# Monitori

Omarchy prema zadanim postavkama pretpostavlja da radiš na zaslonu klase Retina koji podržava 2x. To ti treba da dobiješ one lijepe, oštre programerske fontove. Za to su optimizirana gotovo sva nova premium prijenosna računala sa zaslonima visoke razlučivosti. To bi htio pokrenuti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristiš zaslon s PPI-jem od 218 ili više, htjet ćeš promijeniti postavke monitora. Na primjer, ako imaš 27" ili 32" 4K, možeš odabrati frakcijsku skalu za njega na ploči monitora u gornjoj traci ili postaviti zadanu vrijednost za svaki monitor otvaranjem `~/.config/hypr/monitors.lua` i prebacivanjem na preporuku za tu kombinaciju:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ako koristiš zaslon od 1080p ili 1440p, vjerojatno ćeš htjeti koristiti samo skaliranje 1x, a isto i za GTK i X11 aplikacije, pa možeš koristiti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Promjene `GDK_SCALE` vrijede za aplikacije pokrenute nakon promjene (a GTK prihvaća samo cijele brojeve, pa ga drži na najbližem cijelom broju skale tvog monitora). Zato obavezno zatvori prozore koje imaš, a koji su nakon promjene preveliki (ili zatvori sve prozore sa `Ctrl + Alt + Del`!).

Također možeš brzo prolaziti kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) koristeći `Super + /` za veće i `Super + Alt + /` za manje, ili odabrati jedan na ploči monitora u gornjoj traci. Time se mijenja samo monitor na koji si fokusiran, pa zaslon prijenosnog računala i vanjski zaslon mogu svaki imati svoju skalu. Ploča također postavlja razlučivost svakog monitora. Tvoji se odabiri spremaju za taj fizički monitor u `~/.local/state/omarchy/monitors/settings`, pa ostaju i nakon ponovnog pokretanja i prate monitor na koji god priključak ili dock da ga sljedeći put priključiš. Imaju prednost nad bilo kojim pravilom za isti monitor u `~/.config/hypr/monitors.lua`, koji Omarchy nikada ne uređuje. Budući da je `GDK_SCALE` jedna vrijednost za sve zaslone, odabrana skala postavlja ga prema monitoru s najnižom skalom, pa X11 aplikacije ispadnu malo premale na gušćem zaslonu umjesto prevelike na drugom.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako želiš samo veći ili manji _tekst_, za to postoji jedna jedina postavka:

```
omarchy display text size 14
```

Prima veličinu u pikselima između 9 i 20 i zajedno pomiče Omarchy ljusku, GTK aplikacije i tvoj terminal, pa cijela radna površina ostaje u proporciji. Pokreni je bez argumenta da vidiš gdje si, a `omarchy display text size reset` da se vratiš na zadanu vrijednost. Foot je jedini koji zaostaje: nema načina da ponovno učita svoju konfiguraciju, pa pokrenuti terminali zadržavaju staru veličinu dok ne otvoriš novi.

### Proširivanje i zrcaljenje zaslona prijenosnog računala

Kad priključiš vanjski zaslon na prijenosno računalo, zaslon se automatski proširuje. Ali to možeš promijeniti u zrcaljenje koristeći _Trigger > Hardware_ u izborniku Omarchyja ili `Super + Ctrl + Alt + Delete`. To je posebno korisno ako je taj vanjski zaslon projektor, a želiš nešto pokazati dok radiš.

Kad proširuješ, zatvaranje poklopca prijenosnog računala automatski će isključiti interni zaslon. Otvaranje poklopca ponovno će ga uključiti. To također možeš ručno kontrolirati koristeći _Trigger > Hardware_ u izborniku Omarchyja ili `Super + Ctrl + Delete`.

### Raspoređivanje više zaslona

Hyprland odlično radi s više zaslona. Ploča monitora u gornjoj traci crta ih gdje se nalaze: povuci jedan uz bok drugoga da ga tamo premjestiš i raspored se sprema s ostalim postavkama svakog monitora. Za sve što ploča ne pokriva, pročitaj više o tome kako ih rasporediti u [dokumentaciji o monitorima za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). U Omarchyju to ide u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za fiksiranje određenog monitora na razlučivost, položaj i rotaciju.

Svaki monitor ima svoje radne prostore od 1 do 10, pa `Super + 1` uvijek znači prvi radni prostor monitora na kojem se nalaziš. U pozadini Hyprland i dalje numerira radne prostore preko svih monitora: zaslon tvog prijenosnog računala (ili prvi monitor) dobiva 1–10, sljedeći monitor 11–20 i tako dalje, a svaki monitor zadržava svoj blok svaki put kad ga priključiš. Koristi te brojeve ako pišeš [pravila radnih prostora](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ili pravila prozora za određeni monitor, pa je radni prostor 12 drugi radni prostor tvog drugog monitora. `~/.local/state/omarchy/monitors/workspaces` navodi koji blok ima svaki monitor.

Tipke sa strelicama rade preko monitora koji dijele rub u tvom rasporedu. Zasloni koji se dodiruju samo u kutu ili koji imaju razmak među sobom nisu susjedi, pa koristi `Ctrl + Alt + Tab` da dođeš među njih.

| Tipkovni prečac | Preko monitora |
| --- | --- |
| `Super + Arrow` | Premješta fokus na monitor s te strane kad više nema prozora u tom smjeru |
| `Super + Shift + Arrow` | Zamjenjuje s prozorom na monitoru s te strane |
| `Super + Alt + Arrow` | Premješta prozor u grupu na monitoru s te strane |
| `Super + Shift + Ctrl + Arrow` | Premješta prozor na monitor s te strane, na radni prostor koji prikazuje |
| `Super + Shift + Alt + Arrow` | Premješta radni prostor na monitor s te strane, zadržavajući njegov broj ako je slobodan |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premješta fokus na sljedeći ili prethodni monitor, bez obzira na raspored |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostaju na monitoru na kojem se nalaziš |

Možeš pogledati i [Hyprmon](https://github.com/erans/hyprmon/), ako želiš TUI koji će ti pomoći pri pozicioniranju više zaslona.

### Upravljanje svjetlinom

Svjetlinom monitora upravlja se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako držiš Shift dok pritišćeš te tipke, ići ćeš na maksimalnu ili minimalnu svjetlinu. Tipke upravljaju zaslonom na koji si fokusiran, pa se vanjski monitori koji govore DDC/CI podešavaju na isti način kao zaslon prijenosnog računala.

### Apple zasloni

Ako koristiš Apple zaslon, uobičajene tipke za svjetlinu na tipkovnici također će automatski raditi, ako si fokusiran na Apple zaslon. To se radi putem naredbe `asdcontrol`.

Imaj na umu da, ako koristiš Apple 6K XDR zaslon, možda ćeš vidjeti fantomski zaslon na popisu `hyprctl monitors`. To možeš isključiti nečim poput `hl.monitor({ output = "DP-2", disabled = true })` u `~/.config/hypr/monitors.lua`.

Na Intel strojevima trebao bi se povezivati na Apple zaslone običnim Thunderbolt kabelom. Na drugim strojevima bez Thunderbolta obično ćeš morati koristiti [DP + USB-A -> USB-C kabel](https://www.amazon.com/dp/B0BNX7MS6N) da bi to radilo.
