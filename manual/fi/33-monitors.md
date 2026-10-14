# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-kykyistä retina-luokan näyttöä. Tätä tarvitset saadaksesi nuo mukavat, terävät ohjelmoijafontit. Se on se, mille melkein kaikki uudet huippuresoluutionäytöillä varustetut premium-kannettavat on optimoitu. Se on se, mitä haluaisit käyttää 27" 5K [Apple Studio Displayssa](https://www.apple.com/studio-display/)/[ProArt PA27JCV:ssä](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9:ssä](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P:ssä](https://kuycon.us/monitors/G27P/) tai 32" 6K [Apple XDR:ssä](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV:ssä](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P:ssä](https://kuycon.us/monitors/G32P/).

Mutta jos et käytä näyttöä, jonka PPI on 218 tai yli, haluat muuttaa näyttöasetuksia. Esimerkiksi, jos sinulla on 27" tai 32" 4K, voit käyttää murto-osaskaalausta avaamalla tiedoston `~/.config/hypr/monitors.lua` (Omarchy-valikon kohdan _Asetukset > Näytöt_ kautta) ja vaihtamalla tuolle yhdistelmälle tarkoitettuun suositukseen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat luultavasti vain käyttää 1x-skaalausta, joten voit käyttää:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Muutokset muuttujaan `GDK_SCALE` koskevat muutoksen jälkeen käynnistettyjä sovelluksia (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttösi skaalauksen lähimpänä kokonaislukuna). Varmista siis, että suljet ne ikkunat, jotka ovat muutoksen jälkeen ylimitoitettuja (tai sulje kaikki ikkunat näppäimillä `Ctrl + Alt + Del`!).

Voit myös nopeasti käydä läpi tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) käyttämällä näppäimiä `Super + /` mennäksesi ylemmäs ja `Super + Alt + /` mennäksesi alemmas. Jos sinulla on oletusmääritys, nämä muutokset säilyvät myös uudelleenkäynnistyksen jälkeen.

### Tekstin tekeminen suuremmaksi tai pienemmäksi

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon välillä 9–20 ja siirtää Omarchy-shellin, GTK-sovellukset ja päätteesi yhdessä, joten koko työpöytä pysyy suhteessa. Aja se ilman argumenttia nähdäksesi, missä olet, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jäljessä tuleva: sillä ei ole tapaa ladata määritystään uudelleen, joten käynnissä olevat päätteet säilyttävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun yhdistät ulkoisen näytön kannettavaasi, näyttö laajennetaan automaattisesti. Mutta voit muuttaa sen sen sijaan peilaukseksi käyttämällä Omarchy-valikon kohtaa _Käynnistä > Laitteisto_ tai näppäimiä `Super + Ctrl + Alt + Delete`. Tämä on erityisen hyödyllistä, jos tuo ulkoinen näyttö on projektori ja haluat näyttää jotain työskennellessäsi.

Laajentaessasi kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen käynnistää sen takaisin. Voit ohjata tätä myös manuaalisesti käyttämällä Omarchy-valikon kohtaa _Käynnistä > Laitteisto_ tai näppäimiä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii loistavasti useiden näyttöjen kanssa. Lue lisää niiden asettelusta [Hyprlandin näyttöohjeista](https://wiki.hypr.land/Configuring/Basics/Monitors/). Voit myös [sitoa tietyt työtilat tiettyihin näyttöihin](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Omarchyssa nämä säännöt menevät tiedostoon `~/.config/hypr/monitors.lua` merkintöinä `hl.monitor` — tiedosto toimitetaan kommentoitujen esimerkkien kanssa tietyn näytön kiinnittämiseksi resoluutioon, sijaintiin ja rotaatioon.

Voit myös tutustua ohjelmaan [Hyprmon](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan useiden näyttöjen sijoittelussa.

### Kirkkauden ohjaaminen

Näytön kirkkautta ohjataan omistetuilla kirkkauden ylös/alas-funktionäppäimillä. Jos pidät shiftiä pohjassa painaessasi näitä, menet maksimi- tai minimikirkkauteen. Näppäimet ohjaavat näyttöä, johon olet kohdentunut, joten DDC/CI:ä puhuvia ulkoisia näyttöjä säädetään samalla tavalla kuin kannettavan näyttöä.

### Apple-näytöt

Jos käytät Apple-näyttöä, myös tavalliset näppäimistön kirkkausnäppäimet toimivat automaattisesti, jos olet kohdentunut Apple-näyttöön. Tämä tehdään komennon `asdcontrol` kautta.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön listauksessasi `hyprctl monitors`. Voit kytkeä tämän pois päältä esimerkiksi komennolla `hl.monitor({ output = "DP-2", disabled = true })` kohdan _Asetukset > Näytöt_ kautta.

Intel-koneissa sinun pitäisi yhdistää Apple-näyttöihin tavallisella Thunderbolt-kaapelilla. Muissa koneissa, joissa ei ole Thunderboltia, joudut tyypillisesti käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N) saadaksesi sen toimimaan.
