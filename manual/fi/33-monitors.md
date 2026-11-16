# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-skaalaukseen kykenevää retina-luokan näyttöä. Sellaisen tarvitset saadaksesi ne kivat, terävät ohjelmoijafontit. Lähes kaikki uudet premium-läppärit korkealla resoluutiolla varustetuilla näytöillä on optimoitu sille. Sellaisen haluat käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytöllä.

Mutta jos et käytä näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Esimerkiksi jos sinulla on 27" tai 32" 4K, voit valita sille murtoskaalauksen yläpalkin näyttöpaneelista tai asettaa oletuksen jokaiselle näytölle avaamalla `~/.config/hypr/monitors.lua` ja vaihtamalla kyseiselle yhdistelmälle suositeltuun asetukseen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat luultavasti käyttää vain 1x-skaalausta, ja samaa GTK- ja X11-sovelluksille, joten voit käyttää:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE`-muutokset koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttösi skaalauksen lähimmässä kokonaisluvussa). Varmista siis, että suljet ikkunat, jotka ovat muutoksen jälkeen ylisuuria (tai sulje kaikki ikkunat näppäimillä `Ctrl + Alt + Del`!).

Voit myös selata nopeasti tärkeimpiä näytön skaalaussuhteita (1x, 1.25x, 1.6x, 2x, 3x, 4x) näppäimillä `Super + /` noustaksesi ja `Super + Alt + /` laskeaksesi, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, johon olet kohdistanut, joten läppärin näytöllä ja ulkoisella näytöllä voi kummallakin olla oma skaalauksensa. Paneeli asettaa myös jokaisen näytön resoluution, virkistystaajuuden ja kierron. Valintasi tallennetaan kyseiselle fyysiselle näytölle tiedostoon `~/.local/state/omarchy/monitors/settings`, joten ne säilyvät uudelleenkäynnistyksen yli ja seuraavat näyttöä mihin tahansa porttiin tai telakkaan se seuraavaksi kytketään. Ne ovat etusijalla samaa näyttöä koskevaan sääntöön nähden tiedostossa `~/.config/hypr/monitors.lua`, jota Omarchy ei koskaan muokkaa. Jos asetat näyttösi mieluummin kokonaan siinä tiedostossa, lisää siihen `omarchy_monitor_panel_settings = false`, ja paneelin muutokset kestävät vain siihen asti, kun Hyprland latautuu uudelleen. Koska `GDK_SCALE` on yksi arvo kaikille näytöille, valittu skaalaus asettaa sen näytön perusteella, jolla on pienin skaalaus, joten X11-sovellukset tulevat hieman pieninä tiheämmällä näytöllä sen sijaan, että ne olisivat ylisuuria toisella.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon väliltä 9–20, ja siirtää Omarchyn kuorta, GTK-sovelluksia ja päätettäsi yhdessä, joten koko työpöytä pysyy oikeissa mittasuhteissa. Aja se ilman argumenttia nähdäksesi, missä olet, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jälkijunassa tuleva: sillä ei ole tapaa ladata asetuksiaan uudelleen, joten käynnissä olevat päätteet pitävät vanhan kokonsa, kunnes avaat uuden.

### Läppärin näyttöjen laajentaminen ja peilaaminen

Kun kytket ulkoisen näytön läppäriisi, näyttö laajennetaan automaattisesti. Mutta voit vaihtaa sen sen sijaan peilaukseen Omarchy-valikon kohdasta _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Alt + Delete`. Tämä on erityisen hyödyllistä, jos tuo ulkoinen näyttö on projektori ja haluat näyttää jotakin työskennellessäsi.

Kun käytät laajennusta, läppärin kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit myös ohjata tätä manuaalisesti Omarchy-valikon kohdasta _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii hienosti useiden näyttöjen kanssa. Yläpalkin näyttöpaneeli piirtää ne siihen, missä ne sijaitsevat: vedä yksi toisen sivua vasten siirtääksesi sen sinne, ja järjestely tallennetaan jokaisen näytön muiden asetusten kanssa. Kaikkeen, mitä paneeli ei kata, lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa ne laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä näytön pitämisestä poissa päältä, tiloista joita paneeli ei tarjoa, 10-bittisistä väreistä ja muuttuvasta virkistystaajuudesta.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jolla olet. Kulissien takana Hyprland numeroi työtilat silti kaikkien näyttöjen yli: läppärisi näyttö (tai ensimmäinen näyttö) saa 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö pitää lohkonsa joka kerta, kun kytket sen. Käytä noita numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitors/workspaces` luetteloi, mikä lohko jokaisella näytöllä on.

Nuolinäppäimet toimivat näyttöjen välillä, joilla on yhteinen reuna asettelussasi. Näytöt, jotka koskettavat vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten käytä näppäimiä `Ctrl + Alt + Tab` päästäksesi niiden välillä.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevalle näytölle, kun ikkunoita ei enää ole siihen suuntaan |
| `Super + Shift + Arrow` | Vaihtaa sillä puolella olevalla näytöllä olevan ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevalle näytölle, sen näyttämälle työtilalle |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevalle näytölle ja säilyttää sen numeron, jos se on vapaana |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavalle tai edelliselle näytölle asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät näytöllä, jolla olet |

Voit myös tutustua työkaluun [Hyprmon](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään erillisillä kirkkaus ylös/alas -funktionäppäimillä. Jos pidät shift-näppäintä painettuna samalla kun painat niitä, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet säätelevät näyttöä, johon olet kohdistanut, joten ulkoiset näytöt, jotka puhuvat DDC/CI:tä, säädetään samalla tavalla kuin läppärin näyttö.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos olet kohdistanut Apple-näyttöön. Tämä tapahtuu `asdcontrol`-komennon kautta.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit kytkeä tämän pois päältä esimerkiksi asetuksella `hl.monitor({ output = "DP-2", disabled = true })` tiedostossa `~/.config/hypr/monitors.lua`.

Intel-koneilla sinun pitäisi kytkeä Apple-näytöt tavallisella Thunderbolt-kaapelilla. Muilla koneilla, joissa ei ole Thunderboltia, joudut tyypillisesti käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N) saadaksesi sen toimimaan.
