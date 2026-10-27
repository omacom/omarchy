# Codladh an chórais

Cuireann Omarchy fionraí agus geimhriú ar chumas de réir réamhshocraithe, ach má bhíonn fadhbanna agat le ceachtar acu ar do mheaisín, is féidir leat iad a mhúchadh.

Ar mheaisíní NVIDIA GB10, amhail an DGX Spark agus an ASUS Ascent GX10, tá fionraí agus geimhriú múchta, mar atá siad in DGX OS de chuid NVIDIA, mar níl sé léirithe go fóill go n-oibríonn codladh ar an gcrua-earraí sin. Ní bhaineann an scorán fionraí agus socrú an gheimhrithe leo sin. Chun codladh a chur ar ais ar siúl, bain `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` le `sudo rm`; Filleann Fionraí ar an roghchlár ansin, agus is féidir geimhriú a shocrú mar is féidir ar mheaisíní eile. Cuireann rith `sudo omarchy apply hardware --install-user "$USER"` an comhad ar ais.

### Próifílí cumhachta

Ar ríomhaire glúine, cuimhníonn Omarchy ar do phróifíl chumhachta ar leithligh nuair atá sé plugáilte isteach agus nuair atá sé ag rith ar cheallra, agus aistríonn sé idir an dá cheann de réir mar a phlugálann agus a dhíphlugálann tú. As an mbosca, ciallaíonn sé sin feidhmíocht ar AC agus cothrom ar cheallra.

Is féidir leat a fheiceáil cad a thairgeann do mheaisín le `omarchy powerprofiles list`, agus an ceann is mian leat don staid ina bhfuil tú faoi láthair a shocrú le `omarchy powerprofiles set autodetect power-saver`. Chun an staid eile a shocrú gan aon rud a dhíphlugáil, ainmnigh go díreach í: `omarchy powerprofiles set battery power-saver`. Pé rud a roghnaíonn tú, is é a gheobhaidh tú ar ais an chéad uair eile a bheidh tú sa staid sin.

### Scoránaigh fionraí

Scoránaíonn tú fionraí trí `omarchy toggle suspend` a rith ón teirminéal. Ní dhéanann sé sin ach an rogha faoi _Córas_ (nó `Super + Esc`) a thaispeáint/a cheilt, agus ansin is féidir leat a fheiceáil an n-oibríonn sé go comhsheasmhach ar do chóras. Mura n-oibríonn, is féidir leat é a cheilt arís leis an ordú céanna.

### Scoránaigh geimhriú

Socraíonn tú geimhriú trí `omarchy hibernation setup` a rith ón teirminéal. Cruthaíonn geimhriú fothomhas /swap ar do thiomántán tosaithe ar mhéid do leithdháilte RAM fhisiciúil, mar sin déan cinnte go bhfuil neart spáis le spáráil agat. Ar mheaisín 32GB, beidh 32GB+ saor uait i gcónaí don tomhas seo. Éilíonn geimhriú an lódálaí tosaithe réamhshocraithe Limine freisin.

Nuair a bheidh sé socraithe, feicfidh tú an rogha geimhrithe faoi _Córas_ (nó `Super + Esc`), agus ansin is féidir leat a fheiceáil an n-oibríonn sé go comhsheasmhach ar do chóras. Mura n-oibríonn, is féidir leat é a bhaint arís trí `omarchy hibernation remove` a rith.
