# Pääte

[Foot](https://codeberg.org/dnkl/foot) on Omarchyn oletuspääte. Se on nopea, kevyt ja yhteensopiva jopa vanhojen tietokoneiden kanssa. Se ei kuitenkaan tue kotoperäisiä välilehtiä tai jakoja.

Jos käytät Tmuxia, sinulle ei ehkä ole väliä, mutta jos et, tuemme myös täysin vaihtoehtoja _Alacritty_, _Ghostty_ ja _Kitty_. Valitse suosikkisi Omarchy-valikon kohdasta _Asenna > Pääte_.

Käynnistät uuden päätteen yhdistelmällä `Super + Return`. (Tämä sidos osoittaa automaattisesti siihen päätteeseen, jonka olet asentanut kohdasta _Asenna > Pääte_, ja voit vaihtaa asennettujen päätteet välillä kohdasta _Asetukset > Oletukset > Pääte_.)

## Tmux

Tmux tarjoaa yhtenäisen, ohjelmoitavan käyttöliittymän paneeleille, ikkunoille (eli välilehdille) ja jatkuville istunnoille pääatteestäsi riippumatta. Se toimii jopa etäisännissä, joten kun otat SSH-yhteyden palvelimeen, voit käyttää samaa lähestymistapaa.

Käynnistät uuden Tmux-istunnon tuoreessa pääätteessä yhdistelmällä `Super + Alt + Return`, ja koska Tmux on pysyvä prosessi, voit jatkaa istuntoasi, vaikka sulkisit kyseisen päätteen. Paina vain `Ctrl + Space` (jota kutsutaan etuliitenäppäimeksi) ja sitten `s` nähdäksesi kaikki aktiiviset istuntosi.

Omarchyssa on ergonomisesti optimoitu Tmux-määritys, jossa on paljon opiskeltavia pikanäppäimiä, joten pidä [huijausarkki käden ulottuvilla](07-hotkeys.md#tmux).

## Tmux-asettelufunktiot

Koska Tmux on ohjelmoitava, voimme käyttää funktioita asetteluiden luomiseen. Omarchyssa on neljä erilaista funktiota yleisiin kehittäjäasetteluihin.

`tdl [agent]` käynnistää kolmiosaisen IDE-mäisen käyttöliittymän, jossa `$EDITOR` on vasemmalla, valitsemasi tekoälyagentti oikealla (kuten `c` opencodea varten tai `cx` Claudelle tai `codex` OpenAI:ta varten) ja sitten pääte alareunassa.

Joten `tdl c` käynnistäisi tämän (tai vain `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Voit myös käynnistää toisen agentin yhdistelmällä `tdl c cx` (opencode + claude) (tai vain `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

On myös `tds`, joka käynnistää neliosaisen neliön, jossa editori on vasemmalla ylhäällä, reaaliaikainen diff-valvoja oikealla ylhäällä, pääte vasemmalla alhaalla ja opencode oikealla alhaalla.

Voit myös käynnistää tämän asettelumäärityksen jokaiselle nykyisen hakemiston alihakemistolle komennolla `tdlm [agent]` ja sitten navigoida näppäinyhdistelmillä `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Lopuksi voit käynnistää agenttiparven komennolla `tsl [panes] [command]`. Joten `tsl 4 c` antaa sinulle neliosaisen ruudukon opencode-agentteja:

 ![tmux-tsl](images/tmux-tsl.webp)
