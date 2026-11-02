function stripJsonc(raw) {
  return String(raw || "")
    .replace(/^\s*\/\/[^\n]*(\n|$)/gm, "")
    .replace(/,(\s*[}\]])/g, "$1")
}

function normalizeAliases(value) {
  if (Array.isArray(value)) return value.filter(function(v) { return v })
  if (typeof value === "string" && value) return [value]
  return []
}

function normalizeItem(id, raw) {
  var value = raw || {}
  var aliases = normalizeAliases(value.aliases)
  var parent = value.parent
  if (parent === undefined)
    parent = id.indexOf(".") >= 0 ? id.split(".").slice(0, -1).join(".") : "root"
  if (id === "root") parent = ""

  var kind = value.action ? "action" : (value.target ? "link" : "menu")

  return {
    id: id,
    parent: parent,
    kind: kind,
    icon: value.icon || "",
    iconFont: value.iconFont || "",
    label: value.label || id,
    title: value.title || "",
    target: value.target || "",
    description: value.description || "",
    action: value.action || "",
    provider: value.provider || "",
    aliases: aliases,
    // Search-only terms: matched by nameSearchText, never by resolveRoute.
    // Translations put the English label here so English search keeps
    // working without making English words routable commands.
    searchTerms: normalizeAliases(value.searchTerms),
    when: value.when || "",
    checked: value.checked || "",
    disabled: value.disabled || ""
  }
}

function parseMenuJsonc(raw) {
  return readMenuJsonc(raw) || []
}

// Like parseMenuJsonc, but null when the text is not a menu at all: what a
// reader sees of a file caught mid-write by an update, a checkout or an
// editor's save. A file of nothing but comments is still an empty menu.
function readMenuJsonc(raw) {
  var stripped = stripJsonc(raw)
  if (!stripped.trim()) return []

  var parsed
  try {
    parsed = JSON.parse(stripped)
  } catch (e) {
    return null
  }
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) return null

  var source = (parsed.items && typeof parsed.items === "object" && !Array.isArray(parsed.items))
    ? parsed.items
    : parsed
  var out = []
  for (var id in source) {
    var entry = source[id]
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) continue
    out.push(normalizeItem(id, entry))
  }
  return out
}

// The rows a watched menu file leaves after a read. An update, a checkout or
// an editor's save can be read mid-write, and that read must not replace good
// rows with nothing, so it keeps the previous ones until a later read finds
// the file whole. The shipped menu is never legitimately empty, so for it
// (required) an empty read is mid-write too.
function keepMenuRows(previous, raw, required) {
  var items = readMenuJsonc(raw)
  if (!items || (required && items.length === 0)) return previous
  return items
}

// The root row has no JSONC entry, so the merge injects it when neither
// source supplies one; only then does rootLabel (the catalog's translation
// of "Go") apply. A root row from either source keeps its own label, so a
// user-supplied heading is never overwritten by the catalog.
function mergeMenuSources(defaultItems, userItems, rootLabel) {
  var nextItems = ({})
  var nextOrder = []
  var sources = [defaultItems || [], userItems || []]

  for (var s = 0; s < sources.length; s++) {
    var src = sources[s]
    for (var i = 0; i < src.length; i++) {
      var entry = src[i]
      if (!entry || !entry.id) continue
      if (!nextItems[entry.id]) nextOrder.push(entry.id)
      var prior = nextItems[entry.id] || {}
      var merged = {}
      for (var k in prior) merged[k] = prior[k]
      for (var k2 in entry) merged[k2] = entry[k2]
      merged.id = entry.id
      nextItems[entry.id] = merged
    }
  }

  if (!nextItems.root) {
    nextItems.root = { id: "root", parent: "", kind: "menu", icon: "", iconFont: "", label: (typeof rootLabel === "string" && rootLabel) ? rootLabel : "Go", title: "", target: "", description: "", aliases: [], searchTerms: [], when: "", checked: "", disabled: "", action: "", provider: "" }
    nextOrder.unshift("root")
  }
  for (var k3 = 0; k3 < nextOrder.length; k3++) nextItems[nextOrder[k3]].order = k3

  return {
    items: nextItems,
    itemOrder: nextOrder
  }
}

// Both merges below return fresh items/itemOrder objects for the caller to
// assign in one go. They must never write into the maps they are handed: those
// live in QML `var` properties, and an in-place write into such an object is
// occasionally dropped by the engine — the key lands with an undefined value.
// A lost write used to leave an id in itemOrder with no item behind it, and
// the next merge then kept that orphan and appended a second row for the same
// app, so the launcher listed it twice (and again on every later rescan).

// Swaps every app row for the current set. Rows keep the order they arrive in;
// ids already claimed (including duplicate desktop ids) are listed once.
function mergeAppRows(items, itemOrder, appRows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var rows = Array.isArray(appRows) ? appRows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    // Orphans (an id with no item) are dropped rather than carried forward,
    // so a single lost write cannot compound into a duplicate row.
    if (!existing || existing.kind === "app") continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < rows.length; j++) {
    var row = rows[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

// Swaps the rows one provider contributed, leaving every other item untouched.
// Rows carry the id of the submenu that produced them, so a provider that runs
// again drops its previous batch — a plugin that was just enabled disappears
// from the Enable list — without disturbing static children declared in JSONC.
function swapProviderRows(items, itemOrder, menuId, rows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var incoming = Array.isArray(rows) ? rows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    if (!existing || existing.providerMenu === menuId) continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < incoming.length; j++) {
    var row = incoming[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.providerMenu = menuId
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

function item(items, id) {
  return items && items[id] ? items[id] : null
}

// Routes may name a real id (`system`, `setup.power`) or an alias declared in
// JSONC (`power-menu`, `settings`). An exact id beats any alias, and app rows
// are never routable: their aliases carry .desktop Keywords and GenericName
// for search, so an installed application could otherwise shadow a menu route
// (htop ships `Keywords=system;...`). Unknown strings fall through as the
// literal input so misspellings still attempt to open that id.
function resolveRoute(items, itemOrder, input) {
  var raw = String(input || "").toLowerCase().replace(/_/g, "-")
  if (!raw || raw === "go" || raw === "menu") return "root"
  if (item(items, raw)) return raw
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (!entry || entry.kind === "app" || !entry.aliases) continue
    for (var j = 0; j < entry.aliases.length; j++) {
      var alias = String(entry.aliases[j] || "").toLowerCase().replace(/_/g, "-")
      if (alias === raw) return entry.id
    }
  }
  return raw
}

function slugify(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "item"
}

function depthFor(items, id) {
  var depth = 0
  var current = item(items, id)
  var guard = 0

  while (current && current.parent && current.parent !== "root" && guard < 32) {
    depth += 1
    current = item(items, current.parent)
    guard += 1
  }

  return depth
}

function pathFor(items, id) {
  var labels = []
  var current = item(items, id)
  var guard = 0

  while (current && current.id !== "root" && guard < 32) {
    labels.unshift(current.label)
    current = item(items, current.parent)
    guard += 1
  }

  return labels.join(" › ")
}

function parentPathFor(items, id) {
  var entry = item(items, id)
  if (!entry || !entry.parent || entry.parent === "root") return ""
  return pathFor(items, entry.parent)
}

function isDescendantOf(items, id, ancestorId) {
  if (ancestorId === "root") return id !== "root"

  var current = item(items, id)
  var guard = 0
  while (current && current.parent && guard < 32) {
    if (current.parent === ancestorId) return true
    current = item(items, current.parent)
    guard += 1
  }

  return false
}

function childCount(items, itemOrder, id) {
  var count = 0
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (entry && entry.parent === id) count += 1
  }
  return count
}

function isVisible(items, itemOrder, whenResults, entry, depth) {
  if (!entry) return false
  if (entry.when && whenResults && whenResults[entry.id] === false) return false
  if (entry.kind !== "menu" && entry.kind !== "link") return true
  if (entry.provider) return true

  var guard = depth || 0
  if (guard >= 32) return false

  var target = entry.kind === "link" ? entry.target : entry.id
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var child = item(items, order[i])
    if (child && child.parent === target && isVisible(items, itemOrder, whenResults, child, guard + 1)) return true
  }

  return false
}

// A `disabled:` row stays listed but goes dim and unselectable. The
// Install submenus use it so software already on the machine reads as
// installed rather than disappearing from the list it was installed from.
function isDisabled(disabledResults, entry) {
  if (!entry || !entry.disabled) return false
  return !!(disabledResults && disabledResults[entry.id])
}

// A disabled row is software you already have, which is the same thing the ✓
// says everywhere else in the menu, so it earns the same marker.
function labelFor(entry, checkedResults, disabledResults) {
  if (!entry) return ""
  var marked = (entry.checked && checkedResults && checkedResults[entry.id]) || isDisabled(disabledResults, entry)
  return marked ? entry.label + " ✓" : entry.label
}

function searchableToken(value) {
  return String(value || "").replace(/[._-]+/g, " ")
}

function leafIdFor(id) {
  var parts = String(id || "").split(".")
  return parts.length > 0 ? parts[parts.length - 1] : id
}

// Pinyin first letters for U+4E00-U+9FFF, indexed from 0x4E00, as pinyin-pro 3.29.5 (MIT) gives them;
// "?" has no common reading, and a polyphonic character keeps only its most common one.
var PINYIN_INITIALS = "ydkqsxhwzssxqbymgcczqpssqbycdscdqldylybsgjgypzjjfgcclzzbwdwzjljpfyynwjjtmyyzwzhflyppqhgccyhynjqyxxgjx?sdsjnjjsmhml?rxyfsnqsyzzqzgqllyjlgyzssecykyyhqwjssggyxyqyjtwkdjhychmyxjtlxjyqbyxdldwrrjjwysrldzjpcbzjjbrcfjlbczstzfxxthtrqgybdlyccscymmrfcyqzpwwjjyfcrwfdfzqpyddwyxkyjawjffxjpdftzyhhycyswccyqsclcxxwzcxnbgnnxbxlzsqsbsjpysyzdhmdzbqbzcwdzzyytzhbtsyyfzgntnxqywqykbphglxgybfmjebjhhgqtjcysxstkzglyckglysmzxyalmeldccxgzyrjxsdltjzcqkcnnjwhjczzcqljststbnxbtyxceqxgkwjyflzqlyhjqspsfxlfpbysxxxydcczylllsjxfhjxpjbcffyabyxbhczbjyclwlczggbtssmdtjcxpthyqtgljscjfzkjzjqnlzwlslhdzbwjncjzyzsqnycqyrzcjjwybrtwpyftwexcskdzctbxhyzcayjxzcfbzzmjyxxcdczottbzljwfckszsxfyrlnygmbdthjxsqqccsbxrytsyfbjdztgbcnclcyzzpsacyzqscjcshzqydxlbpjllmqxtydzxsqjtzpxlcglqdcwjbhctdjjsfxyejjtlbgxsxjmyjjqpfzasyjncydjxkjcdjszcbartcclnjqmwnqnclllkbybzzsyhqcltwlccrshllzntylnewyzyxczxxgdkdmtcedeqtsyys?d?d??sd?j?hrwnqlybglxhlgtgxbqjdz?yjsjyjcjmrnymgrcjczgjmzmgxmmryxkjnymsgmzzymklfxmbdtgfbhcjykylpfmdxlqjjsmtqgzsjlqdldgjycalcmzcsdjllnxdjffffjczfmzffpfkhkgdpkxktacjdhhzdddrrcfqyjkqccwjdxhwjlyllzgcfcqdsmlzpbjjplsbcjggdckkdezsqcckjgcgkdjtjllzycxklqccgjcltfpcqczgwbjdqydjjbyjhsjddwgfsjgdkccctllpspkjgqjhzzljplgjgjjthjjyjzczmlzlyqbgjwmljkxzdznjqsyzmljlljkywxmkjlhskjgbmclyymkxjqlbmclkmdxxkwyxwslmlpsjqjjqxyqfjtjdxmxxllcrqbsyjbgwy?xggbcyxpjtgpepfgdjgbhbncfjyzjkjkhxqfgqzkfhygkhdkllsdjjxpqykybnqsxqnszswhbsxwhxwbzzxdmndjbsbkbbzklylxgwxjjwaqzmywsjqlcjxxjqwjeqxscwetlzhlyyysdzpyqyzcmtlshtzcfycyxyljsdcjjagyslcllyyysglqqq?ldxzsccccadycjysfsgbfrlszqsbxjpsjwsdrckgjlgdkzjzbdktcsyqpyhstcldj?hmxmcgxyzhjdctmhltxzxylamohyjcltyfbqqjbfbdfehtksqhzywwcnxxcdwhhwgyjlegwdmcwgfjhcsntfydolbyghqwesjpwnmlrydzsztxyqpzgcwhhnxpyhshmdqzxztdppbfyhzhhjyfdzwkgkzbldntsxhqeegzxylzmmzyjzgszxhhkhtxexxwylyapsthxdwhzydpxagkydxbynhxkd?jnmyhylpmgocslnzhkxxlbzzlbmlsfbhhgcgyyggbhscyajtywlxtzqcwzydqdqm?gd?llszhlsjzwfyhqswscelqajynytlsxthazgkzzsdhlacqtwwcdgqqtddyzbcchyqzflxpslzygpzsznglydqtbdlxjtctajdkywnsyzljhhdzcwnxyzywmhychhhxhjkzwsxhdyxlyscqydpclyzwmyp?kxyjlkzhtyhaxqsysgxasmchkdscrswjpwxsgzjlwwschs?hsqnhzsngndaqtbaalzzmsstdqjcjktscjaxplggjhhgoxzcxpdmmhldgtybysjmxhmrzplxjzckzxshflqxctdhxezfchzccdjtcjyxqhlxdhypjqxnlsyydzozjnyxqezysjyayjkypdgxddxsppyzndlthrhhydxzjjhtcxmctlhbynyhmhzllxnamylllpdcppxhmxdkycyrdltxjchhznxzlcclylnzsxzjzzlnn?lwhyqsnjhxyntttkyjpychhyegkcwtwlgqrlggtgtygyhpyhylqyqgcwyqkpyyyttttlhyhlltyttsplkyzxgtwgpydqqzzdqxskcqnmjjzzbxyqmjrtffbtkhzkbjdjjkdjjtlbwfzpptkqtztgpdwntpjyfalqmkgxfdclzfhzclllladpmxdjhlcclgyhdzfgyddgcyyfgydxkssebdhykdkdkhnaxxybpbyyhxccgabdqyjxdmljcsqzllpchbsxgjyndybyqspqwjlzktddtaccbkzdyzypjzqsjnkktknjdjgyepgtlfyqkasdntcyhblgdzhbbydmjragkzyheyybjmcdtyfzjjhgcjpljhldwxjjkytcyksssmtwcttqzlpbszdtwzxgzagyxtywxlhlcpbclloqmmzsslcmbjqsdzkydczxgqjdsmcytzqqlwzqzxssfpktfqmddzdsddtdwfhtdyzjaqjqkypbdjyyxtljhdrqxlxhaydhrjlklytwhllrllrcxylbwsrszzsymkzzhhkyhxksmcsyzgcjpbzbsqlfcxxxnxkxwwmsddyq?ggqmmyhcdcttfgyyhgstttybykjdhkyjbelhdypjqnfxfdqkzhqkzbyjtzbxhfdxbdaswhawajldyjsfhbldnndnqjtjnchxfjsrfwhzfmdrfjyhwzpdjkzyjymfcyznynxfbytfwfwygdbnzzzdnytxzemmqbsqehxfzmbmflzzsrsymjgsxwzjsprydjsjgxhjjgljjynzzjxhgjkymlpeyycxysgqzswhwlyrjlpxslcxmfswwkcctnxnynpnjszhdzeptmmwywxyysywlxjqzqxzdclaeelmcpjpclwbxsqhfwwtffjtnqjhjqdxhwlbyzcfjlnlhyyjldxhhycstdywnrjtxywdrmdrqhwqcmfjdyzmhmayxjwmyzqtxdlmrspwwchajbxtgcypxyyrrclmpamgkqjszyjrmyjsnxtplnbappypylxmyzkynldgyjzczhnlmzhhanqmpgwqtzmxxmllhgdzxyhxkrxycjmffxyhjfsbssqlqxndycannmtcjcyprrnytyqnyymbmsxndlylysljnlqysxhmllyzlzjjjkymzcsfbzxxmstbjgnxyzhlsnmcqscyznfzlxbrnnnylmnrtgzqysatswryhyjzmzdhzgzdwybsscskxsyhytsxgcqgxzzbhyxjscrhmkkbscjjyjymkqhzjfnbhmqhysnjnzybknqmclgqhwlsnzswxkhljhyybqcbfcdsxdldspfzfskjjzwzxsddxjseeegjscssmgclxxhwwyllymwwwgydkzjgggtggsycknjwnjpcxbjjtqtjwdsspjxzxnzxwmelbtfsxtllxcljxjjljsxctnswxlahhhyqrwhsycsqrybyaywjejqfwqcqqcjqgxaldbzzyjgkgxpltqyfxjltpadkyqhpmatldpdzkxmtxybhblefxdleegqdymsawhzmlftwyqxlyqzljeeyxbqqffnlyxrdsctgjgxywlkllxqkcctlhjlqmkkzgcyygllljdzgydhzwxpysjbzjdzgyzzhywyfqytyzszyezklymhjjhtsmqwyzlkyywzcsrkqyqltcxwcdrjalwskzwbdcqyncjsrszjlkcdcdtlzzzacqqwzddxyplxcbqjylzlllqdtzjjyjyjzyxnyyynxjxkgdazwyrdljyyyrjlxlldyxjcykywnqcclddnyyykyckczhjxcclgzqjgjwggcqqjysbzzxyjxj?xjfzbsbdsfnsfpzxhdwztdmpptflzzbzdmyypqjrsdzsqzsqxbdgcpzjwdwcsqzgmzhzzmwwfybpdgphtmjthzsmmbgzmbzjcfzhfzbbzmqcfmbcmcjxlgpnjbbxgyhyyjgptzgzmqbqdcgybjxlwzkydpdymgcftpfxyztzxdzxtgkmtybbclbjaskytssqyymscxfjeglsllszbqjjjaklyldlycctsxmcwfgkkbqxlllljyxtyltyxytdpjhnhgnkbyqnfjyyzbyyessessgdyhfhwtcjbsdzjtfdmxhcnjzymqwsrxjdzjqptqbbsdjggfbkjbxdgqhmgwjjjgdllthzhhyyyyyhsxwtyyyccbdbpypzyccztjpzywcbdlfwzcwjdxxhyhlhwczxjtcclcdpxdjczczlyxjjsjbhfxwpywxzptdzzbdccjhjhmlxbqxxbylrddgjrrctttgytczwmxfytmmzcwjwxjywcskybzqccttqnhxnkxxkhkfhtswoccjybcmpzzykbnnzpbthhcdlsyddytyfjpxyngfxbyqxcbhxcbsxtyzdm?ysnxsxlhkmzxlthdhkghxxsshqyhhcjyxglhzxcsnhekdtgqxqypkdheqtykcnymyyypkqyytjxzlthhqtbyqhxbmyhsqckwwyllhcyylnneqxqwmcfbdccmljggxdqktlxkgnqcdgzjwyjjlyhhqdttnwchhxcxwheszjydjccdbqcdgdnyxzdhcqrxcbmztqcbxwgqwyybxhmbymykdyecmkkyaqyngycslfykkqgyssqyshjgjcnxkzycxsbkyxhyylctycxqthysmgscpmmgcccccmtztasmgqzjhklosjylswtmqsyqkdzljqqyplcycztcqqpbbqjzclpkhqcyyxxdtdddsjcxffllchqxmjlwcjcxtspycxndtjshjwxdqqjckxyamylsjhmlalygxcyydmamdqmlmcznnyybzkkyflmchcmlhxrcjjhsylnmtjggzgywjxsrxcwjgjqhqzdqjdzjjzkjkgdzqgjjyjylxzhxcdqhhhestmhlfsbdjsyyshfyssczqlpbdrfrztzdkyyhsctgkwdqzrkmsynbcrxqbjyfbxpzzedzcjykbcjwhyjbqdzywnyszptdkzpfpbaztklqyhbbzpnbptyzzybhnydcpjmmcycqmzjfzzdcmnlfpbplngqjtbttajzpzbbdnjkljqylnbzqhksjznggqsczkyxchpzsnbcgzkddzqanzgjkdntlzldwjljzlywtxndjzjhxyatncbgtzcsskmnjbjytsrwxcpjwjjtkhtzplbhsnjzsyjbwbzyzlstlsbjhdwwqpslmmfbjdlajyzccjtbnnrzwqxcdslqgdsdpdzhjtqqpsqlyyjzlgnhyzlctcbjtktyczjtqkbpjlgmjzdmcsgpynjzjjyyknhrpwszxmtncszzyxhbyhyzaxywkcjdllckjjtjhgcxdxyjyczbywblwqcglzgjgqrqcczssbcrpcskydznljsqgxssjmecnstjtpbdlthzwhqwqtzexnqczgwesgssbybstscsjccgbfsdqszlccglllzghzqthcnmjgyzaznmckcstjmmzckbjygqljyjppldxrgzyxccsnhshhdznlchzjjcddcbcjxlbfqbczzwpqdnhxljcthqzjgylnlszzpcjdscqqhjqkdxkpbajyemsmjtzdxlcjyryynhjbngzzkmjxltbsllrtpylcsznxjhllhyllqqzqlxymrcwcxsljmczltzldwdjjllnzggjxppskygyggbfzpdkmwghcxmcgdxjmcjsdycabxjdlnbcddygskydqtxdjjyxmsaqazdcfslqxyjsjzylblxxwxqqzbjzlfbblylwdsljhxjyzjwtdjcyfqzqzzdzsxzzqlzcdzfchwspympqzmlpplffxjjnzzylsj?yqzfpfzksywjjjhrdjzzxtxxglghtdxcskyswmmtcwybazbjkshfhgcxmhfqhyxxyzftsjyzbxyxpzlchmzmbxhzzssyfymncwdabazlxktcshhxkxjjzjsthygxsxyyhhhjwxkzxssbzzwwhhcwtzzzpjxsnxqqjgzyzawllcwxzfxgyxyhxmkyydwsqmnjnaycyspmjkhwcqhylajjmzxhmmcnzhbhxclxtjpltxyjhdyylttxfszhyxxsjbjyayrsmxyplckdlyhlxrlnllstyzyyqygyhhsccsmzctzcxhyqfbyyrpbflfqtntszlljmhwtcjqyzwtllmlm?wmbzzs?zrbpdddlgjjbxccsrzqqygwcsxfwzlxccrstdzmcyggdyqsgtjmwljmymmsyhbbjdgyxccpshxnzcsbsjwjgjmppwaffyfnxhydxzylremzgzcyhsszdlljcsqfzxxkptxzgxjjgbmyyysnbtylbnlhpfzdcyfbmgqrrmsszxysgtznnyddzcdgbjafjbdknzblcsszbsgcycjszlmlrszbzzldl?llysxsqcqlyxzlsgkbrxbrbzcycxzjzeeyfgklzlyyhgzsgzlfjhgtgwkraajyzkzqtsshjjxdcyz?yjlzyrzdqqhgjzxsscbtgjbbfrtjxllfqwjgslqtymblpzdxtzagbdhzzrbgjhwnjtjxlksqfsmwlldqysjtxkzscfwjlbxftzlljzllqblcqmqqcgcdfpbbhzczjlpyygjdtgwdcfczqyyyqysrclqzfklzzzgffcqnwglhjycjjszlqzzyjbjzzbpdccmhjgxdqdgdlzq?fgpsytsdyfwwdjzhysxyycjcyhzwpbygxrylybhkjksfxtjjmmckhlltnyymsyxyzpdjjycdycwmdjjkqyrhllqxpsgtlwycljscbxjyzfnmlrgjjtyzbsyzmsjyjhgfzqmsyxrszcwtlrtqzsstkxgqggsptgcdnjsgcqcqhmxggztqydjkzdlbzsxjlhrqgggthqscpyhjhhgnygkggcmjdzllcclxqsftgzslllmlcskccbljzzszmmnytpzsxqhjcjyqxyexzqzcpshgzzysxcdfgmwqrllqxrfztlystctmjcsjjthjnxtnrztzfqrhqgllgcxszzjdjlxcytsjtlnyxhszxcgjzyqpylfhdjsbpcczgjjjqzjqdybssllcmyttmqtbhjqnnygjynqyqmzgcjkpdcgmyzhqllsllclmholzgdylfzsljcqzlylzcjeshnyllqxgjxlyjyyyxnbcljsswcqqcjyllcldqyllzllbnylgqchxyyqoxccqkyjxxhyklksxaqqccqkkkkcsgyxxyqxygwtjohthxpxxxxslcyeychzzcbwqbbwjqzscszsslzylgdesjzwmymcytsdsxxscjpqqsqylyfzychdjdzywcbtjsycjkcyddjlbdjjsodzyqysqkyxdhhgqjyohdyxwgmmmajdybbbppbcmhcbljzsmtxerxjmhqdstpjdcbssmsssthjtslmmtrcplzszmlqdsdmjmqpnqdxcfynnfsdqqyxhyaykqyddlqyyysszbydslntfgtzqbzmchdhczcwfdxtmqqsphqwwxsrgjcwtjtzzqmgwjjrjhttjbbgwzfxjhnqfxxqywyyhyscdydhhqmnmtmmchbszppzzgpmzfollcfwhmmsjzttdhlmyffytzzgzyskjjxqyjzqbhmbzclyghgfmshpcfzsnclpbqsnjyzslxjfpmtyjygbxlldlxpzjypjyhhzcywhjylsjexfsszywxkzjlladyslymqjpwxxhxsktqjezrpxxzghmhwqpwqlyjjqjjzszcfhjlchhnxjlqwzjhbmzyxbdhhypylhlhlgfwlcfyytlhjjcjmscpxstkpnhjxsntyxxtestjctlsslstdlllwwyhdhrjzsfgxssyczykwhtdhwjslhtzdqdjzxxqggyltzphcsqfzlnjtclzpfstpdynylgmjllycqhynsbchylhqyqtmzybbywrfqykjsyslzdyjmpxyyssrhzjnyqtqdfzbwwdwwrxcwhgyhxmkmyyyhmsmzhngcepmlqqmtcwctmhpxjpjjhfxyyzsjzhtybmstsyjdtqqqytlhynbyqzlcxcnzwsmylkfjxlwgbypjytysylymzcktdwlgsmzsylmpwlzwxwqzssazsyxyrhssntsrapccpwcmgdhhqzdzxfjhgzttsbjhgyzlzysmyclllybtyxhbbzjkssdmalhhycfygmqypjycqxjllljgclzgqlycjcctotyxmtmshllwcgfxymzmklpszzcxhhjyslctyjcyhxsgyxckxlzwpyjpdhjwpjpwsqqxlxxdhmrslzcyzwttcxkystzshbsccstplwsscjchjlcgcjssphylhfhhxjsxallnylmzdhzxylsxlwzykcldyahzcmgdyspjtqjzlngjpsjshctsdszlblmssmnyymjqbjhrcwtyydchqljapzwbgqybkfcmjwlzllyylszydwhxpsbcmljpscgbhxlqhyrljxyswxhxzlldfhlslymjlzyflyjycdrjlfsyzfsllcqyqfgjyhyszlylmstdjcyhbzllnwlxxygyyhhmgdhxxhhlzzjzxczzzcyqzfnjwpylcpkpyypmclqkdgxzggwqbdxzzkzfbxxlzxjtpjpttbytszzdwslchzhsltjxhqlhyxxxywzyswtmzkhlxzxzpyhgchkjfsyh?tjrlxfjxptztwhplyxfcrhxshhkjxxyhzjdxjwylhyhmjtbflkhtxcwhcfwjzfpqrxqxcyyyjygrpxgscsxngqchkzdxhflxxhjjbyzwtqxxncyjjymswyjqrmhxzwfqsylzjzgbhynshbgttcsebhxxwxyhhxyxxsqyxmlywrgyqlxbbcljsylfcytjzyhyzawlhorjmksczjxxxyxchcytryxqjddsjfslyltsffyxlmtyjmzjyyyxltzcsxqzlhzxlwyxzhdnlxxhxjcdyhlbrlmbrllaxksllljlyxxlycrylcjcgqcmtlzllcyzzpzpcyawhjjfybdyyzsepckzdqyqpbpcjpdcyzbdbbcyydycnnpjmtmlrmfmmgwygbsjgyksmdqqqztxmkqwgxllpjgtbqcdjjjfpkjkcxbljmswmdtqjxldlppbxcwkcqqbfqjczagzgmykphyyfzykndkzmbpjyxpxthlfpnyygxjdbkxnhhjhzjxstrstldxskzysybmxjlxyslbzyslhxjpfxbqnbylljqkygzmcyzzymccsl?lhzgwfwyxzmwcxtynhjhbyymcysbmhysmhdyshqyzchmjjmzcaahcfjbbhplxtylsxsdjgjdhkxxtxxnbhnmlngsltxmrhnlxqjxmzllyswqgdlbjhdcgjyqyymhwfmjybbbyjmjwjmdpwhxqldyapdfxxbcgjspckrssyzjmslbzzjfljjjlgxzgyxyxlszqyxbexyxhgcxbpldyhwecdwwcjmbtxchxyqxllxflyxlljlssfwdbzcmyjclmsytczbchqekcqbwlcgydblqppqzqfjqdjhymmcxtxdrmjwrhxcjzclqxdyynhyyhrslsrsywwzjymtltllgtqcjzyabtckzcjyccqljzqxalmzyyyzlwdxzxqdlljshgpjfjljhjabcqzdjgthhsstcyjlbswzlxjxrwgldlzrlzqtgsllllzlymxqgdzhgbdbhzpbrlw?x?bpfdwo???hlypc?jcc?dwbzpbzz?cyqxldomzblzwpdwyygdstthcsqsccrsssyslfybbntyjsydfndpthtzzmbbmxlcmyffgtjjqwftmdpjwdnlbzcmmczgbdzlqlfyfhssmjylsdchdzjwjcctljcldtljjcpddpjdssdynndbjlggjzxsxnlycybjjqycbylzcfzppgkcxzdzfztjjfgsjxzbnzyjqttyjwhtyczhymdjxttmpxsplzcdwslshxybzgtfmmcjtacbbmgdkwycyzcdszzyhflyctygwhkjyylsjcxgywjcbllcsnddbtzbsclyzczzssqdllmqyyhfllqllxfdyhabxggnywyypllsdldllbjcyxjzmlhljdxyyqytdlllbbgbfdfbbbjzzmdpjhgclgmjjpgaehhbwcqxaxhhhzchxyphjaxhlphjpgpzjqcqzgjjzzgzdmqyybdzphyhybwhazyjhykfgdpfqsdlzmljxjpgalxzdaglmdgxmmzqytxdxxpfdmmssympfmdmmkxksyzyshdzkjsysmmzzzmsydnzzczxbplstmddnmxckjmztyymzmzzmsqhhdccjemxxkljstgwlsqlyjzllsjssdbpmhnlyjczyhmxxhhzcjmdhxtkgrmxfwmcgmwkdcksxqmmmfzzydkmsclcmpcgmwspxqpzdsslcjkyxtwlgjyahzjgzqwcsnxyhmmpmlkjxmhlmlgmxctkzmjjyszjsyszhsyjzjcdajzybsdqjzgwzkgxfkdmsdjlfmehkzqkjpeypzyszcdwyjffmzjylttdzzefmzlbnpplplpbpszalltylkckqzkgenqlhagyxydpxlgsxqqwq?kxqclhyxxmlyccwlymqysky?hlcjnszkpyzkcqzqljbdhdjhlasqlbydwqlwdnbqcryddztjybkbwszdxdtnpjdtctqdfxqqmgnseclstbhpwslctxxlpwydzklzygzcqapllkccylbqmqczqcljslqzdjxldthpjqdljjxzqdjyzhkzljcyqdyjppypeakjyrmpcbymcxkllzllfqpylllmbsgjcysslrsysqtmxyxqqzbdzrysyztffbzzsmzqhzssccmlyxwtpzgxzjgzgsjsgkddhtqggzllbjdzlcbchyxyzhzfyxxyzymsdbzzyjgtsmtfxqyxjssdgslnmdlrytzlryylxqhtxsrtzcgzxbnqqzfhykmzjbzymkbpnlyzpblmcnqyzzdsjzhjctshhyzzjrdyzhnfxglfxslkgjtctssyllgzrzbbjzzklpkbczyslxyxbjfpnjzzxcdwxzyjxzzdjjgggrsrjkmsmzjlsjywqs?yhqjsxpjztzlsnshrnypjtwchklbsrzlcxwjqxqkysjycztlqzybbybwkjqdwwyzcytjcjxckcwdkkzhsgkdzxwwyyjqyytcytdjlxwkcckklcclzcqqdzlqlcsfqchqhsfsmqzzllbjjzbsjhtsjdysjqjpdlzcdcwjkjzzlpycgmzwdjjbsjqzsyzyhhxcbbjydssddzncglqmbtsfcbfdzdlznfgfjgfsmptjqlmblgqcyyxbqkdjjqsrfkztjdhczklbsdzcfytplljgjhtxzcsszzxstcygkgckgyoqxjplzpbbgtgyjzgczjszlbjlsjfzgkqqjcgyczpzqtldxrjxbsxxpzxhszyclwdxjjhxmfczpfzhqhqmqgkylyhtycgfrzgnqxcgpdlbzcsczqlljblhbdcypzzppdymtzsgyhckcpzjgslclnscdsldzxbmsdlddfjmkdjdhslzxlszqpqpgjllybdszgqlbzlslkyyhzttncjyqtzzfszqztlljtyyllqllqyzqlbdzlslyyzymdfszsnhlxznczqzbbwskrfbcyzmthblgjpycnzcstlxshtzcyzlzblfeqhlxflcjlyljqcbzlzjghsstbrmhxzhjzclxfnbgxgtqjcztmsfzkjmssnxljkbhszxntnlzdntlmsjxgzjgjczxyhyhwrwwqnztnfjscpzshzjfyrdjsfscjzhjfzqzchzlxfxsbzqlzsgyfttdcszxzjbqmszkjrhxjzcgbjkhcggtjkjqglxbxfgtrtylxjxgdtsjxhjzjjcwzlcqsbtxhqgxtxxhxftsdkfjhzyjfjxrzcdlljcqsqqzjwqxswqtwgwbzcgcllqzbclmqjtzgzxzxljfrmyzflxyszxxjkxrmjdzdmmyxbsqbhgzmwfwtgmxlzbyytgzyccdxyzxswg?yjyznbgpzjcqsyxcxrtfyzgrhztxszzthcbfclsyxzlzqmzlmplmxzjssflbysmyqsxjzxrxsqzzzssljflczjrcrxhhzxqwdshxsjjhqcxjbdynsysxjbqlpxzzpymlxzkyxlxcjlcycrxzzlldlllsjyhzxhyjwkjrwyhcpsgnrzlfzwfzznsxgxflzsxzzzbfcsyjdbrjkrdhhgxjljjtgxjxxstjtjxlyxqfcsgswmsbctlqzzwlzzkxjmltmjwhsddbxgzhdlbmyjfrzfsgclyjbpmlysmsxlszjqqhjzfxgfqfqbpxzgyyqxgztcqwyltlgwwwwhwlfsfgzjmgmgbgtjfsyzzgzyzaflsspmlbflcwbjzcljjmzlpjjlymqdmylyfbgygqzmlyzdxqyxrqqqhsxyyqqygjtyxfsfsllgnqcyhycwfhcccfxbylypllzqxxxxxkqhhxshjzcfdsczjxcpzwhhhhhapylhalpqafyhxdyllkmzqgggddesrenzltzgchyppcsqjjhclljtolnjpzljlhymheydydsqycddhgzpndzclzywllznteytgxlhslpjjbdgwxpcdntjcklkclwkllcasstknzdnqnttlyyzssysszzryljqkcgbhhcrxrzydgrgcwcgzhffbppjfzynakrgywyqpqxxfkjtszzxswzddfbbqtbgtffznpzfpzxzpjszbmqhqcyxyldkljnypkygggdcjxxeahpnzgztzcmxcxmmjxnkszqnmnlwbwwxjjrhclstmcsjdzcxxtpcnpdtnnpglllzcjlspblpgjcdtnjnlyyrszffjfqwdpgzdwmrzcclodaxnssnyzrestyjwjyjdbcfxnmwttbqlwstszgybljpxglboclgpcbjftmxzljylzxcltpnclckxtfzjswcrxsfyszdkntlbyjcyjllstgqcbxnwzxbxklylhzlqzlnzcqwgzlgzjncjgcmnzzgjdzxtzjxycyycxxjyyxjjxsssjstssttppghtcsxwzdcsyfptfbchfbblzjclzzdbxgcxlqpxkfzflsyltywbmnjhskbmddbcysccldxycddqlyjjhmqllcsgljjsyfpyycayldjantqjpwycmmgqyysxdhqmzhszxpftwwzqswqrfkjlxjqqyfbrxjhlfwjgzyqacmyfrhccybyqwlpexcczsdyrlttdmqlykmbbgmyyjprkznpbsxyxbhyzdjdnghpmfsgbwfzmfqmmbzmzzcjjlcnyxyqgmlrygqccyhzlwjgcjchgmcjjfyzzjhycfrrcmtzqzxhfqgdjxccjeaqcrjyhpljlszdjrbcqhqdzrhylyqjsymhzydwldfryhbbydtssccwbxglpzmlzztqsscpjmmxjcsjytycwhycjwynsxlpemwjnmkllswtxhyyy?cmmcwjdqdjzglljwjnkhpzggflccsczmcbltbhbqjxqdjpdjqtghglfqawbzyzjltstdhqhctcbchflqmpwdshyytqwcnztjtlbypbpdyyyxsqkxwyyflxxncwcsybmaelykkjmzzzbrxyaqjfljpfhhhxtzzxsgqqmhspgdzqwbwpjhzjdyjcqwzkthxsqlzyymysdzgrxckkhjlwpysyscsyzlrmlqsyljxbcxtlhdqzpcycykpppnsxfyzjjrcemhszmsxlxglrwgcstlrsxbygbzgztcpldjlslylymdtmtzpalcxpxjcjwtcyyzlblxbzlqmyljpghdslssdmhmbdczsxwhamlczcpjmcnhjyjnsygchskqmzzqdllkablwjqsfmocdxjrrlyqzhjmybyqlrhetfjzfrfksryxfjdwdsxxswsqjyslyxwjhsnlxyyxhbhawhhjcxwmyljcsqlkydttxbzsxfdxgxsjkhsxxybssxdpynzwrptjzczenygcxqfjykjbdmljcmqqxloxslyxxlylljdzbtymhbfsttqqwlhogyblscalzxqlhtwrrqhlstmypyxjjxmqsjpnbryxyjllyqylthylqyfmlgljdmllhfzwkzhljmlhljklj?tlqxylmbhhlnlsxqchxcfxxlhyhjjgbyzzkbxscqdjqdsxjzsygzhhmgsxcsymxfebcqwwrbpyyjqtyqcyjhqqzyhmwffhgzfrjfcdbxndqyzpcykhjlfrzgpbxzdbbgzqstlgdtylcqmgchhmfywlzyxkjlypjhsywmqqgqzmlzjnsqxjqsyjtcbehsxfssfxzwfllbcyyjdytdthwzzfjmqqyjlmqsxlldttkhhybfpwdyysqqrnqwlgwdebdwcyygcdlkjxtmxmyjsxhybrwfymwfrxyymxysctzzdfykmldhqdlwyqnlcryjblpsxcxywlsbrrjwxhqybhtydnhhgmmywytzcsqmdssccdalwztcpqpyjllqzyjswxwzzmmglmxclmxczmxmzsqtzppjqblpgxjzhbljjhycjsnxwcxsccdlxsyjdcqcxslqyclzxlzzxmxqrjmhrhzjphmfljlmlclqnldxzlllfypngjysxcqqdcmqjzzxhnpnxzmekmxxykyqlxsxtxjxyhwdcwdzhqyybgybcyscfgfsjnzdrzzjzxrzrqjjymcanhrjtldbpyzbstjhxxzypfdwfgzzrpymtngxzqbyxmbbfcckrpjjbjegrzgyclkhzdxkknsjkcljspjyyzlqqjybzssqlllkjbcbktylccddblsppfylgydtzjyqggkqttfcxbdkdxxhybbfytyhbclpdytgdhryrnjsbtcsnyjqhklllzslydxxwbcjqsbxbfjzjcjdzfbxxbrmlazgcsnclbjdstblfrz?swsbxbcllxxlzdjzsjpylyxyyfqf?fbhjjjgbygjpmmmpssczjmtlyzjxswxtyledqpjmygqzjgdjlqjwjqllsdgjgygmscljjxdtygjqjqjcjzcjgdzdshqgsjggcjhqxsnjjzzbxhsgzxcxyljxyxyydfqqjhjfxdhctxjdrxysqtjxyefyyssyxjxncyzxfxcsyszxyyschshxzzzgzzzgfjdldylnpzgyjyztyqzpbxqbdztzczyxxyhhscxshcggqhjhgxwsctmzmlhyxgebdylzkkwytjzrclekestdbcykqqsayxcjxwwgsbhjszydhcsjkqcxswxfctynydpzcczjqtzwjqdzzzqzljchlsbhbydxpsxshhezdxfptjqyzzxhyaxncfzyyhxgnxmywxtzsjbkhhgymxmxqcxtsbcqsjyxhtyylybcqlmmszmjzjllcogxzaajzyhjmchhcxzsxzdznleyjjzjbhzwzzsqtjpsxztdsxjjjznyazphhyysrrqdthzhayjyjhdzjzlswclybzyecwcycrylcxnhzydzydyjdfrjjhtrsqtxyxjrjhojynxelxsfsfjzghpzsxzszdzcqzbyyklsgsjhczshdgqgxyzgxchxzjwyqwgyhksseqzzndzfkwysstclzstsymcdhjxxyweyxczaydmpxmdsxybsqmjmzjmtzqlpjyqzcgqhxjhhhxxhlhdldjqcldwbsxfzzyyschtytyjbhecxhjkgjfxbhyzjfxhwhbdzfyzbcapnpgnydmsxhkmmmamlnbyjtmpxyjmcthjbzyfcgdyhwphftgzzezsbzegpbmdskftycmhbllhgpzjxzjgzjyjzsbbqsczzlzccstpgxmjsfdcczjzdjxcybzlfcjsazfgszlybcwzzbyzdzypswyjgxzbdsysxlgzbzfygczxbzhzftpbgzgejbstgkdmfhyzzjhzllzzgjqzlsfdjsscbzgpdlfzfzszyzyzsygcxsntxchczxtzzljfzgqsqyxzjqccccdjcdxzjyqjqcgxztdlgscxzsyjjqtcclqdqztqchqqjzyezzzpbkkdgfcjfztypqyqttyjlmbdktjcpqzjdzfpjsbnjlgyjdxjdzqkzgqkxdlbzjtcjdqbxdjjjstcjnxbxcmslyjcqmtjjwwcjjnjnlllhjcwqtbzqyczczpzzdzyddcyzdzccjgtjfcdprntctjdcqtqndtjnplzbcllctdsxkjzqdpzlbznbtjdcxfczdbccjjltqqpldcgztbbzjcqdcjwynllzlzccdwllxwzlxrxntqjczxkjlsgdfqtddglrlajjtklymkqlldzytdyyjygjwyxdxfrskstcdenqmrkqzhhqkdldazfkypbggpzrebzzykyqspegjjglkqzzzslysywyzwfqznlzhlzhwcgkypqgnpgblplrrjyxcccgyhsfzfwfzywtgzxyljczwhxzjzblfflgskhyjdeyjhlpllllcygxdrzelrhgklzzyhzlyqszzjzqljzflnbhgwlczcfjwspyxnlzlxgccpzbllcxbbbbxbbcbbcrnnzccyrbdsyldcgqyyqxygmqzwtzydyjhyfwdehzdjywlccctzyjjcdedpzdztsy?jhdymbjnyjzlxtsstphndjxxbyxqtzqddtjtdyztgwscszqflshlglbczbhdlyzjyckwtydylbnydsdsycctyszyyebgexhqddwnygyclxtdcystqmygzasccszzddlcclzrqxyyeljsbymxshztembbllyyllytdqyshymrqxkfkbfxnxsbychxbwjyhtqbpbsbwdzylkgzskyghxzjhhxjxgnljkzlyycdclfwfghljgjybxblybxqpqgztzplncybxdjyqydymrbesjyyhkxxstmxrczzywxyhybmcflyzhqyzmqxdbxbzwzmslpdmyckfmzklzcyqyczlhxfzlydqzpzygyjyzmdxdzfyfyttqtchgsfczmlccytzxjcytjmkslpzhysnwllytpzctzzcktxdhxxtqcypksmqccyyazhtjpcylzlyjbjxtpnyljyynrxcylmmnxjsmybcsysslzylljjgyldzdpqhfzzblfndsqkczfyhhgqmrdsxycstxnqqrpyjbfcxdyqfbnxejdgyqbsrcnfyyqpghyjdyzxgrhtkyleqdzntsmgklbsgbpyszbydjzsstjzstxzbhbscsbzczptqfzmqflypybbjgszmxxdjmtsyskkbjtxhjcegbsmhyjzcxtmljyxrzzqscxxqptzhmkdxxxjcljprmyygadyskqlsadhrskqxzxztcxhztlmlwxybwsyctbhjhjfcwzsjwwtkzlxqshlyczjxemplprcgltbzztlzjcyjgdtslklpllqpjmzpapxyzlaktkdnczzbncctdqqzjyjgmctxldgcszlmlhbglkfbnwzhdxphlfmkyclgxdtwzfrjejctzhydxykshwfzcqshknmqqhtchymjdjskhxzjzbzzxympajqmcdbxlsklyynwrtsqgscbpdbsgzwyhtlkssswgzzlyytnxjgmjszsxfwnlsoztxgxlsammlbwldqcylakqcqstmycfjbslxclzjclxxksbzqzlhjphqplsxscgslnhpsfqqxtxjjzlqldxzjjzdyydjnzptfcdskjfsljhylzqjzlbthydgdjfdbyazxdzhzjnhhqbygnxjjqczmlljzkspldsclbblxklelxjlbjycxjxgcnlcqplzlznjtzljgyzdzpltqcssfdmnycxgbtjdcznbgbqyqjwgkfhtnbyqzqgbkpbbyzmtjdytblsqmbsxtbnpdxklemyycjynzdtldykzzxtdxhqshygmzsjycctayrzlpwltlkxslzcggexclfxlkjrtlqjaqzncmbqdkkcxglczjzxjhptdjjmzqykqsecqzdshhadmlzfmmzbgntjnnlhbyjbrbtmlbyjdzxltjlpldlpcqdhlhzlycblcxccjadjlmcmmsshmybhbskkbhrsxxjmxsdznzpxlbbrhgghfchgmsklltsjyycqlcskywyehywhbhqywbawykqldq?tntkhqcgdqktgpkxhcpdhtwtmssyhbwcrwxhjmkmzngwtmlkfghkjyldyycxwhyeclqhkqhttqkhffldxqwytyydesbpkyrzpjfyyzjceqdzzylattbbfjllcxdlmjsdxegygsjqxcwbxsszpdyzcxdnyxpfzqdlyjccpltxlsxyzyrxcyyydylwwndsahjsygyhgywwaxtjzdaxysrltdpssyxfnejdxyzhlxlllzhzsjnyqyqjxyjghzgjcyjchzlycdshhsgczyjgcllnyzcjyyxnfsmwfpylcyllabwddhwdxjmcxztzpmlqzhsfhzynstlldywlslxhymmylmbwwkyxyadtxylldjpybpwfxjmmmllhafdllaflbhhhbqqltzjcqjjdjtffkmmmpymhygdcqrddwrqjxnbysnmzdbxytbjhpybygtjxaahgqdqtmbstqjkbtspkjlxrbeqqhqmjjbdjwtgtbxpgbktlgqxjjjcdhxqdwjlwrfmqgwqhckryswgbtgygbwsdwdwrfhwytjjxxxjyzyslphyypayxhydqqxshxyxeskqhywbdddpplcjlhqeewjksyykdyplfjthkjltcyjhhjttbltzzcdlthqkcjqysteeywkyzyxxyysddjkllpwmcyhqgxyhcrmbxpllnqydqhxsxxwgdqbshyllpjjjthyjkyphthyyktyezyenmdshlcrpqfbgfxzbsbtlgxxjbswyysksflxlpplbbblbsfxfyzbsjssylpbbffffsscjdstzsxtryycyffsyzyzbjtbctsbsdhrtjhbytcxyjeylxcbnebjdsysyhgsjcbxbydfzwgenyhhthjhaxfwgcstbgxklstywmtmbyxjskzsxdyjrcytwxzfhmymcxlznsdjtttxrycfyjsbsdyerxhgjxbbdeynjghxgckgscymblxjmsznskgxfbnbbthfjaafxyxfpxmyfhdttcxzzpxrsywzdlybbktyqwqjpzypzjznjpzjlztfysbttslmptzrtdxqsjehbzylzdhljsqmlhtxtjecxslzzspktlzkqqyfsygywpcpqfhqhytqxzkrsgtgsqczlptxcdyyzssqzslxlzmacpcqbzyxhbsxlzdltcdjtylzjyytpzylltxjsjxhlbmytxcqrblzssfjzztnjydxmyjhlhpblcyxqjqqkzzscpzkswalqsplcczjsxgwwwygyatjbbctdkhxhkgtgpbkqyslbxbbckbmllxdzstbklggqkqlsbkkdfxrmdkbftpzfrtbbmfeeqgxkjpzsstlbztpszqzsjthljqlzbpmsmmsxlqqnhknblrddnhxdkddjcyygyfxgzlgsygmjqgkhbpmxyxlytqwlwgcpbmjxcyzydrjbhtdjyejshtmjsbyplwhlzffnypmhxqhpltbqpfbjwjdbygpnxtbfzjgsdctjshxeawzzylltyybwjkgxghlfkxtjtmszsqynzggswqsphtlsskmclzxyszqqxncjdqgzdlfnykljcjllzlmzznhydsshthxzlzjbbhqzwwycrdhlyqqjbeyfsjxthsrxwjhwpslmssgzttyeyqqwrslalhmjtqjsmxqbjjzjxzyzkxbyqxbjxshzssfglxyxzxfghkzszggylclsarjxhslllmzxelglxydjytlfbhbpnlyzfbbhptgjkwetzhkjjxzxxglljlstgshjjyqlqzfkcgnndjsszfdbctwwseqfhqjbsaqtgypjlbxbmmywxjslzhglzgnyfljbyfdjfrgsfmbyzhqfbwjsyfyjjphzbyyzffwodjrlmftmlbzgycqxcdjygzyyyydytydwegazyhxjlzyyhlrmgrjxzclhneljjthtbwjybjjbxjjtjteekhwslzplpsfazpqqbdlqjjtyyqlyzkdksqjyyjzldqcgjqyzjsycmraqthtejmfctyhypkmhycwjdcfhyyxwshctxrljgjshccyyyjltkttytmxgtcjtzayyoczlylbszywjytsjyhbyshfjlygjxxtmzyyltxxypzlxyjzyzyypnhmymdyylblhlsyygqllnjjymsoycbzgdlyxylcqyxtszegxhzglhwbljheyxtwqmakbpqcgyshhehqcmwyywljyjhyyzlljjylhzyhmgsljljxcjjyclycjbcpzjzjmmylcjlnqljjjlxxjmlszljqlycmmhcfmmfpqqmfxlqmcffqmmmmhmz?fhhjgtthhkhslnchhyqdxtmmqdcydyxyqmyqylddcyyydazdcymdydlzfffmmycqcwzzmabtbyctdmndzggdftypcgcyttssffwbdtzqssystwjjhjytsxxylbyqhwwhxezxwznnqzjzjjqjccchyyxbzxzcyjtllcqxynjycyycynzzqyyyewyczdcjycchyjlbtzyycqwlpgpyllgkdldlgkgqbgychjx????????????????????????????????????????gdm????????????????????????????????????????????????"

// Each polyphonic character followed by the initials of its other readings,
// from the same pinyin-pro, so 重启 is found by cq as well as zq.
var PINYIN_ALTERNATES = "丁z丂qy万m丌j不f且j丱k丼d乁j乇z么y乐y乗s乘s乚y乜m乾g乿l亇m些s亝z亟q亢hg亨p亹m仇q仐s仛cd仠h仡g仧z仯m仰a仸f份b伎q伒y会k传z伡j伺c伽qg佁c佃t佄g佋s佚d佛b佫h佴n侗t侟c侥y侧z侱t侸d便p俇k俏x俞s俟q信s俥j俶t俿c倅z倘c倞j偅t偒d偢q偲s側z傀g傂st傋j傔j傕j傮c傳z傶c僄b僝z僣j僥y僪j僫w僮z儃ts儗ya儴x儶x兊ry兌ry兏z兑ry兪s其j兹c冯p净c凈c凵q凹w刨b券x刹s剎s剡s剢z剬z剳z剸z剹j剿c劋c劦l助c勜y勦c勭d勷x匋y匙s匨c匮g匱g区o匼q區o卒c单sc卛l卜p卝g卡q卬y厂ah厃y厈a厔s厦x厱q厶m厷h厸m厹r参s參s叄s叅s叆y叕ylj叚x叞y句g叨t召s叶x吁y吅s合g吋d吓h吖y吡p吤g否p吪h吭h吲s吷cj吺r吽o吾y呇q呒m呔t呚q呡m呫c呮z呰c呲z呴xg呵a呷g呺x咀j咁g咖g咥d咭xq咯lk咰x咳k咶s咹a咼hg哏h哕h哜z哦e哱p哾y哿j唊q唌dx唔n唝h唫j唬x唲w啁t啍zxd啐q啑sjt啘w啙c啚t啞e啨q啫s啴c喋z喏r喐hg喔o喛yx喝y喠c喥z喬j單sc喯b喰sq喳c喿q嗃x嗄s嗊h嗌y嗒t嗗g嗙b嗛q嗺s嘄d嘅g嘇c嘏j嘐x嘘s嘬c嘲z嘸m嘼xs嘽c嘾t嘿m噃b噈zh噋k噓s噦h噭qc噱x噴f噷h嚄o嚇x嚊p嚋c嚌z嚗p嚡h嚣x囃c囋c囐ny囗g囝n囤d囲t圈j圏j圜y圩w圱s圻y坆f坈k坉d坋b坏p坔l坢b坬g坻c垌t垸h垺f埄f埅f埆j埉j埏y埐j埔b埥z埩c埱t埳x埶s堇q堋b堑zj堕h堡p堥w堨ey填z塸q塹j塼t墆z墤t墥d墫d墮h墽a墿t壆bj壏x壳q夃y夅x夆f夗y夘w夯b夲b夵t夹gx夾gx奃t奇j奍j契x奞z奤pt奥y奧y奲c女r奵t她j妃p妋y妎j妔h妚p妜j妧y妷y姣x姤d姥m姰x姱h姶y姺s娍s娒m娕l娝b娞s娪y娭a娷s娾e婄b婘j婜j婤c婥n婩a婫k婸y婼c婾y媂t媆n媐p媞s媠t媮y媰z嫀s嫅s嫨n嬐yj嬛hx孅x孈h孉q孎c孖z孙x孧n孫x宊j宓f宕t宛y宲s宿x寁z寖q寠j射y将q尉y尌z尢y尨lp尾y尿s屏b属z屟t屬z屯z屰j屸l屽a岂k岨j峇k峊n峒t峙s峤j峫y崒c崥b崭c崵d崻s崼d嵁z嵅d嵌k嵍m嵑j嵣t嵤y嵦k嵪q嶃c嶄c嶠q嶡g嶦s嶰j嶱j嶲xj巂gj巆h巠x巷h帑n帓w帱d帴s帹q帺j幓q幢c幬d广a庉t庍t庬p庰p庴c廆wh廈x廑q廧s弄l弟t弡z弮j弲y強j弹d强j弾t彈t彊j彐x彡x彭b彴b彵y彷f徍j徎z從z徥t徦x徲c徸z徺y忂j忊t忓h忔q忕s忚l忞w忟w忪z忬s忯s忳zd忹w忼h忾x怐j怗z怘g怚jz怞c怢d怶p怸s恌y恓q恔j恗k恫t恮z恶w悁j悆s悈k悎j悝l悥n惌w惐x惓j惔t惛m惝t惡w惢r惿s愉t愒q愓tsy愖xd愘q愡s愩h愾x慅s慉c慐h慬q慸c憕dz憞t憢j懁h懆s懝yn懠j懢x戅z戆z戇g戌q戏h戛g戯h戱x戲h扁p扄j扐c扒p扚yl扛g扜w扝wk扡cy扢jx扱cq扳p扷a扸z扻sk抂wz抇g抌s抐r折s抙f抝n抢c抪p抭t抲q拁y拂b拌p拓z拗n拘g拚f括g拵z拸ch拺s拽y挄g挐r挕s挝z挟j挩s挳q挷p挾j捁k捇c捈sc捊f捔z捗pz捝s捥y捬b捰w捲q捵t捼w捾x掔w掜y掝x掞s掟d掫c掸s掺xs揁k揂y揊c揌zc提d揔s揘y揟j揢q揣tz揥t揭q揰d揲sy揵q搊z搑n搒b搕e搚x搩z搫b搱n搶c搷s摄n摌s摎ln摓p摕tz摖jc摡x摢c摨z摪q摮q摰c摵m摷c摼q撍q撗g撜z撝w撣s撨s撮z撱t撽yj撾w擏j擗b擳j擽y擿z攃s攈p攒c攕j攝n攢c攦s攲qy攼h敄m敊s敋e敠q敧yj敪q敱z敳z斁d斄t斔z斖m斡g斦z斺j於y斿l旁b旇b无m旰h旲y旽z昳d晇k晟c景y晵d晻y暏s暕l暴p曝b曽c曾z朁qj會k朅h朇p朌f朏k朐xc朘z朚mw朝z期j朣c朮s术z朱s朷tm朹q杅w杒e杓b杔z杝zld杫zx杬w杮f杸d杻c枂y枈m枋b枑d枝q枞z枮z枱s枸j枹f枻x柁d柂dl柅c柈b柜j柢c柣z查z柨p柭fp柮zw柷c柸p柹f査z栅zc栎y栖x栝k校j栧x栫z栺y桋t桙m桡n桧h桭z桯y桲p桳f梀y梋j梌c梎y梕e梣c梩sq梴y梼cd棇s棍h棏z棑b棓p棣t棬j棯s棴s棷s棽s椄q椆zd椉c椊c椌k椎c椑p椦j椯c椲h椷j椹z楂c楇k楖z楛h楤c楥x楪y楯s楱z楴s楷j楽y榅y榌p榐n榑b榝x槏lx槙z槛j槢d槣g槦y槫sq槭s槯z槱c槾w樂y樅z樆c樔j樘t樛l樢m樧x橈n橏j橔d橖c橚q橝d橦c橧c橪y橾q檘b檜h檡st檶l檷m檻k檽r櫎g櫖c櫟y櫰g欃z欈z欦x欪qx欬a欯k欸e欹y欻x欿q歏q歘c歙s歛h歭c歾m殑j殕b殖s殙m殨h殸ks殼q殽x毌w毭n氏z氜r氶c氿j汃p汋q汏t汤s汥j汵hc汶m汸p汼y沈c沌z沓d沕w沗p沰d沲t沵l沶c泄y泆d泊p泌b泏s泑a泧s泬x泷s泺p泽s洒x洓qz洝ye洞t洯j浅j浍k浒x浚x浧c浲h浽n涌c涒y涡g涭t涳n涴y淁j淌c淖cz淢x淨c淰s淲h淳z渂m渃l渑s渞w渠j渦g渧t港j渹q湏mx湣h湪n湫j湬j湯s湴p湷h溃h溄h溎g溓nx溚t溱q滀x滈x滊x滎y滜h滧x滸x漎s漙z漨p漯t漰b漴s漷k潀z潈z潐q潒x潢g潨z潬s潰h潳z澄d澍z澒g澚y澠s澤s澫m澮h澹t濄w濆f濈s濎t濔n濞p濢z濬x濭k濻d濼p濽c瀑b瀓d瀢d瀤w瀧s瀳j灂j灒c灙t灥q灬b灹y炃b炅g炐f炪c炮b炰f炶q烄y烔d烰p烲c烻s焄x焆y焌q焎c焏q焘d焣j焥a焧c焬y焯z焸y焽y煇yx煍q煔s煕y煠z煾y熇x熜z熝a熢p熣s熯r燀d燋zq燑d燤l爃y爓x牑m牞l牫q牰c犆z犍q犛l犮q犳b犴h犺g犻f犿h狋qc狌s狏y狢m狧s狪d狵d狶s猈p猏y猚w猰jq猲xg猵p猼p獋g獟x獡x獦lx獱p獳r獶y獿y率s玚c玟w玢f玧y玪q玱c玵g珆t珇j珢k珶t琁q琕p琗s琟w琣p瑎j瑒dy瑱z瑲c瑸p瑹s璅s璚q璯k璷f璸p璾z瓕x瓗w瓛y瓟p瓡h瓨h甴z甸ts町d甼d畁q畐b畗f畜x畟j畠t畤cs畨p番p畬y疆q疋ys疌q疐z疑n疙y疟y疦x疨x疺b痁d痋c痏y痑s痭p痳l痶d痷ye痾e瘈c瘕x瘣h瘧y瘨c癄j癐w皀b皅b皋h皐y皪b皻c皽d盖h盛c盩c盳w盷x盻p省x眃h眑a眗xk眙c眣t眪f眰z眴s睄sx睉z睟z睥b睪zg瞆wk瞉j瞏h瞤r瞯x瞴m瞶k瞿j矃c矆y矌g矔q矜gq矝qg矞xj石d矼qk砉x砏bf砢k硄g硌l硔h硙a硞k硥b硧t硾cd碂c碊z碏x碙g碣y碮d碿x磃t磅p磆kg磈k磍qy磏q磑ag磝q磩z磻b磼s礉q礊h礐h礘q祇z祊f祕m祭z祱l禅s禆p禓s禔t禪c禺o秅n秇y种c秏m秘b秮k秲z秳k秿p稄z稌s稘q稡s稧q稫b稴jl稵j稽q穇c穘r穛b穜z穮p穱j穳z窋z窌l窐g窕y窨y窴dy窼k窽c窾c竐q竘k竧z竲z竺d竻j笍r笒jh笓p笚xn筠j箁bf箄b箈c箉d箌d箐q箘q箢w箷y箹c箾sq篢l篧h篬c篴z篸c篹s篻b篿z簎j簨z籈j籓pb粆c粇j粘z粣s粥y糸s系j紅g紇g紕b紾z絓k絔m絙h絜x絟s絠a絣p給j絧d絩d絯h絺z絻m綄w綅x綖x綝l綨q綪z綸g緂c緝q緟c緤y緰xs緶p緷g緺w緼w縎h縒s縕w縗s縳j繁p繆l繇z繫j繰sz繳z繵tc纀f纅l纕x纚sx红g纤q纥g纰b纶g给j缉q缊y缏p缞c缪l缲s缴z罢p罷p羊x羏x羙g羛x羫k羬xy羾g翍b翑y翟d翢z翵q耆s耎n耏n耑d耙b耛s耝c聉tz聏n聑z聜z聻j肑d肣q肫c肶b胇b胏z胐k胕z胲h胿k脦t脧j脯f腊x腌a膀p膔b膞c膰p膴h膻d臈g臒y臡l臤x臦j臩j臭x臱b臷z臸j般p艴b艽q艾y芍q芐x芘b芚c芥g芧z芲h芴h苂y苐t苕s苙j苛h苣q苧n苩b苴c苼r茄j茈c茋d茜x茷p荑t荠j荥x荨x莑f莘x莞g莤s莦x莩f莬m莶l菀y菆c菍r菨s菬z菭zc菳j菹j菻m葚r葰s蒘n蒝h蒣s蒩j蓋h蓔z蓧t蓲qf蓻j蔓w蔚y蔢b蕁x蕃b薁a薋z薍l薔s薟l薧h薳w薵c薶m薺q藃h藇x藋z藏z藨p藸z虷h虹j虾h蚄b蚔z蚖w蚗q蚣z蚼qx蚾p蛇y蛒l蛖b蛡x蛤g蛪n蛸x蛾y蜡z蝤q蝦h螇q螕p螛x螝h螫z螲d螶j螹c蟦f蟫x行h衰c袌p袔k袦j被p袲n袳qdn袷q袸z袹m裓g裨p裯c裳c裷g裺a裼x褚z覃t見x覕m覵b见x觟x解x觧x觭q觷h詒d誂t誃c誒x說y誳j誺l調t諀b諎c諔j諕x諟d諣g諰sa識z讂x讉t许h识z诒d详y诪c说y诶x调dz谌s谷y豈k豣y貈h貉h貗l貸t賈g賯m贃z贛z贾g趃t趄q趋c趏h趞j趠z趣c趨c趯t趶w趹j趽p跁b跈c跕t跘b跙q跢c跰p跾c蹊x蹢z蹲c躠s車c軋zg軓g軼d车j轧zg辗z辟b辺b迋k迣l迬w追d适k遆d遗w適dz邌c邟h邪y郂h郄q郇x郗x郦z郩a酂c酇c酢z酦p醈d醔c醗f醱f醳s醶lx重c釐x釥j釪h釫w釰j釶y釼j釽z鈀p鉼p鉿k銄j銉s銊h銐l銗x銚ty銛ktg銴z銸n銽ktg銾g銿y鋀d鋄j鋌d鋑c鋖t鋗x鋘h鋜c鋞j鋷n鋺w鎉t鎐z鎑tg鎗c鎘l鎞p鎫j鎬h鏃c鏒sc鏕a鏩z鏸sr鏾x鐺c钑x钭d钯p钿t铅y铛c铤d铦ktg铪k铫dt锬x镉l镐g镡cx長z长z閄s閈b閒j閜k閞g閤g閧x閪x閼y闂jx闆p闍s闛c闞h闟st闬b阇s阏y阚h阽d阿e陂p降x陶y隃s隊z隋d隑qa隓d隗k隩a隳d隸d隹cw雚h雟x雭x雺m靓j靚l革j鞈ts鞕y鞘s鞙x鞝z鞞b鞢d鞰y韎w韘x韫w頻p颈g颉x颌g频b颤z颩d颰f食y飬j飳t飴s饟n饧x饹l馇z馧w馮p馱d馲z馶s馸j駃j駄d駘d驮d骀t骠b骳m骹q髈p髉j髲p髺y鬲l鮆c鮘d鮥g鮭xwk鯆b鯣s鲄g鲑x鲭z鳃x鳜g鳣s鳥d鳭z鳱hy鳺g鳻f鳽qz鶗c鶙c鶝b鶡j鶣b鶨z鶬q鶻h鶽x鹄g鹘g麃p麆c麇q麕q黮s黰y黵z鼂z齊z齐jz龂k龈k龏w龜jq龟jq鿎t"
var pinyinAlternates = null

function pinyinLetters(code) {
  var primary = PINYIN_INITIALS.charAt(code - 0x4E00)
  if (primary === "?") return ""
  if (!pinyinAlternates) {
    pinyinAlternates = {}
    var key = ""
    for (var i = 0; i < PINYIN_ALTERNATES.length; i++) {
      var ch = PINYIN_ALTERNATES.charAt(i)
      if (ch >= "a" && ch <= "z") pinyinAlternates[key] += ch
      else pinyinAlternates[key = ch] = ""
    }
  }
  return primary + (pinyinAlternates[String.fromCharCode(code)] || "")
}

// Initials of the Hanzi in one field, by each character's most common reading.
// Latin is already searchable as itself.
function pinyinInitials(text) {
  return pinyinVariants(text)[0]
}

// Every run of initials one field can be read as, most common reading first.
// Past 16 runs the remaining characters keep only their common reading.
function pinyinVariants(text) {
  var value = String(text || "")
  var variants = [""]
  for (var i = 0; i < value.length; i++) {
    var code = value.charCodeAt(i)
    if (code < 0x4E00 || code > 0x9FFF) continue
    var letters = pinyinLetters(code)
    if (!letters) continue
    if (variants.length * letters.length > 16) letters = letters.charAt(0)
    var next = []
    for (var v = 0; v < variants.length; v++) {
      for (var l = 0; l < letters.length; l++) next.push(variants[v] + letters.charAt(l))
    }
    variants = next
  }
  return variants
}

// Each field's runs are kept apart, so no match crosses a field.
function pinyinFieldInitials(fields) {
  var runs = []
  for (var i = 0; i < fields.length; i++) {
    var variants = pinyinVariants(fields[i])
    for (var v = 0; v < variants.length; v++) {
      if (variants[v] && runs.indexOf(variants[v]) < 0) runs.push(variants[v])
    }
  }
  return runs.join(" ")
}

function nameSearchText(entry) {
  if (!entry) return ""
  var aliases = []
  var values = (Array.isArray(entry.aliases) ? entry.aliases : []).concat(Array.isArray(entry.searchTerms) ? entry.searchTerms : [])
  for (var i = 0; i < values.length; i++) aliases.push(searchableToken(values[i]))
  var pinyin = pinyinFieldInitials([entry.label].concat(values))
  return [entry.label, searchableToken(leafIdFor(entry.id)), aliases.join(" "), pinyin].join(" ").toLowerCase()
}

function termInSearchWords(term, text) {
  var words = String(text || "").toLowerCase().split(/\s+/)
  for (var i = 0; i < words.length; i++) {
    if (words[i] === term) return true
  }
  return false
}

function descriptionTextMatches(query, text) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  for (var i = 0; i < terms.length; i++) {
    if (terms[i] && !termInSearchWords(terms[i], text)) return false
  }
  return true
}

function matchesQuery(entry, query, visible) {
  if (!entry || entry.id === "root") return false
  if (!visible) return false

  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)

  for (var i = 0; i < terms.length; i++) {
    if (!terms[i]) continue
    if (nameText.indexOf(terms[i]) >= 0) continue
    if (termInSearchWords(terms[i], descriptionText)) continue
    return false
  }

  return true
}

function searchScore(items, entry, query) {
  var needle = String(query || "").toLowerCase().trim()
  var label = entry.label.toLowerCase()
  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var score = 80

  if (label === needle) score = entry.parent === "root" ? 2 : 0
  // An installed app whose name contains the query as a whole word ("zen"
  // for Zen Browser) beats exact-labeled menu entries like Install > Zen.
  else if (entry.kind === "app" && label.split(/\s+/).indexOf(needle) >= 0) score = 0
  else if (label.indexOf(needle) === 0) score = 10
  else if (label.indexOf(needle) >= 0) score = 30
  else if (nameText.indexOf(needle) >= 0) score = 40
  else if (descriptionTextMatches(needle, descriptionText)) score = 60

  if (entry.kind === "menu" || entry.kind === "link") score -= 2
  // App rows sort after all menu items, so they lose the tiebreak below to an
  // equal match. Outrank those, but stay inside the tier so better ones win.
  if (entry.kind === "app") score -= 5

  return score * 1000 + depthFor(items, entry.id) * 25 + entry.order
}

function displayRow(items, itemOrder, checkedResults, disabledResults, entry, detail, score, section) {
  var target = entry.kind === "link" ? entry.target : entry.id
  return {
    itemId: entry.id,
    disabled: isDisabled(disabledResults, entry),
    kind: entry.kind,
    icon: entry.icon,
    iconFont: entry.iconFont || "",
    appIcon: entry.appIcon || "",
    appId: entry.appId || "",
    label: labelFor(entry, checkedResults, disabledResults),
    target: target,
    detail: detail || "",
    path: pathFor(items, entry.id),
    childCount: (entry.kind === "menu" || entry.kind === "link") ? childCount(items, itemOrder, target) : 0,
    action: entry.action || "",
    provider: entry.provider || "",
    score: score || 0,
    section: section || ""
  }
}

// Commands a `checked:` expression reads a value out of. Every sibling row
// asks the same one -- Defaults > Browser has seven rows all comparing
// against `omarchy-default-browser` -- so the batch runs it once and the rows
// read the captured answer.
//
// The capture has to be eager. These are read inside `$(...)`, and a value
// cached while one expression runs lives in that subshell only, so a lazy
// memo never survives to the expression after it.
var GUARD_READERS = [
  "omarchy-bar background",
  "omarchy-bar get omarchy.power showPercentage",
  "omarchy-bar get omarchy.clock format",
  "omarchy-bar get omarchy.clock verticalFormat",
  "omarchy-bar position",
  "omarchy-channel-current",
  "omarchy-default-agent",
  "omarchy-default-browser",
  "omarchy-default-editor",
  "omarchy-default-terminal",
  "omarchy-default-dictation",
  "omarchy-dns",
  "omarchy-dock autohide",
  "omarchy-dock position",
  "omarchy-hyprland-corners",
  "omarchy-hyprland-window-transparency",
  "omarchy-hyprland-workspace-layout-default",
  "omarchy-shell notifications isDnd",
  "omarchy-toggle-nightlight --status"
]

// Package and command presence account for most of what the guards ask, and
// asked one at a time they are almost all fork: the shipped menu spends over
// a second on them. Answer them inside the guard process instead. These
// shadow the real commands for the batch only, so they have to agree with
// them everywhere, including for no arguments at all (present is true of
// nothing, missing is not).
//
// `pacman -Q` resolves a name through what installed packages provide, not
// just what they are called -- with gvim installed it reports `vim` as
// present -- so the set has to carry provides too, or `install.editor.vim`
// comes back and offers to install what is already there. A version
// constraint (`bash>=1`) is not a name any set can answer, so it goes to
// pacman itself; no shipped guard writes one.
//
// `pacman -Qi` wraps a long list across continuation lines whenever COLUMNS
// is set in the environment, which a login shell may well have done, so the
// parser follows the indented lines rather than reading the first one and
// dropping half of what is installed.
//
// Building the set is most of the batch's runtime (~75ms of `-Qi` over a
// thousand packages), yet it only changes when a transaction does. So it is
// kept in $XDG_RUNTIME_DIR, stamped with the local database directory's
// identity and change times: every install, removal and upgrade adds, removes
// or renames a `name-version` entry there, which moves them. A set is stored
// only from a build no transaction can have overlapped -- the same stamp
// before and after, and no db.lck at either end -- so a half-written database
// is never what gets remembered. The stamp and the set are read through one
// descriptor, so a writer replacing the file mid-read cannot pair one stamp
// with another set.
//
// A build that failed is used for this run, as before, but never stored:
// only when both queries succeed does it end with a `/` line, which no
// package name can contain.
//
// The database is wherever pacman.conf's DBPath puts it, so pacman-conf
// names the directory the stamp and lock are read from; one that cannot be
// named is never cached.
function guardPackageSnapshot() {
  var build = '{ set -o pipefail; pacman -Qq && LC_ALL=C pacman -Qi'
    + " | awk '/^[A-Za-z]/ { provides = ($0 ~ /^Provides/); sub(/^[^:]*: /, \"\") }"
    + ' provides && $0 != "None" { n = split($0, p, " ");'
    + ' for (i = 1; i <= n; i++) { sub(/[<>=].*/, "", p[i]); print p[i] } }\' && echo /; } 2>/dev/null'
  var stamp = 'stat -c "%d:%i:%.9Y:%.9Z" -- "$__omarchy_pkg_db/local" 2>/dev/null'

  return '__omarchy_pkg_db=${OMARCHY_PACMAN_DB_PATH:-$(pacman-conf DBPath 2>/dev/null)} || __omarchy_pkg_db=""\n'
    + '__omarchy_pkg_db=${__omarchy_pkg_db%/}\n'
    + '__omarchy_pkg_cache=${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/omarchy-menu-packages}\n'
    + '__omarchy_pkg_stamp=""\n'
    + '[[ -z $__omarchy_pkg_db ]] || __omarchy_pkg_stamp=$(' + stamp + ') || __omarchy_pkg_stamp=""\n'
    + '__omarchy_pkg_names=()\n'
    + 'if [[ -n $__omarchy_pkg_cache && -n $__omarchy_pkg_stamp ]]'
    + ' && { IFS= read -r __omarchy_pkg_line && [[ $__omarchy_pkg_line == "$__omarchy_pkg_stamp" ]]'
    + ' && mapfile -t __omarchy_pkg_names; } 2>/dev/null <"$__omarchy_pkg_cache"; then :\n'
    + 'else\n'
    + '  __omarchy_pkg_names=()\n'
    + '  [[ ! -e $__omarchy_pkg_db/db.lck ]] || __omarchy_pkg_stamp=""\n'
    + '  mapfile -t __omarchy_pkg_names < <(' + build + ')\n'
    + '  if ((${#__omarchy_pkg_names[@]})) && [[ ${__omarchy_pkg_names[-1]} == "/" ]]; then unset "__omarchy_pkg_names[-1]"; else __omarchy_pkg_stamp=""; fi\n'
    + '  if [[ -n $__omarchy_pkg_cache && -n $__omarchy_pkg_stamp && ! -e $__omarchy_pkg_db/db.lck ]]'
    + ' && [[ $(' + stamp + ') == "$__omarchy_pkg_stamp" ]]; then\n'
    + '    { printf "%s\\n" "$__omarchy_pkg_stamp" "${__omarchy_pkg_names[@]}" >"$__omarchy_pkg_cache.$$"'
    + ' && mv -f -- "$__omarchy_pkg_cache.$$" "$__omarchy_pkg_cache"; } 2>/dev/null'
    + ' || rm -f -- "$__omarchy_pkg_cache.$$" 2>/dev/null || :\n'
    + '  fi\n'
    + 'fi\n'
}

function guardHelpers() {
  return 'declare -A __omarchy_pkgs=()\n'
    + guardPackageSnapshot()
    + 'for __omarchy_pkg in "${__omarchy_pkg_names[@]}"; do __omarchy_pkgs[$__omarchy_pkg]=1; done\n'
    + '__omarchy_pkg_has() { [[ -n ${__omarchy_pkgs[$1]-} ]] && return 0; '
    + '[[ $1 == *[\\<\\>=]* ]] && { pacman -Q "$1" &>/dev/null; return; }; return 1; }\n'
    + 'omarchy-pkg-present() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 1; done; return 0; }\n'
    + 'omarchy-pkg-missing() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 0; done; return 1; }\n'
    + 'omarchy-cmd-present() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 1; done; return 0; }\n'
    + 'omarchy-cmd-missing() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 0; done; return 1; }\n'
}

// Substitute the captured answer into the expression rather than shadowing
// the reader with a function. `$(reader)` and the variable holding what it
// printed are interchangeable -- both strip trailing newlines, both split the
// same way unquoted -- while a function would also catch `command -v reader`,
// `VAR=x reader`, and every other form, and answer those wrong. Anything but
// the plain substitution is left alone to run the real command.
//
// The readers are separate programs with nothing to share, so they all start
// at once, before the package set is built, each on a process substitution
// of its own; the batch then reads each one's output in turn. Run one after
// another they were a quarter of the batch. Reading to EOF and dropping the
// trailing newlines is what `$(...)` does with the same output.
function guardPrelude(guards) {
  var start = ""
  var collect = ""

  for (var i = 0; i < GUARD_READERS.length; i++) {
    // The guards arrive already substituted, so what marks a reader as wanted
    // is the slot standing in for it, not the call it replaced.
    if (guards.indexOf(guardReaderSlot(i)) < 0) continue
    var value = "__omarchy_read_" + i
    var fd = "__omarchy_read_fd_" + i
    start += "exec {" + fd + "}< <(" + GUARD_READERS[i] + " 2>/dev/null)\n"
    // `|| :` because read reports the EOF it stops at, and a login shell may
    // have turned on errexit.
    collect += "IFS= read -r -d '' " + value + " <&$" + fd + " || :\n"
      + "exec {" + fd + "}<&-\n"
      + value + "=${" + value + "%\"${" + value + "##*[!$'\\n']}\"}\n"
  }

  return start + guardHelpers() + collect
}

function guardReaderSlot(index) {
  return "${__omarchy_read_" + index + "}"
}

function substituteGuardReaders(expression) {
  for (var i = 0; i < GUARD_READERS.length; i++)
    expression = expression.split("$(" + GUARD_READERS[i] + ")").join(guardReaderSlot(i))

  return expression
}

function guardLine(id, tag, expression) {
  return "if { " + substituteGuardReaders(expression) + "; } >/dev/null 2>&1; then echo "
    + id + ":" + tag + ":1; else echo " + id + ":" + tag + ":0; fi\n"
}

// How many subshells share the guards. Most of what is left of the batch is
// a few dozen separate programs (hardware probes, systemctl, the screen
// recorder's status), each waiting on its own process start rather than on
// a core, so running them side by side is where the time comes back. Eight
// took the shipped menu's batch from ~400ms to ~160ms on a 32-thread desktop
// (~195ms to ~55ms once the package set was cached); more stopped paying.
var GUARD_GROUPS = 8

// One bash script for every `when:`, `checked:` and `disabled:` in the menu,
// reporting `<id>:<w|c|d>:<0|1>` per line. Speed is the whole point: the menu
// opens on the last evaluation's answers, so however long this takes is how
// long a row can contradict the state it describes.
//
// Guards are dealt round-robin into GUARD_GROUPS background subshells, each
// inheriting the package set, the shadowed helpers and the readers' answers,
// and the batch exits once all of them have. Lines arrive in any order, which
// the menu never relied on: each names its row, and each is one short write
// to the pipe, which the kernel never interleaves.
//
// A group that dies part way (a guard tripping a login shell's `set -u`, say)
// has left its remaining rows unanswered, and the menu keeps the last full
// set only when the batch fails. So each group is waited for by pid, and the
// batch's status is nonzero if any of them was.
function guardScript(items) {
  var lines = []
  var ids = Object.keys(items || {})

  for (var i = 0; i < ids.length; i++) {
    var entry = items[ids[i]]
    if (!entry) continue
    if (entry.when) lines.push(guardLine(ids[i], "w", entry.when))
    if (entry.checked) lines.push(guardLine(ids[i], "c", entry.checked))
    if (entry.disabled) lines.push(guardLine(ids[i], "d", entry.disabled))
  }
  if (lines.length === 0) return ""

  var groups = []
  for (var j = 0; j < lines.length; j++) {
    var group = j % GUARD_GROUPS
    groups[group] = (groups[group] || "") + lines[j]
  }

  var script = guardPrelude(lines.join("")) + "__omarchy_groups=()\n"
  for (var k = 0; k < groups.length; k++) script += "{\n" + groups[k] + "} &\n__omarchy_groups+=($!)\n"
  return script + "__omarchy_failed=0\n"
    + 'for __omarchy_group in "${__omarchy_groups[@]}"; do wait "$__omarchy_group" || __omarchy_failed=1; done\n'
    + "((__omarchy_failed == 0))\n"
}

// An action that only asks this shell to summon one of its own plugins can be
// run in-process, skipping the bash and qs ipc spawns. Anything more than the
// bare call, such as a second command or a shell-expanded payload, is left to
// bash.
function summonAction(action) {
  var match = /^omarchy-shell shell summon ([A-Za-z0-9._-]+)(?: '([^']*)')?$/.exec(String(action || ""))
  if (!match) return null
  return { id: match[1], payload: match[2] || "{}" }
}


// Multi-select requests return stable values, without icons, in option order.
function dmenuValue(option) {
  var parts = String(option || "").split("\t")
  if (parts.length > 1) parts.shift()
  return parts.join("\t")
}

function dmenuSelections(options, selected, preserveOrder) {
  var available = options.map(dmenuValue)
  return (preserveOrder ? selected : available).filter(function(value, index, values) {
    return available.indexOf(value) !== -1 && selected.indexOf(value) !== -1 && values.indexOf(value) === index
  })
}

function toggleDmenuSelection(selected, value) {
  return selected.indexOf(value) === -1 ? selected.concat([value])
    : selected.filter(function(item) { return item !== value })
}

// Returns a copy of items with label/title/description replaced from a
// translation catalog ({id: {label, title, description}}), as shipped in
// default/i18n/<code>/menu.json. The English label stays searchable by
// moving it into searchTerms when the translation differs — searchTerms
// feed search but never resolveRoute, so English words do not become
// routable commands in other languages. Items without a
// catalog entry pass through untouched, so an incomplete (or missing)
// catalog degrades to English row by row. Applied to the default items
// before the user extension merges, so user rows and retitles always win.
function applyTranslations(items, catalog) {
  var source = Array.isArray(items) ? items : []
  var strings = (catalog && typeof catalog === "object") ? catalog : ({})
  var out = []
  for (var i = 0; i < source.length; i++) {
    var entry = source[i]
    var translated = entry && strings[entry.id]
    if (!translated || typeof translated !== "object") {
      out.push(entry)
      continue
    }
    var next = {}
    for (var k in entry) next[k] = entry[k]
    if (translated.label) {
      if (translated.label !== entry.label && entry.label) {
        var terms = Array.isArray(entry.searchTerms) ? entry.searchTerms.slice() : []
        if (terms.indexOf(entry.label) < 0) terms.push(entry.label)
        next.searchTerms = terms
      }
      next.label = translated.label
    }
    if (translated.title) next.title = translated.title
    if (translated.description) next.description = translated.description
    out.push(next)
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    summonAction: summonAction,
    guardReaders: GUARD_READERS,
    guardScript: guardScript,
    stripJsonc: stripJsonc,
    normalizeAliases: normalizeAliases,
    normalizeItem: normalizeItem,
    parseMenuJsonc: parseMenuJsonc,
    keepMenuRows: keepMenuRows,
    mergeMenuSources: mergeMenuSources,
    mergeAppRows: mergeAppRows,
    swapProviderRows: swapProviderRows,
    item: item,
    resolveRoute: resolveRoute,
    slugify: slugify,
    depthFor: depthFor,
    pathFor: pathFor,
    parentPathFor: parentPathFor,
    isDescendantOf: isDescendantOf,
    childCount: childCount,
    isVisible: isVisible,
    isDisabled: isDisabled,
    labelFor: labelFor,
    searchableToken: searchableToken,
    leafIdFor: leafIdFor,
    nameSearchText: nameSearchText,
    pinyinInitials: pinyinInitials,
    pinyinVariants: pinyinVariants,
    pinyinFieldInitials: pinyinFieldInitials,
    termInSearchWords: termInSearchWords,
    descriptionTextMatches: descriptionTextMatches,
    matchesQuery: matchesQuery,
    searchScore: searchScore,
    dmenuValue: dmenuValue,
    dmenuSelections: dmenuSelections,
    toggleDmenuSelection: toggleDmenuSelection,
    displayRow: displayRow,
    applyTranslations: applyTranslations
  }
}
