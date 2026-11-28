# Teme

Omarchy ima triindvajset čudovitih tem. Med njimi lahko izbirate prek _Videz > Tema_ v meniju Omarchy (`Super + Space`) ali pa skočite naravnost v izbirnik tem z `Super + Ctrl + T`.

Vsaka tema oblikuje namizje, terminal, neovim, zaslon dejavnosti (btop), vaš brskalnik (Chrome, Chromium, Edge ali Brave) in celotno lupino Omarchy: zgornjo vrstico, meni, obvestila, OSD in zaklenjeni zaslon. (Pri Obsidianu morate temo Omarchy izbrati ročno prek _Videz > Teme_ v sami aplikaciji).

Teme imajo nabor slik za ozadje, med katerimi lahko izbirate z `Super + Ctrl + W`.

Še več tem najdete na [strani z dodatnimi temami](https://omarchy.org/themes/) ali pa si celo [izdelate svojo temo](43-making-your-own-theme.md).

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

### Ikone aplikacij

Ikone v zaganjalniku aplikacij in doku so narisane v barvah vaše teme, zato se spreminjajo skupaj z njo. Prihajajo iz nabora ikon, ki ga izberete ločeno od teme pod _Videz > Ikone_, iz predogledov vsakega nabora, na enak način kot izberete temo:

- _Papercraft_ je privzeti: vse, kar je nameščeno, narisano v enem slogu. Aplikacije, prepoznavne po svojem logotipu, kot so Chrome, HEY ali YouTube, obdržijo svojo obliko in prevzamejo barve teme.
- _Arcade_ nariše iste aplikacije kot 8-bitno pikselsko grafiko, kot bi to naredila stara igralna konzola.
- _Original_ prikaže vsako aplikacijo z ikono, ki ji jo je dal njen izdelovalec.

Nabor ikon, ki ga je izdelal nekdo drug, lahko namestite prek _Namesti > Slog > Ikone_ (ali z `omarchy icons install <git url>`) in ga znova odstranite pod _Odstrani > Ikone_. _Posodobi > Dodatne ikone_ pridobi najnovejšo različico naborov, ki jih imate nameščenih.

Če želite izdelati svojega, dajte svoje ikone v `~/.config/omarchy/icons/<name>/`, eno datoteko na aplikacijo, poimenovano po vrstici `Icon=` v datoteki `.desktop` te aplikacije. Datoteka s končnico `.svg` je prikazana taka, kot je. Datoteka s končnico `.svg.tpl` je narisana v barvah teme: napišite `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ali `{{ icon_shadow }}`, kjer spada barva. Privzeti nabor v `/usr/share/omarchy/icons/papercraft/` je dobro mesto za začetek. Dodajte `preview.png`, da bo vaš nabor prikazan v izbirniku; brez njega Omarchy nariše predogled iz vaših ikon. Če želite spremeniti eno samo ikono privzetega nabora, dajte svojo različico v `~/.config/omarchy/icons/papercraft/`.

### Zagon in prijava

Zaslon, ki vas ob zagonu računalnika vpraša za geslo vašega diska, in prijavni zaslon prav tako sledita temi. Vsakič, ko zamenjate temo, prevzameta njeno ozadje ter barve besedila, poudarka in rdečo, zato ni ločenega videza za odklepanje, ki bi ga bilo treba izbrati. Na Macih z Apple Silicon zaslon za geslo diska ohrani privzeti videz Omarchyja, ne glede na temo.
