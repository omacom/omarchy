# Uirlisí Forbartha

## Eagarthóirí Eile

Tagann Omarchy le Plain mar an eagarthóir réamhshocraithe ar shuiteálacha nua agus [Neovim](https://neovim.io/) réamhshuiteáilte, ach más mian leat rud éigin beagán níos coitianta agus níos aithnidiúla, is féidir leat Roghchlár Omarchy (`Super + Space`) a rith agus na roghanna faoi _Install > Editor_ a fheiceáil. Tá VSCode, Cursor, Zed, Sublime Text, Helix, Vim, agus Emacs liostaithe againn ansin. Mura bhfaigheann tú an rud atá á lorg agat, féach ar _Install > Package_, agus féach an bhfuil sé i bpacáiste Arch (agus mura bhfuil, bain triail as _Install > AUR_ chun an AUR a sheiceáil).

Tá an bunchóip den eagarthóir `vi` ar fáil díreach as an mbosca freisin. Rith `vi filename` chun comhad a chur in eagar sa teirminéal.

Cuirtear meaitseáil téama ar fáil do `VSCode`, `Cursor`, `VSCodium`, agus `Helix`.

Is féidir leat an t-eagarthóir réamhshocraithe ar fud an chórais a shocrú faoi `Setup > Defaults > Editor`.

## Timpeallacht

Tacaíonn Omarchy le han-chuid timpeallachtaí forbartha a shocrú tríd an gcuid _Install > Development_ de Roghchlár Omarchy (`Super + Space`). Gheobhaidh tú _Ruby on Rails_ ann ar ndóigh, ach freisin na trí phríomh-am rite go léir le haghaidh JavaScript (Node.js, Bun, Deno), chomh maith le creataí PHP a bhfuil tóir orthu mar Laravel agus Symfony. Ó, agus tá Go, Rust, Python, Java, Elixir (le Phoenix), .NET, OCaml, Zig, Clojure, agus Scala ann freisin. Is rogha an-leathan é!

Déanann [Mise](https://mise.jdx.dev/) bainistiú ar thromlach na dtimpeallachtaí seo. Is uirlis é a ligeann duit leaganacha éagsúla de theanga ríomhchlárúcháin a shuiteáil agus a rith ar an meaisín céanna. Tá sé cosúil le rbenv nó rvm le haghaidh Ruby nó virtualenv le haghaidh Python, ach oibríonn sé le haghaidh a lán timpeallachtaí éagsúla.

Chun Ruby a shuiteáil, mar shampla, rithfeá `mise use -g ruby`, a shuiteálfaidh Ruby agus a shocróidh mar an réamhshocrú domhanda é araon. Nó, má tá comhad .ruby-version ag do thionscadal, is féidir leat `mise i` a rith i bhfréamh an tionscadail sin.

## Uirlisí CLI réamhshuiteáilte

Cuireann Omarchy uirlisí ar nós `gh`, `uv`, agus an chuid is mó de na [gníomhairí códaithe](17-ai.md) ar fáil trí [suiteáil leisciúil mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). An chéad uair a rithfidh tú ceann acu, suiteálann mise é. Seiceálann gníomhairí códaithe ansin an bhfuil nuashonrú ann sula ritheann siad, uair amháin gach ceithre huaire ar a mhéad; athúsáideann uirlisí eile, ar nós `gh` agus `uv`, an leagan suiteáilte go dtí go ndéanfaidh tú nuashonrú.

Is féidir leat na réamhshocruithe a scrúdú freisin nó iad a shuiteáil roimh ré:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Rith `omarchy update` chun uirlisí suiteáilte a nuashonrú in éineacht leis an gcuid eile de Omarchy. Ní nuashonraíonn an t-ailias `mup` ach uirlisí atá á mbainistiú ag mise. Chun uirlis eile a chur le do chumraíocht féin, úsáid `mise use -g <tool>`.

Suiteálann socrú Python `uv` trí mise freisin. Fágann baint thimpeallacht forbartha Python `uv` ar fáil mar uirlis neamhspleách.

### Do shuiteáil féin a úsáid

Tagann orduithe mise roimh `~/.local/bin` ar `PATH`, mar sin ritear cóip mise fós le huirlis a shuiteáil tú féin, mar shampla le suiteálaí Claude Code nó Cursor féin. Aimsíonn aipeanna a sheoltar ón deasc orduithe mise roimh phacáistí an chórais freisin, mar sin faigheann aip a ritheann `gh` cóip mise fiú má shuiteáil tú `github-cli` le pacman, agus suiteálann mise an chóip sin an chéad uair. Chun do chóip féin a úsáid ina ionad sin, díchumasaigh cóip mise in `~/.config/mise/config.toml`. Mar shampla, má shuiteáil tú Cursor CLI tú féin:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Má tá tábla `[settings]` agat cheana féin, cuir an iontráil leis ansin; leathnaigh liosta `disable_tools` atá ann cheana seachas é a athsholáthar. Bí cinnte go bhfuil do shuiteáil ar `PATH`. Úsáid ainm uirlis mise, a d'fhéadfadh a bheith difriúil lena ordú: soláthraíonn `oh-my-pi` `omp`, mar shampla. Is fearr leis an seoladóir gníomhaire réamhshocraithe freisin Cursor nó Muse arna shuiteáil ag an úsáideoir in `~/.local/bin`.

### Réamhshocruithe a bhaint agus a athchóiriú

Bainann _Remove > Preinstalls_ aipeanna gréasáin, TUIanna agus aipeanna réamhshuiteáilte Omarchy, agus cuireann sé ar mise dearbhuithe uirlisí Omarchy a scipeáil do d'úsáideoir, trí iad a chur le `ignored_config_paths` in `~/.config/mise/miserc.toml`. Tugann _Install > Preinstalls_ ar ais iad agus bainann sé an líne sin arís. Leanann uirlisí a dhearbhaíonn tú féin, i do chumraíocht féin nó in `mise.toml` tionscadail, ag obair ar an dá bhealach. Má roghnaíonn tú gníomhaire réamhshocraithe nó má shocraíonn tú Python tar éis na réamhshuiteálacha a bhaint, cuirtear an uirlis sin le do chumraíocht féin. Ní bhaineann socrú mise ach le d'úsáideoir féin, agus coinníonn úsáideoirí eile a rogha féin; is pacáistí iad na haipeanna, áfach, mar sin athraíonn a mbaint nó a n-athchóiriú iad do gach duine ar an meaisín.

## Docker

Is ar éigean a theastaíonn aon réamhrá faoi [Docker](https://www.docker.com/). Ligeann sé duit coimeádáin iargúlta a rith, agus suiteálann Omarchy gach rud is gá chun é a rith go maith, lena n-áirítear Docker féin agus [Docker Compose](https://docs.docker.com/compose/).

De réir réamhshocraithe *níl* d'úsáideoir sa ghrúpa `docker`. Is é atá sa ghrúpa sin go bunúsach ná root gan phasfhocal — is féidir le haon rud ann `docker run -v /:/host` a rith agus an meaisín a ghabháil — mar sin bheadh script nó spleáchas mailíseach amháin a ritheann mar tú féin ordú amháin ó root murach sin. Mar sin ar an líne ordaithe riteann tú Docker le `sudo` (`sudo docker ps`, `sudo docker compose up`), agus iarrann na huirlisí grafacha a labhraíonn leis an deamhan — an Windows VM — údarú nuair a bhíonn sé de dhíth orthu. Más mian leat áisiúlacht socraithe gan ghrúpa ar ais agus go dtuigeann tú an chomhbhabhtáil, cumasaigh é ó **Setup > Security > Sudoless Docker** (nó rith `omarchy-setup-security-sudoless-docker`), a chuireann leis an ngrúpa `docker` thú tar éis rabhaidh; ansin oibríonn `docker` lom agus an t-ailias `d` gan `sudo` arís.

Is féidir leat na bunachair shonraí choitianta le haghaidh forbartha áitiúla in Docker a shocrú ag úsáid _Install > Development > Docker DB_ i roghchlár Omarchy.

## GitHub CLI

Tá [GitHub CLI](https://cli.github.com/) ar fáil mar `gh` chun oibriú le stórtha, saincheisteanna, agus iarratais tarraingthe ón teirminéal. Rith `gh auth login` chun é a shuiteáil ar an gcéad úsáid agus chun fíordheimhniú a dhéanamh, ansin `gh repo clone org/repo` chun stór a chlónáil. Rith `gh --help` chun a chuid orduithe a fhiosrú.

Le haghaidh comhéadan teirminéil le haghaidh iarratais tarraingthe, rith `ghui`; suiteálann mise é ar an gcéad úsáid freisin. Tá [Lazygit](https://github.com/jesseduffield/lazygit) réamhshuiteáilte chun oibriú le Git féin.
