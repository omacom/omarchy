# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-kykyistä retina-luokan näyttöä. Tätä tarvitset saadaksesi ne kivat, terävät ohjelmoijafontit. Lähes kaikki uudet korkealuokkaiset kannettavat, joissa on korkean resoluution näyttö, on optimoitu tätä varten. Tätä haluaisit käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) -näytöllä tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytöllä.

Mutta jos et käytä näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K-näyttö, voit valita sille murtolukuskaalauksen yläpalkin näyttöpaneelista tai asettaa oletuksen joka näytölle avaamalla `~/.config/hypr/monitors.lua` ja vaihtamalla kyseiselle yhdistelmälle suositeltuun vaihtoehtoon:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat todennäköisesti vain käyttää 1x-skaalausta, ja samaa GTK- ja X11-sovelluksille, joten voit käyttää:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Muutokset `GDK_SCALE`-asetukseen koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttösi skaalausta lähimpänä kokonaislukuna). Varmista siis, että suljet ikkunat, jotka ovat muutoksen jälkeen ylisuuria (tai sulje kaikki ikkunat painamalla `Ctrl + Alt + Del`!).

Voit myös selata nopeasti tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) painamalla `Super + /` kasvattaaksesi ja `Super + Alt + /` pienentääksesi, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, jossa kohdistus on, joten kannettavan näytöllä ja ulkoisella näytöllä voi kummallakin olla oma skaalauksensa. Paneeli määrittää myös kunkin näytön resoluution, virkistystaajuuden ja kierron. Valintasi tallennetaan kyseiselle fyysiselle näytölle tiedostoon `~/.local/state/omarchy/monitors/settings`, joten ne säilyvät uudelleenkäynnistyksen yli ja seuraavat näyttöä siihen porttiin tai telakkaan, johon se seuraavaksi kytketään. Ne ovat etusijalla samaa näyttöä koskevaan sääntöön nähden tiedostossa `~/.config/hypr/monitors.lua`, jota Omarchy ei koskaan muokkaa. Jos haluat mieluummin määrittää näyttösi kokonaan kyseisessä tiedostossa, lisää siihen `omarchy_monitor_panel_settings = false`, ja paneelin muutokset kestävät vain siihen asti, kun Hyprland latautuu uudelleen. Koska `GDK_SCALE` on yksi arvo kaikille näytöille, valittu skaalaus asettaa sen pienimmän skaalauksen näytön perusteella, joten X11-sovellukset tulevat hieman pieninä tiheämmällä näytöllä sen sijaan, että ne olisivat ylisuuria toisella.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon väliltä 9 ja 20 ja siirtää Omarchy-kuorta, GTK-sovelluksia ja päätettäsi yhdessä, joten koko työpöytä pysyy oikeassa suhteessa. Suorita se ilman argumenttia nähdäksesi, missä olet nyt, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jäänne: sillä ei ole tapaa ladata asetuksiaan uudelleen, joten käynnissä olevat päätteet säilyttävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun kytket ulkoisen näytön kannettavaasi, näyttö laajennetaan automaattisesti. Mutta voit vaihtaa sen sen sijaan peilaamiseen valitsemalla _Laajenna_ | _Peilaa_ yläpalkin näyttöpaneelissa, _Trigger > Hardware_ Omarchy-valikossa tai painamalla `Super + Ctrl + Alt + Delete`. Tämä on erityisen hyödyllistä, jos kyseinen ulkoinen näyttö on projektori ja haluat näyttää jotakin työskennellessäsi.

Kun laajennat, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit myös hallita tätä manuaalisesti käyttämällä _Trigger > Hardware_ Omarchy-valikossa tai painamalla `Super + Ctrl + Delete`.

Kun kannettava on kytkettynä verkkovirtaan, kannen sulkeminen ei koskaan laita sitä nukkumaan, joten telakoitu kannettava pysyy hereillä, vaikka ulkoinen näyttö irtoaisi hetkeksi. Kun ulkoista näyttöä ei ole kytketty, kannen sulkeminen verkkovirralla vain lukitsee sen. Akulla kannen sulkeminen keskeyttää toiminnan tavalliseen tapaan.

### Useiden näyttöjen järjestäminen

Hyprland toimii hienosti useiden näyttöjen kanssa. Yläpalkin näyttöpaneeli piirtää ne siihen, missä ne sijaitsevat: vedä yksi toisen sivua vasten siirtääksesi sen sinne, ja järjestely tallennetaan kunkin näytön muiden asetusten kanssa. Kaikkea sitä varten, mitä paneeli ei kata, lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa nämä menevät tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedosto toimitetaan kommentoiduilla esimerkeillä näytön pitämisestä pois päältä, tiloista, joita paneeli ei tarjoa, 10-bittisestä väristä ja muuttuvasta virkistystaajuudesta.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jossa olet. Konepellin alla Hyprland numeroi työtilat silti kaikkien näyttöjen yli: kannettavasi näyttö (tai ensimmäinen näyttö) saa työtilat 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö säilyttää oman lohkonsa joka kerta, kun kytket sen. Käytä näitä numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitors/workspaces` luetteloi, mikä lohko kullakin näytöllä on.

Nuolinäppäimet toimivat näyttöjen yli, joilla on yhteinen reuna asettelussasi. Näytöt, jotka koskettavat toisiaan vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten käytä `Ctrl + Alt + Tab` päästäksesi niiden välillä.

| Pikanäppäin | Näyttöjen yli |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevaan näyttöön, kun ikkunaa ei enää ole siinä suunnassa |
| `Super + Shift + Arrow` | Vaihtaa sillä puolella olevassa näytössä olevan ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevassa näytössä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevaan näyttöön, sen näyttämään työtilaan |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevaan näyttöön säilyttäen sen numeron, jos se on vapaa |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavaan tai edelliseen näyttöön asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät näytössä, jossa olet |

Voit myös tutustua [Hyprmoniin](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan sinua useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään kirkkauden lisäämiseen ja vähentämiseen tarkoitetuilla erillisillä funktionäppäimillä. Jos pidät shift-näppäintä painettuna samalla, kun painat näitä, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet säätävät näyttöä, jossa kohdistus on, joten ulkoisia näyttöjä, jotka puhuvat DDC/CI:tä, säädetään samalla tavalla kuin kannettavan näyttöä.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos kohdistus on Apple-näytössä. Tämä tehdään `asdcontrol`-komennolla.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit kytkeä tämän pois päältä esimerkiksi lisäämällä `hl.monitor({ output = "DP-2", disabled = true })` tiedostoon `~/.config/hypr/monitors.lua`.

Intel-koneissa sinun pitäisi kytkeä Apple-näyttöihin tavallisella Thunderbolt-kaapelilla. Muissa koneissa, joissa ei ole Thunderboltia, sinun on yleensä käytettävä [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N), jotta se toimii.
