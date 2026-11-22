# Izstrādes rīki

## Alternatīvi redaktori

Omarchy jaunās instalācijās nāk ar Plain kā noklusējuma redaktoru un iepriekš instalētu [Neovim](https://neovim.io/), bet, ja vēlies ko nedaudz plašāk izplatītu un pazīstamāku, vari palaist Omarchy Menu (`Super + Space`) un apskatīt opcijas sadaļā _Install > Editor_. Tur ir uzskaitīti VSCode, Cursor, Zed, Sublime Text, Helix, Vim un Emacs. Ja neatrodi to, ko meklē, paskaties _Install > Package_ un noskaidro, vai tā nav kādā Arch pakotnē (un, ja nav, pamēģini _Install > AUR_, lai pārbaudītu AUR).

Sākotnējais `vi` redaktors arī ir pieejams jau no kastes. Palaid `vi filename`, lai rediģētu failu terminālī.

Tēmu saskaņošana tiek piedāvāta `VSCode`, `Cursor`, `VSCodium` un `Helix`.

Sistēmas mēroga noklusējuma redaktoru vari iestatīt sadaļā `Setup > Defaults > Editor`.

## Vide

Omarchy atbalsta vesela lēruma izstrādes vižu iestatīšanu, izmantojot Omarchy Menu (`Super + Space`) sadaļu _Install > Development_. Tur, protams, atradīsi _Ruby on Rails_, bet arī visus trīs galvenos JavaScript izpildlaikus (Node.js, Bun, Deno), kā arī populārus PHP ietvarus, piemēram, Laravel un Symfony. Ak, un tur ir arī Go, Rust, Python, Java, Elixir (ar Phoenix), .NET, OCaml, Zig, Clojure un Scala. Tā ir ļoti plaša izvēle!

Lielāko daļu šo vižu pārvalda [Mise](https://mise.jdx.dev/). Tas ir rīks, kas ļauj vienā datorā instalēt un palaist vairākas vienas programmēšanas valodas versijas. Tas ir kā rbenv vai rvm priekš Ruby vai virtualenv priekš Python, bet tas darbojas daudzām dažādām vidēm.

Lai instalētu, teiksim, Ruby, palaid `mise use -g ruby`, kas gan instalēs Ruby, gan iestatīs to kā globālo noklusējumu. Vai arī, ja tavam projektam ir .ruby-version fails, šī projekta saknē vari vienkārši palaist `mise i`.

## Iepriekš instalēti CLI rīki

Omarchy tādus rīkus kā `gh`, `uv` un lielāko daļu [kodēšanas aģentu](17-ai.md) padara pieejamus, izmantojot [mise slinko instalēšanu](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pirmajā reizē, kad kādu no tiem palaid, mise to instalē. Kodēšanas aģenti pēc tam pirms palaišanas pārbauda, vai nav atjauninājuma, ne biežāk kā reizi četrās stundās; citi rīki, piemēram, `gh` un `uv`, atkārtoti izmanto instalēto versiju, līdz tu tos atjaunini.

Vari arī apskatīt noklusējumus vai instalēt tos jau iepriekš:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Palaid `omarchy update`, lai atjauninātu instalētos rīkus kopā ar pārējo Omarchy. Aizstājvārds `mup` atjaunina tikai mise pārvaldītos rīkus. Lai savai konfigurācijai pievienotu citu rīku, izmanto `mise use -g <tool>`.

Python iestatīšana arī instalē `uv`, izmantojot mise. Python izstrādes vides noņemšana atstāj `uv` pieejamu kā neatkarīgu rīku.

### Savas instalācijas izmantošana

mise komandas `PATH` sarakstā atrodas pirms `~/.local/bin`, tāpēc rīkam, ko instalēji pats, piemēram, ar Claude Code vai Cursor paša instalētāju, joprojām tiek palaista mise kopija. Arī no darbvirsmas palaistās lietotnes mise komandas atrod pirms sistēmas pakotnēm, tāpēc lietotne, kas palaiž `gh`, iegūst mise kopiju pat tad, ja `github-cli` instalēji ar pacman, un mise šo kopiju instalē pirmajā reizē. Lai tā vietā izmantotu savējo, atspējo mise kopiju failā `~/.config/mise/config.toml`. Piemēram, ja pats instalēji Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ja tev jau ir `[settings]` tabula, pievieno ierakstu tur; paplašini esošu `disable_tools` sarakstu, nevis aizstāj to. Pārliecinies, ka tava instalācija atrodas `PATH`. Izmanto mise rīka nosaukumu, kas var atšķirties no tā komandas: `oh-my-pi` nodrošina `omp`, piemēram. Noklusējuma aģenta palaišanas rīks arī dod priekšroku lietotāja instalētam Cursor vai Muse mapē `~/.local/bin`.

### Noklusējumu noņemšana un atjaunošana

_Remove > Preinstalls_ noņem Omarchy iepriekš instalētās tīmekļa lietotnes, TUI un lietotnes un liek mise izlaist Omarchy rīku deklarācijas tavam lietotājam, pievienojot tās `ignored_config_paths` failā `~/.config/mise/miserc.toml`. _Install > Preinstalls_ tās atgriež atpakaļ un atkal noņem šo rindu. Rīki, ko deklarē pats savā konfigurācijā vai projekta `mise.toml`, darbojas jebkurā gadījumā. Ja pēc iepriekš instalēto rīku noņemšanas izvēlies noklusējuma aģentu vai iestati Python, šis rīks tiek pievienots tavai konfigurācijai. mise iestatījums attiecas tikai uz tavu lietotāju, un citi lietotāji saglabā savu izvēli; lietotnes tomēr ir pakotnes, tāpēc to noņemšana vai atjaunošana tās maina visiem datora lietotājiem.

## Docker

[Docker](https://www.docker.com/) diez vai vajag kā īpaši iepazīstināt. Tas ļauj palaist izolētus konteinerus, un Omarchy instalē visu, kas nepieciešams, lai to labi palaistu, tostarp pašu Docker un [Docker Compose](https://docs.docker.com/compose/).

Pēc noklusējuma tavs lietotājs *nav* `docker` grupā. Šī grupa faktiski ir root bez paroles — jebkas tajā var palaist `docker run -v /:/host` un pārņemt datoru —, tāpēc viens negants skripts vai atkarība, kas darbojas tavā vārdā, citādi būtu tikai vienas komandas attālumā no root. Tāpēc komandrindā Docker palaid ar `sudo` (`sudo docker ps`, `sudo docker compose up`), un grafiskie rīki, kas sazinās ar dēmonu — Windows VM —, prasa autorizāciju, kad tā ir nepieciešama. Ja vēlies atgūt ērtību, ko sniedz iestatījums bez grupas, un izproti kompromisu, iespējo to sadaļā **Setup > Security > Sudoless Docker** (vai palaid `omarchy-setup-security-sudoless-docker`), kas pēc brīdinājuma pievieno tevi `docker` grupai; pēc tam vienkāršais `docker` un aizstājvārds `d` atkal darbojas bez `sudo`.

Izplatītākās datubāzes lokālajai izstrādei Docker vari iestatīt, Omarchy izvēlnē izmantojot _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ir pieejams kā `gh` darbam ar repozitorijiem, problēmām un izvilkšanas pieprasījumiem no termināļa. Palaid `gh auth login`, lai to instalētu pirmajā lietošanas reizē un autentificētos, pēc tam `gh repo clone org/repo`, lai klonētu repozitoriju. Palaid `gh --help`, lai izpētītu tā komandas.

Lai izvilkšanas pieprasījumiem izmantotu termināļa saskarni, palaid `ghui`; arī to mise instalē pirmajā lietošanas reizē. [Lazygit](https://github.com/jesseduffield/lazygit) ir iepriekš instalēts darbam ar pašu Git.
