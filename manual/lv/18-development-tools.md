# Izstrādes rīki

## Alternatīvi redaktori

Omarchy pēc noklusējuma nāk ar [Neovim](https://neovim.io/), bet, ja vēlies kaut ko nedaudz plašāk izplatītu un pazīstamāku, vari atvērt Omarchy Menu (`Super + Space`) un apskatīt opcijas sadaļā _Install > Editor_. Tur uzskaitīti VSCode, Cursor, Zed, Sublime Text, Helix, Vim un Emacs. Ja neatrod meklēto, ieskaties _Install > Package_ un pārbaudi, vai tā nav Arch pakotnē (un, ja nav, pamēģini _Install > AUR_, lai pārbaudītu AUR).

Oriģinālais `vi` redaktors arī ir pieejams jau no kastes. Palaid `vi filename`, lai rediģētu failu terminālī.

Tēmu saskaņošana tiek piedāvāta `VSCode`, `Cursor`, `VSCodium` un `Helix`.

Sistēmas mēroga noklusējuma redaktoru vari iestatīt sadaļā `Setup > Defaults > Editor`.

## Vide

Omarchy atbalsta vesela lēruma izstrādes vižu iestatīšanu Omarchy Menu (`Super + Space`) sadaļā _Install > Development_. Tur, protams, atradīsi _Ruby on Rails_, bet arī visus trīs galvenos JavaScript izpildlaikus (Node.js, Bun, Deno), kā arī populārus PHP ietvarus, piemēram, Laravel un Symfony. Ak, un tur ir arī Go, Rust, Python, Java, Elixir (ar Phoenix), .NET, OCaml, Zig, Clojure un Scala. Tā ir ļoti plaša izvēle!

Lielāko daļu šo vižu pārvalda [Mise](https://mise.jdx.dev/). Tas ir rīks, kas ļauj vienā iekārtā instalēt un palaist vairākas programmēšanas valodas versijas. Tas ir kā rbenv vai rvm priekš Ruby vai virtualenv priekš Python, bet darbojas daudzām dažādām vidēm.

Lai instalētu, piemēram, Ruby, palaid `mise use -g ruby`, kas gan instalēs Ruby, gan iestatīs to kā globālo noklusējumu. Vai arī, ja tavam projektam ir .ruby-version fails, šī projekta saknē vari vienkārši palaist `mise i`.

## Iepriekš instalēti CLI rīki

Omarchy rīkus, piemēram, `gh`, `uv` un lielāko daļu [kodēšanas aģentu](17-ai.md), padara pieejamus, izmantojot [mise slinko instalēšanu](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pirmajā palaišanas reizē mise to instalē. Turpmākajās palaišanas reizēs tiek izmantota instalētā versija; tā nepārbauda atjauninājumu katrā palaišanas reizē.

Vari arī pārbaudīt noklusējumus vai instalēt tos iepriekš:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Palaid `omarchy update`, lai atjauninātu instalētos rīkus kopā ar pārējo Omarchy. Aizstājvārds `mup` atjaunina tikai mise pārvaldītos rīkus. Lai savai konfigurācijai pievienotu citu rīku, izmanto `mise use -g <tool>`.

Python iestatīšana arī instalē `uv`, izmantojot mise. Python izstrādes vides noņemšana atstāj `uv` pieejamu kā neatkarīgu rīku.

### Savas instalācijas izmantošana

mise komandas `PATH` sarakstā ir pirms `~/.local/bin`, tāpēc rīks, ko instalēji pats, piemēram, ar Claude Code vai Cursor paša instalētāju, joprojām palaiž mise kopiju. Arī no darbvirsmas palaistās lietotnes mise komandas atrod pirms sistēmas pakotnēm, tāpēc lietotne, kas palaiž `gh`, saņem mise kopiju pat tad, ja `github-cli` instalēji ar pacman, un mise šo kopiju instalē pirmajā reizē. Lai tā vietā izmantotu savējo, atspējo mise kopiju failā `~/.config/mise/config.toml`. Piemēram, ja pats instalēji Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ja tev jau ir `[settings]` tabula, pievieno ierakstu tur; paplašini esošo `disable_tools` sarakstu, nevis aizstāj to. Pārliecinies, ka tava instalācija ir `PATH`. Izmanto mise rīka nosaukumu, kas var atšķirties no tā komandas: piemēram, `oh-my-pi` nodrošina `omp`. Noklusējuma aģenta palaišanas rīks arī dod priekšroku lietotāja instalētam Cursor vai Muse mapē `~/.local/bin`.

### Noklusējumu noņemšana un atjaunošana

_Remove Preinstalls_ liek mise izlaist Omarchy rīku deklarācijas tavam lietotājam, pievienojot tās `ignored_config_paths` failā `~/.config/mise/miserc.toml`. _Restore Preinstalls_ šo rindu atkal noņem. Rīki, ko deklarē tu pats savā konfigurācijā vai projekta `mise.toml`, turpina darboties jebkurā gadījumā. Ja pēc iepriekš instalēto rīku noņemšanas izvēlēsies noklusējuma aģentu vai iestatīsi Python, šis rīks tiks pievienots tavai konfigurācijai. Abas iespējas attiecas tikai uz tavu lietotāju; citi lietotāji šajā iekārtā saglabā savu izvēli.

## Docker

[Docker](https://www.docker.com/) diez vai vajag īpaši iepazīstināt. Tas ļauj palaist izolētus konteinerus, un Omarchy instalē visu, kas vajadzīgs tā labai darbībai, tostarp pašu Docker un [Docker Compose](https://docs.docker.com/compose/).

Pēc noklusējuma tavs lietotājs *nav* `docker` grupā. Šī grupa faktiski ir root bez paroles — jebkas tajā var palaist `docker run -v /:/host` un pārņemt iekārtu —, tāpēc viens negodīgs skripts vai atkarība, kas darbojas ar tavām tiesībām, citādi būtu tikai vienas komandas attālumā no root. Tāpēc komandrindā Docker palaiž ar `sudo` (`sudo docker ps`, `sudo docker compose up`), bet grafiskie rīki, kas sazinās ar dēmonu — Windows VM —, vajadzības gadījumā prasa autorizāciju. Ja vēlies atgūt ērtības bez grupas un saproti kompromisu, iespējo to sadaļā **Setup > Security > Sudoless Docker** (vai palaid `omarchy-setup-security-sudoless-docker`), kas pēc brīdinājuma pievienos tevi `docker` grupai; tad parastais `docker` un aizstājvārds `d` atkal darbosies bez `sudo`.

Parastās datubāzes lokālajai izstrādei Docker vari iestatīt Omarchy izvēlnē, izmantojot _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ir pieejams kā `gh` darbam ar repozitorijiem, problēmām un izvilkšanas pieprasījumiem no termināļa. Palaid `gh auth login`, lai pirmajā lietošanas reizē to instalētu un autentificētos, pēc tam `gh repo clone org/repo`, lai klonētu repozitoriju. Palaid `gh --help`, lai izpētītu tā komandas.

Termināļa saskarnei izvilkšanas pieprasījumiem palaid `ghui`; mise to arī instalē pirmajā lietošanas reizē. [Lazygit](https://github.com/jesseduffield/lazygit) ir iepriekš instalēts darbam ar pašu Git.
