# Uirlisí Forbartha

## Eagarthóirí Eile

Tagann Omarchy le [Neovim](https://neovim.io/) de réir réamhshocraithe, ach más mian leat rud éigin níos coitianta agus níos familiar, is féidir leat an Roghchlár Omarchy (`Super + Space`) a rith agus na roghanna a fheiceáil faoi _Suiteáil > Eagarthóir_. Tá VSCode, Cursor, Zed, Sublime Text, Helix, Vim, agus Emacs ar an liosta ansin. Mura bhfaighidh tú an rud atá á lorg agat, téigh chuig _Suiteáil > Pacáiste_, agus féach an bhfuil sé ar fáil i bpacáiste Arch (agus mura bhfuil, bain triail as _Suiteáil > AUR_ chun an AUR a sheiceáil).

Tá an t-eagarthóir bhunaidh `vi` ar fáil as an mbunús freisin. Rith `vi filename` chun comhad a chur in eagar sa teirminéal.

Cuirtear meaitseáil téama ar fáil do `VSCode`, `Cursor`, `VSCodium`, agus `Helix`.

Is féidir leat an t-eagarthóir réamhshocraithe ar fud an chórais a shocrú faoi `Socrú > Réamhshocruithe > Eagarthóir`.

## Timpeallacht

Tacaíonn Omarchy le réimse iomlán timpeallachtaí forbartha a chur ar bun tríd an roinn _Suiteáil > Forbairt_ sa Roghchlár Omarchy (`Super + Space`). Gheobhaidh tú _Ruby on Rails_ ar ndóigh, ach freisin na trí phríomh-am rith don JavaScript (Node.js, Bun, Deno), chomh maith le creatlacha PHP coitianta mar Laravel agus Symfony. Ó, agus tá Go, Rust, Python, Java, Elixir (le Phoenix), .NET, OCaml, Zig, Clojure, agus Scala ann freisin. Is rogha an-leathan é!

Déanann [Mise](https://mise.jdx.dev/) bainistiú ar bhformhór na dtimpeallachtaí seo. Is uirlis é a ligeann duit leaganacha éagsúla de theanga ríomhchlárúcháin a shuiteáil agus a rith ar an meaisín céanna. Tá sé cosúil le rbenv nó rvm do Ruby nó virtualenv do Python, ach oibríonn sé do go leor timpeallachtaí éagsúla.

Chun Ruby, abair, a shuiteáil, rithfeá `mise use -g ruby`, rud a shuiteálfaidh Ruby agus a shocróidh é mar an réamhshocrú domhanda. Nó, má tá comhad .ruby-version ag do thionscadal, is féidir leat `mise i` a rith i bhfréamh an tionscadail sin.

## Docker

Ní gá mórán réamhrá a thabhairt do [Docker](https://www.docker.com/). Ligeann sé duit coimeádáin scoite a rith, agus suiteálann Omarchy gach rud atá ag teastáil chun é a rith go maith, lena n-áirítear Docker féin agus [Docker Compose](https://docs.docker.com/compose/).

De réir réamhshocraithe *níl* d'úsáideoir sa ghrúpa `docker`. Is éard atá sa ghrúpa sin go héifeachtach ná root gan pasfhocal — is féidir le haon rud ann `docker run -v /:/host` a rith agus an meaisín a ghabháil — mar sin bheadh script amháin nó spleáchas amháin ag rith mar tusa aon ordú amháin ar shiúl ó root murach sin. Mar sin ar an líne ordaithe rithann tú Docker le `sudo` (`sudo docker ps`, `sudo docker compose up`), agus iarrann na huirlisí grafacha a labhraíonn leis an deamhan — an Windows VM — údarú nuair a theastaíonn sé uathu. Más mian leat áisiúlacht socrú gan ghrúpa ar ais agus go dtuigeann tú an comhbhabhtáil, cumasaigh é ó **Socrú > Slándáil > Docker Gan Sudo** (nó rith `omarchy-setup-security-sudoless-docker`), rud a chuirfidh tú leis an ngrupa `docker` tar éis rabhaidh; ansin oibríonn `docker` simplí agus an ailias `d` gan `sudo` arís.

Is féidir leat na bunachair shonraí choitianta le haghaidh forbartha áitiúil a chumrú i Docker trí _Suiteáil > Forbairt > Docker DB_ sa roghchlár Omarchy a úsáid.

## GitHub CLI

Ligeann [GitHub CLI](https://cli.github.com/) duit fíordheimhniú le do chuntas GitHub agus stórais phríobháideacha a chlônáil leis. Tá sé ceangailte suas mar cheann de na stubs lódála leisciúil mise, mar sin an chéad uair a rithann tú `gh`, suiteálann sé é féin. Chun fíordheimhniú, rith `gh auth login`. Ansin is féidir leat stórais phríobháideacha a sheiceáil amach trí `gh repo clone org/repo` a úsáid.

Is féidir leat a lán oibríochtaí GitHub eile a dhéanamh leis an ordú seo freisin. Rith `gh` chun gach rud is féidir a fheiceáil.

Tá stub suiteála leisciúil ann freisin do `ghui` chun do iarratais tarraingthe a bhainistiú i TUI. Agus tá [lazygit](https://github.com/jesseduffield/lazygit) réamhshuiteáilte, más mian leat git féin a thiomáint ó TUI freisin.
