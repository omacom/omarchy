# Elsewhen

A world clock for the Omarchy shell: a globe in the bar that opens a panel of clocks, one row per city, with a spinnable globe behind it. It lives in `shell/plugins/panels/elsewhen/` under the plugin id `omarchy.elsewhen`, and file names below are relative to that directory. Its checks live in `test/shell.d/elsewhen/` and run as part of `./test/shell` through `test/shell.d/elsewhen-test.sh`.

Everything it needs is already on an Omarchy install: `date` and `timedatectl` for zone offsets, and `python3` (standard library only) for the temperature and currency script. That script is the only thing that touches the network, and it fetches from [Open-Meteo](https://open-meteo.com) (geocoding, weather) and [open.er-api.com](https://www.exchangerate-api.com/docs/free) (exchange rates) without an API key; results are cached under `~/.cache/omacom-elsewhen/`. The globe's coastlines are [Natural Earth](https://www.naturalearthdata.com) 110m (public domain), shipped as `world.json`. Settings live inline on the widget's `shell.json` entry; see [Settings](#settings).

## Why it shells out to `date`

Qt's QML engine has no `Intl`, so JavaScript cannot be asked for the time in an arbitrary IANA zone. Instead a single `date` probe reports each zone's current UTC offset and abbreviation, and the rows tick locally against those offsets. Offsets only move at a DST boundary, so the probe re-runs whenever the panel opens and every five minutes while it stays open.

## Reordering

Grab the body of a row and drag it up or down. The row lifts and follows the pointer while the ones it passes step aside by exactly one row; the new order is written to `shell.json` on release.

Three things make it feel solid, each of which was wrong first time:

**The pointer is measured in the Column, not in the row.** The grab area sits inside the row, and the row is translated as it is dragged - so reading `mouse.y` directly is a feedback loop: the local frame slides out from under a stationary pointer, the offset chases itself, and the row stutters. `mapToItem` into the (never-moving) Column gives a stable reading.

**The target slot has hysteresis.** Recomputing it freely means a pointer resting near a boundary flips between two slots on sub-pixel movement. The target now only changes once the pointer is 0.6 of a row past the current slot, so jitter at a midpoint holds steady.

**The drop is animated.** On release the row glides the remaining distance into its slot and the reorder commits when it arrives, rather than the row vanishing from under the pointer. Rows making room ease aside too - but the dragged row itself is excluded from that easing, or it lags the cursor.

The list itself is **not** touched while the pointer moves - rows are displaced with a `Translate` transform, which is purely visual and leaves the Column's layout alone. Reordering the model mid-drag would replace the array the Repeater is built from, rebuild every delegate, and drop the gesture half-way through. That is exactly the bug that once made the time scrubber behave like a click.

The grab area stops above the daylight strip, so vertical reordering never competes with the strip's horizontal scrub, and it is declared before the briefcase and remove buttons so those keep their taps. A few pixels of slack are required before a drag arms, so a click is never a reorder.

## The first run

A fresh install has no configuration and asks for none. The first time the panel opens it writes its own starting list: **the city you are in, plus four well-known destinations spread round the clock from it** - five rows, so it looks like a world clock immediately rather than an empty box with an "add a city" button.

The four are chosen **relative to home**, which is the whole point. A fixed list would hand someone in Paris a second Paris, and would give a reader in Tokyo a spread that is really a spread around California. From Los Angeles the list comes out as New York, London, Dubai, Tokyo; from Copenhagen as Delhi, Tokyo, Los Angeles, New York.

Candidates are taken in order of how well known they are, and one is kept only if it is at least three hours from home *and* from every city already picked - so the gap does the spreading rather than a rule about spacing. The obvious alternative, spacing four cities evenly round the dial and taking whoever is nearest each mark, gives a tidier spread but a stranger list: from Los Angeles it produces Sao Paulo, Cairo, Bangkok and Auckland, which is even but reads like a lottery. If somewhere has too little of the world far enough away - the Pacific, mostly - the three-hour gap relaxes rather than returning a short list. The result is sorted eastward, so the list walks round the world.

It costs one process: the same `date` probe that reads the local zone also prices the candidate cities on that first run, and never again. The local zone is emitted twice in that probe - once as the `LOCAL` marker and once as an ordinary row - so home's own offset is available like any other city's, which the picker needs and cannot ask for in advance.

Everything is written to `shell.json` as a normal list, so the first thing anyone can do is delete or reorder it. `test/shell.d/elsewhen/seed_check.js` runs the whole thing from fifteen different home cities, including UTC, Kathmandu's forty-five-minute offset, and the Pacific.

## Adding and removing cities

The search is driven from the keyboard: type, walk the results with the up and down arrows, Return adds the highlighted one, Escape closes. The selection starts on the first match, so the common case - type three letters, press Return - never needs an arrow at all, and it wraps at both ends because the list is six long and entirely on screen, with no edge worth protecting anyone from. A changed query puts the selection back on the first row: the list under it has been replaced, and Return should not add a city nobody looked at.

Hover and keyboard selection are drawn as two different marks rather than sharing one. If they shared, a mouse resting anywhere over the results while someone typed would drag the selection out from under the arrow keys.

Both lists name the zone and say where it is: `Asia/Kathmandu  UTC+5:45`. The name alone does not settle it - half a dozen entries share `America/Los_Angeles`, and `Asia/Kolkata` tells you nothing about India being half an hour off the hour until it says `UTC+5:30`. The offset is absolute rather than relative to you, unlike the `+9h` on a tracked row: a city you have not added yet has no relationship to you yet.

Search results are not covered by the probe that feeds the rows - that one only knows the cities you track - so the offsets come from a second `date` call over whatever the list is currently showing, at most six zones, coalesced while one is in flight. The answers are merged into what is already known rather than replacing it, because replacing blanked the column on every keystroke and read as flicker.

The globe's own **jump box** works the same way, for the same reasons - arrows, Return, Escape, selection on the first match, wrapping over five results. Its results grow upward out of the field rather than down from it, but the first match is still at the top of them, so Down moves down the screen and down the list at once and nothing needed inverting. It was already committing the label alongside the zone, so it never had the bug below: typing "Ber" and pressing Return on the fifth result goes to Cologne rather than to Berlin.

**A zone is not a city**, and this is where that bites. Six of the picker's entries share `America/Los_Angeles`; the name is the only thing telling Oakland from Las Vegas from Los Angeles. Committing a choice used to pass the zone alone, so picking Oakland put "Los Angeles" on the list - true of clicking too, and quietly wrong for as long as the picker has existed. It took keyboard selection to make it obvious, because the highlight says out loud which row you chose. `Model.addZone` had always accepted a label; the panel was dropping it on the way in.


`+ Add a city` opens an inline search over the system's zone list. Clicking a result adds it; hovering a row reveals a `×` in its top-right corner to remove it. The last row cannot be removed.

The `×` is placed from the corner rather than centred in its target, so how tucked-in it reads does not depend on how big the target is. The target itself is anchored flush into the corner and is larger than the mark, because a corner is the easiest place on a row to hit. Changes are written straight back to this widget's entry in `~/.config/omarchy/shell.json`, so they survive a restart.

The search is rendered inline rather than in a dropdown popup on purpose: the shared `SearchableDropdown` only ever opens downward, and this panel hangs off a vertical bar low on the screen, so its list ran off the bottom edge.

Inline, the list grows the panel instead - but only up to the card's cap, the screen's height or `space(680)`, whichever is smaller. Past that the column used to keep growing and paint straight over the border, which is what the search results made obvious and what a long enough list of cities would have done on its own. The content is now clipped to the card and scrolls, and while the search is open the panel follows the results down so the last one is not left clipped against the bottom edge.

Scrolling is the wheel only. The rows own the pointer - drag-to-reorder and the scrub strip are `MouseArea`s with `preventStealing` - so an interactive `Flickable` would be fighting them for every gesture.

### City aliases

The tz database ships one representative city per zone, so most places people actually search for are missing — there is no `Miami`, only `America/New_York`. `CITY_ALIASES` in `Model.js` adds extra search entries pointing at the zone that governs them. Adding a city is a one-line change; the only rule is that the zone must be the one that place actually observes, DST rules included.

Two cities may share a zone (Miami and Boca Raton are both `America/New_York`), so a row is identified by its label and zone together, and removal is by position.

## Day and night

Each row carries a strip showing that city's own 24 hours, midnight to midnight. The civil-daylight window is lit, and a marker sits at the city's current time — so reading down the column shows who is awake: markers inside the lit band are in daylight, markers out at the dark ends are not. Rows are also filled by phase, lightest at midday and darkest at night, and the marker turns gold while it is inside the lit band and stays white outside it.

Whether the marker is "in daylight" is decided geometrically, from its position against the band, not from the phase name: the band ends at 18:00 but `dusk` runs to 20:00, so a phase test would paint the dot gold while it sat visibly out in the dark end of the strip. The gold is a literal colour rather than a theme role, because several themes map the palette name `yellow` to something that isn't yellow (this one uses it for a green).

The lit band is fixed civil hours (06:00-18:00), not real sunrise. Without a latitude and a network call there is no true sunrise to plot, and inventing one would be worse than an honest convention.

## The daylight strip

Each row carries a 24-hour bar, midnight to midnight in that city's own clock, with the daylight lit and a marker at now. Read down the column and you can see who is awake.

The lit band is the city's real day. It was a fixed 06-18 convention for a long time, which was honest while the panel had no coordinates - but the fetcher geocodes every city for the weather, so they were already there. Reykjavik's four-hour December day and Auckland's long January one are different shapes, and that difference is most of what a daylight bar is worth looking at. A city the geocoder has not placed yet keeps the old fixed band, so a row without coordinates looks like the old convention rather than like a broken new feature.

`Sun.js` computes it, built on the globe's own `subsolarPoint` rather than a second copy of the astronomy. Declination comes straight off that function and the equation of time is recovered from it - `subsolarPoint` builds its meridian as `lon = -15 * (utcHours - 12) - eot`, so running that relation backwards hands the correction back with nothing new to keep in step. Local solar noon is found by iterating: the subsolar meridian sweeps west at a steady 15 degrees an hour, so the gap between where the sun is and where you want it converts straight into a time correction, and three passes put the residual under a second.

`test/shell.d/elsewhen/sun_check.js` checks it against Open-Meteo's published sunrise and sunset for thirteen cities - both hemispheres, both solstices, the equator, and Kashgar, which runs on Beijing time and sees the sun rise at 08:23 by the clock. The reference rows are held in the test verbatim so it stays offline.

Inside a minute at mid-latitudes, and about four minutes at Nuuk and Anadyr, both a little past 64 degrees north. That is the shared low-precision solar position doing what it says: it is good to a fraction of a degree, and near the poles the sun crosses the horizon at such a shallow angle that a fraction of a degree is minutes of time. Four minutes is invisible on a three-pixel bar, but the chip prints a time, so the two high-latitude cities are in the test with the tolerance they actually need rather than left out to keep the number tidy.

A bar can be lit at both ends, and that is not a drawing fault. Reykjavik on the June solstice sets four minutes after midnight, so the first four minutes of the same day are lit too - by the sun that rose the morning before. The band was clipped to the bar at first, with a comment explaining that a bar lit at both ends reads as two days; the reasoning was wrong, and it drew the sun below the horizon at an hour when the solar model puts it at -0.689 degrees, above it. The day is now drawn where it falls and again a day either side, and only the parts that land on the bar survive.

The arrows do not wrap with it. A sunset at 00:04 belongs to the next bar along, and a mark pinned to this one's edge would claim the sun set at midnight.

Above the Arctic circle there is no sunrise to plot, and that is a real answer rather than an error: `kind` comes back as `midnightSun` or `polarNight`, the band is the whole bar or none of it, and no arrows are drawn. Longyearbyen in June and in December are both in the test.

### The arrows

An up arrow just before the band and a down arrow just after it, shown while the pointer is on that row and outside the lit part rather than on its edge - a mark sitting on the boundary reads as part of the band and gets lost in it, and the arrow's job is to point at that boundary. The band already says how long the day is; the arrows say which end is which, which is the one thing a bare band cannot. They keep off the resting state: five rows each carrying two arrows all the time is a lot of furniture for something looked up rarely.

They are tucked in close to the band. The tap target is finger-sized and the glyph sits in the middle of it, so a box placed flush against the crossing left the arrow itself half a box away, pointing at the boundary from across a gap. The nudge closes most of that without letting the glyph touch the band - which is the one thing it must not do, since a mark on the edge reads as part of it.

Sunrise sits two pixels high and sunset two pixels low. The glyphs are the same height and the same shape reversed, which is the pair the eye is worst at telling apart at this size - it has to stop and read the arrowhead. The offset gives a second, coarser cue that needs no reading: the one above the line is the one going up. The asymmetry is the information.

Click one and it prints `Sunrise 6:16 AM` in a small dark chip above the bar - named, not just numbered, because a bare time floating over a row that already has a clock on it has to be worked out from which arrow was clicked. One at a time, and it clears when the pointer leaves the row: five rows each printing two more clock times is a table, and this panel is not one.

Above and not below, because below is where the pointer is - the hand cursor that just clicked the arrow lands squarely on top of the answer. The chip floats over the date line, which is why it has a ground of its own: text over text is unreadable whatever the two colours are.

The chip was opaque from the start and still had the zone line showing through it. That was stacking, not transparency: `sunArrows` is declared before `timeBlock`, so the offset painted over the top of it. `z: 1` on the arrows fixes the paint order without touching the tap order, which still comes from declaration order. Worth remembering that a stacking bug and an alpha bug are the same picture from the reader's side. Its two colours are literal rather than theme roles, because a tooltip is inverted everywhere - a dark chip with light text is the same shape in a light theme as in a dark one, while the theme's own foreground would be dark text on a dark chip half the time.

They are declared after the strip's scrub `MouseArea`. That one covers the whole bar to drag time, and an earlier sibling would never see a press - the same later-sibling rule the remove button and the briefcase rely on.

An arrow hides while the marker is standing on it. Two things drawn at the same point read as a printing fault rather than as two things at the same place, and the arrow is the one that can be spared: it marks a boundary that is not going anywhere, while the marker is the only thing on the bar that says when now is. It follows `nowMarker.x` and not the row's progress, so the arrow comes back exactly as the sun clears it rather than while the sun is still sliding over - the marker's motion is eased, and progress is where it is going, not where it is. Hidden rather than faded, because invisible is also untappable: a click on the sun should scrub time the way it does everywhere else on the bar. If the marker covers an arrow whose time is open, the chip closes with it.

### Naming the moon (built, then taken out)

Clicking the marker named the moon's phase in the same chip. It lasted a day. The marker is also the scrub handle, so aiming at a ten-pixel dot to read a label meant nudging the whole list two minutes off the hour on every miss - and the scrub cursor sitting over the marker is a promise about what a press there does. The label was worth less than the accident cost.

Shift-clicking the moon still runs the phase animation. That is a deliberate gesture rather than one you land on by aiming badly.

`moonPhaseName` stays in `GlobeModel.js`, tested and unused: the naming was never the part that was wrong. It is checked in `test/shell.d/elsewhen/moon_check.js` against the same eclipses that pin the phase itself - a solar eclipse can only happen at new moon and a lunar one only at full, so the name at those instants is not a matter of taste. The four principal phases are instants rather than eighths of a cycle, so each is given a day either side; nobody says "waning gibbous" about a disc that is 99.9% lit.

Clicking anywhere else on the row puts the chip away. A tooltip that can only be dismissed by hitting the same few pixels that opened it is a trap - clicking elsewhere is what everyone tries first.

The arrows sit over the strip's scrub area and over the row's reorder grab, so it looked as though a press on an arrow would reach all three, and that clicking "sunrise" would drag every clock in the list back to sunrise. It does not: a click on the arrow stops at the arrow, and the bar underneath records no press at all. That is measured rather than reasoned - see **Testing what the pointer does** below - and it means the scrub bar needs no guard against the arrows drawn on top of it.

A press on the row body does still reach the grab, which dismisses, so the two decisions can meet on one click. So neither rule reads the live value. Both are answered from what was showing when the press began, which is the same number whichever runs first. The two rules are `Model.chipAfterTap` and `Model.chipAfterRelease`, and `test/shell.d/elsewhen/selection_check.js` plays a click through both delivery orders across every case: opening, closing, swapping one chip for another, and a release that must not undo a chip opened during the same press.

The marker reads its lit state from the same span the band draws, so the sun can never be painted sitting in the dark half of its own bar.

## Weather

Each row shows one glyph beside its temperature: sun, partly cloudy, cloud, rain, or snow. It sits with the temperature because the two are the same fact about being outside.

Open-Meteo reports WMO present-weather codes - nearly a hundred of them, separating drizzle from freezing drizzle from rain showers. `Model.weatherKind` collapses them to those five, which is all a row has space for; fog joins cloud rather than getting a symbol nobody could read at this size. The code travels with the temperature in the same reading, so the two cannot disagree.

The sun is `white-balance-sunny`, not `weather-sunny`. The obvious one is a hollow ring inside a six-point burst, which at eleven pixels is a snowflake - sitting directly beside an actual snowflake. Candidates were rendered at the real size and compared before choosing; the one in use is a solid disc with short rays, which cannot be mistaken for anything else in the set.

One trap worth naming, caught by `test/shell.d/elsewhen/weather_check.js`: `Number(null)` is `0`, and `0` is the WMO code for *clear sky* - so a missing reading would have quietly rendered a sun. Absent values are rejected before the conversion.

## The hour's greeting

Point at a row and its date line turns into what people there would actually be saying to each other at that moment: Tokyo at midday says こんにちは, at eight in the evening こんばんは, at three in the morning おやすみ. The pronunciation follows it in grey, because a greeting you cannot say out loud is only a decoration.

This exists because the number is the one thing about a time zone that does not travel. "18:40" is the same symbol in every city on the list and says nothing about what 18:40 *is* there. The greeting is the hour as the people in it experience it, and it turns a column of digits into six places where the evening is arriving at different times.

The table is three levels deep - a zone belongs to a country, a country is greeted in a language, and a handful of cities override their country - and it is baked into `Greetings.js` and never fetched. Greetings do not change, and a network round trip on a hover would be absurd - the panel's standing rule is that nothing it draws needs the network.

Two decisions inside it are judgement calls, and are meant to be:

**It picks the language you would hear, not the one on the paperwork.** Brussels is French, Dublin is Irish, Hong Kong is Cantonese rather than Mandarin, Nairobi is Swahili. An official-languages list would have made several of these duller and one or two of them wrong.

**It does not invent an hourly split where a language has none.** Burmese greets you with မင်္ဂလာပါ at any hour and Thai barely moves, so those tables are one and two bands long. A short table is a fact about the language, not a gap in the data.

The boundaries are where the language moves rather than where a clock does, and the most interesting thing in the file is that the same language disagrees with itself: Spanish in Madrid is still saying *buenas tardes* at 20:00, while Spanish in Lima gave it up an hour earlier. Vienna gets *Grüß Gott* and Zurich *Grüezi* where Berlin gets *Guten Tag*. Indonesian has five bands where English has four - *siang* and *sore* split an afternoon English keeps whole.

The panel's own monospace family carries none of these scripts. Fontconfig substitutes per character, so a Japanese greeting is set in whatever the system has for Japanese and only the Latin ones stay monospaced; Arabic sits right-to-left with its pronunciation in a separate item beside it, which is what keeps the two from being reordered into each other.

**The bug that shaped the file.** The first version mapped the 74 cities in `cities.json` and greeted everything else in English, which held up until somebody added Tel Aviv and was wished "Good morning". The picker does not offer `cities.json`; it offers every zone `timedatectl list-timezones` returns, which is 598 of them. The fix was the whole list, by way of the system's own `zone.tab` - and the more useful half of the fix was in the test, which had been checking coverage against the wrong list and passing. English is now checked at the source rather than in the result: a zone may only be greeted in English because some country asked for English, and a zone missing from the table is a failure rather than a silent fall-through.

The overrides earn their place by being few. Honolulu is Hawaiian though the United States is English, Montreal is French though Canada is not, and that is nearly the whole list - the country is the right answer almost everywhere.

`test/shell.d/elsewhen/greetings_check.js` checks everything around the words - that every zone the picker can offer maps to a language, that no hour of any day falls into a gap, that adjacent bands actually differ, and that every non-Latin greeting carries a pronunciation while no Latin one does. The words themselves are the one thing here with no independent reference on this machine, and they want a speaker's eye rather than a test.

### The legacy aliases

The zone table was built by matching each zone's *compiled* zoneinfo file against the ones in `zone.tab`. That is exact for real zones and quietly wrong for the legacy aliases, because an alias shares its rules with whatever zone the tz database linked it to - chosen for keeping identical time, not for being anywhere near it. `Iceland` keeps Abidjan's clock all year, so it matched Burkina Faso and said *Bonjour*. `NZ` matched Antarctica, `Asia/Rangoon` the Cocos Islands, `Africa/Asmera` Djibouti. Twenty zones were in the wrong country.

Following the tz link table instead does not fix it: that returns the country of the *canonical* zone, which for `Iceland` is Côte d'Ivoire and for `Pacific/Truk` is Papua New Guinea. There is no rule available here, only places, so the fifteen are named by hand in `ALIAS_COUNTRY` and `countryFor` reads that first.

Two that look like mistakes and are not: `Antarctica/South_Pole` really is in Antarctica and `Pacific/Ponape` really is in Micronesia, whatever zones they share their rules with. `Europe/Simferopol` stays Ukrainian, which is a choice rather than a lookup.

The test checks each alias against the canonical zone for the *same place* - `Iceland` against `Atlantic/Reykjavik`, `Pacific/Truk` against `Pacific/Chuuk` - which is an answer that does not come from the table being tested. The previous alias tests only checked that the aliases were present.

## Temperature and currency

Each row shows the current temperature beside the city name. It can also show what one unit of the local currency buys in US dollars (`DKK $0.16` reads "one krone is sixteen cents"), which is **off by default** - set `showCurrency` to `true` to bring it back. US cities never show a currency: quoting dollars in dollars says nothing, the same reasoning that drops the offset for your own zone. With currency off the panel passes `--no-fx` and skips the rate request entirely.

`worldclock-data.py` gathers both and caches each on disk with its own TTL, so the panel can call it on every open without hammering anyone: geocodes are kept forever (a city does not move), currency for six hours (published once a day), weather for twenty minutes (the resolution the source offers). A warm run does no network at all and returns in about 40ms. Nothing here is fatal - a failed fetch falls back to the cached value, and failing that the row simply renders without it.

Cities are geocoded by their **label**, not their zone, which matters for aliases: Miami and Boca Raton share `America/New_York` but resolve to their own Florida coordinates and report genuinely different temperatures. Where a label cannot be geocoded, the zone's representative coordinates from `/usr/share/zoneinfo/zone1970.tab` are the fallback.

Sources are Open-Meteo (geocoding and weather) and open.er-api.com (rates); neither needs an API key.

Country-to-currency is a table in `worldclock-data.py`, validated by `test/shell.d/elsewhen/currency_check.py` against the system's iso-codes data and the live rate feed. Run it after editing that table - it is what caught Bulgaria, whose euro adoption retired BGN while the FX feed still publishes a legacy peg rate for it.

## The Earth's row (shelved)

**Off by default since 2026-08-29, the day it was built.** The author's verdict after living with it: "as much as I like the earth concept, I don't think it lands quite right." Nothing was wrong with it mechanically - it is described here in the present tense because the code and its tests are intact and `showEarth: true` brings it straight back.

Worth writing down what it might have been, since the idea itself is a good one and will come back in some other shape. The row is the only one in the list that cannot answer the question the list exists to answer. Every other row says what time it is somewhere you might call; this one says what time it is in a place nobody is, and having answered that once it has nothing further to say - it is the same row tomorrow and in three million years. In a panel whose whole subject is that time is different in different places *right now*, a row that never changes may simply be in the wrong room. The next attempt is probably one of the other deep-time sketches in `NOTES.md` - the ones that move, or that say something about the cities that are already there.

At the foot of the list, under the cities, is one more row whose city is the planet. Its day is the whole 4.54 billion years, so its clock reads 11:59 PM, its date line says *Holocene · Meghalayan*, and its strip is banded by eon instead of by daylight. Everything else about it - the padding, the type, the strip, the marker - is deliberately identical to a city, because the whole point arrives on the second read: it looks like another row until you notice what it says.

The division that makes it worth having is a single one:

| one hour   | 189 million years |
| one minute | 3.15 million years - the entire genus *Homo* |
| one second | 52,500 years - longer than every city ever built |

So all of recorded history is the last tenth of a second of the day, and everything you have ever heard of happened after the minute hand last moved. Pointing at the row swaps the epoch line for `one minute = 3.15 Myr`, which is the key to reading it at all.

Three details that are not arbitrary:

**The right-hand edge of the list is its doing.** Every city row used to set its time in from the panel's edge to keep the corner clear for a remove button that is only drawn on hover. Nobody noticed until this row arrived without one and stood 16px further out than everything above it; the fix was to bring the cities out to meet it rather than to push it back in, since the reserved column was buying nothing. The cross still sits in the corner, above the meridiem.

**It is the darkest row on the list**, at the same fill a city gets in the small hours - because it *is* in the small hours, by the same rule. For the same reason its now-marker is the moon rather than the sun.

**The marker hangs half off the right-hand end of the strip.** That is where we are, and pulling it inside to look tidy would have been a lie about the only thing the row is for.

**Nothing on it ticks.** The minute hand last moved 3.15 million years ago and will not move again for another 3.15 million. A row that cannot tick is a strange thing to put in a clock, which is exactly why it is worth putting in a clock.

It is not one of the cities. It lives outside the list model, which is what makes it permanently last and impossible to drag or remove without a special case anywhere in the drag, the remove button or the stored settings - and it would need one in all three, since the model carries a time-zone probe, weather and a currency behind every entry, none of which mean anything for a planet. `showEarth: false` is the way out if it wears thin.

The timescale in `DeepTime.js` is the ICS chart (v2023/07) with its published boundaries rather than the round numbers people remember - 538.8 Ma for the base of the Cambrian, 251.902 for the Permian-Triassic, 66 for the asteroid. `test/shell.d/elsewhen/deeptime_check.js` checks that every division is contiguous with its neighbours and nested inside its parent, which is the property a hand-typed table loses silently: a gap between two eras looks like nothing at all until a moment falls into it. The clock anchors are worked out on paper from the division alone - 66/4540 of a day is 20.93 minutes, so the dinosaurs go at 23:39 - rather than by running the code and writing down what it said.

## Overlap band (shelved)

**Off by default.** Set `showOverlap` to `true` on the widget's `shell.json` entry and the whole feature returns - the headline, the briefcase toggles and the accent bands on every strip. Nothing was removed; the model functions and `test/shell.d/elsewhen/overlap_check.js` are intact. It was shelved because "overlap" leans on a definition of working hours that the interface never states, which made the line read as unexplained. If it comes back it probably wants to say what window it is using.

The time scrubber below is a separate feature and is unaffected.

### What it does

Under the header, one line answers the question a world clock is usually for: **when can we all talk.**

Which cities count is set per row by the **briefcase** toggle - tracking a city and having someone to work with there are different things, so the band is computed only from cities with the briefcase on. New cities start off; the line appears once at least two are toggled. The toggle is stored as a third field on the zone entry (`Label|Zone|w`), so it survives a restart and existing two-field entries keep parsing.

The working windows of the toggled cities are intersected in UTC, and the result is shown in your own clock - "everyone overlaps 3:00 AM - 4:00 AM, 1:00 PM - 2:00 PM" - or "no overlapping working hours" when there is none, which for a genuinely spread-out set is the honest and useful answer.

The same interval is drawn on **every** row's daylight strip - including cities outside the working group - in the accent colour, at **that city's own local hours**, so you can also see where the meeting lands for a city you merely track. One real instant lands in a different place on each row, which is the whole point: you can see at a glance that your 1pm is Tokyo's small hours.

The intersection is sampled a minute at a time rather than solved analytically - intersecting N circular intervals has enough edge cases (windows that wrap midnight, empty results, two separate arcs) that 1440 cheap checks are worth more than clever code. A run that crosses midnight is merged into a single range rather than reported as two.

Working hours default to 09:00-17:00 local and are set per widget with `workStartHour` and `workEndHour`. Those settings are inert while `showOverlap` is false.

## Time scrubber

Drag any row's daylight strip and **every** clock moves together, so you can ask "if I propose 3pm, what am I doing to Auckland?" and see the answer rather than compute it. The header shows the shifted time in the accent colour with the offset from now (`+3h`), so a scrubbed clock can never be mistaken for the real one. Release and it holds for a couple of seconds - long enough to read - then returns to the present. Closing the panel also returns it.

The drag maps *absolutely*: the pointer's position across the strip is a local time-of-day for that city, measured against the unscrubbed present, so a drag cannot accumulate drift. It resolves to the nearest occurrence of that time, so dragging slightly left means an hour ago, never twenty-three hours on.

The rows are modelled on the zone list rather than on the computed clock rows. That matters: the clock rows are a binding on the scrubbable, ticking time, so using them as the model rebuilt every delegate on every tick - and destroyed the MouseArea mid-gesture the moment scrubbing began, which turned every drag into a single click.

`test/shell.d/elsewhen/overlap_check.js` covers the band, the scrub arithmetic and the briefcase flag, including windows that wrap midnight, runs that split across a city's local midnight, scrub direction, and round-tripping the work flag through the settings string.

## Globe mode

Tapping the globe in the header does not swap one view for another: the globe **grows out of the little circle** and shoves the rows aside, and the panel opens out around it. Tapping the cross that takes its place in the circle reverses the whole thing.

One number, `zoom`, runs from 0 (the list) to 1 (the globe). Everything is a function of it - the stage's height, each row's displacement and fade, the globe's scale and position, the cross in the header, the globe's own footer and search bar - so no part of the transition can fall out of step with any other. The animation is on `zoom` alone: 800ms `OutQuart` opening, which spends its speed early and then settles, and a brisker 500ms `InOutCubic` coming back.

**Hold Shift while clicking** to run the whole thing at a third speed - the gesture macOS has used for slow-motion window animations for years, and free here because every Hyprland binding is SUPER-prefixed. Because one number drives everything, slowing that number slows the rows, the fades and the globe's chrome with it; there is no second thing to keep in step.

The duration and easing are set *before* `globeMode` is flipped, never derived from it. Deriving them from `globeMode` inside the animation is a race - it is the very property whose change starts the animation - and losing that race means an opening transition runs with the closing duration. Every path into globe mode goes through `setGlobeMode` for that reason.

The globe is scaled about **the centre of its own disc**, not the centre of its box, so it grows from where it is drawn; the translation then carries that centre between the little circle and the middle of the stage. The two globes trade places with a quick crossfade while they are still the same size and in the same spot, so there is never a moment with two of them on screen.

Rows are shoved in sequence rather than together - each waits its turn, then covers the rest of the distance - so it reads as something arriving from above rather than the list simply leaving. They tilt, shrink, and are thrown a long way sideways in alternating directions.

They do not fade at all: they fall **clear off the bottom of the panel**. The distance is measured from the list at rest plus a margin, so even the topmost row - which has the whole list below it to fall past - is gone by the end. The fall is squared against the zoom so it accelerates rather than easing out; rows are dropped, and a dropped thing does not slow down on the way. Anything that dims on the way reads as dissolving in place rather than dropping into the dark.

Everything involved is **opaque**. The globe's ocean and the row cards were all painted as low-alpha foreground over the panel background - the right tone, but see-through, so during the transition the rows showed straight through the globe and through each other. They now mix the same tones against the background and return a colour with no alpha, which looks identical at rest and correct in motion: the globe arrives as a solid object in front of the list rather than as a tinted pane over it.

Two other details that are easy to get wrong: the **stage is not clipped**, because at the start of the flight the globe is still up in the header above it and clipping would cut it in half exactly when it is meant to look like the little circle. The rows are clipped instead, by a separate item, so they slide out of the panel rather than piling up past its edge. And the globe is **loaded on hover**, not on click, so reading its two data files never lands in the middle of the animation.

### What it shows

Tapping the globe in the panel's hero swaps the list for a spinnable orthographic globe: coastlines, a graticule, the day/night terminator, and a major city for every time zone. Drag to spin (it keeps going and eases to a stop), drag vertically to tilt, and tap a city to read its local time in the footer. Tapping the hero globe again returns to the list, and closing the panel returns to it too - the list stays the way in.

City names are drawn **in two tones**: light over the sea, dark over the land. They are painted twice - once light over everything, then again dark through a clip of the continents - so a name straddling a coastline comes out dark on its land half and light on its sea half, and every part of it sits against something it contrasts with. An outline cannot do this; it only fattens the letters and dulls both halves, which is why the names were still hard to read when they were white-with-a-black-outline. Tracked and home cities keep their distinction through weight and their dot rings rather than label colour.

Names are placed to the left of their dot when placing them to the right would run off the panel, so nothing is truncated at the edge.

On each row's daylight strip the marker is **gold by day and the moon by night** - not a plain pale dot, but tonight's actual phase, with the unlit part bitten out of it. Sun and moon are the same size: they are the same marker in the same place meaning the same thing, so only their content differs. The whole disc is always drawn faintly underneath, so the marker never disappears at new moon.

**Shift-click a moon** to walk it through a full lunation and back - the moon is nearly always somewhere unremarkable, so without this there is no way to see that the marker really is drawing a phase. It runs about five seconds, tweening between eight stops, then drops straight back to the real phase (the tween is disabled for that last step, or it would run the month backwards on the way).

It is one element carrying two facts rather than a new thing on the row, which is the only reason it earns its place. The phase follows the scrubber too, so dragging time walks the moon through its month.

`GlobeModel.moonPhase` is the mean synodic month against a known new moon - enough to draw a phase, not enough to predict an eclipse. It drifts from the true lunation by up to about half a day, which is under 6% of illumination and sub-pixel on a marker this size. `test/shell.d/elsewhen/moon_check.js` pins it against five eclipses, which are the one thing that fixes a lunation to a wall clock: a solar eclipse can only happen at new moon and a lunar eclipse only at full. The drawn shape is checked by rasterising it and counting lit pixels against the illumination formula.

City dots on the globe use the same rule as the list: gold in daylight, pale at night.

**The city you are in is always on the globe**, always labelled, and drawn the way the panel globe draws it - the dot in its own sky colour, a dark edge so a daylight sky does not vanish into the land, and a halo. It is merged in ahead of everything else, so a built-in or a tracked row of the same name cannot shadow it.

**Cities the list is tracking are painted in their own sky too**, so a city on the globe is the same colour as its row in the list: Tokyo violet at four in the morning, Copenhagen rose at dusk, Chicago blue at midday. They keep an accent ring around the dot, and they get first claim on a label slot so they are always named. Matching is by city name, not zone - tracking Miami does not light up New York, because they are different cities that happen to share `America/New_York`. A tracked city that is not one of the globe's own built-ins is merged in using the coordinates the fetcher already geocoded, so a city in the list can never be missing from the globe.

Dots are thinned in screen space before anything is drawn: candidates are offered in priority order and one is kept only if it clears the others by a minimum distance, so a dense region like western Europe shows a few legible cities instead of a smear of overlapping dots. Tracked cities and the current selection are exempt and always survive. The survivors change as the globe turns or the panel resizes, since the test is in pixels rather than degrees.

Labels are then placed greedily over the survivors with collision avoidance, so names appear and disappear as the globe turns rather than piling up.

**A city's label is part of its click target.** A two-pixel dot is a hard thing to hit, so label boxes are tested first - before dots - because a label sits beside its own dot and would otherwise lose the proximity test to a neighbouring city.

**A moving globe is drawn with less in it.** A full paint measured about 14ms on this machine - already over a 120Hz frame at 8.3ms - and the globe was managing roughly 20 paints a second whenever it moved, whether it was riding the zoom, being dragged, or coasting after a throw. Every frame of movement repaints the whole canvas, because the projection changes.

Two things dominated that paint: the city names, which cost a layout pass and two passes of text, one of them through a clip rebuilt from every coastline ring; and the graticule, 17 stroked polylines. Both are dropped while the globe is in motion and come back the moment it settles, which roughly halved the cost. Nothing is lost that could be read - names on a turning globe are a smear, and mid-zoom the whole thing is a few dozen pixels across.

Below half size the coastline is drawn at half its vertices as well. That one is tied to how big the globe is being drawn rather than to whether it is transitioning, because the zoom's ease-out spends its slow tail near full size, where the missing islands would be visible and would then snap back in. The fast early frames, where the drops actually were, happen down small.

Measured over the open transition, with `smoothMotion` off and on: average paint 11.6ms to 7ms, and the worst gap between frames 105ms to 45ms. Set `smoothMotion` to `false` to draw everything, always.

**Everything drawn scales with the shell.** Stroke widths and marker radii go through `GlobeModel.scalePx` rather than being pixel literals, because the globe's radius and its labels already follow the shell's base font size - so literals meant that raising that size grew the globe and its names while the lines and dots stayed put, and they read as proportionally thinner. The small globe never had this problem: it derives its widths from its own radius, which the large globe cannot do, its radius being hundreds of pixels rather than tens. Widths are floored at one pixel, below which a stroke stops reading as a thin line and starts dropping out of the raster.

Nothing here touches the network at runtime. The coastlines are Natural Earth 110m, simplified with Douglas-Peucker to 68 rings and 1337 points (14 KB), and the cities were geocoded once at build time - both are plain data files in the plugin. Zone offsets come from the same `date` probe the list uses.

`test/shell.d/elsewhen/globe_check.js` covers the projection and solar maths, including a check of the terminator against Open-Meteo's `is_day` for every city.

### One selection, two views

The list and the globe are two views of the same choice, so they hold it together. Clicking a row and then opening the globe lands on that city rather than resetting to home, and picking a city on the globe moves the list's focus so the header and the small globe are already on it when the globe closes.

Picking a city on the globe also brings it round to face you. Every other way of choosing one already did - opening the globe flies to the city you are in, and the jump box centres what it finds - so the click was the odd one out, and a city chosen near the limb sat where the projection is most foreshortened and was the least legible thing on screen. Only a hit turns the globe: a tap on open ocean clears the selection and leaves the view alone, because turning it for a miss would be answering a gesture nobody made.

The pick is `pickAt(x, y)` on the globe's root rather than a body inside the `MouseArea`, so the same code the pointer runs can be driven from a test or over IPC. This desktop cannot inject a pointer at all, and a copy of the logic in a test would be free to drift from the one the mouse actually reaches.

A globe city the list does not track is the ordinary case - the globe draws every zone's main city, the list holds the handful you chose - and it leaves the list where it was. There is no row to focus, and sending the list home would move it somewhere nobody asked to go. Clicking empty ocean is the same story from the other side: it clears the globe's selection, but the globe's "no city" and the list's "home" are different states and forwarding one as the other would be a lie.

The list's own focus is held the same way. `focusKey` is the city's `label|zone` and the row number is derived from it, because `zones` is a binding too - replaced wholesale on a reorder or a removal - so a stored index silently comes to mean a different city. Focus Tokyo, drag the row above it to the end, and the header, the small globe and the next globe opening all used to follow the number to whoever now sat in that slot. Deriving the index means a reorder carries the focus with the city and removing the focused city drops it back to home, neither of which anyone has to remember to do. Verified on the running panel: focused Tokyo at row 3, moved Chicago to the end, focus followed to row 2.

The crossing is made on `label|zone`, not on an index. The two views index different things - a row is an index into the settings list, the globe's selection is an index into its own catalogue of everything it draws - and that catalogue is a binding, rebuilt whenever the home row, a tracked city's coordinates or a session city lands. An index into it silently comes to mean a different city: the globe would fly to Auckland and the footer would name Honolulu. A key survives the rebuild. `test/shell.d/elsewhen/selection_check.js` covers the crossing, including the untracked city and the case where both fields have to agree.

### Jumping to a city

The bar at the bottom searches the whole zone catalogue - every IANA city plus the aliases - and turns the globe to whatever is picked, centring it by setting the spin to the city's longitude and `viewLat` to its latitude, taking the short way round.

A city already on the globe is flown to immediately. One that is not is added **for this session only**: the panel asks the fetcher to geocode it, and the globe flies there once the coordinates arrive. Nothing is written to `shell.json`, which is the point - no saved list means no delete affordance, no ordering, no migration. Want it again, type it again.

Results are drawn over the globe rather than growing the panel, so the globe does not resize under the pointer while a search is being typed.

### Turning it off

Set `globeEnabled` to `false` on the widget's `shell.json` entry. The hero stops being a button and the Loader never activates; nothing else changes.

To remove it outright:

```bash
cd "$OMARCHY_PATH/shell/plugins/panels/elsewhen"
rm Globe.qml GlobeModel.js world.json cities.json
rm "$OMARCHY_PATH/test/shell.d/elsewhen/globe_check.js"
```

then in `Panel.qml` delete the `globeEnabled`/`globeMode` properties, the `trackedNames`/`trackedCities` properties, the `HoverHandler`/`TapHandler` on `heroIcon`, the `globeMode` ternary in the hero subtitle, the two `visible: !root.globeMode` lines, the `Loader` block, and the `globe` and `globeStatus` IPC methods. Everything else is independent of it.

### The footer under the globe

Two lines: the city with its time, and under it the zone with its offset. It named nothing at all when the globe first opened - it flew to the city you are in without selecting it, so the marker sat plainly on a city with an empty line beneath it, which reads as a broken footer rather than as "nothing is selected". Opening now selects home.

A mark sits against the city's name, the same one the rows carry on their strips: a lit dot by day, tonight's moon by night. It is judged by this globe's own daylight - real solar geometry rather than the rows' fixed civil hours - so it agrees with the dot drawn on that same city an inch above it. The two definitions disagree near sunrise, and of the two possible disagreements the visible one is worse.

It is sized off the name it stands next to rather than set in pixels, and it stands on the same baseline, so it occupies exactly the band the capital does - never above the cap, never below the letters. `tightBoundingRect` on a capital M gives the ink of the glyph; the mark is one pixel under that, which is what rasterises to the same 14 device pixels, because a circle's antialiased edge reads a pixel wider than a glyph's stem. All of that was counted off a screenshot rather than judged by eye - by eye, two pixels under the cap looked fine and was not: it had turned the moon into a bullet point, and a crescent needs room to be a crescent.

Getting it onto the baseline is where the interesting failure was. `anchors.baseline` is the obvious tool and is the wrong one: inside a Row, anchoring to a sibling whose own position depends on the Row's height is a loop, and QML settled it by dropping the dot onto the line below, on top of the zone name. A Row leaves `y` alone, so both items start at its top and the dot's underside can be placed on the baseline directly - `Text.baselineOffset` is the ascent of its first line, the same number the glyph itself is drawn from.

The mark and the name are their own Row inside the line, so the gap between them can be tighter than the gaps after them - the mark belongs to the name, not to the row of facts.

It used to say "daylight" or "night" after the time as well. The globe already draws that - the city markers and the terminator say it in the picture - so the word was the picture repeated in text. It wants to be one line and cannot be - "Johannesburg Africa/Johannesburg UTC+2 7:50 PM daylight" runs off the end of the panel - but the footer's reserved height already held two caption lines, so nothing above it moved to make room.

Worth knowing if you touch it: the parts of that line used to reach the footer through `parent.parent`, which was exactly true while the line was a single Row. Wrapping it in a Column put the chain a step short, and QML resolves that to `undefined` in silence rather than complaining - the name and the time simply stopped rendering while "tracked" carried on, because "tracked" asked `root` directly. They are anchored to a named `footer` id now.

## Sky tint (shelved)

**Off by default.** Set `skyTint` to `true` on the widget's `shell.json` entry and it returns everywhere at once - city names in the list, the header city, the panel globe's marker, and every dot on the large globe.

It was shelved for a reason worth remembering: the colours were pleasant, but nothing in the interface ever *said* what they meant, so they read as decoration rather than information. Every other signal in the panel explains itself - a gold dot in a lit band is obviously daylight, a briefcase is obviously a toggle - and this one did not. If colour comes back it should arrive with something that teaches the rule.

`Sky.js` and `test/shell.d/elsewhen/sky_check.js` are untouched.

### What it did

Each city name is coloured by the sky where it is: deep blue-violet at night, dusty rose through civil twilight, amber at golden hour, pale blue under a high sun. The list becomes a gradient of the world's light, and because the tint follows the scrubber, dragging time sweeps the names through dawn and dusk.

The colour comes from the sun's actual elevation at that city's coordinates - `GlobeModel.solarElevation`, the same maths the globe's terminator uses - mapped through a ramp of literal colours in `Sky.js`. They are literal rather than theme roles because this is trying to look like the sky, and no palette role means "dawn"; they are kept fairly light so a name stays legible on a dark panel. Cities not yet geocoded fall back to the plain foreground.

### Turning it off

Set `skyTint` to `false`. To remove it outright, delete `Sky.js` and `test/shell.d/elsewhen/sky_check.js`, drop the `import "Sky.js"` and `import "GlobeModel.js"` lines from `Panel.qml`, and restore the city-name colour to `root.foreground` - the `skyColorFor` function and the `subsolar` property go with it. Note `GlobeModel.js` is also used by globe mode, so only remove the import, not the file.

## The hero globe

The globe in the header is drawn, not a glyph, by `MiniGlobe.qml`. A glyph cannot spin: rotating a flat image about the vertical axis squashes it to a line and flips it, which reads as a coin. A sphere keeps its circular outline and moves only its surface across it - so the disc is constant and the graticule and coastlines are re-projected as the spin advances, using the same orthographic projection as globe mode and the same `world.json`.

Landmasses are filled rather than outlined, and only rings above a size threshold are drawn: at icon size an outline is a scribble and an island is a speck of dirt on the lens. The rim is stroked last so nothing spills over it.

Both globes fill their continents from the same clipping code in `GlobeModel.js`. Neither strokes a coastline over the fill: the fill's own edge *is* the coastline, and that second pass over every ring turned out to be the expensive half. Measured on the large globe, per repaint: outlines only 8.1ms, fill plus outline 13.4ms, **fill alone 9.1ms** - so the filled look costs about 1ms over the outlines it replaced, against a 16.7ms frame budget.

Filling also means labels and city dots now cross light land as often as dark ocean, so labels are outlined and every dot carries a dark edge.

Clipping a coastline to the visible hemisphere has to produce **one** polygon per ring. The obvious approach - keep each visible run and close it - makes self-intersecting shapes whose area jumps whenever a run splits, and that is visible: continents morph and pulse at the limb, worst as the spin slows and there is time to watch. Sutherland-Hodgman against the hemisphere keeps the ring whole, and walking the limb between an exit and the next entry (rather than cutting straight across) makes the silhouette continuous. Measured over a full rotation, the worst area change per quarter-degree of spin goes from 356 px^2 (split runs) to 278 (whole ring, chords) to **3.5** (whole ring, limb arcs) on a 2463 px^2 disc. `test/shell.d/elsewhen/clip_check.js` holds it there.

The globe leans by `GlobeModel.AXIAL_TILT` - 23.44 degrees, the real obliquity, and the same constant the subsolar calculation uses.

It is drawn at full strength and oversized rather than sitting at text weight: as the centrepiece a dimmed thin globe just reads as washed out.

A marker shows the city you are in, painted the same sky colour the header paints its name - so the dot and the name always agree about what time of day it is there. It carries a dark edge: a daylight sky is nearly the same lightness as the filled continents, and without one the dot dissolves into whichever landmass it is sitting on. With the tint switched off it falls back to the accent colour.

**The globe opens on the city you are in.** It flies there as the panel zooms out, so the two motions - growing out of the header and turning round to home - land together rather than one after the other. If your coordinates have not arrived yet, which happens on a cold geocode cache, the request is held and runs the moment they do.

**Clicking a city row turns the globe to it**, marks it, and paints the marker with that city's sky - so a tap on Tokyo swings the globe round and drops a night-violet dot on Japan. It takes the shortest way round rather than always turning forward: Los Angeles to Tokyo is 102 degrees west, not 258 east.

While the globe is showing somewhere else, the city name in the header line is underlined; clicking that line brings it home. The whole line is the target, not just the name - it is a small piece of text to have to hit exactly - and it is only live while the globe is away, so it is never a dead click target. Reopening the panel also returns it home.

The opening spin **lands on home** - the animation runs from `homeLon - 1080` to `homeLon`, which is three whole turns that finish with your own meridian facing you rather than stopping wherever the arithmetic left it. At rest a `Binding` holds the globe there, standing down while the animation is writing the property. Until the fetcher has geocoded your city the marker is hidden and it rests on Greenwich.

The sidebar icon carries the same tilt, via `WidgetButton.textRotation`.

Opening the panel spins it three turns. `Easing.OutQuart` over 1250ms puts most of the rotation in the first third and lets the rest coast out, which is what a globe flicked by hand does rather than a motor driving it at a constant rate.

## Where "here" is

The header reads "It's 10:28 AM here in Los Angeles." rather than a bare "here", which names your own city without spending a row on it. The zone comes from the same `date` probe the rows use - one extra `LOCAL|<zone>` line, from `timedatectl` with the `/etc/localtime` symlink as fallback - so it costs no additional process and follows a time-zone change on the next refresh.

The city name is the zone's last segment, and the tz database names zones after a *representative* city: someone in Boca Raton would read "here in New York". Set `homeCity` to override it.

## Two offsets, one line

A row's offset reads `+2h` - how far that city is from you - until you click it, and then every row reads `UTC-5` instead. Both are the same fact from different ends, and neither is the useful one twice running: the relative offset answers "how far ahead are they", the absolute one answers "where is this place", and the click is cheaper than printing both and doubling the width of the line.

It is one setting for the whole list rather than one per row. A column where each row had picked its own units would be unreadable, and the point of a column is that it can be read down. The choice is stored, so it survives a restart.

The tap target sits on the offset itself, and works because it is declared late: the drag handle covers the whole body of the row, and later siblings win the tap - the same rule the remove button and the briefcase already rely on.

The globe's footer reads the same setting and offers the same click, so the offset under the globe is never in different units from the offset in the list you just came from, and flipping it in either place flips it in both. There the target is the zone name as well as the number: on your own home city the relative offset is blank - "same time" is the one answer the reader already has - and a control that disappears on one city out of the list is not a control.

The globe does not own the setting. It publishes `offsetModeToggleRequested` and the panel flips it; the new mode arrives back down the same binding as every other property. A child that wrote the setting itself would be a second place the mode could live, and the two could disagree.

## Units and notation, on a click

The temperature and the time are both controls. Click any temperature to swap the whole list between Celsius and Fahrenheit; click any time to swap it between 12- and 24-hour. Both work the way the offset does - one setting for every row, changed where you are already reading rather than in a settings pane, and written straight to `shell.json` so it survives a restart.

One setting for all rows, not one per row, for the same reason the offsets move together: every clock here exists to be read against the others, and a single row in different units would be the one thing on screen that could not be compared.

The starting notation follows the machine too. With `hour24` unset, the locale's own short time format decides: `Qt.locale().timeFormat` gives `h:mm Ap` for `en_US` and `en_AU`, `HH:mm` for `en_GB`, `de_DE`, `fr_FR` and `zh_CN`, `H:mm` for `ja_JP` and `H.mm` for `fi_FI`. The test is the AM/PM designator rather than the case of the hour letter - `h` means 1-12 and `H` means 0-23, which is the same answer, but a locale may spell a 24-hour clock with either while a designator only ever belongs to a 12-hour one. Quoted literal text is stripped first, because some locales write the separator as `H'h'mm`.

Those patterns were read off the running shell, not assumed, and the ones that matter are in `test/shell.d/elsewhen/weather_check.js` verbatim - including the detail that Qt spells the designator `Ap` and puts U+202F in front of it, not a space.

The starting unit follows the machine rather than the author. With `units` unset, `Qt.locale().measurementSystem` decides: the US system means Fahrenheit and everything else means Celsius. `F` was the default while this ran on one desktop and is the wrong default for almost everywhere else. Measured, not assumed - `en_US` reports `ImperialUSSystem`, `en_GB` reports `ImperialUKSystem` and `de_DE` and `ja_JP` report `MetricSystem`, so the rule gives Britain Celsius, which is what Britain uses for weather whatever else it measures in miles.

The rule is Qt's CLDR data and it is not a survey of thermometers: Liberia, which does use Fahrenheit day to day, reports as metric. That is what the click is for. An explicit `C` or `F` always wins over the automatic answer, so one click is the whole escape hatch, and `""` puts it back on the system's units. `Model.resolveUnits` holds those rules and `test/shell.d/elsewhen/weather_check.js` covers them, including the junk values a hand-edited `shell.json` can produce.

## Testing what the pointer does

For most of this project's life the interactions were reasoned about rather than tried: no pointer can be injected into the running shell, so handler questions were settled by reading Qt's documentation. That was a mistake. `qmltestrunner` synthesises real mouse events into an offscreen window, and the structures worth checking are small enough to rebuild in a test:

```bash
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input test/shell.d/elsewhen/qml
```

Use that full path. `/usr/bin/qmltestrunner` is the Qt5 binary; it exits 0 having run nothing and printed nothing, which looks exactly like success - the same trap as `qml` versus `qml6` on this machine.

`test/shell.d/elsewhen/qml/tst_arrows.qml` is the first of these, and it settled a question that had been answered wrongly twice: whether a click on an item in front also reaches a `MouseArea` behind it. It does not.

## Keys

| Key | What it does |
|-----|--------------|
| `Space` | opens the globe, and closes it again |
| `+` | opens the city search, or the globe's jump box when the globe is up |
| `a` | opens the city search (list only) |
| `j` | opens the globe's jump box (globe only) |
| `r` | re-probes the zones and refetches the weather |
| `Esc` | closes the search, then leaves the globe, then closes the panel |
| arrows, Return | walk and pick a search result |

Space was a door rather than a switch for a while: it opened the globe and pressing it again did nothing, because Escape was already the way back and one key per direction is easier to hold in the head than one key that depends on where you are. That is a sound argument about the keyboard as a system and the wrong one about the hand, which is already on the space bar and has nowhere to go for the round trip. Space toggles now. Escape still unwinds the whole ladder - search, globe, panel - so nothing was given up to allow it.

The key catcher reports Space as "activate" and reports Return as a return *and then* an activate, so Return marks itself on the way past and the activate behind it stands down - otherwise Return would quietly work the globe too.

Escape unwinds one layer per press rather than closing outright, so the way out of the globe is the same key as the way out of everything else. Getting that right needed the globe's search to hand the keyboard back when it closes: a hidden item keeps its focus, so the field that had been taking the keys went on swallowing them, and the second Escape went nowhere.

## Settings

Inline on the widget's `shell.json` entry:

| Key      | Meaning                                              |
|----------|------------------------------------------------------|
| `zones`  | `Label\|IANA name`, comma separated                   |
| `hour24` | `true` or `false`; blank (the default) follows the system's time format. Click any row's time to flip it |
| `offsetMode` | `home` for the offset from you (default), `utc` for the absolute one |
| `units`  | `F` or `C`; blank (the default) follows the system's measurement units. Click any temperature to flip it |
| `homeCity` | your city for the header (blank = from the system zone) |
| `smoothMotion` | drop labels and detail while the globe moves (default true) |
| `skyTint` | `true` to colour cities by their sky (default off, shelved)     |
| `showCurrency` | `true` to show local currency value in USD (default off) |
| `globeEnabled` | `false` to remove the globe entry point (default on)     |
| `showEarth` | `true` to bring back the Earth's own row at the foot of the list (default off, shelved) |
| `showOverlap` | `true` to restore the overlap band and briefcases (default off) |
| `workStartHour` / `workEndHour` | working window for the overlap band (9 / 17) |

## IPC

```bash
omarchy-shell omarchy.elsewhen toggle
omarchy-shell omarchy.elsewhen times                            # JSON, one entry per row
omarchy-shell omarchy.elsewhen add America/New_York Miami
omarchy-shell omarchy.elsewhen remove America/New_York
omarchy-shell omarchy.elsewhen refresh                          # re-probe offsets
```
