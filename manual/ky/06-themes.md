# Темалар

Omarchy жыйырма үч кооз тема менен келет. Аларды Omarchy менюсундагы (`Super + Space`) _Көрүнүш > Тема_ бөлүмүнөн тандасаңыз болот, же `Super + Ctrl + T` менен түз эле тема тандагычка өтсөңүз болот.

Ар бир тема иш столун, терминалды, neovim'ди, активдүүлүк экранын (btop), браузериңизди (Chrome, Chromium, Edge же Brave) жана бүт Omarchy кабыгын жасалгалайт: жогорку панелди, менюну, билдирмелерди, OSD'ни жана кулпу экранын. (Obsidian үчүн Omarchy темасын тиркеменин ичиндеги _Appearance > Themes_ бөлүмүнөн өзүңүз тандашыңыз керек).

Ар бир теманын өз фон сүрөттөрү бар, алардын арасынан `Super + Ctrl + W` менен тандай аласыз.

Дагы көп теманы [кошумча темалар барагынан](https://omarchy.org/themes/) таба аласыз, атүгүл [өз темаңызды жасай аласыз](43-making-your-own-theme.md).

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

### Тиркемелердин белгилери

Тиркеме иштеткичтеги жана доктогу белгилер темаңыздын түстөрү менен тартылат, ошондуктан тема алмашканда алар да кошо өзгөрөт. Алар белгилер топтомунан алынат, аны темадан өзүнчө _Көрүнүш > Белгилер_ бөлүмүнөн, ар бир топтомдун алдын ала көрүнүшүн карап, теманы тандагандай эле тандайсыз:

- _Papercraft_ демейки топтом: орнотулуп келген нерселердин баары бир стилде тартылган. Chrome, HEY же YouTube сыяктуу логотиби менен таанылган тиркемелер ошол формасын сактап, теманын түстөрүн алат.
- _Arcade_ ошол эле тиркемелерди эски оюн консолундагыдай 8-биттик пиксель арт кылып тартат.
- _Original_ ар бир тиркемени жасоочусу берген белгиси менен көрсөтөт.

Башка бирөө жасаган белгилер топтомун _Орнотуу > Көрүнүш > Белгилер_ аркылуу (же `omarchy icons install <git url>` менен) орнотуп, кайра _Алып салуу > Белгилер_ бөлүмүнөн алып салсаңыз болот. _Жаңыртуу > Кошумча белгилер_ орнотулган топтомдордун эң акыркы версиясын жүктөп алат.

Өзүңүздүн топтомуңузду жасоо үчүн белгилериңизди `~/.config/omarchy/icons/<name>/` папкасына салыңыз: ар бир тиркемеге бир файл, аты тиркеменин `.desktop` файлындагы `Icon=` сабына ылайык болсун. `.svg` менен аяктаган файл ошол бойдон көрсөтүлөт. `.svg.tpl` менен аяктаган файл теманын түстөрү менен тартылат: түс турушу керек болгон жерге `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` же `{{ icon_shadow }}` деп жазыңыз. `/usr/share/omarchy/icons/papercraft/` ичиндеги демейки топтом баштоо үчүн жакшы үлгү. Топтомуңуз тандагычта көрүнүшү үчүн `preview.png` кошуңуз; ал жок болсо, Omarchy алдын ала көрүнүштү белгилериңизден өзү тартып чыгат. Демейки топтомдун бир эле белгисин алмаштыруу үчүн өз вариантыңызды `~/.config/omarchy/icons/papercraft/` ичине салыңыз.

### Кулпуну ачуу экрандары

Темаларда өзүнчө кулпуну ачуу дизайны да болушу мүмкүн, ал жүктөлүү учурунда дискти чечмелөөдө колдонулат. Алардын бирин _Көрүнүш > Кулпуну ачуу_ бөлүмүнөн тандай аласыз. Алар мындай көрүнөт:

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

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

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

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
