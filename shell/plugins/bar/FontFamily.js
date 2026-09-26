.pragma library

// Nerd Fonts publishes full family names and, for some fonts, short aliases.
// Only substitute known suffixes; never guess a different underlying typeface.
function preferPropo(family, availableFamilies) {
  var candidate = family.replace(/ Nerd Font(?: Mono)?$/i, " Nerd Font Propo");
  if (candidate === family)
    candidate = family.replace(/ (?:NF|NFM)$/i, " NFP");
  if (candidate === family)
    return family;

  for (var i = 0; i < availableFamilies.length; ++i) {
    if (availableFamilies[i].toLowerCase() === candidate.toLowerCase())
      return availableFamilies[i];
  }
  return family;
}
