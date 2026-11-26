# Uirlisí Forbartha

## Eagarthóirí Eile

Tagann Omarchy le Plain mar an t-eagarthóir réamhshocraithe ar shuiteálacha nua agus le [Neovim](https://neovim.io/) réamhshuiteáilte, ach más mian leat rud éigin beagán níos príomhshrutha agus níos aithnidiúla, is féidir leat Roghchlár Omarchy (`Super + Space`) a rith agus na roghanna faoi _Suiteáil > Eagarthóir_ a fheiceáil. Tá VSCode, Cursor, Zed, Sublime Text, Helix, Vim, agus Emacs liostaithe againn ansin. Mura bhfaigheann tú an rud atá á lorg agat, féach ar _Suiteáil > Pacáiste_, agus féach nach bhfuil sé i bpacáiste Arch (agus mura bhfuil, bain triail as _Suiteáil > AUR_ chun an AUR a sheiceáil).

Tá an t-eagarthóir bunaidh `vi` ar fáil díreach as an mbosca freisin. Rith `vi filename` chun comhad a chur in eagar sa teirminéal.

Cuirtear meaitseáil téama ar fáil do `VSCode`, `Cursor`, `VSCodium`, agus `Helix`.

Is féidir leat an t-eagarthóir réamhshocraithe ar fud an chórais a shocrú faoi `Setup > Defaults > Editor`.

## Timpeallacht

Tacaíonn Omarchy le raon leathan timpeallachtaí forbartha a shocrú tríd an rannóg _Suiteáil > Forbairt_ de Roghchlár Omarchy (`Super + Space`). Gheobhaidh tú _Ruby on Rails_ ann ar ndóigh, ach gheobhaidh tú freisin na trí phríomh-amanna rite le haghaidh JavaScript (Node.js, Bun, Deno), chomh maith le creataí PHP a bhfuil tóir orthu ar nós Laravel agus Symfony. Ó, agus tá Go, Rust, Python, Java, Elixir (le Phoenix), .NET, OCaml, Zig, Clojure, agus Scala ann freisin. Is rogha an-leathan é!

Is trí [Mise](https://mise.jdx.dev/) a bhainistítear formhór na dtimpeallachtaí seo. Is uirlis é a ligeann duit leaganacha éagsúla de theanga ríomhchlárúcháin a shuiteáil agus a rith ar an meaisín céanna. Tá sé cosúil le rbenv nó rvm do Ruby nó virtualenv do Python, ach oibríonn sé le roinnt mhaith timpeallachtaí éagsúla.

Chun Ruby, abair, a shuiteáil, rithfeá `mise use -g ruby`, rud a shuiteálfaidh Ruby agus a shocróidh mar an réamhshocrú domhanda é freisin. Nó, má tá comhad .ruby-version ag do thionscadal, is féidir leat `mise i` a rith i bhfréamh an tionscadail sin.

## Uirlisí CLI réamhshuiteáilte

Tagann `uv`, Node.js, agus `playwright-cli` (le go bhféadfaidh gníomhairí brabhsálaí a thiomáint, agus an Chrome atá suiteáilte á úsáid acu) suiteáilte mar phacáistí, agus coinníonn `omarchy update` cothrom le dáta iad in éineacht leis an gcuid eile den chóras. Níl [Hunk](https://github.com/modem-dev/hunk) agus na CLInna GitHub, Basecamp, Cloudflare agus HEY ach rogha ar shiúl faoi _Suiteáil > CLI_, agus [gníomhairí códaithe](17-ai.md) faoi _Suiteáil > AI > CLI_.

Ní bhainistíonn mise ach na hamanna rite a shocraíonn tú ó _Suiteáil > Forbairt_; ní shuiteálann Omarchy aon rud tríd leis féin. Rith `omarchy update` chun iad a nuashonrú in éineacht leis an gcuid eile de Omarchy; ní nuashonraíonn an t-ailias `mup` ach uirlisí arna mbainistiú ag mise. Chun uirlis eile a chur le do chumraíocht féin, úsáid `mise use -g <tool>`.

## Docker

Níl aon ghá [Docker](https://www.docker.com/) a chur i láthair ar éigean. Ligeann sé duit coimeádáin iargúlta a rith, agus suiteálann Omarchy gach rud atá ag teastáil chun é a rith go maith, lena n-áirítear Docker féin agus [Docker Compose](https://docs.docker.com/compose/).

De réir réamhshocraithe *níl* d'úsáideoir sa ghrúpa `docker`. Is éard atá sa ghrúpa sin, i ndáiríre, ná root gan focal faire — is féidir le haon rud atá ann `docker run -v /:/host` a rith agus smacht a ghlacadh ar an meaisín — mar sin, d'fhéadfadh script nó spleáchas mailíseach amháin a bheadh ag rith mar thú a bheith ach ordú amháin ó root murach sin. Mar sin, ar líne na n-orduithe ritheann tú Docker le `sudo` (`sudo docker ps`, `sudo docker compose up`), agus iarrann na huirlisí grafacha a labhraíonn leis an deamhán — an VM Windows — údarú nuair a bhíonn sé ag teastáil uathu. Más mian leat áisiúlacht na socrúcháin gan grúpa ar ais agus go dtuigeann tú an chomhbhabhtáil, cumasaigh é ó **Socrú > Slándáil > Docker Gan Sudo** (nó rith `omarchy-setup-security-sudoless-docker`), rud a chuireann leis an ngrúpa `docker` thú tar éis rabhaidh; ansin oibríonn `docker` lom agus an t-ailias `d` gan `sudo` arís.

Is féidir leat na bunachair sonraí choitianta le haghaidh forbartha áitiúla a shocrú in Docker ag úsáid _Suiteáil > Forbairt > Docker DB_ i roghchlár Omarchy.

## GitHub CLI

Is é [GitHub CLI](https://cli.github.com/) ná `gh`, chun oibriú le stórtha, saincheisteanna, agus iarratais tarraingthe ón teirminéal. Suiteálann _Socrú > Git_ é nuair a roghnaíonn tú síniú isteach i GitHub ansin, nó suiteáil leat féin é ó _Suiteáil > CLI > GitHub_. Ansin déanann `gh repo clone org/repo` stór a chlónáil; rith `gh --help` chun a chuid orduithe a fhiosrú.

Tá [Lazygit](https://github.com/jesseduffield/lazygit) réamhshuiteáilte chun oibriú le Git féin.
