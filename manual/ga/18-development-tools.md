# Uirlisí Forbartha

## Eagarthóirí Eile

Tagann Plain mar an t-eagarthóir réamhshocraithe le Omarchy ar shuiteálacha nua agus [Neovim](https://neovim.io/) réamhshuiteáilte, ach más mian leat rud éigin beagán níos coitianta agus níos aithnidiúla, is féidir leat Roghchlár Omarchy (`Super + Space`) a rith agus na roghanna a fheiceáil faoi _Suiteáil > Eagarthóir_. Tá VSCode, Cursor, Zed, Sublime Text, Helix, Vim, agus Emacs liostaithe againn ansin. Mura bhfaigheann tú an rud atá á lorg agat, féach _Suiteáil > Pacáiste_, agus féach an bhfuil sé i bpacáiste Arch (agus mura bhfuil, bain triail as _Suiteáil > AUR_ chun an AUR a sheiceáil).

Tá an t-eagarthóir bunaidh `vi` ar fáil díreach as an mbosca freisin. Rith `vi filename` chun comhad a chur in eagar sa teirminéal.

Cuirtear meaitseáil téama ar fáil do `VSCode`, `Cursor`, `VSCodium`, agus `Helix`.

Is féidir leat an t-eagarthóir réamhshocraithe ar fud an chórais a shocrú faoi `Setup > Defaults > Editor`.

## Timpeallacht

Tacaíonn Omarchy le raon iomlán timpeallachtaí forbartha a shocrú tríd an gcuid _Suiteáil > Forbairt_ de Roghchlár Omarchy (`Super + Space`). Gheobhaidh tú _Ruby on Rails_ ann ar ndóigh, ach gheobhaidh tú na trí phríomh-am rite do JavaScript freisin (Node.js, Bun, Deno), chomh maith le creataí PHP a bhfuil tóir orthu mar Laravel agus Symfony. Ó, agus tá Go, Rust, Python, Java, Elixir (le Phoenix), .NET, OCaml, Zig, Clojure, agus Scala ann freisin. Is rogha an-leathan é!

Déantar formhór na dtimpeallachtaí seo a bhainistiú le [Mise](https://mise.jdx.dev/). Is uirlis í a ligeann duit leaganacha éagsúla de theanga ríomhchlárúcháin a shuiteáil agus a rith ar an meaisín céanna. Tá sé cosúil le rbenv nó rvm do Ruby nó virtualenv do Python, ach oibríonn sé do chuid mhaith timpeallachtaí éagsúla.

Chun, abair, Ruby a shuiteáil, rithfeá `mise use -g ruby`, a shuiteálfaidh Ruby agus a shocróidh é mar an réamhshocrú domhanda araon. Nó, má tá comhad .ruby-version ag do thionscadal, is féidir leat `mise i` a rith i bhfréamh an tionscadail sin.

## Uirlisí CLI réamhshuiteáilte

Tagann `uv`, Node.js, agus `playwright-cli` (chun go stiúrfaidh gníomhairí brabhsálaí, ag úsáid an Chrome atá suiteáilte) suiteáilte mar phacáistí, agus coinníonn `omarchy update` cothrom le dáta iad leis an gcuid eile den chóras. Tá `ghui`, [Hunk](https://github.com/modem-dev/hunk), agus CLI-anna Basecamp, Cloudflare agus HEY rogha amháin ar shiúl faoi _Suiteáil > CLI_, agus [gníomhairí códaithe](17-ai.md) faoi _Suiteáil > AI > CLI_.

Ní bhainistíonn mise ach na hamanna rite a shocraíonn tú ó _Suiteáil > Forbairt_; ní shuiteálann Omarchy aon rud tríd leis féin. Rith `omarchy update` chun iad a nuashonrú leis an gcuid eile de Omarchy; ní nuashonraíonn an t-ailias `mup` ach uirlisí atá á mbainistiú ag mise. Chun uirlis eile a chur le do chumraíocht féin, úsáid `mise use -g <tool>`.

## Docker

Ní gá [Docker](https://www.docker.com/) a chur in aithne ar éigean. Ligeann sé duit coimeádáin aonraithe a rith, agus suiteálann Omarchy gach rud atá ag teastáil chun é a rith go maith, Docker féin agus [Docker Compose](https://docs.docker.com/compose/) san áireamh.

De réir réamhshocraithe, *níl* d'úsáideoir sa ghrúpa `docker`. Is root gan phasfhocal an grúpa sin go bunúsach — is féidir le haon rud ann `docker run -v /:/host` a rith agus an meaisín a ghabháil — mar sin bheadh script nó spleáchas bradach amháin a ritheann mar tú féin ordú amháin ar shiúl ó root murach sin. Mar sin ar an líne ordaithe ritheann tú Docker le `sudo` (`sudo docker ps`, `sudo docker compose up`), agus iarrann na huirlisí grafacha a labhraíonn leis an deamhan — an Windows VM — údarú nuair a bhíonn sé ag teastáil uathu. Más mian leat áisiúlacht socraithe gan grúpa ar ais agus má thuigeann tú an chomhbhabhtáil, cumasaigh é ó **Socrú > Slándáil > Sudoless Docker** (nó rith `omarchy-setup-security-sudoless-docker`), a chuireann thú leis an ngrúpa `docker` tar éis rabhaidh; ansin oibríonn `docker` lom agus an t-ailias `d` gan `sudo` arís.

Is féidir leat na bunachair shonraí choitianta d'fhorbairt áitiúil in Docker a shocrú ag úsáid _Suiteáil > Forbairt > Docker DB_ i roghchlár Omarchy.

## GitHub CLI

Is é [GitHub CLI](https://cli.github.com/) ná `gh`, chun oibriú le stórtha, saincheisteanna, agus iarratais tarraingthe ón teirminéal. Suiteálann _Socrú > Git_ é nuair a roghnaíonn tú síniú isteach ar GitHub ansin, ansin clónálann `gh repo clone org/repo` stór. Rith `gh --help` chun a chuid orduithe a fhiosrú.

Suiteálann _Suiteáil > CLI > GitHub_ an GitHub CLI, `gh`, in éineacht le `ghui`, comhéadan teirminéil d'iarratais tarraingthe. Tá [Lazygit](https://github.com/jesseduffield/lazygit) réamhshuiteáilte chun oibriú le Git féin.
