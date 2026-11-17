# Teme

Omarchy prihaja z dvaindvajsetimi čudovitimi temami. Med njimi lahko izbirate prek _Videz > Tema_ v meniju Omarchy (`Super + Space`) ali pa skočite naravnost v izbirnik tem z `Super + Ctrl + T`.

Vsaka tema oblikuje namizje, terminal, neovim, zaslon dejavnosti (btop), Chromium in celotno lupino Omarchy: zgornjo vrstico, meni, obvestila, OSD in zaklenjeni zaslon. (Pri Obsidianu morate temo Omarchy izbrati ročno prek _Videz > Teme_ v aplikaciji).

Teme imajo nabor slik za ozadje, med katerimi lahko izbirate z `Super + Ctrl + W`.

Še več tem najdete na [strani z dodatnimi temami](https://omarchy.org/themes/) ali pa celo [izdelate lastno temo](43-making-your-own-theme.md).

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

### Ikone aplikacij

Ikone v zaganjalniku aplikacij in doku so narisane v barvah vaše teme, zato se spreminjajo skupaj z njo. Izhajajo iz nabora ikon, ki ga izberete ločeno od teme pod _Videz > Ikone_, med predogledi posameznega nabora, na enak način, kot izberete temo:

- _Papercraft_ je privzet: vse, kar je nameščeno, narisano v enem slogu. Aplikacije, znane po svojem logotipu, kot so Chrome, HEY ali YouTube, obdržijo svojo obliko in prevzamejo barve teme.
- _Arcade_ nariše iste aplikacije kot 8-bitno pikselno grafiko, kot bi jih stara igralna konzola.
- _Original_ prikaže vsako aplikacijo z ikono, ki ji jo je dal njen izdelovalec.

Nabor ikon, ki ga je izdelal kdo drug, lahko namestite z _Namesti > Slog > Ikone_ (ali `omarchy icons install <git url>`), odstranite pa ga znova pod _Odstrani > Ikone_. _Posodobi > Dodatne ikone_ pridobi najnovejšo različico naborov, ki jih imate nameščene.

Če želite izdelati lastne, postavite svoje ikone v `~/.config/omarchy/icons/<name>/`, eno datoteko na aplikacijo, poimenovano po vrstici `Icon=` v datoteki `.desktop` aplikacije. Datoteka, ki se konča z `.svg`, je prikazana takšna, kot je. Datoteka, ki se konča z `.svg.tpl`, je narisana v barvah teme: napišite `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ali `{{ icon_shadow }}` tja, kamor gre barva. Privzeti nabor v `/usr/share/omarchy/icons/papercraft/` je dobro izhodišče. Dodajte `preview.png`, da svoj nabor prikažete v izbirniku; brez njega Omarchy nariše predogled iz vaših ikon. Če želite spremeniti eno samo ikono privzetega nabora, postavite svojo različico v `~/.config/omarchy/icons/papercraft/`.

### Odklepi

Teme imajo lahko tudi obliko za odklepanje po meri, ki se uporablja za postopek dešifriranja ob zagonu. Eno od teh lahko izberete pod _Videz > Odklep_. Videti so takole:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
