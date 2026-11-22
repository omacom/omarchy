# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-skaalaukseen kykenevää retina-luokan näyttöä. Sitä tarvitset saadaksesi ne kivat, terävät ohjelmoijafontit. Siihen lähes kaikki uudet korkean resoluution näytöillä varustetut premium-kannettavat on optimoitu. Sellaista haluaisit käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytöllä.

Mutta jos et käytä näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K-näyttö, voit valita sille murto-osasakaalauksen yläpalkin näyttöpaneelista tai asettaa oletuksen jokaiselle näytölle avaamalla `~/.config/hypr/monitors.lua` ja vaihtamalla kyseiselle yhdistelmälle suositeltuun asetukseen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat todennäköisesti vain käyttää 1x-skaalausta, ja samaa GTK- ja X11-sovelluksille, joten voit käyttää:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE`-muutokset koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttöskaalasi lähimmässä kokonaisluvussa). Muista siis sulkea ikkunat, jotka ovat muutoksen jälkeen liian suuria (tai sulje kaikki ikkunat näppäimillä `Ctrl + Alt + Del`!).

Voit myös selata nopeasti läpi tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) näppäimillä `Super + /` siirtyäksesi suurempaan ja `Super + Alt + /` siirtyäksesi pienempään, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, johon olet kohdistanut, joten kannettavan näytöllä ja ulkoisella näytöllä voi kummallakin olla oma skaalansa. Paneelista asetetaan myös kunkin näytön resoluutio, virkistystaajuus ja kierto. Valintasi tallennetaan kyseiselle fyysiselle näytölle tiedostoon `~/.local/state/omarchy/monitors/settings`, joten ne säilyvät uudelleenkäynnistyksen yli ja seuraavat näyttöä siihen porttiin tai telakkaan, johon se seuraavaksi kytketään. Ne ovat etusijalla samaa näyttöä koskeviin sääntöihin nähden tiedostossa `~/.config/hypr/monitors.lua`, jota Omarchy ei koskaan muokkaa. Jos haluat mieluummin asettaa näyttösi kokonaan kyseisessä tiedostossa, lisää siihen `omarchy_monitor_panel_settings = false`, jolloin paneelin muutokset kestävät vain siihen asti, kun Hyprland ladataan uudelleen. Koska `GDK_SCALE` on yksi arvo kaikille näytöille, valittu skaala asettaa sen pienimmän skaalan näytön perusteella, joten X11-sovellukset näkyvät hieman pieninä tiheämmällä näytöllä sen sijaan, että ne olisivat liian suuria toisella.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon välillä 9–20 ja siirtää Omarchy-kuorta, GTK-sovelluksia ja terminaaliasi yhdessä, joten koko työpöytä pysyy oikeissa mittasuhteissa. Aja se ilman argumenttia nähdäksesi, missä olet nyt, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jäljelle jäävä: sillä ei ole tapaa ladata asetuksiaan uudelleen, joten käynnissä olevat terminaalit säilyttävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun kytket ulkoisen näytön kannettavaasi, näyttö laajennetaan automaattisesti. Mutta voit vaihtaa sen sen sijaan peilaamiseen valinnalla _Laajenna_ | _Peilaa_ yläpalkin näyttöpaneelissa, valinnalla _Trigger > Laitteisto_ Omarchy-valikossa tai näppäimillä `Super + Ctrl + Alt + Delete`. Tämä on erityisen kätevää, jos ulkoinen näyttö on projektori ja haluat näyttää jotakin työskennellessäsi.

Kun laajennat, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit hallita tätä myös manuaalisesti Omarchy-valikon kohdasta _Trigger > Laitteisto_ tai näppäimillä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii erinomaisesti useiden näyttöjen kanssa. Yläpalkin näyttöpaneeli piirtää ne siihen, missä ne sijaitsevat: vedä yksi toisen sivua vasten siirtääksesi sen sinne, ja järjestys tallennetaan kunkin näytön muiden asetusten mukana. Kaikesta, mitä paneeli ei kata, voit lukea lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa nämä laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä näytön pitämisestä pois päältä, tiloista, joita paneeli ei tarjoa, 10-bittisistä väreistä ja vaihtelevasta virkistystaajuudesta.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jolla olet. Kulissien takana Hyprland numeroi työtilat silti kaikkien näyttöjen läpi: kannettavasi näyttö (tai ensimmäinen näyttö) saa 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö säilyttää oman lohkonsa joka kerta, kun kytket sen. Käytä näitä numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitors/workspaces` luettelee, mikä lohko kullakin näytöllä on.

Nuolinäppäimet toimivat näyttöjen välillä, joilla on yhteinen reuna asettelussasi. Näytöt, jotka koskettavat vain kulmasta tai joiden välillä on rako, eivät ole naapureita, joten käytä näppäimiä `Ctrl + Alt + Tab` päästäksesi niiden välillä.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevalle näytölle, kun kyseiseen suuntaan ei ole enää ikkunaa |
| `Super + Shift + Arrow` | Vaihtaa paikkaa sillä puolella olevalla näytöllä olevan ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevalle näytölle, sen näyttämälle työtilalle |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevalle näytölle ja säilyttää sen numeron, jos se on vapaana |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavalle tai edelliselle näytölle asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät näytöllä, jolla olet |

Voit myös tutustua työkaluun [Hyprmon](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään erillisillä kirkkaus ylös/alas -toimintonäppäimillä. Jos pidät Shift-näppäintä painettuna näitä painaessasi, siirryt maksimi- tai minimikirkkauteen. Näppäimet säätelevät näyttöä, johon olet kohdistanut, joten DDC/CI:tä puhuvia ulkoisia näyttöjä säädetään samalla tavalla kuin kannettavan näyttöä.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos olet kohdistanut Apple-näyttöön. Tämä tehdään `asdcontrol`-komennon kautta.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit kytkeä tämän pois päältä esimerkiksi koodilla `hl.monitor({ output = "DP-2", disabled = true })` tiedostossa `~/.config/hypr/monitors.lua`.

Intel-koneilla Apple-näytöt kannattaa kytkeä tavallisella Thunderbolt-kaapelilla. Muilla koneilla, joissa ei ole Thunderboltia, joudut yleensä käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N), jotta se toimii.
