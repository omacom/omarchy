# Seatanna córais

Cruthaímid seatanna go huathoibríoch le gach nuashonrú Omarchy, ach más mian leat do cheann féin a chruthú, is féidir leat `omarchy-snapshot create` a úsáid.

Chun seatán a thosú agus a athchóiriú, roghnaíonn tú é ón lódálaí tosaithe Limine. Fanann an roghchlár tosaithe i bhfolach de réir réamhshocraithe, mar sin brúigh aon eochair chomh luath agus a thosaíonn Limine chun é a thabhairt aníos.

Ón scáileán sin, roghnaigh an seatán ar mhaith leat tosú isteach ann bunaithe ar an dáta agus ar an leagan. Is féidir leagan Omarchy ag am an tseatáin a fheiceáil sa chúinne íochtair ar chlé.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Nuair a shroicheann tú an taobh istigh, preabfaidh fógra aníos ag cur in iúl duit go bhfuil tú i seatán intosaithe agus, má chliceálann tú air, cuirfidh sé tús leis an bpróiseas athchóirithe. Nó is féidir leat `omarchy-snapshot restore` a úsáid.

 ![snapshots-restore](images/snapshots-restore.webp)

Déanfaidh sé seo do chóras comhad fréimhe a athchóiriú, ach ní dhéanfaidh sé do `/home`. Mar sin oibríonn sé chun nuashonrú córais briste a chur ar ais, ach ní chun comhaid phearsanta caillte a aisghabháil.

Ciallaíonn sé seo freisin go gcoinnítear d’eolaire `~/.config` mar atá sé. Mar sin má tá tú ag rolladh ar ais go leagan níos luaithe de leabharlann nó d’fheidhmchlár a stórálann comhaid chumraíochta i bhformáid nua, beidh ort é sin a réiteach de láimh.

Baineann an rud céanna le taifead Omarchy féin ar na himircí atá rite cheana féin: tá sé i d’eolaire baile, mar sin maireann sé tríd an athchóiriú. Fanann himircí a ritheadh tar éis don seatán a bheith tógtha marcáilte mar déanta, cé go bhfuil na hathruithe a rinne siad ar an gcóras comhad fréimhe rollta ar ais, agus ní rithfidh an chéad `omarchy update` eile arís iad. Mar sin má dhéanann tú nuashonrú arís tar éis athchóirithe agus má tá rud éigin a bhí socraithe ag nuashonrú níos luaithe fós ar iarraidh, is é sin an chúis is dóichí.

_Nóta: Níl an ghné seo ar fáil ach ar shuiteálacha a úsáideann an lódálaí tosaithe Limine, a bhí mar an réamhshocrú ó Omarchy 2.0. Níl sé ar fáil má tá tú ar GRUB nó systemd-boot._
