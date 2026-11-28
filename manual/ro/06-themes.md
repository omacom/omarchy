# Teme

Omarchy vine cu douăzeci și trei de teme frumoase. Poți alege dintre ele prin _Appearance > Theme_ în Meniul Omarchy (`Super + Space`) sau poți sări direct la selectorul de teme folosind `Super + Ctrl + T`.

Fiecare temă stilizează desktopul, terminalul, neovim, ecranul de activitate (btop), browserul tău (Chrome, Chromium, Edge sau Brave) și întregul shell Omarchy: bara superioară, meniul, notificările, OSD și ecranul de blocare. (Pentru Obsidian, trebuie să selectezi manual tema Omarchy prin _Appearance > Themes_ în interiorul aplicației).

Temele au un set de imagini de fundal între care poți alege folosind `Super + Ctrl + W`.

Poți găsi și mai multe teme pe [pagina cu teme suplimentare](https://omarchy.org/themes/) sau chiar [să-ți faci propria temă](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Pictogramele aplicațiilor

Pictogramele din lansatorul de aplicații și din dock sunt desenate în culorile temei tale, așa că se schimbă odată cu ea. Ele provin dintr-un set de pictograme, pe care îl alegi separat de temă la _Appearance > Icons_, din previzualizări ale fiecărui set, în același mod în care alegi o temă:

- _Papercraft_ este setul implicit: tot ce vine instalat, desenat într-un singur stil. Aplicațiile cunoscute după logo, precum Chrome, HEY sau YouTube, își păstrează forma și preiau culorile temei.
- _Arcade_ desenează aceleași aplicații ca artă pixelată pe 8 biți, așa cum ar face-o o consolă de jocuri veche.
- _Original_ afișează fiecare aplicație cu pictograma pe care i-a dat-o creatorul ei.

Poți instala un set de pictograme creat de altcineva cu _Install > Style > Icons_ (sau `omarchy icons install <git url>`) și îl poți elimina din nou la _Remove > Icons_. _Update > Extra Icons_ preia cea mai recentă versiune a seturilor pe care le ai instalate.

Pentru a-ți crea propriul set, pune pictogramele în `~/.config/omarchy/icons/<name>/`, câte un fișier pentru fiecare aplicație, numit după linia `Icon=` din fișierul `.desktop` al aplicației. Un fișier cu extensia `.svg` este afișat așa cum este. Un fișier cu extensia `.svg.tpl` este desenat în culorile temei: scrie `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` sau `{{ icon_shadow }}` unde merge o culoare. Setul implicit din `/usr/share/omarchy/icons/papercraft/` este un bun punct de plecare. Adaugă un `preview.png` pentru a-ți afișa setul în selector; fără unul, Omarchy desenează o previzualizare din pictogramele tale. Pentru a schimba o singură pictogramă din setul implicit, pune versiunea ta în `~/.config/omarchy/icons/papercraft/`.

### Pornire și autentificare

Ecranul care îți cere parola unității când pornește computerul și ecranul de autentificare urmează și ele tema. De fiecare dată când schimbi tema, ele preiau fundalul, textul, accentul și culorile roșii ale acesteia, așa că nu există un design separat de deblocare de ales. Pe Mac-urile cu Apple Silicon, ecranul pentru parola unității păstrează aspectul implicit Omarchy, indiferent de temă.
