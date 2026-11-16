# Uirlisí Forbartha

## Eagarthóirí Eile

Tagann [Neovim](https://neovim.io/) le Omarchy de réir réamhshocraithe, ach más mian leat rud éigin beagán níos príomhshrutha agus níos eolaí, is féidir leat Roghchlár Omarchy (`Super + Space`) a rith agus na roghanna faoi _Install > Editor_ a fheiceáil. Tá VSCode, Cursor, Zed, Sublime Text, Helix, Vim, agus Emacs liostaithe againn ansin. Mura bhfaighidh tú an rud atá á lorg agat, féach ar _Install > Package_, agus féach an bhfuil sé i bpacáiste Arch (agus mura bhfuil, bain triail as _Install > AUR_ chun an AUR a sheiceáil).

Tá an t-eagarthóir bunaidh `vi` ar fáil as an mbosca freisin. Rith `vi filename` chun comhad a chur in eagar sa teirminéal.

Cuirtear meaitseáil téama ar fáil do `VSCode`, `Cursor`, `VSCodium`, agus `Helix`.

Is féidir leat an t-eagarthóir réamhshocraithe ar fud an chórais a shocrú faoi `Setup > Defaults > Editor`.

## Timpeallacht

Tacaíonn Omarchy le réimse iomlán timpeallachtaí forbartha a shocrú tríd an gcuid _Install > Development_ de Roghchlár Omarchy (`Super + Space`). Gheobhaidh tú _Ruby on Rails_ ar ndóigh, ach freisin na trí phríomhréim ama uile do JavaScript (Node.js, Bun, Deno), chomh maith le creataí PHP a bhfuil tóir orthu ar nós Laravel agus Symfony. Ó, agus tá Go, Rust, Python, Java, Elixir (le Phoenix), .NET, OCaml, Zig, Clojure, agus Scala ann freisin. Is rogha an-leathan é!

Is le [Mise](https://mise.jdx.dev/) a bhainistítear formhór na dtimpeallachtaí seo. Is uirlis é a ligeann duit leaganacha éagsúla de theanga ríomhchlárúcháin a shuiteáil agus a rith ar an meaisín céanna. Tá sé cosúil le rbenv nó rvm do Ruby nó virtualenv do Python, ach oibríonn sé do chuid mhaith timpeallachtaí éagsúla.

Chun Ruby a shuiteáil, mar shampla, rithfeá `mise use -g ruby`, rud a shuiteálfaidh Ruby agus a shocróidh mar an réamhshocrú domhanda é araon. Nó, má tá comhad .ruby-version ag do thionscadal, is féidir leat `mise i` a rith i bhfréamh an tionscadail sin.

## Uirlisí CLI réamhshuiteáilte

Cuireann Omarchy uirlisí ar nós `gh`, `uv`, agus formhór na [n-oibreán códaithe](17-ai.md) ar fáil trí [shuiteáil leisciúil mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). An chéad uair a ritheann tú ceann, suiteálann mise é. Úsáideann rití ina dhiaidh sin an leagan suiteáilte arís; ní sheiceálann siad le haghaidh nuashonraithe ar gach seoladh.

Is féidir leat na réamhshocruithe a scrúdú freisin nó iad a shuiteáil roimh ré:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Rith `omarchy update` chun uirlisí suiteáilte a nuashonrú leis an gcuid eile de Omarchy. Nuashonraíonn an t-ailias `mup` uirlisí faoi bhainistíocht mise amháin. Chun uirlis eile a chur le do chumraíocht féin, úsáid `mise use -g <tool>`.

Suiteálann socrú Python `uv` trí mise freisin. Má bhaintear timpeallacht forbartha Python, fanann `uv` ar fáil mar uirlis neamhspleách.

### Do shuiteáil féin a úsáid

Tagann orduithe mise roimh `~/.local/bin` ar `PATH`, mar sin úsáideann uirlis a shuiteáil tú féin, mar shampla le suiteálaí Claude Code nó Cursor féin, cóip mise fós. Faigheann aipeanna a sheoltar ón deasc orduithe mise roimh phacáistí an chórais freisin, mar sin faigheann aip a ritheann `gh` cóip mise fiú má shuiteáil tú `github-cli` le pacman, agus suiteálann mise an chóip sin an chéad uair. Chun do chóip féin a úsáid ina ionad, díchumasaigh cóip mise i `~/.config/mise/config.toml`. Mar shampla, má shuiteáil tú Cursor CLI tú féin:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Má tá tábla `[settings]` agat cheana, cuir an iontráil leis ansin; leathnaigh liosta `disable_tools` atá ann cheana seachas é a athsholáthar. Bí cinnte go bhfuil do shuiteáil ar `PATH`. Úsáid ainm uirlis mise, ar féidir leis a bheith difriúil lena ordú: soláthraíonn `oh-my-pi` `omp`, mar shampla. Is fearr leis an seoladóir oibreáin réamhshocraithe freisin Cursor nó Muse arna shuiteáil ag an úsáideoir i `~/.local/bin`.

### Réamhshocruithe a bhaint agus a athchóiriú

Fágann _Remove Preinstalls_ go scipeálann mise dearbhuithe uirlisí Omarchy do d'úsáideoir, trí iad a chur le `ignored_config_paths` i `~/.config/mise/miserc.toml`. Baineann _Restore Preinstalls_ an líne sin arís. Leanann uirlisí a dhearbhaíonn tú féin, i do chumraíocht féin nó i `mise.toml` tionscadail, ag obair ar an dá bhealach. Má roghnaíonn tú oibreán réamhshocraithe nó má shocraíonn tú Python tar éis na réamhshuiteálacha a bhaint, cuirtear an uirlis sin le do chumraíocht féin. Ní bhaineann an dá cheann ach le d'úsáideoir; coinníonn úsáideoirí eile ar an meaisín a rogha féin.

## Docker

Ní gá [Docker](https://www.docker.com/) a chur in aithne ar éigean. Ligeann sé duit coimeádáin iargúlta a rith, agus suiteálann Omarchy gach rud is gá chun é a rith go maith, lena n-áirítear Docker féin agus [Docker Compose](https://docs.docker.com/compose/).

De réir réamhshocraithe níl d'úsáideoir sa ghrúpa `docker`. Is root gan phasfhocal an grúpa sin go bunúsach — is féidir le haon rud ann `docker run -v /:/host` a rith agus seilbh a ghlacadh ar an meaisín — mar sin bheadh script nó spleáchas amháin bradach a ritheann mar tusa ordú amháin ó root murach sin. Mar sin ar an líne ordaithe ritheann tú Docker le `sudo` (`sudo docker ps`, `sudo docker compose up`), agus iarrann na huirlisí grafacha a labhraíonn leis an deamhan — an Windows VM — údarú nuair is gá dóibh é. Más mian leat áisiúlacht socrú gan grúpa ar ais agus má thuigeann tú an chomhbhabhtáil, cumasaigh é ó **Setup > Security > Sudoless Docker** (nó rith `omarchy-setup-security-sudoless-docker`), a chuireann leis an ngrúpa `docker` thú tar éis rabhaidh; ansin oibríonn `docker` lom agus an t-ailias `d` gan `sudo` arís.

Is féidir leat na bunachair shonraí choitianta d'fhorbairt áitiúil i Docker a shocrú le _Install > Development > Docker DB_ i roghchlár Omarchy.

## GitHub CLI

Tá [GitHub CLI](https://cli.github.com/) ar fáil mar `gh` chun oibriú le stórtha, saincheisteanna, agus iarratais tarraingthe ón teirminéal. Rith `gh auth login` chun é a shuiteáil ar an gcéad úsáid agus chun fíordheimhniú, ansin `gh repo clone org/repo` chun stór a chlónáil. Rith `gh --help` chun a orduithe a fhiosrú.

Chun comhéadan teirminéil d'iarratais tarraingthe a fháil, rith `ghui`; suiteálann mise é ar an gcéad úsáid freisin. Tá [Lazygit](https://github.com/jesseduffield/lazygit) réamhshuiteáilte chun oibriú le Git féin.
