# Yhtenäinen leikepöytä ja historia

Linuxissa tarvitset yleensä pääätteessä kopiointiin ja liittämiseen yhdistelmän `Ctrl + Shift + C/V` ja kaikkialla muualla yhdistelmän `Ctrl + C/V`. Siihen on vaikea tottua kaikilla, jotka eivät ole syntyneet ja kasvaneet Linuxin parissa! Samoin Super-näppäimestä Ctrl-näppäimeen vaihtaminen, jos tulet Macista.

Omarchy ratkaisee molemmat ongelmat yhtenäisillä leikepöydän pikanäppäimillä, jotka toimivat (melkein) kaikkialla. Ne ovat:

| Pikanäppäin | Komento |
| ------- | ----------- |
| Super + C | Kopioi |
| Super + X | Leikkaa |
| Super + V | Liitä |
| Super + Ctrl + V | Leikepöydän historia |

_Huomaa, että useimmat agenttiharnessit käyttävät yhdistelmää `Ctrl + V` kuvien liittämiseen, mutta yhdistelmää `Super + V` tekstin liittämiseen._

### Leikepöydän historia

Leikepöydän historian tarjoaa Omarchyn kuori, ja se toimii sekä tekstille että kuville. Käynnistät sen yhdistelmällä `Super + Ctrl + V`, valitset merkintäsi Enterillä, ja se sijoitetaan sitten leikepöydälle valmiina liitettäväksi yhdistelmällä `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Voit myös hakea historiasta vain alkamalla kirjoittaa:

 ![clipboard-history-search](images/clipboard-history-search.webp)
