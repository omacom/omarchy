# Yhtenäinen leikepöytä ja historia

Tavallisesti Linuxissa tarvitset `Ctrl + Shift + C/V` kopioimiseen ja liittämiseen terminaalissa ja `Ctrl + C/V` samaan kaikkialla muualla. Siihen on vaikea tottua kenenkään, joka ei ole syntynyt ja kasvanut Linuxin parissa! Sama koskee vaihtamista superista ctrliin, jos tulet Macista.

Omarchy ratkaisee molemmat ongelmat yhtenäisillä leikepöydän pikanäppäimillä, jotka toimivat (melkein) kaikkialla. Ne ovat:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Valitse kaikki |
| Super + C | Kopioi |
| Super + X | Leikkaa |
| Super + V | Liitä |
| Super + Ctrl + V | Leikepöydän historia |

_Huomaa, että useimmat agenttiharnessit käyttävät `Ctrl + V` kuvien liittämiseen, mutta `Super + V` tekstin liittämiseen._

Käytä `Super + A` ja sitten `Super + C` kopioidaksesi kaiken kohdistetussa tekstikentässä tai muussa sovelluksessa, joka tukee `Ctrl + A`. Terminaalissa `Ctrl + A` siirtää komentorivin alkuun sen tekstin valitsemisen sijaan.

### Leikepöydän historia

Leikepöydän historian tarjoaa Omarchy shell, ja se toimii sekä tekstille että kuville. Käynnistät sen näppäimillä `Super + Ctrl + V` ja valitset merkintäsi returnilla, mikä liittää sen suoraan sovellukseen, jossa olit. Käytä `Shift + Return` vain kopioidaksesi sen leikepöydälle, `Alt + Return` avataksesi sen, `Delete` poistaaksesi sen historiasta ja `Shift + Delete` tyhjentääksesi koko historian.

 ![clipboard-history](images/clipboard-history.webp)

Voit myös hakea historiasta yksinkertaisesti alkamalla kirjoittaa:

 ![clipboard-history-search](images/clipboard-history-search.webp)
