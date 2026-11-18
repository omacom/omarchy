# Yhtenäinen leikepöytä ja historia

Yleensä Linuxissa tarvitset terminaalissa kopioimiseen ja liittämiseen `Ctrl + Shift + C/V` ja kaikkialla muualla `Ctrl + C/V`. Siihen on vaikea tottua kenelle tahansa, joka ei ole syntynyt ja kasvanut Linuxin parissa! Samoin on vaihtamisen laita Superista Ctrliin, jos tulet Macista.

Omarchy ratkaisee molemmat ongelmat yhtenäisillä leikepöydän pikanäppäimillä, jotka toimivat (lähes) kaikkialla. Ne ovat:

| Pikanäppäin | Komento |
| ------- | ----------- |
| Super + A | Valitse kaikki |
| Super + C | Kopioi |
| Super + X | Leikkaa |
| Super + V | Liitä |
| Super + Ctrl + V | Leikepöydän historia |

_Huomaa, että useimmat agenttivaljaat käyttävät kuvien liittämiseen `Ctrl + V`, mutta tekstin liittämiseen `Super + V`._

Käytä `Super + A` ja sitten `Super + C` kopioidaksesi kaiken kohdistettuna olevassa tekstikentässä tai muussa sovelluksessa, joka tukee näppäinyhdistelmää `Ctrl + A`. Terminaalissa `Ctrl + A` siirtyy komentorivin alkuun sen sijaan, että se valitsisi sen tekstin.

### Leikepöydän historia

Leikepöydän historian tarjoaa Omarchy shell, ja se toimii sekä tekstille että kuville. Käynnistät sen näppäimillä `Super + Ctrl + V`, valitset kohteesi Return-näppäimellä, ja se asetetaan leikepöydälle valmiiksi liitettäväksi näppäimillä `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Voit myös hakea historiasta yksinkertaisesti alkamalla kirjoittaa:

 ![clipboard-history-search](images/clipboard-history-search.webp)
