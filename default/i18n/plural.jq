# CLDR cardinal plural categories for whole counts, per Omarchy language
# code, for omarchy-i18n. shell/Commons/Plural.js holds the same rules for
# the shell, and i18n-test.sh keeps the two in agreement.

def plural_category($code; $count):
  ($count | if . < 0 then -. else . end | floor) as $n
  | ($n % 10) as $n10
  | ($n % 100) as $n100
  | ($n != 0 and $n % 1000000 == 0) as $millions
  | if ["ja", "ko", "zh-CN", "zh-TW", "th", "vi", "id", "ms"] | index([$code]) then "other"
    elif ["hi", "bn", "fa", "si"] | index([$code]) then (if $n <= 1 then "one" else "other" end)
    elif ["fr", "pt-BR"] | index([$code]) then (if $n <= 1 then "one" elif $millions then "many" else "other" end)
    elif ["ca", "es-MX", "it", "pt"] | index([$code]) then (if $n == 1 then "one" elif $millions then "many" else "other" end)
    elif $code == "fil" then (if $n10 == 4 or $n10 == 6 or $n10 == 9 then "other" else "one" end)
    elif $code == "is" then (if $n10 == 1 and $n100 != 11 then "one" else "other" end)
    elif ["cs", "sk"] | index([$code]) then (if $n == 1 then "one" elif $n >= 2 and $n <= 4 then "few" else "other" end)
    elif $code == "pl" then
      (if $n == 1 then "one" elif $n10 >= 2 and $n10 <= 4 and ($n100 < 12 or $n100 > 14) then "few" else "many" end)
    elif ["ru", "uk"] | index([$code]) then
      (if $n10 == 1 and $n100 != 11 then "one" elif $n10 >= 2 and $n10 <= 4 and ($n100 < 12 or $n100 > 14) then "few" else "many" end)
    elif ["hr", "sr"] | index([$code]) then
      (if $n10 == 1 and $n100 != 11 then "one" elif $n10 >= 2 and $n10 <= 4 and ($n100 < 12 or $n100 > 14) then "few" else "other" end)
    elif $code == "sl" then
      (if $n100 == 1 then "one" elif $n100 == 2 then "two" elif $n100 >= 3 and $n100 <= 4 then "few" else "other" end)
    elif $code == "lt" then
      (if $n100 >= 11 and $n100 <= 19 then "other" elif $n10 == 1 then "one" elif $n10 >= 2 then "few" else "other" end)
    elif $code == "lv" then
      (if $n10 == 0 or ($n100 >= 11 and $n100 <= 19) then "zero" elif $n10 == 1 then "one" else "other" end)
    elif $code == "ro" then
      (if $n == 1 then "one" elif $n == 0 or ($n100 >= 1 and $n100 <= 19) then "few" else "other" end)
    elif $code == "ar" then
      (if $n <= 2 then ["zero", "one", "two"][$n] elif $n100 >= 3 and $n100 <= 10 then "few" elif $n100 >= 11 then "many" else "other" end)
    elif $code == "he" then (if $n == 1 then "one" elif $n == 2 then "two" else "other" end)
    elif $code == "ga" then
      (if $n == 1 then "one" elif $n == 2 then "two" elif $n >= 3 and $n <= 6 then "few" elif $n >= 7 and $n <= 10 then "many" else "other" end)
    else (if $n == 1 then "one" else "other" end)
    end;

# The string for a count from a plural entry, or the entry itself when it is
# a plain string; a missing category falls back to the entry's "other".
def plural_pick($code; $count):
  if type == "object" then (.[plural_category($code; $count)] // .other // empty)
  else . end;

# A plain number in the language's decimal separator and digits.
def localize_number($decimal; $zero):
  if test("^-?[0-9]+([.][0-9]+)?$") then
    ($zero | explode[0]) as $z
    | explode | map(if . >= 48 and . <= 57 then . - 48 + $z else . end) | implode
    | sub("[.]"; $decimal)
  else . end;
