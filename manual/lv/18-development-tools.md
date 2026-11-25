# Izstrādes rīki

## Alternatīvi redaktori

Omarchy jaunās instalācijās kā noklusējuma redaktors ir Plain un [Neovim](https://neovim.io/) ir iepriekš instalēts, bet, ja vēlies ko nedaudz populārāku un pazīstamāku, vari atvērt Omarchy Menu (`Super + Space`) un apskatīt iespējas sadaļā _Install > Editor_. Tur ir uzskaitīti VSCode, Cursor, Zed, Sublime Text, Helix, Vim un Emacs. Ja neatrodi to, ko meklē, ieskaties _Install > Package_ un pārbaudi, vai tā nav kādā Arch pakotnē (un, ja nav, pamēģini _Install > AUR_, lai pārbaudītu AUR).

Arī oriģinālais `vi` redaktors ir pieejams jau no sākuma. Palaid `vi filename`, lai rediģētu failu terminālī.

Tēmu saskaņošana tiek piedāvāta `VSCode`, `Cursor`, `VSCodium` un `Helix`.

Visai sistēmai paredzēto noklusējuma redaktoru vari iestatīt sadaļā `Setup > Defaults > Editor`.

## Vide

Omarchy atbalsta veselas virknes izstrādes vide iestatīšanu, izmantojot Omarchy Menu (`Super + Space`) sadaļu _Install > Development_. Protams, tur atradīsi _Ruby on Rails_, bet arī visas trīs galvenās JavaScript izpildvides (Node.js, Bun, Deno), kā arī populārus PHP ietvarus, piemēram, Laravel un Symfony. Ak, un tur ir arī Go, Rust, Python, Java, Elixir (ar Phoenix), .NET, OCaml, Zig, Clojure un Scala. Izvēle ir ļoti plaša!

Lielāko daļu no šīm vidēm pārvalda [Mise](https://mise.jdx.dev/). Tas ir rīks, kas ļauj vienā datorā instalēt un palaist vairākas programmēšanas valodas versijas. Tas ir līdzīgs rbenv vai rvm priekš Ruby vai virtualenv priekš Python, bet darbojas veselai virknei dažādu vide.

Lai instalētu, piemēram, Ruby, palaid `mise use -g ruby` — tas gan instalēs Ruby, gan iestatīs to kā globālo noklusējumu. Vai, ja tavam projektam ir .ruby-version fails, vari vienkārši palaist `mise i` šī projekta saknes mapē.

## Iepriekš instalēti CLI rīki

`uv`, Node.js un `playwright-cli` (lai aģenti varētu vadīt pārlūku, izmantojot instalēto Chrome) ir instalēti kā pakotnes, un `omarchy update` uztur tos aktuālus kopā ar pārējo sistēmu. `ghui`, [Hunk](https://github.com/modem-dev/hunk) un Basecamp, Cloudflare un HEY CLI ir tikai viena izvēle attālumā sadaļā _Install > CLI_, bet [kodēšanas aģenti](17-ai.md) — sadaļā _Install > AI > CLI_.

mise pārvalda tikai tās izpildvides, kuras iestati sadaļā _Install > Development_; Omarchy pati caur to neko neinstalē. Palaid `omarchy update`, lai atjauninātu tās kopā ar pārējo Omarchy; aizstājvārds `mup` atjaunina tikai mise pārvaldītos rīkus. Lai savai konfigurācijai pievienotu citu rīku, izmanto `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) diez vai vajag īpaši iepazīstināt. Tas ļauj palaist izolētus konteinerus, un Omarchy instalē visu, kas nepieciešams, lai to labi darbinātu, tostarp pašu Docker un [Docker Compose](https://docs.docker.com/compose/).

Pēc noklusējuma tavs lietotājs *nav* grupā `docker`. Šī grupa faktiski ir root bez paroles — jebkas, kas tajā atrodas, var palaist `docker run -v /:/host` un pārņemt datoru — tāpēc viens negodīgs skripts vai atkarība, kas darbojas ar tavu lietotāju, citādi būtu tikai vienas komandas attālumā no root. Tāpēc komandrindā Docker palaid ar `sudo` (`sudo docker ps`, `sudo docker compose up`), bet grafiskie rīki, kas sazinās ar dēmonu — Windows VM —, vajadzības gadījumā prasa autorizāciju. Ja vēlies atgūt ērtības, ko sniedz iestatījums bez grupas, un saproti kompromisu, iespējo to sadaļā **Setup > Security > Sudoless Docker** (vai palaid `omarchy-setup-security-sudoless-docker`), kas pēc brīdinājuma pievienos tevi grupai `docker`; tad parastais `docker` un aizstājvārds `d` atkal darbosies bez `sudo`.

Ierastās datubāzes lokālajai izstrādei Docker vari iestatīt, Omarchy izvēlnē izmantojot _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ir `gh` darbam ar repozitorijiem, problēmziņojumiem un pull requests no termināļa. _Setup > Git_ to instalē, kad tur izvēlies pierakstīties GitHub, pēc tam `gh repo clone org/repo` klonē repozitoriju. Palaid `gh --help`, lai izpētītu tā komandas.

_Install > CLI > GitHub_ instalē GitHub CLI, `gh`, kopā ar `ghui` — termināļa saskarni darbam ar pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) ir iepriekš instalēts darbam ar pašu Git.
