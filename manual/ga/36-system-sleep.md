# Codladh an chórais

Cumasaíonn Omarchy crochadh de réir réamhshocraithe, agus geimhriú a luaithe a bhíonn sé socraithe, ach má bhíonn fadhbanna agat le ceachtar acu ar do mheaisín, is féidir leat iad a scoránú as.

Ar mheaisíní NVIDIA GB10, amhail an DGX Spark agus an ASUS Ascent GX10, tá crochadh agus geimhriú múchta, mar atá siad in DGX OS de chuid NVIDIA, toisc nár léiríodh go n-oibríonn codladh ar na crua-earraí sin go fóill. Ní bhaineann an scorán crochta ná socrú an gheimhridh ansin. Chun codladh a chur ar ais, bain `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` le `sudo rm`; filleann Crochadh ansin ar an roghchlár, agus is féidir geimhriú a shocrú mar is féidir ar mheaisíní eile. Cuireann rith `sudo omarchy apply hardware --install-user "$USER"` an comhad ar ais.

### Próifílí cumhachta

Ar ríomhaire glúine, coinníonn Omarchy cuimhne ar do phróifíl chumhachta ar leithligh agus é plugáilte isteach agus ag rith ar cheallra, agus aistríonn sé idir an dá cheann de réir mar a phlugálann tú isteach agus a dhíphlugálann tú. As an mbosca ciallaíonn sé sin feidhmíocht ar AC agus cothrom ar cheallra.

Féadfaidh tú a fheiceáil cad a thairgeann do mheaisín le `omarchy powerprofiles list`, agus an ceann atá uait don staid ina bhfuil tú faoi láthair a shocrú le `omarchy powerprofiles set autodetect power-saver`. Chun an staid eile a shocrú gan aon rud a dhíphlugáil, ainmnigh go díreach í: `omarchy powerprofiles set battery power-saver`. Cibé rud a roghnaíonn tú, sin an rud a gheobhaidh tú ar ais an chéad uair eile a bheidh tú sa staid sin.

### Crochadh a scoránú

Scoránaíonn tú crochadh trí `omarchy toggle suspend` a rith ón teirminéal. Ní dhéanann sé sin ach an rogha faoi _System_ (nó `Super + Esc`) a thaispeáint/a cheilt, agus ansin féadfaidh tú a fheiceáil an n-oibríonn sé go seasta ar do chóras. Mura n-oibríonn, féadfaidh tú é a cheilt arís leis an ordú céanna.

### Geimhriú a scoránú

Socraíonn tú geimhriú trí `omarchy hibernation setup` a rith ón teirminéal (níl sé ar fáil ar mhaca Apple Silicon). Cruthaíonn geimhriú fothomhas /swap ar do thiomántán tosaithe ar mhéid do leithdháilte RAM fhisiciúil, mar sin déan cinnte go bhfuil dóthain spáis le spáráil agat. Ar mheaisín 32GB, beidh 32GB+ saor ag teastáil uait i gcónaí don tomhas seo. Éilíonn geimhriú lódálaí tosaithe réamhshocraithe Limine freisin.

Nuair a bheidh sé socraithe, feicfidh tú an rogha geimhridh faoi _System_ (nó `Super + Esc`), agus ansin féadfaidh tú a fheiceáil an n-oibríonn sé go seasta ar do chóras. Mura n-oibríonn, féadfaidh tú é a bhaint arís trí `omarchy hibernation remove` a rith.
