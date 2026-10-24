# Izstrādes rīki

## Alternatīvi redaktori

Omarchy pēc noklusējuma tiek piegādāts ar [Neovim](https://neovim.io/), taču, ja vēlaties ko ierastāku un pazīstamāku no plaša pielietojuma rīkiem, atveriet Omarchy izvēlni (`Super + Space`) un apskatiet iespējas sadaļā _Instalēt > Editor_. Tur sarakstā ir VSCode, Cursor, Zed, Sublime Text, Helix, Vim un Emacs. Ja neatrodat meklēto, ieskatieties sadaļā _Instalēt > Package_ un pārbaudiet, vai vajadzīgais nav pieejams kā Arch pakotne (un, ja nav, mēģiniet _Instalēt > AUR_, lai pārbaudītu AUR).

Oriģinālais `vi` redaktors arī ir pieejams jau uzreiz. Palaidiet `vi filename`, lai rediģētu failu terminālī.

Tēmas saskaņošana tiek piedāvāta redaktoriem `VSCode`, `Cursor`, `VSCodium` un `Helix`.

Sistēmas mēroga noklusējuma redaktoru var iestatīt sadaļā `Iestatīšana > Defaults > Editor`.

## Vide

Omarchy atbalsta vesela lēvenia izstrādes vides iestatīšanu Omarchy izvēlnes (`Super + Space`) sadaļā _Instalēt > Development_. Tur, protams, atradīsiet _Ruby on Rails_, kā arī visas trīs galvenās JavaScript izpildvides (Node.js, Bun, Deno) un populāros PHP ietvarus, piemēram, Laravel un Symfony. Ak jā, ir arī Go, Rust, Python, Java, Elixir (ar Phoenix), .NET, OCaml, Zig, Clojure un Scala. Izvēle ir patiešām plaša!

Lielāko daļu šo vidi pārvalda [Mise](https://mise.jdx.dev/). Tas ir rīks, kas ļauj vienā datorā instalēt un palaist vairākas vienas programmēšanas valodas versijas. Tas ir kā rbenv vai rvm valodai Ruby vai virtualenv valodai Python, tikai darbojas ar veselām daudzām dažādām vidēm.

Piemēram, lai instalētu Ruby, palaidiet `mise use -g ruby`, kas gan instalēs Ruby, gan iestatīs to kā globālo noklusējumu. Vai arī, ja jūsu projektā ir .ruby-version fails, varat projekta saknē vienkārši palaist `mise i`.

## Docker

[Docker](https://www.docker.com/) gandrīz nemaz nav jāiepazīstina. Tas ļauj palaist izolētus konteinerus, un Omarchy instalē visu, kas nepieciešams tā labai darbībai, ieskaitot pašu Docker un [Docker Compose](https://docs.docker.com/compose/).

Pēc noklusējuma jūs *neesat* `docker` grupā. Šī grupa būtībā ir root piekļuve bez paroles — jebkas, kas tajā atrodas, var izpildīt `docker run -v /:/host` un pārņemt datoru, — tāpēc viens vienīgs negodīgs skripts vai atkarīga pakotne, kas darbojas jūsu vārdā, citādi būtu tikai vienas komandas attālumā no root piekļuves. Tāpēc komandrindā Docker jāpalaiž ar `sudo` (`sudo docker ps`, `sudo docker compose up`), bet grafiskie rīki, kas sazinās ar dēmonu, — Windows VM —, kad tas nepieciešams, prasa autorizāciju. Ja vēlaties atgūt iestatījuma bez grupas ērtību un saprotat kompromisu, iespējojiet to sadaļā **Iestatīšana > Security > Sudoless Docker** (vai palaidiet `omarchy-setup-security-sudoless-docker`), kas pēc brīdinājuma pievieno jūs `docker` grupai; tad vienkāršs `docker` un `d` aizstājvārds atkal darbosies bez `sudo`.

Biežākās datubāzes lokālai izstrādei Docker vidē var iestatīt Omarchy izvēlnē sadaļā _Instalēt > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ļauj autentificēties ar savu GitHub kontu un to izmantojot klonēt privātas repozitorijas. Tas ir pieslēgts kā viens no mise aizpildītājiem ar lēnu ielādi, tāpēc pirmoreiz palaižot `gh`, tas instalē sevi pats. Lai autentificētos, palaidiet `gh auth login`. Pēc tam varat izrakstīt privātas repozitorijas ar `gh repo clone org/repo`.

Ar šo komandu var veikt arī veselām daudzām citām GitHub darbībām. Vienkārši palaidiet `gh`, lai redzētu visu iespējamo.

Ir arī lēni instalējams aizpildītājs komandai `ghui`, ar ko pārvaldīt izmaiņu pieprasījumus (pull request) termināļa saskarnē (TUI). Savukārt [lazygit](https://github.com/jesseduffield/lazygit) ir iepriekš instalēts, ja vēlaties arī pašu git vadīt no termināļa saskarnes.
