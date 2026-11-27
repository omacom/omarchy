# Seatanna córais

Cruthaímid seatanna go huathoibríoch ar gach nuashonrú Omarchy, ach más mian leat do cheann féin a chruthú, is féidir leat `omarchy-snapshot create` a úsáid.

Braitheann an chaoi a dtosnaíonn tú isteach i seat agus a n-athchóiríonn tú seat ar an lódálaí tosaithe a thosaíonn do mheaisín leis. Úsáideann suiteálacha UEFI nua systemd-boot; úsáideann suiteálacha níos sine agus meaisíní BIOS Limine. Insíonn `omarchy-boot-backend` duit cé acu ceann atá agat.

## Le systemd-boot

Roghnaigh _Córas > Seatanna_ sa roghchlár Omarchy agus roghnaigh an seat ar mian leat tosú isteach ann. Atosaíonn an meaisín isteach ann aon uair amháin. Nó coinnigh Space síos agus an meaisín ag tosú chun an roghchlár tosaithe a fheiceáil, áit a bhfuil gach seat liostaithe, an ceann is nuaí ar dtús, lena leagan Omarchy agus a dháta.

Tosnaíonn seat le sraith shealadach ar a bharr, mar sin is féidir leat é a úsáid mar is gnách, ach imíonn aon rud a athraíonn tú ag an gcéad atosaíocht eile. Chun é a choinneáil, déan do chóras de: cliceáil an fógra a thagann aníos nuair a logálann tú isteach, roghnaigh _Córas > Seatanna > Athchóirigh an Seat Seo_, nó rith `omarchy-snapshot restore`. Tarlaíonn an athchóiriú agus an meaisín ag atosú. Fanann an córas mar a bhí sé roimhe sin sa roghchlár tosaithe mar _Roimh an athchóiriú_, agus cuireann `omarchy-snapshot restore backup` ar ais é.

Ón teirminéal:

- liostaíonn `omarchy-snapshot list` na seatanna ar féidir leat tosú isteach iontu;
- atosaíonn `omarchy-snapshot boot 12` isteach i seat 12 aon uair amháin;
- déanann `omarchy-snapshot restore 12` córas de seat 12 ag an gcéad atosaíocht eile, agus athraíonn `omarchy-snapshot restore --cancel` d'intinn roimh an atosaíocht sin.

## Le Limine

Chun seat a thosú agus a athchóiriú, roghnaíonn tú é ó lódálaí tosaithe Limine. Fanann an roghchlár tosaithe i bhfolach de réir réamhshocraithe, mar sin brúigh eochair ar bith chomh luath agus a thosaíonn Limine chun é a thabhairt aníos.

Ón scáileán sin, roghnaigh an seat ar mian leat tosú isteach ann bunaithe ar an dáta agus ar an leagan. Is féidir leagan Omarchy ag am an tseat a fheiceáil sa chúinne íochtarach ar chlé.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Nuair a shroicheann tú istigh, preabfaidh fógra aníos ag cur in iúl duit go bhfuil tú i seat intosaithe agus, má chliceálann tú é, go dtosóidh sé an próiseas athchóirithe. Nó is féidir leat `omarchy-snapshot restore` a úsáid.

 ![snapshots-restore](images/snapshots-restore.webp)

## Cad a chlúdaíonn athchóiriú

Tugann athchóiriú do chóras comhad fréimhe ar ais, ach ní thugann sé do `/home` ar ais. Mar sin oibríonn sé chun nuashonrú córais briste a chealú, ach ní chun comhaid phearsanta caillte a aisghabháil.

Ciallaíonn sé seo freisin go gcoimeádtar do chomhadlann `~/.config` mar atá sí. Mar sin má tá tú ag filleadh ar leagan níos luaithe de leabharlann nó d'fheidhmchlár a stórálann comhaid chumraíochta i bhformáid nua, beidh ort é sin a réiteach de láimh.

Baineann an rud céanna le taifead Omarchy féin ar na himircí atá rite cheana: tá sé i do chomhadlann baile, mar sin maireann sé tríd an athchóiriú. Fanann imircí a ritheadh tar éis an seat a dhéanamh marcáilte mar déanta, cé gur cealaíodh na hathruithe a rinne siad ar an gcóras comhad fréimhe, agus ní rithfidh an chéad `omarchy update` eile arís iad. Mar sin má nuashonraíonn tú arís tar éis athchóirithe agus má tá rud éigin a bhí curtha ar bun ag nuashonrú níos luaithe fós ar iarraidh, is dócha gurb é sin an chúis.
