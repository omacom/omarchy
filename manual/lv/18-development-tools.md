# Izstrādes rīki

## Alternatīvi redaktori

Omarchy jaunās instalācijās noklusējuma redaktors ir Plain, un [Neovim](https://neovim.io/) ir instalēts jau iepriekš, bet, ja vēlaties ko mazliet ierastāku un pazīstamāku, varat palaist Omarchy Menu (`Super + Space`) un skatīt iespējas sadaļā _Instalēt > Redaktors_. Tur ir norādīti VSCode, Cursor, Zed, Sublime Text, Helix, Vim un Emacs. Ja neatrodat meklēto, ieskatieties _Instalēt > Pakotne_ un pārbaudiet, vai tā nav pieejama kā Arch pakotne (un, ja nav, pamēģiniet _Instalēt > AUR_, lai pārbaudītu AUR).

Oriģinālais `vi` redaktors arī ir pieejams jau no sākuma. Palaidiet `vi filename`, lai terminālī rediģētu failu.

Motīvu saskaņošana tiek piedāvāta `VSCode`, `Cursor`, `VSCodium` un `Helix`.

Sistēmas mēroga noklusējuma redaktoru varat iestatīt sadaļā `Setup > Defaults > Editor`.

## Vide

Omarchy atbalsta veselas virknes izstrādes videņu iestatīšanu, izmantojot Omarchy Menu (`Super + Space`) sadaļu _Instalēt > Izstrāde_. Tur, protams, atradīsiet _Ruby on Rails_, bet arī visus trīs galvenos JavaScript izpildlaikus (Node.js, Bun, Deno), kā arī populārus PHP ietvarus, piemēram, Laravel un Symfony. Ak, un tur ir arī Go, Rust, Python, Java, Elixir (ar Phoenix), .NET, OCaml, Zig, Clojure un Scala. Tā ir ļoti plaša izvēle!

Lielāko daļu šo videņu pārvalda [Mise](https://mise.jdx.dev/). Tas ir rīks, kas ļauj vienā datorā instalēt un palaist vairākas programmēšanas valodas versijas. Tas ir līdzīgs rbenv vai rvm priekš Ruby vai virtualenv priekš Python, bet darbojas daudzām dažādām vidēm.

Lai instalētu, piemēram, Ruby, palaidiet `mise use -g ruby` — tā gan instalēs Ruby, gan iestatīs to kā globālo noklusējumu. Vai arī, ja jūsu projektam ir .ruby-version fails, varat vienkārši palaist `mise i` šī projekta saknes mapē.

## Iepriekš instalēti CLI rīki

`uv`, Node.js un `playwright-cli` (lai aģenti varētu vadīt pārlūku, izmantojot instalēto Chrome) ir instalēti kā pakotnes, un `omarchy update` uztur tos aktuālus kopā ar pārējo sistēmu. [Hunk](https://github.com/modem-dev/hunk) un GitHub, Basecamp, Cloudflare un HEY CLI ir tikai vienas izvēles attālumā sadaļā _Instalēt > CLI_, bet [kodēšanas aģenti](17-ai.md) — sadaļā _Instalēt > AI > CLI_.

Mise pārvalda tikai tos izpildlaikus, kurus iestatāt sadaļā _Instalēt > Izstrāde_; Omarchy pati caur to neko neinstalē. Palaidiet `omarchy update`, lai atjauninātu tos kopā ar pārējo Omarchy; aizstājvārds `mup` atjaunina tikai Mise pārvaldītos rīkus. Lai savai konfigurācijai pievienotu citu rīku, izmantojiet `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) diez vai vajag īpaši iepazīstināt. Tas ļauj palaist izolētus konteinerus, un Omarchy instalē visu, kas nepieciešams, lai to darītu labi, tostarp pašu Docker un [Docker Compose](https://docs.docker.com/compose/).

Pēc noklusējuma jūsu lietotājs *nav* grupā `docker`. Šī grupa faktiski ir root bez paroles — jebkas tajā var palaist `docker run -v /:/host` un pārņemt datoru —, tāpēc viens negants skripts vai atkarība, kas darbojas jūsu vārdā, citādi būtu tikai vienas komandas attālumā no root. Tāpēc komandrindā Docker palaidiet ar `sudo` (`sudo docker ps`, `sudo docker compose up`), un grafiskie rīki, kas sazinās ar dēmonu — Windows VM —, kad tiem tas nepieciešams, prasa autorizāciju. Ja vēlaties atgūt ērtības, ko sniedz iestatījums bez grupas, un saprotat kompromisu, iespējojiet to sadaļā **Iestatīšana > Drošība > Sudoless Docker** (vai palaidiet `omarchy-setup-security-sudoless-docker`), kas pēc brīdinājuma pievienos jūs grupai `docker`; pēc tam parastais `docker` un aizstājvārds `d` atkal darbosies bez `sudo`.

Izplatītākās datubāzes lokālai izstrādei Docker varat iestatīt, izmantojot Omarchy izvēlnes sadaļu _Instalēt > Izstrāde > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ir `gh`, lai no termināļa strādātu ar repozitorijiem, problēmziņojumiem un izmaiņu pieprasījumiem. _Iestatīšana > Git_ to instalē, kad tur izvēlaties pierakstīties GitHub, vai instalējiet to atsevišķi sadaļā _Instalēt > CLI > GitHub_. Pēc tam `gh repo clone org/repo` klonē repozitoriju; palaidiet `gh --help`, lai izpētītu tā komandas.

[Lazygit](https://github.com/jesseduffield/lazygit) ir iepriekš instalēts darbam ar pašu Git.
