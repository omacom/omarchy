# Shell-funktiot

Omarchyssa on joukko shell-funktioita yleisten tehtävien yksinkertaistamiseksi ja monimutkaisten parametrikutsujen kapseloimiseksi.

## Pakkaus

- `compress [file/dir]`: Luo tar.gz-arkisto tiedostosta/hakemistosta.
- `decompress [file.tar.gz]`: Pura tar.gz-tiedosto.

## Asemat

- `iso2sd [image.iso]`: Luo käynnistettävä asema SD-kortille käyttäen viitattua iso-tiedostoa ja valitsemalla asema vuorovaikutteisesti.
- `format-drive [device] [name]`: Alusta koko levy yhdellä exFAT-osiolla (joka toimii myös Windowsissa ja macOS:ssä). Aja se ilman argumentteja nähdäksesi käytettävissä olevat asemat. Ole varovainen!

## Kehitysasettelut

Välittömät moniruutuiset kehitysasettelut tmuxille:

- `tdl [ai]`: Luo Tmux Dev Layout, jossa on editorisi, tekoälyagentti ja pääte. Käytä agenttialiaksia, kuten `tdl c` opencodelle tai `tdl cx` Claude Codelle, tai anna toisena agentti ajaaksesi molempia, kuten `tdl c cx`.
- `tds`: Luo Tmux Dev Square, jossa on editori, diffien seuranta (komennolla `hunk diff --watch`), pääte ja opencode.
- `tdlm [ai]`: Luo `tdl`-ikkuna jokaiselle nykyisen hakemiston alihakemistolle.
- `tsl [count] [command]`: Luo ruudukkoon laatoitetun ruutuparven, jotka kaikki ajavat samaa komentoa (erinomainen tekoälyagenteille).

Samat asettelut ovat saatavilla Herdrille nimillä `hdl`, `hds`, `hdlm` ja `hsl`.

## Git-työpuut

- `ga [branch]`: Luo uusi työpuu ja haara nykyisen repositorion vierelle ja hyppää sinne.
- `gd`: Poista nykyinen työpuu ja sen haara (kysyy ensin vahvistuksen).

## Rsync-valvojat

- `rsw [source] [destination]`: Käynnistä taustavalvoja, joka rsyncää lähteen kohteeseen aina, kun mikään muuttuu. Kohde voi olla etäkone, kuten `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Listaa kaikki aktiiviset valvojat.
- `dsw`: Pysäytä kaikki aktiiviset valvojat.

## SSH-porttiohjaukset

Ihanteellinen verkkokehitykseen localhostin suojatun kontekstin oikeuksilla etäkonetta vasten.

- `fip`: Ohjaa yksi tai useampi portti etäkoneelta localhostiin SSH:n kautta.
- `dip`: Katkaise yhteys yhteen tai useampaan ohjattuun porttiin.
- `lip`: Listaa kaikki aktiiviset SSH-porttiohjaukset.

Sanotaan, että käynnistät kehityspalvelimen portissa `3000` koneella, joka on saavutettavissa nimellä `nyc-dev`; silloin voit ajaa `fip nyc-dev 3000` ohjataksesi kyseisen portin, jolloin `localhost:3000` tavoittaa oikeasti osoitteen `nyc-dev:3000`, mutta ilman SSL-sertifikaattien tarvetta sen suojatun kontekstin luomiseksi, jota tarvitaan esimerkiksi web socketien testaamiseen.

## SSH:n uudelleenyhdistäminen

Itse `ssh` on kääritty funktioon, joka siivoaa päätteen, jos yhteys katkeaa, kun etä-tmux, Herdr tai editori on ottanut sen haltuunsa, ja yhdistää sitten automaattisesti uudelleen, kun vuorovaikutteinen istunto katkeaa (Ctrl-C pysäyttää uudelleenyrityssilmukan).
