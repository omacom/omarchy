.pragma library

// What people actually say to each other at this hour, where this clock is
// pointing.
//
// The point of the panel is that 8pm is a different social object in Tokyo
// than it is at home, and a number cannot say that. "18:40" is the same
// symbol everywhere; "konbanwa" is the evening itself.
//
// Baked, never fetched. Greetings do not change and a network round trip for
// a hover would be absurd - and the panel's rule is that nothing here needs
// the network to draw.
//
// GENERATED IN PART. The language tables and the country map below are hand
// written; the zone-to-country map is derived from the system's own
// `zone.tab`, with the aliases (`Asia/Calcutta`, `US/Pacific`, and 178 more)
// resolved by matching their compiled zoneinfo against a canonical zone's.
// The picker offers every zone `timedatectl list-timezones` returns, which is
// where the first version of this file went wrong: it covered the 74 cities in
// `cities.json` and quietly greeted the other 500-odd zones in English. Tel
// Aviv said "Good morning".
//
// Three levels, because a flat zone-to-language map of 600 entries explains
// nothing: a zone belongs to a country, a country is greeted in a language,
// and a handful of cities override the country because being right about the
// country would be wrong about the city.
//
// Two things this deliberately does not do:
//
// - It does not pick a language from a country's official list. It picks the
//   one you would actually hear said out loud there, which is why Brussels is
//   French, Dublin is Irish, Hong Kong is Cantonese, Singapore is Malay and
//   Paraguay is Guarani. Where a colonial language really is the everyday one,
//   it says so rather than reaching for something more picturesque.
// - It does not invent an hourly split where the language has none. Burmese
//   greets you with mingalaba at any hour, Tongan with malo e lelei; those
//   tables are one band long on purpose, and a short table is information
//   about the language rather than a gap in the data.
//
// Bands run in local hours, ascending, and the first always starts at 0. The
// boundaries are where the language moves, not where a clock does: Spanish in
// Madrid holds "buenas tardes" until 21:00 while Spanish in Lima gives it up
// at 19:00, and that difference is the most interesting thing in this file.
//
// `roman` is a pronunciation, given only where the script is not Latin. It is
// not a translation and it is not a fallback for a missing font - it is there
// so the greeting can be said aloud, which is the only thing a greeting is
// for.


var LANGUAGES = {
  en: { name: "English", bands: [
    { from: 0, text: "Good night", roman: "" },
    { from: 5, text: "Good morning", roman: "" },
    { from: 12, text: "Good afternoon", roman: "" },
    { from: 18, text: "Good evening", roman: "" }
  ] },
  enAU: { name: "Australian English", bands: [
    { from: 0, text: "Night", roman: "" },
    { from: 5, text: "Morning", roman: "" },
    { from: 12, text: "G'day", roman: "" },
    { from: 18, text: "Evening", roman: "" }
  ] },
  ga: { name: "Irish", bands: [
    { from: 0, text: "O\u00edche mhaith", roman: "" },
    { from: 6, text: "Maidin mhaith", roman: "" },
    { from: 12, text: "Tr\u00e1thn\u00f3na maith", roman: "" },
    { from: 19, text: "O\u00edche mhaith", roman: "" }
  ] },
  es: { name: "Spanish", bands: [
    { from: 0, text: "Buenas noches", roman: "" },
    { from: 6, text: "Buenos d\u00edas", roman: "" },
    { from: 12, text: "Buenas tardes", roman: "" },
    { from: 19, text: "Buenas noches", roman: "" }
  ] },
  esES: { name: "Spanish (Spain)", bands: [
    { from: 0, text: "Buenas noches", roman: "" },
    { from: 6, text: "Buenos d\u00edas", roman: "" },
    { from: 14, text: "Buenas tardes", roman: "" },
    { from: 21, text: "Buenas noches", roman: "" }
  ] },
  ca: { name: "Catalan", bands: [
    { from: 0, text: "Bona nit", roman: "" },
    { from: 6, text: "Bon dia", roman: "" },
    { from: 13, text: "Bona tarda", roman: "" },
    { from: 20, text: "Bona nit", roman: "" }
  ] },
  pt: { name: "Portuguese", bands: [
    { from: 0, text: "Boa noite", roman: "" },
    { from: 6, text: "Bom dia", roman: "" },
    { from: 12, text: "Boa tarde", roman: "" },
    { from: 20, text: "Boa noite", roman: "" }
  ] },
  fr: { name: "French", bands: [
    { from: 0, text: "Bonne nuit", roman: "" },
    { from: 6, text: "Bonjour", roman: "" },
    { from: 18, text: "Bonsoir", roman: "" },
    { from: 22, text: "Bonne nuit", roman: "" }
  ] },
  it: { name: "Italian", bands: [
    { from: 0, text: "Buonanotte", roman: "" },
    { from: 5, text: "Buongiorno", roman: "" },
    { from: 14, text: "Buon pomeriggio", roman: "" },
    { from: 18, text: "Buonasera", roman: "" },
    { from: 23, text: "Buonanotte", roman: "" }
  ] },
  ro: { name: "Romanian", bands: [
    { from: 0, text: "Noapte bun\u0103", roman: "" },
    { from: 5, text: "Bun\u0103 diminea\u021ba", roman: "" },
    { from: 12, text: "Bun\u0103 ziua", roman: "" },
    { from: 18, text: "Bun\u0103 seara", roman: "" }
  ] },
  de: { name: "German", bands: [
    { from: 0, text: "Gute Nacht", roman: "" },
    { from: 5, text: "Guten Morgen", roman: "" },
    { from: 11, text: "Guten Tag", roman: "" },
    { from: 18, text: "Guten Abend", roman: "" },
    { from: 22, text: "Gute Nacht", roman: "" }
  ] },
  deAT: { name: "Austrian German", bands: [
    { from: 0, text: "Gute Nacht", roman: "" },
    { from: 5, text: "Guten Morgen", roman: "" },
    { from: 11, text: "Gr\u00fc\u00df Gott", roman: "" },
    { from: 18, text: "Guten Abend", roman: "" },
    { from: 22, text: "Gute Nacht", roman: "" }
  ] },
  deCH: { name: "Swiss German", bands: [
    { from: 0, text: "Gute Nacht", roman: "" },
    { from: 5, text: "Guete Morge", roman: "" },
    { from: 11, text: "Gr\u00fcezi", roman: "" },
    { from: 18, text: "Guete Abig", roman: "" },
    { from: 22, text: "Gute Nacht", roman: "" }
  ] },
  lb: { name: "Luxembourgish", bands: [
    { from: 0, text: "Gutt Nuecht", roman: "" },
    { from: 5, text: "Moien", roman: "" },
    { from: 12, text: "Gudde M\u00ebtteg", roman: "" },
    { from: 18, text: "Gudden Owend", roman: "" }
  ] },
  nl: { name: "Dutch", bands: [
    { from: 0, text: "Goedenacht", roman: "" },
    { from: 6, text: "Goedemorgen", roman: "" },
    { from: 12, text: "Goedemiddag", roman: "" },
    { from: 18, text: "Goedenavond", roman: "" }
  ] },
  da: { name: "Danish", bands: [
    { from: 0, text: "Godnat", roman: "" },
    { from: 5, text: "Godmorgen", roman: "" },
    { from: 10, text: "Goddag", roman: "" },
    { from: 18, text: "Godaften", roman: "" }
  ] },
  no: { name: "Norwegian", bands: [
    { from: 0, text: "God natt", roman: "" },
    { from: 5, text: "God morgen", roman: "" },
    { from: 10, text: "God dag", roman: "" },
    { from: 18, text: "God kveld", roman: "" }
  ] },
  sv: { name: "Swedish", bands: [
    { from: 0, text: "God natt", roman: "" },
    { from: 5, text: "God morgon", roman: "" },
    { from: 10, text: "God dag", roman: "" },
    { from: 18, text: "God kv\u00e4ll", roman: "" }
  ] },
  fi: { name: "Finnish", bands: [
    { from: 0, text: "Hyv\u00e4\u00e4 y\u00f6t\u00e4", roman: "" },
    { from: 5, text: "Huomenta", roman: "" },
    { from: 11, text: "P\u00e4iv\u00e4\u00e4", roman: "" },
    { from: 18, text: "Iltaa", roman: "" },
    { from: 23, text: "Hyv\u00e4\u00e4 y\u00f6t\u00e4", roman: "" }
  ] },
  is: { name: "Icelandic", bands: [
    { from: 0, text: "G\u00f3\u00f0a n\u00f3tt", roman: "" },
    { from: 6, text: "G\u00f3\u00f0an daginn", roman: "" },
    { from: 18, text: "Gott kv\u00f6ld", roman: "" }
  ] },
  fo: { name: "Faroese", bands: [
    { from: 0, text: "G\u00f3\u00f0a n\u00e1tt", roman: "" },
    { from: 5, text: "G\u00f3\u00f0an morgun", roman: "" },
    { from: 10, text: "G\u00f3\u00f0an dag", roman: "" },
    { from: 18, text: "Gott kv\u00f8ld", roman: "" }
  ] },
  kl: { name: "Greenlandic", bands: [
    { from: 0, text: "Inuugujoq", roman: "" }
  ] },
  et: { name: "Estonian", bands: [
    { from: 0, text: "Head \u00f6\u00f6d", roman: "" },
    { from: 5, text: "Tere hommikust", roman: "" },
    { from: 12, text: "Tere p\u00e4evast", roman: "" },
    { from: 18, text: "Tere \u00f5htust", roman: "" }
  ] },
  lv: { name: "Latvian", bands: [
    { from: 0, text: "Ar labu nakti", roman: "" },
    { from: 5, text: "Labr\u012bt", roman: "" },
    { from: 12, text: "Labdien", roman: "" },
    { from: 18, text: "Labvakar", roman: "" }
  ] },
  lt: { name: "Lithuanian", bands: [
    { from: 0, text: "Labanakt", roman: "" },
    { from: 5, text: "Labas rytas", roman: "" },
    { from: 12, text: "Laba diena", roman: "" },
    { from: 18, text: "Labas vakaras", roman: "" }
  ] },
  pl: { name: "Polish", bands: [
    { from: 0, text: "Dobranoc", roman: "" },
    { from: 5, text: "Dzie\u0144 dobry", roman: "" },
    { from: 18, text: "Dobry wiecz\u00f3r", roman: "" }
  ] },
  cs: { name: "Czech", bands: [
    { from: 0, text: "Dobrou noc", roman: "" },
    { from: 5, text: "Dobr\u00e9 r\u00e1no", roman: "" },
    { from: 10, text: "Dobr\u00fd den", roman: "" },
    { from: 18, text: "Dobr\u00fd ve\u010der", roman: "" }
  ] },
  sk: { name: "Slovak", bands: [
    { from: 0, text: "Dobr\u00fa noc", roman: "" },
    { from: 5, text: "Dobr\u00e9 r\u00e1no", roman: "" },
    { from: 10, text: "Dobr\u00fd de\u0148", roman: "" },
    { from: 18, text: "Dobr\u00fd ve\u010der", roman: "" }
  ] },
  sl: { name: "Slovenian", bands: [
    { from: 0, text: "Lahko no\u010d", roman: "" },
    { from: 5, text: "Dobro jutro", roman: "" },
    { from: 10, text: "Dober dan", roman: "" },
    { from: 18, text: "Dober ve\u010der", roman: "" }
  ] },
  hu: { name: "Hungarian", bands: [
    { from: 0, text: "J\u00f3 \u00e9jszak\u00e1t", roman: "" },
    { from: 5, text: "J\u00f3 reggelt", roman: "" },
    { from: 10, text: "J\u00f3 napot", roman: "" },
    { from: 18, text: "J\u00f3 est\u00e9t", roman: "" }
  ] },
  hr: { name: "Croatian", bands: [
    { from: 0, text: "Laku no\u0107", roman: "" },
    { from: 5, text: "Dobro jutro", roman: "" },
    { from: 12, text: "Dobar dan", roman: "" },
    { from: 18, text: "Dobra ve\u010der", roman: "" }
  ] },
  bs: { name: "Bosnian", bands: [
    { from: 0, text: "Laku no\u0107", roman: "" },
    { from: 5, text: "Dobro jutro", roman: "" },
    { from: 12, text: "Dobar dan", roman: "" },
    { from: 18, text: "Dobro ve\u010de", roman: "" }
  ] },
  sq: { name: "Albanian", bands: [
    { from: 0, text: "Nat\u00ebn e mir\u00eb", roman: "" },
    { from: 5, text: "Mir\u00ebm\u00ebngjes", roman: "" },
    { from: 12, text: "Mir\u00ebdita", roman: "" },
    { from: 18, text: "Mir\u00ebmbr\u00ebma", roman: "" }
  ] },
  mt: { name: "Maltese", bands: [
    { from: 0, text: "Il-lejl it-tajjeb", roman: "" },
    { from: 5, text: "Bon\u0121u", roman: "" },
    { from: 13, text: "Bonsw\u00e0", roman: "" }
  ] },
  tr: { name: "Turkish", bands: [
    { from: 0, text: "\u0130yi geceler", roman: "" },
    { from: 5, text: "G\u00fcnayd\u0131n", roman: "" },
    { from: 12, text: "\u0130yi g\u00fcnler", roman: "" },
    { from: 18, text: "\u0130yi ak\u015famlar", roman: "" }
  ] },
  af: { name: "Afrikaans", bands: [
    { from: 0, text: "Goeienag", roman: "" },
    { from: 5, text: "Goeiem\u00f4re", roman: "" },
    { from: 12, text: "Goeiemiddag", roman: "" },
    { from: 18, text: "Goeienaand", roman: "" }
  ] },
  yo: { name: "Yoruba", bands: [
    { from: 0, text: "O d\u00e0\u00e1r\u1ecd\u0300", roman: "" },
    { from: 5, text: "\u1eb8 k\u00e1\u00e0\u00e1r\u1ecd\u0300", roman: "" },
    { from: 12, text: "\u1eb8 k\u00e1\u00e0s\u00e1n", roman: "" },
    { from: 16, text: "\u1eb8 k\u00fa\u00f9r\u1ecd\u0300l\u1eb9\u0301", roman: "" },
    { from: 20, text: "\u1eb8 k\u00fa\u00f9\u00e1l\u1eb9\u0301", roman: "" }
  ] },
  tw: { name: "Twi", bands: [
    { from: 0, text: "Maadwo", roman: "" },
    { from: 5, text: "Maakye", roman: "" },
    { from: 12, text: "Maaha", roman: "" },
    { from: 18, text: "Maadwo", roman: "" }
  ] },
  ha: { name: "Hausa", bands: [
    { from: 0, text: "Barka da dare", roman: "" },
    { from: 5, text: "Barka da safiya", roman: "" },
    { from: 12, text: "Barka da rana", roman: "" },
    { from: 16, text: "Barka da yamma", roman: "" },
    { from: 20, text: "Barka da dare", roman: "" }
  ] },
  wo: { name: "Wolof", bands: [
    { from: 0, text: "Fanaanal j\u00e0mm", roman: "" },
    { from: 5, text: "J\u00e0mm nga fanaan", roman: "" },
    { from: 12, text: "Naka nga def", roman: "" },
    { from: 18, text: "J\u00e0mm nga yendoo", roman: "" }
  ] },
  sw: { name: "Swahili", bands: [
    { from: 0, text: "Usiku mwema", roman: "" },
    { from: 5, text: "Habari za asubuhi", roman: "" },
    { from: 12, text: "Habari za mchana", roman: "" },
    { from: 16, text: "Habari za jioni", roman: "" },
    { from: 20, text: "Usiku mwema", roman: "" }
  ] },
  rw: { name: "Kinyarwanda", bands: [
    { from: 0, text: "Ijoro ryiza", roman: "" },
    { from: 5, text: "Mwaramutse", roman: "" },
    { from: 12, text: "Mwiriwe", roman: "" },
    { from: 18, text: "Ijoro ryiza", roman: "" }
  ] },
  lg: { name: "Luganda", bands: [
    { from: 0, text: "Sula bulungi", roman: "" },
    { from: 5, text: "Wasuze otya", roman: "" },
    { from: 12, text: "Osiibye otya", roman: "" },
    { from: 18, text: "Sula bulungi", roman: "" }
  ] },
  ny: { name: "Chichewa", bands: [
    { from: 0, text: "Gonani bwino", roman: "" },
    { from: 5, text: "Mwadzuka bwanji", roman: "" },
    { from: 12, text: "Mwaswera bwanji", roman: "" },
    { from: 18, text: "Gonani bwino", roman: "" }
  ] },
  sn: { name: "Shona", bands: [
    { from: 0, text: "Manheru", roman: "" },
    { from: 5, text: "Mangwanani", roman: "" },
    { from: 12, text: "Masikati", roman: "" },
    { from: 18, text: "Manheru", roman: "" }
  ] },
  st: { name: "Sesotho", bands: [
    { from: 0, text: "Lumela", roman: "" }
  ] },
  ss: { name: "Siswati", bands: [
    { from: 0, text: "Sawubona", roman: "" }
  ] },
  mg: { name: "Malagasy", bands: [
    { from: 0, text: "Manao ahoana", roman: "" }
  ] },
  so: { name: "Somali", bands: [
    { from: 0, text: "Habeen wanaagsan", roman: "" },
    { from: 5, text: "Subax wanaagsan", roman: "" },
    { from: 12, text: "Galab wanaagsan", roman: "" },
    { from: 18, text: "Habeen wanaagsan", roman: "" }
  ] },
  id: { name: "Indonesian", bands: [
    { from: 0, text: "Selamat malam", roman: "" },
    { from: 4, text: "Selamat pagi", roman: "" },
    { from: 11, text: "Selamat siang", roman: "" },
    { from: 15, text: "Selamat sore", roman: "" },
    { from: 18, text: "Selamat malam", roman: "" }
  ] },
  ms: { name: "Malay", bands: [
    { from: 0, text: "Selamat malam", roman: "" },
    { from: 5, text: "Selamat pagi", roman: "" },
    { from: 12, text: "Selamat tengah hari", roman: "" },
    { from: 15, text: "Selamat petang", roman: "" },
    { from: 19, text: "Selamat malam", roman: "" }
  ] },
  tl: { name: "Filipino", bands: [
    { from: 0, text: "Magandang gabi", roman: "" },
    { from: 5, text: "Magandang umaga", roman: "" },
    { from: 12, text: "Magandang tanghali", roman: "" },
    { from: 13, text: "Magandang hapon", roman: "" },
    { from: 18, text: "Magandang gabi", roman: "" }
  ] },
  vi: { name: "Vietnamese", bands: [
    { from: 0, text: "Ch\u00fac ng\u1ee7 ngon", roman: "" },
    { from: 5, text: "Ch\u00e0o bu\u1ed5i s\u00e1ng", roman: "" },
    { from: 12, text: "Ch\u00e0o bu\u1ed5i chi\u1ec1u", roman: "" },
    { from: 18, text: "Ch\u00e0o bu\u1ed5i t\u1ed1i", roman: "" }
  ] },
  sm: { name: "Samoan", bands: [
    { from: 0, text: "Manuia le po", roman: "" },
    { from: 5, text: "Manuia le taeao", roman: "" },
    { from: 12, text: "Manuia le aoauli", roman: "" },
    { from: 17, text: "Manuia le afiafi", roman: "" },
    { from: 21, text: "Manuia le po", roman: "" }
  ] },
  mi: { name: "Maori", bands: [
    { from: 0, text: "P\u014d m\u0101rie", roman: "" },
    { from: 5, text: "M\u014drena", roman: "" },
    { from: 11, text: "Kia ora", roman: "" },
    { from: 17, text: "Ahiahi m\u0101rie", roman: "" },
    { from: 21, text: "P\u014d m\u0101rie", roman: "" }
  ] },
  rar: { name: "Cook Islands Maori", bands: [
    { from: 0, text: "Kia orana", roman: "" }
  ] },
  niu: { name: "Niuean", bands: [
    { from: 0, text: "Fakalofa lahi atu", roman: "" }
  ] },
  tkl: { name: "Tokelauan", bands: [
    { from: 0, text: "M\u0101l\u014d ni", roman: "" }
  ] },
  tvl: { name: "Tuvaluan", bands: [
    { from: 0, text: "T\u0101lofa", roman: "" }
  ] },
  to: { name: "Tongan", bands: [
    { from: 0, text: "M\u0101l\u014d e lelei", roman: "" }
  ] },
  ty: { name: "Tahitian", bands: [
    { from: 0, text: "Ia ora na", roman: "" }
  ] },
  fj: { name: "Fijian", bands: [
    { from: 0, text: "Ni sa moce", roman: "" },
    { from: 5, text: "Ni sa yadra", roman: "" },
    { from: 11, text: "Bula", roman: "" },
    { from: 19, text: "Ni sa moce", roman: "" }
  ] },
  haw: { name: "Hawaiian", bands: [
    { from: 0, text: "Aloha p\u014d", roman: "" },
    { from: 5, text: "Aloha kakahiaka", roman: "" },
    { from: 11, text: "Aloha awakea", roman: "" },
    { from: 14, text: "Aloha \u02bbauinal\u0101", roman: "" },
    { from: 18, text: "Aloha ahiahi", roman: "" },
    { from: 23, text: "Aloha p\u014d", roman: "" }
  ] },
  gil: { name: "Gilbertese", bands: [
    { from: 0, text: "Mauri", roman: "" }
  ] },
  ch: { name: "Chamorro", bands: [
    { from: 0, text: "H\u00e5fa adai", roman: "" }
  ] },
  mh: { name: "Marshallese", bands: [
    { from: 0, text: "Iakwe", roman: "" }
  ] },
  pau: { name: "Palauan", bands: [
    { from: 0, text: "Alii", roman: "" }
  ] },
  tpi: { name: "Tok Pisin", bands: [
    { from: 0, text: "Gutnait", roman: "" },
    { from: 5, text: "Moning", roman: "" },
    { from: 12, text: "Apinun", roman: "" },
    { from: 18, text: "Gutnait", roman: "" }
  ] },
  bi: { name: "Bislama", bands: [
    { from: 0, text: "Gudnaet", roman: "" },
    { from: 5, text: "Gude", roman: "" },
    { from: 18, text: "Gudnaet", roman: "" }
  ] },
  ht: { name: "Haitian Creole", bands: [
    { from: 0, text: "B\u00f2nwit", roman: "" },
    { from: 5, text: "Bonjou", roman: "" },
    { from: 12, text: "Bon apre midi", roman: "" },
    { from: 18, text: "Bonswa", roman: "" }
  ] },
  pap: { name: "Papiamento", bands: [
    { from: 0, text: "Bon nochi", roman: "" },
    { from: 5, text: "Bon dia", roman: "" },
    { from: 12, text: "Bon tardi", roman: "" },
    { from: 18, text: "Bon nochi", roman: "" }
  ] },
  gn: { name: "Guarani", bands: [
    { from: 0, text: "Mba'\u00e9ichapa", roman: "" }
  ] },
  el: { name: "Greek", bands: [
    { from: 0, text: "\u039a\u03b1\u03bb\u03b7\u03bd\u03cd\u03c7\u03c4\u03b1", roman: "kalinihta" },
    { from: 5, text: "\u039a\u03b1\u03bb\u03b7\u03bc\u03ad\u03c1\u03b1", roman: "kalimera" },
    { from: 12, text: "\u039a\u03b1\u03bb\u03b7\u03c3\u03c0\u03ad\u03c1\u03b1", roman: "kalispera" },
    { from: 21, text: "\u039a\u03b1\u03bb\u03b7\u03bd\u03cd\u03c7\u03c4\u03b1", roman: "kalinihta" }
  ] },
  ru: { name: "Russian", bands: [
    { from: 0, text: "\u0421\u043f\u043e\u043a\u043e\u0439\u043d\u043e\u0439 \u043d\u043e\u0447\u0438", roman: "spokoynoy nochi" },
    { from: 5, text: "\u0414\u043e\u0431\u0440\u043e\u0435 \u0443\u0442\u0440\u043e", roman: "dobroye utro" },
    { from: 12, text: "\u0414\u043e\u0431\u0440\u044b\u0439 \u0434\u0435\u043d\u044c", roman: "dobryy den" },
    { from: 18, text: "\u0414\u043e\u0431\u0440\u044b\u0439 \u0432\u0435\u0447\u0435\u0440", roman: "dobryy vecher" }
  ] },
  uk: { name: "Ukrainian", bands: [
    { from: 0, text: "\u041d\u0430\u0434\u043e\u0431\u0440\u0430\u043d\u0456\u0447", roman: "nadobranich" },
    { from: 5, text: "\u0414\u043e\u0431\u0440\u043e\u0433\u043e \u0440\u0430\u043d\u043a\u0443", roman: "dobroho ranku" },
    { from: 12, text: "\u0414\u043e\u0431\u0440\u043e\u0433\u043e \u0434\u043d\u044f", roman: "dobroho dnya" },
    { from: 18, text: "\u0414\u043e\u0431\u0440\u043e\u0433\u043e \u0432\u0435\u0447\u043e\u0440\u0430", roman: "dobroho vechora" }
  ] },
  be: { name: "Belarusian", bands: [
    { from: 0, text: "\u0414\u0430\u0431\u0440\u0430\u043d\u0430\u0447", roman: "dabranach" },
    { from: 5, text: "\u0414\u043e\u0431\u0440\u0430\u0439 \u0440\u0430\u043d\u0456\u0446\u044b", roman: "dobray ranitsy" },
    { from: 12, text: "\u0414\u043e\u0431\u0440\u044b \u0434\u0437\u0435\u043d\u044c", roman: "dobry dzen" },
    { from: 18, text: "\u0414\u043e\u0431\u0440\u044b \u0432\u0435\u0447\u0430\u0440", roman: "dobry vechar" }
  ] },
  bg: { name: "Bulgarian", bands: [
    { from: 0, text: "\u041b\u0435\u043a\u0430 \u043d\u043e\u0449", roman: "leka nosht" },
    { from: 5, text: "\u0414\u043e\u0431\u0440\u043e \u0443\u0442\u0440\u043e", roman: "dobro utro" },
    { from: 12, text: "\u0414\u043e\u0431\u044a\u0440 \u0434\u0435\u043d", roman: "dobar den" },
    { from: 18, text: "\u0414\u043e\u0431\u044a\u0440 \u0432\u0435\u0447\u0435\u0440", roman: "dobar vecher" }
  ] },
  sr: { name: "Serbian", bands: [
    { from: 0, text: "\u041b\u0430\u043a\u0443 \u043d\u043e\u045b", roman: "laku noc" },
    { from: 5, text: "\u0414\u043e\u0431\u0440\u043e \u0458\u0443\u0442\u0440\u043e", roman: "dobro jutro" },
    { from: 12, text: "\u0414\u043e\u0431\u0430\u0440 \u0434\u0430\u043d", roman: "dobar dan" },
    { from: 18, text: "\u0414\u043e\u0431\u0440\u043e \u0432\u0435\u0447\u0435", roman: "dobro vece" }
  ] },
  mk: { name: "Macedonian", bands: [
    { from: 0, text: "\u0414\u043e\u0431\u0440\u0430 \u043d\u043e\u045c", roman: "dobra nok" },
    { from: 5, text: "\u0414\u043e\u0431\u0440\u043e \u0443\u0442\u0440\u043e", roman: "dobro utro" },
    { from: 12, text: "\u0414\u043e\u0431\u0430\u0440 \u0434\u0435\u043d", roman: "dobar den" },
    { from: 18, text: "\u0414\u043e\u0431\u0440\u043e \u0432\u0435\u0447\u0435\u0440", roman: "dobro vecher" }
  ] },
  kk: { name: "Kazakh", bands: [
    { from: 0, text: "\u049a\u0430\u0439\u044b\u0440\u043b\u044b \u0442\u04af\u043d", roman: "qaiyrly tun" },
    { from: 5, text: "\u049a\u0430\u0439\u044b\u0440\u043b\u044b \u0442\u0430\u04a3", roman: "qaiyrly tang" },
    { from: 12, text: "\u049a\u0430\u0439\u044b\u0440\u043b\u044b \u043a\u04af\u043d", roman: "qaiyrly kun" },
    { from: 18, text: "\u049a\u0430\u0439\u044b\u0440\u043b\u044b \u043a\u0435\u0448", roman: "qaiyrly kesh" }
  ] },
  ky: { name: "Kyrgyz", bands: [
    { from: 0, text: "\u0416\u0430\u043a\u0448\u044b \u0436\u0430\u0442\u044b\u043f \u0442\u0443\u0440\u0443\u04a3\u0443\u0437", roman: "jakshy jatyp turunguz" },
    { from: 5, text: "\u041a\u0430\u0439\u044b\u0440\u043b\u0443\u0443 \u0442\u0430\u04a3", roman: "kaiyrluu tang" },
    { from: 12, text: "\u041a\u0443\u0442\u043c\u0430\u043d\u0434\u0443\u0443 \u043a\u04af\u043d", roman: "kutmanduu kun" },
    { from: 18, text: "\u041a\u0443\u0442\u043c\u0430\u043d\u0434\u0443\u0443 \u043a\u0435\u0447", roman: "kutmanduu kech" }
  ] },
  tg: { name: "Tajik", bands: [
    { from: 0, text: "\u0428\u0430\u0431 \u0431\u0430 \u0445\u0430\u0439\u0440", roman: "shab ba khayr" },
    { from: 5, text: "\u0421\u0443\u0431\u04b3 \u0431\u0430 \u0445\u0430\u0439\u0440", roman: "subh ba khayr" },
    { from: 12, text: "\u0420\u04ef\u0437 \u0431\u0430 \u0445\u0430\u0439\u0440", roman: "ruz ba khayr" },
    { from: 18, text: "\u0428\u043e\u043c \u0431\u0430 \u0445\u0430\u0439\u0440", roman: "shom ba khayr" }
  ] },
  mn: { name: "Mongolian", bands: [
    { from: 0, text: "\u0421\u0430\u0439\u0445\u0430\u043d \u0430\u043c\u0440\u0430\u0430\u0440\u0430\u0439", roman: "saikhan amraarai" },
    { from: 5, text: "\u04e8\u0433\u043b\u04e9\u04e9\u043d\u0438\u0439 \u043c\u044d\u043d\u0434", roman: "ogloonii mend" },
    { from: 12, text: "\u04e8\u0434\u0440\u0438\u0439\u043d \u043c\u044d\u043d\u0434", roman: "odriin mend" },
    { from: 18, text: "\u041e\u0440\u043e\u0439\u043d \u043c\u044d\u043d\u0434", roman: "oroin mend" }
  ] },
  ka: { name: "Georgian", bands: [
    { from: 0, text: "\u10e6\u10d0\u10db\u10d4 \u10db\u10e8\u10d5\u10d8\u10d3\u10dd\u10d1\u10d8\u10e1\u10d0", roman: "ghame mshvidobisa" },
    { from: 5, text: "\u10d3\u10d8\u10da\u10d0 \u10db\u10e8\u10d5\u10d8\u10d3\u10dd\u10d1\u10d8\u10e1\u10d0", roman: "dila mshvidobisa" },
    { from: 12, text: "\u10d3\u10e6\u10d4 \u10db\u10e8\u10d5\u10d8\u10d3\u10dd\u10d1\u10d8\u10e1\u10d0", roman: "dghe mshvidobisa" },
    { from: 18, text: "\u10e1\u10d0\u10e6\u10d0\u10db\u10dd \u10db\u10e8\u10d5\u10d8\u10d3\u10dd\u10d1\u10d8\u10e1\u10d0", roman: "saghamo mshvidobisa" }
  ] },
  hy: { name: "Armenian", bands: [
    { from: 0, text: "\u0562\u0561\u0580\u056b \u0563\u056b\u0577\u0565\u0580", roman: "bari gisher" },
    { from: 5, text: "\u0562\u0561\u0580\u056b \u056c\u0578\u0582\u0575\u057d", roman: "bari luys" },
    { from: 12, text: "\u0562\u0561\u0580\u056b \u0585\u0580", roman: "bari or" },
    { from: 18, text: "\u0562\u0561\u0580\u056b \u0565\u0580\u0565\u056f\u0578", roman: "bari ereko" }
  ] },
  he: { name: "Hebrew", bands: [
    { from: 0, text: "\u05dc\u05d9\u05dc\u05d4 \u05d8\u05d5\u05d1", roman: "laila tov" },
    { from: 5, text: "\u05d1\u05d5\u05e7\u05e8 \u05d8\u05d5\u05d1", roman: "boker tov" },
    { from: 12, text: "\u05e6\u05d4\u05e8\u05d9\u05d9\u05dd \u05d8\u05d5\u05d1\u05d9\u05dd", roman: "tzohorayim tovim" },
    { from: 17, text: "\u05e2\u05e8\u05d1 \u05d8\u05d5\u05d1", roman: "erev tov" }
  ] },
  ar: { name: "Arabic", bands: [
    { from: 0, text: "\u062a\u0635\u0628\u062d \u0639\u0644\u0649 \u062e\u064a\u0631", roman: "tusbih ala khayr" },
    { from: 5, text: "\u0635\u0628\u0627\u062d \u0627\u0644\u062e\u064a\u0631", roman: "sabah al-khayr" },
    { from: 12, text: "\u0645\u0633\u0627\u0621 \u0627\u0644\u062e\u064a\u0631", roman: "masaa al-khayr" }
  ] },
  fa: { name: "Persian", bands: [
    { from: 0, text: "\u0634\u0628 \u0628\u062e\u06cc\u0631", roman: "shab bekheir" },
    { from: 5, text: "\u0635\u0628\u062d \u0628\u062e\u06cc\u0631", roman: "sobh bekheir" },
    { from: 12, text: "\u0639\u0635\u0631 \u0628\u062e\u06cc\u0631", roman: "asr bekheir" },
    { from: 20, text: "\u0634\u0628 \u0628\u062e\u06cc\u0631", roman: "shab bekheir" }
  ] },
  ur: { name: "Urdu", bands: [
    { from: 0, text: "\u0634\u0628 \u0628\u062e\u06cc\u0631", roman: "shab bakhair" },
    { from: 5, text: "\u0635\u0628\u062d \u0628\u062e\u06cc\u0631", roman: "subah bakhair" },
    { from: 12, text: "\u0627\u0644\u0633\u0644\u0627\u0645 \u0639\u0644\u06cc\u06a9\u0645", roman: "assalam-o-alaikum" },
    { from: 18, text: "\u0634\u0627\u0645 \u0628\u062e\u06cc\u0631", roman: "shaam bakhair" }
  ] },
  prs: { name: "Dari", bands: [
    { from: 0, text: "\u0634\u0628 \u0628\u062e\u06cc\u0631", roman: "shab bakhair" },
    { from: 5, text: "\u0635\u0628\u062d \u0628\u062e\u06cc\u0631", roman: "sobh bakhair" },
    { from: 12, text: "\u0631\u0648\u0632 \u0628\u062e\u06cc\u0631", roman: "roz bakhair" },
    { from: 18, text: "\u0634\u0627\u0645 \u0628\u062e\u06cc\u0631", roman: "sham bakhair" }
  ] },
  dv: { name: "Dhivehi", bands: [
    { from: 0, text: "\u0787\u07a6\u0787\u07b0\u0790\u07a6\u078d\u07a7\u0789\u07aa \u07a2\u07a6\u078d\u07a6\u0787\u07a8\u0786\u07aa\u0789\u07b0", roman: "assalaamu alaikum" }
  ] },
  hi: { name: "Hindi", bands: [
    { from: 0, text: "\u0936\u0941\u092d \u0930\u093e\u0924\u094d\u0930\u093f", roman: "shubh ratri" },
    { from: 5, text: "\u0938\u0941\u092a\u094d\u0930\u092d\u093e\u0924", roman: "suprabhat" },
    { from: 12, text: "\u0928\u092e\u0938\u094d\u0924\u0947", roman: "namaste" },
    { from: 17, text: "\u0936\u0941\u092d \u0938\u0902\u0927\u094d\u092f\u093e", roman: "shubh sandhya" }
  ] },
  bn: { name: "Bengali", bands: [
    { from: 0, text: "\u09b6\u09c1\u09ad \u09b0\u09be\u09a4\u09cd\u09b0\u09bf", roman: "shubho ratri" },
    { from: 5, text: "\u09b8\u09c1\u09aa\u09cd\u09b0\u09ad\u09be\u09a4", roman: "suprobhat" },
    { from: 12, text: "\u09a8\u09ae\u09b8\u09cd\u0995\u09be\u09b0", roman: "nomoshkar" },
    { from: 17, text: "\u09b6\u09c1\u09ad \u09b8\u09a8\u09cd\u09a7\u09cd\u09af\u09be", roman: "shubho shondha" }
  ] },
  ne: { name: "Nepali", bands: [
    { from: 0, text: "\u0936\u0941\u092d \u0930\u093e\u0924\u094d\u0930\u0940", roman: "shubha ratri" },
    { from: 5, text: "\u0936\u0941\u092d \u092a\u094d\u0930\u092d\u093e\u0924", roman: "shubha prabhat" },
    { from: 12, text: "\u0928\u092e\u0938\u094d\u0924\u0947", roman: "namaste" },
    { from: 17, text: "\u0936\u0941\u092d \u0938\u0928\u094d\u0927\u094d\u092f\u093e", roman: "shubha sandhya" }
  ] },
  si: { name: "Sinhala", bands: [
    { from: 0, text: "\u0dc3\u0dd4\u0db6 \u0dbb\u0dcf\u0dad\u0dca\u200d\u0dbb\u0dd2\u0dba\u0d9a\u0dca", roman: "suba rathriyak" },
    { from: 5, text: "\u0dc3\u0dd4\u0db6 \u0d8b\u0daf\u0dd1\u0dc3\u0db1\u0d9a\u0dca", roman: "suba udaesanak" },
    { from: 12, text: "\u0dc3\u0dd4\u0db6 \u0daf\u0dc0\u0dc3\u0d9a\u0dca", roman: "suba dawasak" },
    { from: 18, text: "\u0dc3\u0dd4\u0db6 \u0dc3\u0db1\u0dca\u0db0\u0dca\u200d\u0dba\u0dcf\u0dc0\u0d9a\u0dca", roman: "suba sandhyawak" }
  ] },
  ta: { name: "Tamil", bands: [
    { from: 0, text: "\u0b87\u0bb0\u0bb5\u0bc1 \u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd", roman: "iravu vanakkam" },
    { from: 5, text: "\u0b95\u0bbe\u0bb2\u0bc8 \u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd", roman: "kaalai vanakkam" },
    { from: 12, text: "\u0bae\u0ba4\u0bbf\u0baf \u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd", roman: "madhiya vanakkam" },
    { from: 17, text: "\u0bae\u0bbe\u0bb2\u0bc8 \u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd", roman: "maalai vanakkam" }
  ] },
  dz: { name: "Dzongkha", bands: [
    { from: 0, text: "\u0f40\u0f74\u0f0b\u0f5f\u0f74\u0f0b\u0f5f\u0f44\u0f0b\u0f54\u0f7c\u0f0b\u0f63\u0f42\u0f66", roman: "kuzuzangpo la" }
  ] },
  my: { name: "Burmese", bands: [
    { from: 0, text: "\u1019\u1004\u103a\u1039\u1002\u101c\u102c\u1015\u102b", roman: "mingalaba" }
  ] },
  th: { name: "Thai", bands: [
    { from: 0, text: "\u0e23\u0e32\u0e15\u0e23\u0e35\u0e2a\u0e27\u0e31\u0e2a\u0e14\u0e34\u0e4c", roman: "ratri sawat" },
    { from: 5, text: "\u0e2d\u0e23\u0e38\u0e13\u0e2a\u0e27\u0e31\u0e2a\u0e14\u0e34\u0e4c", roman: "arun sawat" },
    { from: 12, text: "\u0e2a\u0e27\u0e31\u0e2a\u0e14\u0e35", roman: "sawatdee" }
  ] },
  lo: { name: "Lao", bands: [
    { from: 0, text: "\u0eaa\u0eb0\u0e9a\u0eb2\u0e8d\u0e94\u0eb5", roman: "sabaidee" }
  ] },
  km: { name: "Khmer", bands: [
    { from: 0, text: "\u179a\u17b6\u178f\u17d2\u179a\u17b8\u179f\u17bd\u179f\u17d2\u178f\u17b8", roman: "reatrei suostei" },
    { from: 5, text: "\u17a2\u179a\u17bb\u178e\u179f\u17bd\u179f\u17d2\u178f\u17b8", roman: "arun suostei" },
    { from: 12, text: "\u1791\u17b7\u179c\u17b6\u179f\u17bd\u179f\u17d2\u178f\u17b8", roman: "tivea suostei" },
    { from: 18, text: "\u179f\u17b6\u1799\u17d0\u178e\u17d2\u17a0\u179f\u17bd\u179f\u17d2\u178f\u17b8", roman: "sayoanh suostei" }
  ] },
  zh: { name: "Mandarin", bands: [
    { from: 0, text: "\u665a\u5b89", roman: "wan an" },
    { from: 5, text: "\u65e9\u4e0a\u597d", roman: "zaoshang hao" },
    { from: 11, text: "\u4e2d\u5348\u597d", roman: "zhongwu hao" },
    { from: 14, text: "\u4e0b\u5348\u597d", roman: "xiawu hao" },
    { from: 18, text: "\u665a\u4e0a\u597d", roman: "wanshang hao" }
  ] },
  yue: { name: "Cantonese", bands: [
    { from: 0, text: "\u65e9\u551e", roman: "jou tau" },
    { from: 5, text: "\u65e9\u6668", roman: "jou san" },
    { from: 12, text: "\u5348\u5b89", roman: "ng on" },
    { from: 18, text: "\u665a\u5b89", roman: "maan on" }
  ] },
  ko: { name: "Korean", bands: [
    { from: 0, text: "\uc548\ub155\ud788 \uc8fc\ubb34\uc138\uc694", roman: "annyeonghi jumuseyo" },
    { from: 5, text: "\uc88b\uc740 \uc544\uce68", roman: "joeun achim" },
    { from: 11, text: "\uc548\ub155\ud558\uc138\uc694", roman: "annyeonghaseyo" },
    { from: 18, text: "\uc88b\uc740 \uc800\ub141", roman: "joeun jeonyeok" }
  ] },
  ja: { name: "Japanese", bands: [
    { from: 0, text: "\u304a\u3084\u3059\u307f", roman: "oyasumi" },
    { from: 5, text: "\u304a\u306f\u3088\u3046", roman: "ohayo" },
    { from: 11, text: "\u3053\u3093\u306b\u3061\u306f", roman: "konnichiwa" },
    { from: 18, text: "\u3053\u3093\u3070\u3093\u306f", roman: "konbanwa" }
  ] },
  am: { name: "Amharic", bands: [
    { from: 0, text: "\u12f0\u1205\u1293 \u12a5\u12f0\u1229", roman: "dehna ederu" },
    { from: 5, text: "\u12a5\u1295\u12f0\u121d\u1295 \u12a0\u12f0\u1229", roman: "endemin aderu" },
    { from: 12, text: "\u12a5\u1295\u12f0\u121d\u1295 \u12cb\u1209", roman: "endemin walu" },
    { from: 18, text: "\u12a5\u1295\u12f0\u121d\u1295 \u12a0\u1218\u1239", roman: "endemin ameshu" }
  ] },
  ti: { name: "Tigrinya", bands: [
    { from: 0, text: "\u1230\u120b\u121d", roman: "selam" }
  ] },
  az: { name: "Azerbaijani", bands: [
    { from: 0, text: "Gec\u0259niz xeyr\u0259 qals\u0131n", roman: "" },
    { from: 5, text: "Sabah\u0131n\u0131z xeyir", roman: "" },
    { from: 12, text: "G\u00fcnortan\u0131z xeyir", roman: "" },
    { from: 18, text: "Ax\u015fam\u0131n\u0131z xeyir", roman: "" }
  ] },
  uz: { name: "Uzbek", bands: [
    { from: 0, text: "Xayrli tun", roman: "" },
    { from: 5, text: "Xayrli tong", roman: "" },
    { from: 12, text: "Xayrli kun", roman: "" },
    { from: 18, text: "Xayrli kech", roman: "" }
  ] },
  tk: { name: "Turkmen", bands: [
    { from: 0, text: "Gij\u00e4\u0148iz rahat", roman: "" },
    { from: 5, text: "Ertiri\u0148iz ha\u00fdyrly", roman: "" },
    { from: 12, text: "Salam", roman: "" },
    { from: 18, text: "Ag\u015famy\u0148yz ha\u00fdyrly", roman: "" }
  ] }
}

// The language a country is greeted in. Judgement calls, every one of them;
// see the note at the top about which way they lean.
var COUNTRIES = {
  "AD": "ca", "AE": "ar", "AF": "prs", "AG": "en", "AI": "en", "AL": "sq",
  "AM": "hy", "AO": "pt", "AQ": "en", "AR": "es", "AS": "sm", "AT": "deAT",
  "AU": "enAU", "AW": "pap", "AX": "sv", "AZ": "az", "BA": "bs", "BB": "en",
  "BD": "bn", "BE": "fr", "BF": "fr", "BG": "bg", "BH": "ar", "BI": "fr",
  "BJ": "fr", "BL": "fr", "BM": "en", "BN": "ms", "BO": "es", "BQ": "pap",
  "BR": "pt", "BS": "en", "BT": "dz", "BW": "en", "BY": "be", "BZ": "en",
  "CA": "en", "CC": "en", "CD": "fr", "CF": "fr", "CG": "fr", "CH": "deCH",
  "CI": "fr", "CK": "rar", "CL": "es", "CM": "fr", "CN": "zh", "CO": "es",
  "CR": "es", "CU": "es", "CV": "pt", "CW": "pap", "CX": "en", "CY": "el",
  "CZ": "cs", "DE": "de", "DJ": "fr", "DK": "da", "DM": "en", "DO": "es",
  "DZ": "ar", "EC": "es", "EE": "et", "EG": "ar", "EH": "ar", "ER": "ti",
  "ES": "esES", "ET": "am", "FI": "fi", "FJ": "fj", "FK": "en", "FM": "en",
  "FO": "fo", "FR": "fr", "GA": "fr", "GB": "en", "GD": "en", "GE": "ka",
  "GF": "fr", "GG": "en", "GH": "tw", "GI": "en", "GL": "kl", "GM": "en",
  "GN": "fr", "GP": "fr", "GQ": "es", "GR": "el", "GS": "en", "GT": "es",
  "GU": "ch", "GW": "pt", "GY": "en", "HK": "yue", "HN": "es", "HR": "hr",
  "HT": "ht", "HU": "hu", "ID": "id", "IE": "ga", "IL": "he", "IM": "en",
  "IN": "hi", "IO": "en", "IQ": "ar", "IR": "fa", "IS": "is", "IT": "it",
  "JE": "en", "JM": "en", "JO": "ar", "JP": "ja", "KE": "sw", "KG": "ky",
  "KH": "km", "KI": "gil", "KM": "fr", "KN": "en", "KP": "ko", "KR": "ko",
  "KW": "ar", "KY": "en", "KZ": "kk", "LA": "lo", "LB": "ar", "LC": "en",
  "LI": "deCH", "LK": "si", "LR": "en", "LS": "st", "LT": "lt", "LU": "lb",
  "LV": "lv", "LY": "ar", "MA": "ar", "MC": "fr", "MD": "ro", "ME": "hr",
  "MF": "fr", "MG": "mg", "MH": "mh", "MK": "mk", "ML": "fr", "MM": "my",
  "MN": "mn", "MO": "yue", "MP": "ch", "MQ": "fr", "MR": "ar", "MS": "en",
  "MT": "mt", "MU": "fr", "MV": "dv", "MW": "ny", "MX": "es", "MY": "ms",
  "MZ": "pt", "NA": "af", "NC": "fr", "NE": "fr", "NF": "en", "NG": "yo",
  "NI": "es", "NL": "nl", "NO": "no", "NP": "ne", "NR": "en", "NU": "niu",
  "NZ": "mi", "OM": "ar", "PA": "es", "PE": "es", "PF": "ty", "PG": "tpi",
  "PH": "tl", "PK": "ur", "PL": "pl", "PM": "fr", "PN": "en", "PR": "es",
  "PS": "ar", "PT": "pt", "PW": "pau", "PY": "gn", "QA": "ar", "RE": "fr",
  "RO": "ro", "RS": "sr", "RU": "ru", "RW": "rw", "SA": "ar", "SB": "bi",
  "SC": "fr", "SD": "ar", "SE": "sv", "SG": "ms", "SH": "en", "SI": "sl",
  "SJ": "no", "SK": "sk", "SL": "en", "SM": "it", "SN": "wo", "SO": "so",
  "SR": "nl", "SS": "en", "ST": "pt", "SV": "es", "SX": "nl", "SY": "ar",
  "SZ": "ss", "TC": "en", "TD": "fr", "TF": "fr", "TG": "fr", "TH": "th",
  "TJ": "tg", "TK": "tkl", "TL": "pt", "TM": "tk", "TN": "ar", "TO": "to",
  "TR": "tr", "TT": "en", "TV": "tvl", "TW": "zh", "TZ": "sw", "UA": "uk",
  "UG": "lg", "UM": "en", "US": "en", "UY": "es", "UZ": "uz", "VA": "it",
  "VC": "en", "VE": "es", "VG": "en", "VI": "en", "VN": "vi", "VU": "bi",
  "WF": "fr", "WS": "sm", "YE": "ar", "YT": "fr", "ZA": "af", "ZM": "en",
  "ZW": "sn"
}

// Cities whose own language is not their country's. Kept short on purpose.
var OVERRIDES = {
  "America/Montreal": "fr",
  "Asia/Kolkata": "hi",
  "Pacific/Honolulu": "haw"
}

// Aliases the generator put in the wrong country.
//
// ZONE_COUNTRY below was built by matching each zone's *compiled* zoneinfo file
// against the ones in zone.tab. That works for real zones and fails for the
// legacy aliases, because an alias shares its rules with whatever zone the tz
// database linked it to - which is chosen for having identical rules, not for
// being anywhere near it. `Iceland` keeps the same time as Abidjan all year, so
// it matched Burkina Faso and greeted people in French. `NZ` matched Antarctica,
// `Asia/Rangoon` the Cocos Islands, `Africa/Asmera` Djibouti.
//
// Following the tz link table instead does not fix it: that hands back the
// country of the *canonical* zone, which for `Iceland` is Côte d'Ivoire and for
// `Pacific/Truk` is Papua New Guinea. There is no rule here, only places. These
// fifteen are named by hand, each one the country the place is actually in.
//
// Two that look wrong and are not: `Antarctica/South_Pole` really is AQ, and
// `Pacific/Ponape` really is FM, though the link table says NZ and SB. And
// `Europe/Simferopol` stays UA, which is a choice rather than a lookup - the
// tz database has moved it to RU, and this greets Crimea in Ukrainian.
//
// tests/greetings_check.js pins every one of these.
var ALIAS_COUNTRY = {
  "Africa/Asmera": "ER",          // Asmara, Eritrea
  "Africa/Timbuktu": "ML",        // Timbuktu, Mali
  "America/Montreal": "CA",
  "America/Nipigon": "CA",
  "America/Thunder_Bay": "CA",
  "America/Virgin": "VI",         // the US Virgin Islands
  "Asia/Rangoon": "MM",           // Yangon, Myanmar
  "Canada/Eastern": "CA",
  "EST": "US",                    // a North American offset, not a place
  "Iceland": "IS",
  "MST": "US",
  "NZ": "NZ",
  "Pacific/Truk": "FM",           // Chuuk, Micronesia
  "Pacific/Yap": "FM",            // Yap, Micronesia
  "Singapore": "SG",
  "US/Arizona": "US"
}

// Every zone the picker can offer, from the system's own zone.tab, aliases
// included. Baked rather than read at runtime: the panel draws without
// touching the disk, and a zone list that changed under a running shell
// would be a stranger bug than a stale one.
var ZONE_COUNTRY = {
  "Africa/Abidjan": "CI", "Africa/Accra": "GH", "Africa/Addis_Ababa": "ET",
  "Africa/Algiers": "DZ", "Africa/Asmara": "ER", "Africa/Asmera": "DJ",
  "Africa/Bamako": "ML", "Africa/Bangui": "CF", "Africa/Banjul": "GM",
  "Africa/Bissau": "GW", "Africa/Blantyre": "MW",
  "Africa/Brazzaville": "CG", "Africa/Bujumbura": "BI",
  "Africa/Cairo": "EG", "Africa/Casablanca": "MA", "Africa/Ceuta": "ES",
  "Africa/Conakry": "GN", "Africa/Dakar": "SN",
  "Africa/Dar_es_Salaam": "TZ", "Africa/Djibouti": "DJ",
  "Africa/Douala": "CM", "Africa/El_Aaiun": "EH", "Africa/Freetown": "SL",
  "Africa/Gaborone": "BW", "Africa/Harare": "ZW",
  "Africa/Johannesburg": "ZA", "Africa/Juba": "SS", "Africa/Kampala": "UG",
  "Africa/Khartoum": "SD", "Africa/Kigali": "RW", "Africa/Kinshasa": "CD",
  "Africa/Lagos": "NG", "Africa/Libreville": "GA", "Africa/Lome": "TG",
  "Africa/Luanda": "AO", "Africa/Lubumbashi": "CD", "Africa/Lusaka": "ZM",
  "Africa/Malabo": "GQ", "Africa/Maputo": "MZ", "Africa/Maseru": "LS",
  "Africa/Mbabane": "SZ", "Africa/Mogadishu": "SO", "Africa/Monrovia": "LR",
  "Africa/Nairobi": "KE", "Africa/Ndjamena": "TD", "Africa/Niamey": "NE",
  "Africa/Nouakchott": "MR", "Africa/Ouagadougou": "BF",
  "Africa/Porto-Novo": "BJ", "Africa/Sao_Tome": "ST",
  "Africa/Timbuktu": "BF", "Africa/Tripoli": "LY", "Africa/Tunis": "TN",
  "Africa/Windhoek": "NA", "America/Adak": "US", "America/Anchorage": "US",
  "America/Anguilla": "AI", "America/Antigua": "AG",
  "America/Araguaina": "BR", "America/Argentina/Buenos_Aires": "AR",
  "America/Argentina/Catamarca": "AR",
  "America/Argentina/ComodRivadavia": "AR",
  "America/Argentina/Cordoba": "AR", "America/Argentina/Jujuy": "AR",
  "America/Argentina/La_Rioja": "AR", "America/Argentina/Mendoza": "AR",
  "America/Argentina/Rio_Gallegos": "AR", "America/Argentina/Salta": "AR",
  "America/Argentina/San_Juan": "AR", "America/Argentina/San_Luis": "AR",
  "America/Argentina/Tucuman": "AR", "America/Argentina/Ushuaia": "AR",
  "America/Aruba": "AW", "America/Asuncion": "PY", "America/Atikokan": "CA",
  "America/Atka": "US", "America/Bahia": "BR",
  "America/Bahia_Banderas": "MX", "America/Barbados": "BB",
  "America/Belem": "BR", "America/Belize": "BZ",
  "America/Blanc-Sablon": "CA", "America/Boa_Vista": "BR",
  "America/Bogota": "CO", "America/Boise": "US",
  "America/Buenos_Aires": "AR", "America/Cambridge_Bay": "CA",
  "America/Campo_Grande": "BR", "America/Cancun": "MX",
  "America/Caracas": "VE", "America/Catamarca": "AR",
  "America/Cayenne": "GF", "America/Cayman": "KY", "America/Chicago": "US",
  "America/Chihuahua": "MX", "America/Ciudad_Juarez": "MX",
  "America/Coral_Harbour": "CA", "America/Cordoba": "AR",
  "America/Costa_Rica": "CR", "America/Coyhaique": "CL",
  "America/Creston": "CA", "America/Cuiaba": "BR", "America/Curacao": "CW",
  "America/Danmarkshavn": "GL", "America/Dawson": "CA",
  "America/Dawson_Creek": "CA", "America/Denver": "US",
  "America/Detroit": "US", "America/Dominica": "DM",
  "America/Edmonton": "CA", "America/Eirunepe": "BR",
  "America/El_Salvador": "SV", "America/Ensenada": "MX",
  "America/Fort_Nelson": "CA", "America/Fort_Wayne": "US",
  "America/Fortaleza": "BR", "America/Glace_Bay": "CA",
  "America/Godthab": "GL", "America/Goose_Bay": "CA",
  "America/Grand_Turk": "TC", "America/Grenada": "GD",
  "America/Guadeloupe": "GP", "America/Guatemala": "GT",
  "America/Guayaquil": "EC", "America/Guyana": "GY",
  "America/Halifax": "CA", "America/Havana": "CU",
  "America/Hermosillo": "MX", "America/Indiana/Indianapolis": "US",
  "America/Indiana/Knox": "US", "America/Indiana/Marengo": "US",
  "America/Indiana/Petersburg": "US", "America/Indiana/Tell_City": "US",
  "America/Indiana/Vevay": "US", "America/Indiana/Vincennes": "US",
  "America/Indiana/Winamac": "US", "America/Indianapolis": "US",
  "America/Inuvik": "CA", "America/Iqaluit": "CA", "America/Jamaica": "JM",
  "America/Jujuy": "AR", "America/Juneau": "US",
  "America/Kentucky/Louisville": "US", "America/Kentucky/Monticello": "US",
  "America/Knox_IN": "US", "America/Kralendijk": "BQ",
  "America/La_Paz": "BO", "America/Lima": "PE", "America/Los_Angeles": "US",
  "America/Louisville": "US", "America/Lower_Princes": "SX",
  "America/Maceio": "BR", "America/Managua": "NI", "America/Manaus": "BR",
  "America/Marigot": "MF", "America/Martinique": "MQ",
  "America/Matamoros": "MX", "America/Mazatlan": "MX",
  "America/Mendoza": "AR", "America/Menominee": "US",
  "America/Merida": "MX", "America/Metlakatla": "US",
  "America/Mexico_City": "MX", "America/Miquelon": "PM",
  "America/Moncton": "CA", "America/Monterrey": "MX",
  "America/Montevideo": "UY", "America/Montreal": "BS",
  "America/Montserrat": "MS", "America/Nassau": "BS",
  "America/New_York": "US", "America/Nipigon": "BS", "America/Nome": "US",
  "America/Noronha": "BR", "America/North_Dakota/Beulah": "US",
  "America/North_Dakota/Center": "US",
  "America/North_Dakota/New_Salem": "US", "America/Nuuk": "GL",
  "America/Ojinaga": "MX", "America/Panama": "PA",
  "America/Pangnirtung": "CA", "America/Paramaribo": "SR",
  "America/Phoenix": "US", "America/Port-au-Prince": "HT",
  "America/Port_of_Spain": "TT", "America/Porto_Acre": "BR",
  "America/Porto_Velho": "BR", "America/Puerto_Rico": "PR",
  "America/Punta_Arenas": "CL", "America/Rainy_River": "CA",
  "America/Rankin_Inlet": "CA", "America/Recife": "BR",
  "America/Regina": "CA", "America/Resolute": "CA",
  "America/Rio_Branco": "BR", "America/Rosario": "AR",
  "America/Santa_Isabel": "MX", "America/Santarem": "BR",
  "America/Santiago": "CL", "America/Santo_Domingo": "DO",
  "America/Sao_Paulo": "BR", "America/Scoresbysund": "GL",
  "America/Shiprock": "US", "America/Sitka": "US",
  "America/St_Barthelemy": "BL", "America/St_Johns": "CA",
  "America/St_Kitts": "KN", "America/St_Lucia": "LC",
  "America/St_Thomas": "VI", "America/St_Vincent": "VC",
  "America/Swift_Current": "CA", "America/Tegucigalpa": "HN",
  "America/Thule": "GL", "America/Thunder_Bay": "BS",
  "America/Tijuana": "MX", "America/Toronto": "CA", "America/Tortola": "VG",
  "America/Vancouver": "CA", "America/Virgin": "AG",
  "America/Whitehorse": "CA", "America/Winnipeg": "CA",
  "America/Yakutat": "US", "America/Yellowknife": "CA",
  "Antarctica/Casey": "AQ", "Antarctica/Davis": "AQ",
  "Antarctica/DumontDUrville": "AQ", "Antarctica/Macquarie": "AU",
  "Antarctica/Mawson": "AQ", "Antarctica/McMurdo": "AQ",
  "Antarctica/Palmer": "AQ", "Antarctica/Rothera": "AQ",
  "Antarctica/South_Pole": "AQ", "Antarctica/Syowa": "AQ",
  "Antarctica/Troll": "AQ", "Antarctica/Vostok": "AQ",
  "Arctic/Longyearbyen": "SJ", "Asia/Aden": "YE", "Asia/Almaty": "KZ",
  "Asia/Amman": "JO", "Asia/Anadyr": "RU", "Asia/Aqtau": "KZ",
  "Asia/Aqtobe": "KZ", "Asia/Ashgabat": "TM", "Asia/Ashkhabad": "TM",
  "Asia/Atyrau": "KZ", "Asia/Baghdad": "IQ", "Asia/Bahrain": "BH",
  "Asia/Baku": "AZ", "Asia/Bangkok": "TH", "Asia/Barnaul": "RU",
  "Asia/Beirut": "LB", "Asia/Bishkek": "KG", "Asia/Brunei": "BN",
  "Asia/Calcutta": "IN", "Asia/Chita": "RU", "Asia/Choibalsan": "MN",
  "Asia/Chongqing": "CN", "Asia/Chungking": "CN", "Asia/Colombo": "LK",
  "Asia/Dacca": "BD", "Asia/Damascus": "SY", "Asia/Dhaka": "BD",
  "Asia/Dili": "TL", "Asia/Dubai": "AE", "Asia/Dushanbe": "TJ",
  "Asia/Famagusta": "CY", "Asia/Gaza": "PS", "Asia/Harbin": "CN",
  "Asia/Hebron": "PS", "Asia/Ho_Chi_Minh": "VN", "Asia/Hong_Kong": "HK",
  "Asia/Hovd": "MN", "Asia/Irkutsk": "RU", "Asia/Istanbul": "TR",
  "Asia/Jakarta": "ID", "Asia/Jayapura": "ID", "Asia/Jerusalem": "IL",
  "Asia/Kabul": "AF", "Asia/Kamchatka": "RU", "Asia/Karachi": "PK",
  "Asia/Kashgar": "CN", "Asia/Kathmandu": "NP", "Asia/Katmandu": "NP",
  "Asia/Khandyga": "RU", "Asia/Kolkata": "IN", "Asia/Krasnoyarsk": "RU",
  "Asia/Kuala_Lumpur": "MY", "Asia/Kuching": "MY", "Asia/Kuwait": "KW",
  "Asia/Macao": "MO", "Asia/Macau": "MO", "Asia/Magadan": "RU",
  "Asia/Makassar": "ID", "Asia/Manila": "PH", "Asia/Muscat": "OM",
  "Asia/Nicosia": "CY", "Asia/Novokuznetsk": "RU", "Asia/Novosibirsk": "RU",
  "Asia/Omsk": "RU", "Asia/Oral": "KZ", "Asia/Phnom_Penh": "KH",
  "Asia/Pontianak": "ID", "Asia/Pyongyang": "KP", "Asia/Qatar": "QA",
  "Asia/Qostanay": "KZ", "Asia/Qyzylorda": "KZ", "Asia/Rangoon": "CC",
  "Asia/Riyadh": "SA", "Asia/Saigon": "VN", "Asia/Sakhalin": "RU",
  "Asia/Samarkand": "UZ", "Asia/Seoul": "KR", "Asia/Shanghai": "CN",
  "Asia/Singapore": "SG", "Asia/Srednekolymsk": "RU", "Asia/Taipei": "TW",
  "Asia/Tashkent": "UZ", "Asia/Tbilisi": "GE", "Asia/Tehran": "IR",
  "Asia/Tel_Aviv": "IL", "Asia/Thimbu": "BT", "Asia/Thimphu": "BT",
  "Asia/Tokyo": "JP", "Asia/Tomsk": "RU", "Asia/Ujung_Pandang": "ID",
  "Asia/Ulaanbaatar": "MN", "Asia/Ulan_Bator": "MN", "Asia/Urumqi": "CN",
  "Asia/Ust-Nera": "RU", "Asia/Vientiane": "LA", "Asia/Vladivostok": "RU",
  "Asia/Yakutsk": "RU", "Asia/Yangon": "MM", "Asia/Yekaterinburg": "RU",
  "Asia/Yerevan": "AM", "Atlantic/Azores": "PT", "Atlantic/Bermuda": "BM",
  "Atlantic/Canary": "ES", "Atlantic/Cape_Verde": "CV",
  "Atlantic/Faeroe": "FO", "Atlantic/Faroe": "FO",
  "Atlantic/Jan_Mayen": "DE", "Atlantic/Madeira": "PT",
  "Atlantic/Reykjavik": "IS", "Atlantic/South_Georgia": "GS",
  "Atlantic/St_Helena": "SH", "Atlantic/Stanley": "FK",
  "Australia/ACT": "AU", "Australia/Adelaide": "AU",
  "Australia/Brisbane": "AU", "Australia/Broken_Hill": "AU",
  "Australia/Canberra": "AU", "Australia/Currie": "AU",
  "Australia/Darwin": "AU", "Australia/Eucla": "AU",
  "Australia/Hobart": "AU", "Australia/LHI": "AU",
  "Australia/Lindeman": "AU", "Australia/Lord_Howe": "AU",
  "Australia/Melbourne": "AU", "Australia/NSW": "AU",
  "Australia/North": "AU", "Australia/Perth": "AU",
  "Australia/Queensland": "AU", "Australia/South": "AU",
  "Australia/Sydney": "AU", "Australia/Tasmania": "AU",
  "Australia/Victoria": "AU", "Australia/West": "AU",
  "Australia/Yancowinna": "AU", "Brazil/Acre": "BR",
  "Brazil/DeNoronha": "BR", "Brazil/East": "BR", "Brazil/West": "BR",
  "CET": "BE", "CST6CDT": "US", "Canada/Atlantic": "CA",
  "Canada/Central": "CA", "Canada/Eastern": "BS", "Canada/Mountain": "CA",
  "Canada/Newfoundland": "CA", "Canada/Pacific": "CA",
  "Canada/Saskatchewan": "CA", "Canada/Yukon": "CA",
  "Chile/Continental": "CL", "Chile/EasterIsland": "CL", "Cuba": "CU",
  "EET": "GR", "EST": "CA", "EST5EDT": "US", "Egypt": "EG", "Eire": "IE",
  "Europe/Amsterdam": "NL", "Europe/Andorra": "AD",
  "Europe/Astrakhan": "RU", "Europe/Athens": "GR", "Europe/Belfast": "GB",
  "Europe/Belgrade": "RS", "Europe/Berlin": "DE", "Europe/Bratislava": "SK",
  "Europe/Brussels": "BE", "Europe/Bucharest": "RO",
  "Europe/Budapest": "HU", "Europe/Busingen": "DE", "Europe/Chisinau": "MD",
  "Europe/Copenhagen": "DK", "Europe/Dublin": "IE",
  "Europe/Gibraltar": "GI", "Europe/Guernsey": "GG",
  "Europe/Helsinki": "FI", "Europe/Isle_of_Man": "IM",
  "Europe/Istanbul": "TR", "Europe/Jersey": "JE",
  "Europe/Kaliningrad": "RU", "Europe/Kiev": "UA", "Europe/Kirov": "RU",
  "Europe/Kyiv": "UA", "Europe/Lisbon": "PT", "Europe/Ljubljana": "SI",
  "Europe/London": "GB", "Europe/Luxembourg": "LU", "Europe/Madrid": "ES",
  "Europe/Malta": "MT", "Europe/Mariehamn": "AX", "Europe/Minsk": "BY",
  "Europe/Monaco": "MC", "Europe/Moscow": "RU", "Europe/Nicosia": "CY",
  "Europe/Oslo": "NO", "Europe/Paris": "FR", "Europe/Podgorica": "ME",
  "Europe/Prague": "CZ", "Europe/Riga": "LV", "Europe/Rome": "IT",
  "Europe/Samara": "RU", "Europe/San_Marino": "SM", "Europe/Sarajevo": "BA",
  "Europe/Saratov": "RU", "Europe/Simferopol": "UA", "Europe/Skopje": "MK",
  "Europe/Sofia": "BG", "Europe/Stockholm": "SE", "Europe/Tallinn": "EE",
  "Europe/Tirane": "AL", "Europe/Tiraspol": "MD", "Europe/Ulyanovsk": "RU",
  "Europe/Uzhgorod": "UA", "Europe/Vaduz": "LI", "Europe/Vatican": "VA",
  "Europe/Vienna": "AT", "Europe/Vilnius": "LT", "Europe/Volgograd": "RU",
  "Europe/Warsaw": "PL", "Europe/Zagreb": "HR", "Europe/Zaporozhye": "UA",
  "Europe/Zurich": "CH", "GB": "GB", "GB-Eire": "GB", "HST": "US",
  "Hongkong": "HK", "Iceland": "BF", "Indian/Antananarivo": "MG",
  "Indian/Chagos": "IO", "Indian/Christmas": "CX", "Indian/Cocos": "CC",
  "Indian/Comoro": "KM", "Indian/Kerguelen": "TF", "Indian/Mahe": "SC",
  "Indian/Maldives": "MV", "Indian/Mauritius": "MU", "Indian/Mayotte": "YT",
  "Indian/Reunion": "RE", "Iran": "IR", "Israel": "IL", "Jamaica": "JM",
  "Japan": "JP", "Kwajalein": "MH", "Libya": "LY", "MET": "BE", "MST": "CA",
  "MST7MDT": "US", "Mexico/BajaNorte": "MX", "Mexico/BajaSur": "MX",
  "Mexico/General": "MX", "NZ": "AQ", "NZ-CHAT": "NZ", "Navajo": "US",
  "PRC": "CN", "PST8PDT": "US", "Pacific/Apia": "WS",
  "Pacific/Auckland": "NZ", "Pacific/Bougainville": "PG",
  "Pacific/Chatham": "NZ", "Pacific/Chuuk": "FM", "Pacific/Easter": "CL",
  "Pacific/Efate": "VU", "Pacific/Enderbury": "KI", "Pacific/Fakaofo": "TK",
  "Pacific/Fiji": "FJ", "Pacific/Funafuti": "TV", "Pacific/Galapagos": "EC",
  "Pacific/Gambier": "PF", "Pacific/Guadalcanal": "SB",
  "Pacific/Guam": "GU", "Pacific/Honolulu": "US", "Pacific/Johnston": "US",
  "Pacific/Kanton": "KI", "Pacific/Kiritimati": "KI",
  "Pacific/Kosrae": "FM", "Pacific/Kwajalein": "MH", "Pacific/Majuro": "MH",
  "Pacific/Marquesas": "PF", "Pacific/Midway": "UM", "Pacific/Nauru": "NR",
  "Pacific/Niue": "NU", "Pacific/Norfolk": "NF", "Pacific/Noumea": "NC",
  "Pacific/Pago_Pago": "AS", "Pacific/Palau": "PW",
  "Pacific/Pitcairn": "PN", "Pacific/Pohnpei": "FM", "Pacific/Ponape": "FM",
  "Pacific/Port_Moresby": "PG", "Pacific/Rarotonga": "CK",
  "Pacific/Saipan": "MP", "Pacific/Samoa": "AS", "Pacific/Tahiti": "PF",
  "Pacific/Tarawa": "KI", "Pacific/Tongatapu": "TO", "Pacific/Truk": "AQ",
  "Pacific/Wake": "UM", "Pacific/Wallis": "WF", "Pacific/Yap": "AQ",
  "Poland": "PL", "Portugal": "PT", "ROC": "TW", "ROK": "KR",
  "Singapore": "MY", "Turkey": "TR", "US/Alaska": "US", "US/Aleutian": "US",
  "US/Arizona": "CA", "US/Central": "US", "US/East-Indiana": "US",
  "US/Eastern": "US", "US/Hawaii": "US", "US/Indiana-Starke": "US",
  "US/Michigan": "US", "US/Mountain": "US", "US/Pacific": "US",
  "US/Samoa": "AS", "W-SU": "RU", "WET": "PT"
}

var FALLBACK = "en"

// The language key a zone is greeted in: the city's own if it has one, its
// country's otherwise. Zones with no country at all - Etc/GMT+5, UTC and the
// rest - are not places and have nobody to greet you; they get the fallback.
function languageFor(zoneId) {
  var id = String(zoneId)
  if (OVERRIDES[id] && LANGUAGES[OVERRIDES[id]]) return OVERRIDES[id]
  // Through countryFor, not the raw table: the alias corrections above are what
  // make Iceland Icelandic, and reading ZONE_COUNTRY directly walked straight
  // past them.
  var key = COUNTRIES[countryFor(id)]
  return (key && LANGUAGES[key]) ? key : FALLBACK
}

// The greeting for a zone at a local hour: { text, roman, language, key }.
// `roman` is "" where the script is already Latin, and callers show it only
// when it is there rather than testing the language.
function greeting(zoneId, hour) {
  var key = languageFor(zoneId)
  var bands = LANGUAGES[key].bands
  var h = Math.max(0, Math.min(23, Math.floor(Number(hour))))
  if (!isFinite(h)) h = 0
  // Bands ascend from 0, so the last one that has started is the one in force.
  var band = bands[0]
  for (var i = 1; i < bands.length; i++) {
    if (bands[i].from > h) break
    band = bands[i]
  }
  return { text: band.text, roman: band.roman, language: LANGUAGES[key].name, key: key }
}

// For the tests, which check every table rather than a sample of them.
function languageKeys() {
  var out = []
  for (var key in LANGUAGES) out.push(key)
  return out
}

function zoneIds() {
  var out = []
  for (var id in ZONE_COUNTRY) out.push(id)
  return out
}

// The country a zone belongs to, "" for the offset-only zones that are not
// places at all. Exposed so the tests can tell a deliberate English from an
// accidental one: English is only ever right when a country asked for it.
function countryFor(zoneId) {
  var id = String(zoneId)
  return ALIAS_COUNTRY[id] || ZONE_COUNTRY[id] || ""
}

function countryCodes() {
  var out = []
  for (var code in COUNTRIES) out.push(code)
  return out
}

function bandsOf(key) { return LANGUAGES[key].bands }
