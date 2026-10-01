# Elsewhen

A world clock for the Omarchy shell: a globe in the bar that opens a panel of clocks, one row per city, with a spinnable globe behind it. It lives in `shell/plugins/panels/elsewhen/` under the plugin id `omarchy.elsewhen`, and file names below are relative to that directory. Its checks live in `test/shell.d/elsewhen/` and run as part of `./test/shell` through `test/shell.d/elsewhen-test.sh`.

Everything it needs is already on an Omarchy install: `date` and `timedatectl` for zone offsets, and `curl` for weather. Weather is the only thing that touches the network: [Open-Meteo](https://open-meteo.com) geocoding and forecasts, without an API key. The globe's coastlines are [Natural Earth](https://www.naturalearthdata.com) 110m (public domain), shipped as `world.json`. Settings live inline on the widget's `shell.json` entry; see [Settings](#settings).

## Why it shells out to `date`

Qt's QML engine has no `Intl`, so JavaScript cannot be asked for the time in an arbitrary IANA zone. Instead a single `date` probe reports each zone's current UTC offset and abbreviation, and the rows tick locally against those offsets. Offsets only move at a DST boundary, so the probe re-runs whenever the panel opens and every five minutes while it stays open.

## Reordering

Grab the body of a row and drag it up or down. The row lifts and follows the pointer while the ones it passes step aside by exactly one row; the new order is written to `shell.json` on release.

Three things make it feel solid:

**The pointer is measured in the Column, not in the row.** The grab area sits inside the row, and the row is translated as it is dragged - so reading `mouse.y` directly is a feedback loop: the local frame slides out from under a stationary pointer, the offset chases itself, and the row stutters. `mapToItem` into the (never-moving) Column gives a stable reading.

**The target slot has hysteresis.** Recomputing it freely means a pointer resting near a boundary flips between two slots on sub-pixel movement. The target only changes once the pointer is 0.6 of a row past the current slot, so jitter at a midpoint holds steady.

**The drop is animated.** On release the row glides the remaining distance into its slot and the reorder commits when it arrives, rather than the row vanishing from under the pointer. Rows making room ease aside too - but the dragged row itself is excluded from that easing, or it lags the cursor.

The list itself is **not** touched while the pointer moves - rows are displaced with a `Translate` transform, which is purely visual and leaves the Column's layout alone. Reordering the model mid-drag would replace the array the Repeater is built from, rebuild every delegate, and drop the gesture half-way through.

The grab area stops above the daylight strip, so vertical reordering never competes with the strip's horizontal scrub, and it is declared before the remove button so that keeps its taps. A few pixels of slack are required before a drag arms, so a click is never a reorder.

## The first run

A fresh install has no configuration and asks for none. The first time the panel opens it writes its own starting list: **the city you are in, plus four well-known destinations spread round the clock from it** - five rows, so it looks like a world clock immediately rather than an empty box with an "add a city" button.

The four are chosen **relative to home**. A fixed list would hand someone in Paris a second Paris, and would give a reader in Tokyo a spread that is really a spread around California. From Los Angeles the list comes out as New York, London, Dubai, Tokyo; from Copenhagen as Delhi, Tokyo, Los Angeles, New York.

Candidates are taken in order of how well known they are, and one is kept only if it is at least three hours from home *and* from every city already picked - so the gap does the spreading rather than a rule about spacing. Spacing four cities evenly round the dial and taking whoever is nearest each mark gives a tidier spread but a stranger list: from Los Angeles it produces Sao Paulo, Cairo, Bangkok and Auckland, which is even but reads like a lottery. If somewhere has too little of the world far enough away - the Pacific, mostly - the three-hour gap relaxes rather than returning a short list. The result is sorted eastward, so the list walks round the world.

It costs one process: the same `date` probe that reads the local zone also prices the candidate cities on that first run, and never again. The local zone is emitted twice in that probe - once as the `LOCAL` marker and once as an ordinary row - so home's own offset is available like any other city's, which the picker needs and cannot ask for in advance.

Everything is written to `shell.json` as a normal list, so the first thing anyone can do is delete or reorder it. `test/shell.d/elsewhen-model-test.sh` runs the whole thing from fifteen different home cities, including UTC, Kathmandu's forty-five-minute offset, and the Pacific.

## Adding and removing cities

`+ Add a city` opens an inline search over the system's zone list. Clicking a result adds it; hovering a row reveals a `×` in its top-right corner to remove it. The last row cannot be removed. Changes are written straight back to this widget's entry in `~/.config/omarchy/shell.json`, so they survive a restart.

The search is driven from the keyboard: type, walk the results with the up and down arrows, Return adds the highlighted one, Escape closes. The selection starts on the first match, so the common case - type three letters, press Return - never needs an arrow at all, and it wraps at both ends because the list is six long and entirely on screen. A changed query puts the selection back on the first row: the list under it has been replaced, and Return should not add a city nobody looked at.

Both lists name the zone and say where it is: `Asia/Kathmandu  UTC+5:45`. The name alone does not settle it - half a dozen entries share `America/Los_Angeles`, and `Asia/Kolkata` tells you nothing about India being half an hour off the hour until it says `UTC+5:30`. The offset is absolute rather than relative to you, unlike the `+9h` on a tracked row: a city you have not added yet has no relationship to you yet.

Search results are not covered by the probe that feeds the rows - that one only knows the cities you track - so the offsets come from a second `date` call over whatever the list is currently showing, at most six zones, coalesced while one is in flight. The answers are merged into what is already known rather than replacing it, so the column does not blank on every keystroke.

The globe's own **jump box** works the same way - arrows, Return, Escape, selection on the first match, wrapping over five results. Its results grow upward out of the field rather than down from it, but the first match is still at the top of them, so Down moves down the screen and down the list at once.

**A zone is not a city.** Six of the picker's entries share `America/Los_Angeles`; the name is the only thing telling Oakland from Las Vegas from Los Angeles. Committing a choice passes the label alongside the zone, so picking Oakland puts "Oakland" on the list rather than "Los Angeles".

The `×` is placed from the corner rather than centered in its target, so how tucked-in it reads does not depend on how big the target is. The target itself is anchored flush into the corner and is larger than the mark, because a corner is the easiest place on a row to hit.

The search is rendered inline rather than in a dropdown popup: the shared `SearchableDropdown` only ever opens downward, and this panel hangs off a vertical bar low on the screen, so its list would run off the bottom edge.

Inline, the list grows the panel instead - but only up to the card's cap, the screen's height or `space(680)`, whichever is smaller. Past that the content is clipped to the card and scrolls, and while the search is open the panel follows the results down so the last one is not left clipped against the bottom edge.

Scrolling is the wheel only. The rows own the pointer - drag-to-reorder and the scrub strip are `MouseArea`s with `preventStealing` - so an interactive `Flickable` would be fighting them for every gesture.

### City aliases

The tz database ships one representative city per zone, so most places people actually search for are missing — there is no `Miami`, only `America/New_York`. `CITY_ALIASES` in `Model.js` adds extra search entries pointing at the zone that governs them. Adding a city is a one-line change; the only rule is that the zone must be the one that place actually observes, DST rules included.

Two cities may share a zone (Miami and Boca Raton are both `America/New_York`), so a row is identified by its label and zone together, and removal is by position.

## The daylight strip

Each row carries a 24-hour bar, midnight to midnight in that city's own clock, with the daylight lit and a marker at now. Read down the column and you can see who is awake: markers inside the lit band are in daylight, markers out at the dark ends are not. Rows are also filled by phase, lightest at midday and darkest at night.

The lit band is the city's real day, from the coordinates the weather lookup already geocodes. Reykjavik's four-hour December day and Auckland's long January one are different shapes, and that difference is most of what a daylight bar is worth looking at. A city the geocoder has not placed yet gets a fixed 06:00-18:00 band until its coordinates arrive.

The marker turns gold while it is inside the lit band and stays white outside it. That is decided geometrically, from the same span the band draws, not from the phase name - so the sun can never be painted sitting in the dark half of its own bar. The gold is a literal color rather than a theme role, because several themes map the palette name `yellow` to something that isn't yellow.

`Sun.js` computes the day, built on the globe's own `subsolarPoint` rather than a second copy of the astronomy. Declination comes straight off that function and the equation of time is recovered from it - `subsolarPoint` builds its meridian as `lon = -15 * (utcHours - 12) - eot`, so running that relation backwards hands the correction back with nothing new to keep in step. Local solar noon is found by iterating: the subsolar meridian sweeps west at a steady 15 degrees an hour, so the gap between where the sun is and where you want it converts straight into a time correction, and three passes put the residual under a second.

`test/shell.d/elsewhen-sun-test.sh` checks it against Open-Meteo's published sunrise and sunset for thirteen cities - both hemispheres, both solstices, the equator, and Kashgar, which runs on Beijing time and sees the sun rise at 08:23 by the clock. The reference rows are held in the test verbatim so it stays offline.

It is inside a minute at mid-latitudes, and about four minutes at Nuuk and Anadyr, both a little past 64 degrees north. That is the shared low-precision solar position doing what it says: it is good to a fraction of a degree, and near the poles the sun crosses the horizon at such a shallow angle that a fraction of a degree is minutes of time. The two high-latitude cities are in the test with the tolerance they actually need rather than left out.

A bar can be lit at both ends, and that is not a drawing fault. Reykjavik on the June solstice sets four minutes after midnight, so the first four minutes of the same day are lit too - by the sun that rose the morning before. The day is drawn where it falls and again a day either side, and only the parts that land on the bar survive.

The arrows do not wrap with it. A sunset at 00:04 belongs to the next bar along, and a mark pinned to this one's edge would claim the sun set at midnight.

Above the Arctic circle there is no sunrise to plot, and that is a real answer rather than an error: `kind` comes back as `midnightSun` or `polarNight`, the band is the whole bar or none of it, and no arrows are drawn. Longyearbyen in June and in December are both in the test.

### The arrows

An up arrow just before the band and a down arrow just after it, shown while the pointer is on that row and outside the lit part rather than on its edge - a mark sitting on the boundary reads as part of the band and gets lost in it. The band already says how long the day is; the arrows say which end is which. They keep off the resting state: five rows each carrying two arrows all the time is a lot of furniture for something looked up rarely.

They are tucked in close to the band. The tap target is finger-sized and the glyph sits in the middle of it, so a box placed flush against the crossing would leave the arrow half a box away. A nudge closes most of that without letting the glyph touch the band.

Sunrise sits two pixels high and sunset two pixels low. The glyphs are the same height and the same shape reversed, which is the pair the eye is worst at telling apart at this size. The offset gives a second, coarser cue that needs no reading: the one above the line is the one going up.

Click one and it prints `Sunrise 6:16 AM` in a small dark chip above the bar - named, not just numbered, because a bare time floating over a row that already has a clock on it has to be worked out from which arrow was clicked. One at a time, and it clears when the pointer leaves the row.

Above and not below, because below is where the pointer is. The chip floats over the date line, which is why it has a ground of its own, and its colors are inverted in every theme the way a tooltip is. The arrows carry `z: 1` so the chip paints over the row's time block, which is declared after them.

They are declared after the strip's scrub `MouseArea`. That one covers the whole bar to drag time, and an earlier sibling would never see a press - the same later-sibling rule the remove button relies on.

An arrow hides while the marker is standing on it. Two things drawn at the same point read as a printing fault, and the arrow is the one that can be spared: it marks a boundary that is not going anywhere, while the marker is the only thing on the bar that says when now is. It follows `nowMarker.x` and not the row's progress, so the arrow comes back exactly as the sun clears it - the marker's motion is eased, and progress is where it is going, not where it is. Hidden rather than faded, because invisible is also untappable: a click on the sun should scrub time the way it does everywhere else on the bar. If the marker covers an arrow whose time is open, the chip closes with it.

Clicking the marker itself does not name the moon's phase: the marker is also the scrub handle, so aiming at a ten-pixel dot to read a label would nudge the whole list off the hour on every miss. Shift-clicking the moon runs the phase animation instead, which is a deliberate gesture rather than one you land on by aiming badly.

Clicking anywhere else on the row puts the chip away. A tooltip that can only be dismissed by hitting the same few pixels that opened it is a trap.

A click on an arrow stops at the arrow: the scrub bar and the row's reorder grab underneath record no press at all, so the scrub bar needs no guard against the arrows drawn on top of it. That is measured rather than reasoned - see [Testing what the pointer does](#testing-what-the-pointer-does).

A press on the row body does still reach the grab, which dismisses, so the two decisions can meet on one click. Neither rule reads the live value; both are answered from what was showing when the press began, which is the same number whichever runs first. The two rules are `Model.chipAfterTap` and `Model.chipAfterRelease`, and `test/shell.d/elsewhen-model-test.sh` plays a click through both delivery orders across every case: opening, closing, swapping one chip for another, and a release that must not undo a chip opened during the same press.

## Weather

Each row shows the current temperature beside the city name, and one glyph beside it: sun, partly cloudy, cloud, rain, or snow. The glyph sits with the temperature because the two are the same fact about being outside.

Open-Meteo reports WMO present-weather codes - nearly a hundred of them, separating drizzle from freezing drizzle from rain showers. `Model.weatherKind` collapses them to those five, which is all a row has space for; fog joins cloud rather than getting a symbol nobody could read at this size. The code travels with the temperature in the same reading, so the two cannot disagree.

The sun is `white-balance-sunny`, not `weather-sunny`. The obvious one is a hollow ring inside a six-point burst, which at eleven pixels reads as a snowflake - sitting directly beside an actual snowflake. The one in use is a solid disc with short rays, which cannot be mistaken for anything else in the set.

`Number(null)` is `0`, and `0` is the WMO code for *clear sky* - so a missing reading would quietly render a sun. Absent values are rejected before the conversion; `test/shell.d/elsewhen-model-test.sh` covers it.

The panel fetches it with `curl`, in two steps: one geocoding request per city it has no coordinates for yet, then one batched forecast for every city. Both results live in memory as `facts`, keyed `label|zone`. Geocodes last the session (a city does not move) and weather twenty minutes (the resolution the source offers), so opening the panel again soon does no network at all. Nothing here is fatal - a failed fetch keeps the previous value, and failing that the row simply renders without it.

Cities are geocoded by their **label**, not their zone, which matters for aliases: Miami and Boca Raton share `America/New_York` but resolve to their own Florida coordinates and report genuinely different temperatures. Where a label cannot be geocoded, the zone's representative coordinates from `/usr/share/zoneinfo/zone1970.tab` are the fallback; after a network failure that fallback is used for now and the geocode retried on the next refresh.

## The hour's greeting

Point at a row and its date line turns into what people there would actually be saying to each other at that moment: Tokyo at midday says こんにちは, at eight in the evening こんばんは, at three in the morning おやすみ. The pronunciation follows it in grey, because a greeting you cannot say out loud is only a decoration.

The number is the one thing about a time zone that does not travel. "18:40" is the same symbol in every city on the list and says nothing about what 18:40 *is* there. The greeting is the hour as the people in it experience it.

The table is three levels deep - a zone belongs to a country, a country is greeted in a language, and a handful of cities override their country - and it is baked into `Greetings.js` and never fetched. Greetings do not change, and nothing the panel draws on hover should need the network.

Two decisions inside it are judgement calls, and are meant to be:

**It picks the language you would hear, not the one on the paperwork.** Brussels is French, Dublin is Irish, Hong Kong is Cantonese rather than Mandarin, Nairobi is Swahili. An official-languages list would have made several of these duller and one or two of them wrong.

**It does not invent an hourly split where a language has none.** Burmese greets you with မင်္ဂလာပါ at any hour and Thai barely moves, so those tables are one and two bands long. A short table is a fact about the language, not a gap in the data.

The boundaries are where the language moves rather than where a clock does, and the same language disagrees with itself: Spanish in Madrid is still saying *buenas tardes* at 20:00, while Spanish in Lima gave it up an hour earlier. Vienna gets *Grüß Gott* and Zurich *Grüezi* where Berlin gets *Guten Tag*. Indonesian has five bands where English has four - *siang* and *sore* split an afternoon English keeps whole.

The panel's own monospace family carries none of these scripts. Fontconfig substitutes per character, so a Japanese greeting is set in whatever the system has for Japanese and only the Latin ones stay monospaced; Arabic sits right-to-left with its pronunciation in a separate item beside it, which is what keeps the two from being reordered into each other.

**Every zone the picker offers is covered.** The picker offers every zone `timedatectl list-timezones` returns - 598 of them, not just the 74 in `cities.json` - so the table is built from the system's own `zone.tab`. English is checked at the source rather than in the result: a zone may only be greeted in English because some country asked for English, and a zone missing from the table is a failure rather than a silent fall-through to English.

The overrides earn their place by being few. Honolulu is Hawaiian though the United States is English, Montreal is French though Canada is not, and that is nearly the whole list - the country is the right answer almost everywhere.

`test/shell.d/elsewhen-greetings-test.sh` checks everything around the words - that every zone the picker can offer maps to a language, that no hour of any day falls into a gap, that adjacent bands actually differ, and that every non-Latin greeting carries a pronunciation while no Latin one does. The words themselves are the one thing here with no independent reference on this machine, and they want a speaker's eye rather than a test.

### The legacy aliases

The zone table matches each zone's *compiled* zoneinfo file against the ones in `zone.tab`. That is exact for real zones and wrong for the legacy aliases, because an alias shares its rules with whatever zone the tz database linked it to - chosen for keeping identical time, not for being anywhere near it. `Iceland` keeps Abidjan's clock all year, so it would match Burkina Faso and say *Bonjour*; `NZ` would match Antarctica, `Asia/Rangoon` the Cocos Islands, `Africa/Asmera` Djibouti.

Following the tz link table instead does not help: that returns the country of the *canonical* zone, which for `Iceland` is Côte d'Ivoire and for `Pacific/Truk` is Papua New Guinea. There is no rule available here, only places, so the fifteen are named by hand in `ALIAS_COUNTRY` and `countryFor` reads that first.

Two that look like mistakes and are not: `Antarctica/South_Pole` really is in Antarctica and `Pacific/Ponape` really is in Micronesia, whatever zones they share their rules with. `Europe/Simferopol` stays Ukrainian, which is a choice rather than a lookup.

The test checks each alias against the canonical zone for the *same place* - `Iceland` against `Atlantic/Reykjavik`, `Pacific/Truk` against `Pacific/Chuuk` - which is an answer that does not come from the table being tested.

## Time scrubber

Drag any row's daylight strip and **every** clock moves together, so you can ask "if I propose 3pm, what am I doing to Auckland?" and see the answer rather than compute it. The header shows the shifted time in the accent color with the offset from now (`+3h`), so a scrubbed clock can never be mistaken for the real one. Release and it holds for a couple of seconds - long enough to read - then returns to the present. Closing the panel also returns it.

The drag maps *absolutely*: the pointer's position across the strip is a local time-of-day for that city, measured against the unscrubbed present, so a drag cannot accumulate drift. It resolves to the nearest occurrence of that time, so dragging slightly left means an hour ago, never twenty-three hours on.

The rows are modelled on the zone list rather than on the computed clock rows. The clock rows are a binding on the scrubbable, ticking time, so using them as the model would rebuild every delegate on every tick and destroy the `MouseArea` mid-gesture, turning every drag into a single click.

`test/shell.d/elsewhen-model-test.sh` covers the scrub arithmetic, including scrub direction and the short way round midnight.

## Globe mode

Tapping the globe in the header does not swap one view for another: the globe **grows out of the little circle** and shoves the rows aside, and the panel opens out around it. Tapping the cross that takes its place in the circle reverses the whole thing.

One number, `zoom`, runs from 0 (the list) to 1 (the globe). Everything is a function of it - the stage's height, each row's displacement, the globe's scale and position, the cross in the header, the globe's own footer and search bar - so no part of the transition can fall out of step with any other. The animation is on `zoom` alone: 800ms `OutQuart` opening, which spends its speed early and then settles, and a brisker 500ms `InOutCubic` coming back.

**Hold Shift while clicking** to run the whole thing at a third speed - the gesture macOS uses for slow-motion window animations, and free here because every Hyprland binding is SUPER-prefixed. Because one number drives everything, slowing that number slows the rows, the fades and the globe's chrome with it.

The duration and easing are set *before* `globeMode` is flipped, never derived from it. Deriving them from `globeMode` inside the animation is a race - it is the very property whose change starts the animation - and losing that race means an opening transition runs with the closing duration. Every path into globe mode goes through `setGlobeMode` for that reason.

The globe is scaled about **the center of its own disc**, not the center of its box, so it grows from where it is drawn; the translation then carries that center between the little circle and the middle of the stage. The two globes trade places with a quick crossfade while they are still the same size and in the same spot, so there is never a moment with two of them on screen.

Rows are shoved in sequence rather than together - each waits its turn, then covers the rest of the distance - so it reads as something arriving from above rather than the list simply leaving. They tilt, shrink, and are thrown a long way sideways in alternating directions.

They do not fade at all: they fall **clear off the bottom of the panel**. The distance is measured from the list at rest plus a margin, so even the topmost row - which has the whole list below it to fall past - is gone by the end. The fall is squared against the zoom so it accelerates rather than easing out, the way a dropped thing does.

Everything involved is **opaque**. The globe's ocean and the row cards mix their tones against the panel background and return a color with no alpha, rather than painting low-alpha foreground over it. That looks identical at rest and correct in motion: the globe arrives as a solid object in front of the list rather than as a tinted pane the rows show through.

The **stage is not clipped**, because at the start of the flight the globe is still up in the header above it and clipping would cut it in half exactly when it is meant to look like the little circle. The rows are clipped instead, by a separate item, so they slide out of the panel rather than piling up past its edge. The globe is **loaded on hover**, not on click, so reading its two data files never lands in the middle of the animation.

### What it shows

A spinnable orthographic globe: coastlines, a graticule, the day/night terminator, and a major city for every time zone. Drag to spin (it keeps going and eases to a stop), drag vertically to tilt, and tap a city to read its local time in the footer. Tapping the hero globe again returns to the list, and closing the panel returns to it too - the list stays the way in.

City names are drawn **in two tones**: light over the sea, dark over the land. They are painted twice - once light over everything, then again dark through a clip of the continents - so a name straddling a coastline comes out dark on its land half and light on its sea half, and every part of it sits against something it contrasts with. An outline cannot do this; it only fattens the letters and dulls both halves. Tracked and home cities keep their distinction through weight and their dot rings rather than label color.

Names are placed to the left of their dot when placing them to the right would run off the panel, so nothing is truncated at the edge.

On each row's daylight strip the marker is **gold by day and the moon by night** - not a plain pale dot, but tonight's actual phase, with the unlit part bitten out of it. Sun and moon are the same size: they are the same marker in the same place meaning the same thing, so only their content differs. The whole disc is always drawn faintly underneath, so the marker never disappears at new moon.

**Shift-click a moon** to walk it through a full lunation and back - the moon is nearly always somewhere unremarkable, so without this there is no way to see that the marker really is drawing a phase. It runs about five seconds, tweening between eight stops, then drops straight back to the real phase (the tween is disabled for that last step, or it would run the month backwards on the way).

It is one element carrying two facts rather than a new thing on the row, which is the only reason it earns its place. The phase follows the scrubber too, so dragging time walks the moon through its month.

`GlobeModel.moonPhase` is the mean synodic month against a known new moon - enough to draw a phase, not enough to predict an eclipse. It drifts from the true lunation by up to about half a day, which is under 6% of illumination and sub-pixel on a marker this size. `test/shell.d/elsewhen-globe-test.sh` pins it against five eclipses, which are the one thing that fixes a lunation to a wall clock: a solar eclipse can only happen at new moon and a lunar eclipse only at full. The drawn shape is checked by rasterising it and counting lit pixels against the illumination formula.

City dots on the globe use the same rule as the list: gold in daylight, pale at night.

**The city you are in is always on the globe**, always labelled, and drawn the way the panel globe draws it - the dot in the accent color, a dark edge so it does not vanish into the land, and a halo. It is merged in ahead of everything else, so a built-in or a tracked row of the same name cannot shadow it.

**Cities the list is tracking** get an accent ring around the dot, and first claim on a label slot so they are always named. Matching is by city name, not zone - tracking Miami does not light up New York, because they are different cities that happen to share `America/New_York`. A tracked city that is not one of the globe's own built-ins is merged in using the coordinates the weather script already geocoded, so a city in the list can never be missing from the globe.

Dots are thinned in screen space before anything is drawn: candidates are offered in priority order and one is kept only if it clears the others by a minimum distance, so a dense region like western Europe shows a few legible cities instead of a smear of overlapping dots. Tracked cities and the current selection are exempt and always survive. The survivors change as the globe turns or the panel resizes, since the test is in pixels rather than degrees.

Labels are then placed greedily over the survivors with collision avoidance, so names appear and disappear as the globe turns rather than piling up.

**A city's label is part of its click target.** A two-pixel dot is a hard thing to hit, so label boxes are tested first - before dots - because a label sits beside its own dot and would otherwise lose the proximity test to a neighbouring city.

**A moving globe is drawn with less in it.** A full paint measures about 14ms - already over a 120Hz frame at 8.3ms - and every frame of movement repaints the whole canvas, because the projection changes, whether the globe is riding the zoom, being dragged, or coasting after a throw.

Two things dominate that paint: the city names, which cost a layout pass and two passes of text, one of them through a clip built from every coastline ring; and the graticule, 17 stroked polylines. Both are dropped while the globe is in motion and come back the moment it settles, which roughly halves the cost. Nothing is lost that could be read - names on a turning globe are a smear, and mid-zoom the whole thing is a few dozen pixels across.

Below half size the coastline is drawn at half its vertices as well. That one is tied to how big the globe is being drawn rather than to whether it is transitioning, because the zoom's ease-out spends its slow tail near full size, where the missing islands would be visible and would then snap back in.

Measured over the open transition, with `smoothMotion` off and on: average paint 11.6ms to 7ms, and the worst gap between frames 105ms to 45ms. Set `smoothMotion` to `false` to draw everything, always.

**Everything drawn scales with the shell.** Stroke widths and marker radii go through `GlobeModel.scalePx` rather than being pixel literals, because the globe's radius and its labels already follow the shell's base font size, and literal widths would read as proportionally thinner as that size grows. The small globe derives its widths from its own radius, which the large globe cannot do, its radius being hundreds of pixels rather than tens. Widths are floored at one pixel, below which a stroke stops reading as a thin line and starts dropping out of the raster.

Nothing here touches the network at runtime. The coastlines are Natural Earth 110m, simplified with Douglas-Peucker to 68 rings and 1337 points (14 KB), and the cities were geocoded once at build time - both are plain data files in the plugin. Zone offsets come from the same `date` probe the list uses.

`test/shell.d/elsewhen-globe-test.sh` covers the projection and solar maths, including a check of the terminator against Open-Meteo's `is_day` for every city.

### One selection, two views

The list and the globe are two views of the same choice, so they hold it together. Clicking a row and then opening the globe lands on that city rather than resetting to home, and picking a city on the globe moves the list's focus so the header and the small globe are already on it when the globe closes.

Picking a city on the globe also brings it round to face you, as opening the globe does for home and the jump box does for what it finds - a city chosen near the limb would otherwise sit where the projection is most foreshortened. Only a hit turns the globe: a tap on open ocean clears the selection and leaves the view alone.

The pick is `pickAt(x, y)` on the globe's root rather than a body inside the `MouseArea`, so the same code the pointer runs can be driven from a test or over IPC. This desktop cannot inject a pointer at all, and a copy of the logic in a test would be free to drift from the one the mouse actually reaches.

A globe city the list does not track is the ordinary case - the globe draws every zone's main city, the list holds the handful you chose - and it leaves the list where it was. There is no row to focus, and sending the list home would move it somewhere nobody asked to go. Clicking empty ocean is the same story from the other side: it clears the globe's selection, but the globe's "no city" and the list's "home" are different states and forwarding one as the other would be a lie.

The list's own focus is held the same way. `focusKey` is the city's `label|zone` and the row number is derived from it, because `zones` is a binding too - replaced wholesale on a reorder or a removal - so a stored index would silently come to mean a different city. Deriving the index means a reorder carries the focus with the city and removing the focused city drops it back to home.

The crossing is made on `label|zone`, not on an index. The two views index different things - a row is an index into the settings list, the globe's selection is an index into its own catalogue of everything it draws - and that catalogue is a binding, rebuilt whenever the home row, a tracked city's coordinates or a session city lands. A key survives the rebuild. `test/shell.d/elsewhen-model-test.sh` covers the crossing, including the untracked city and the case where both fields have to agree.

### Jumping to a city

The bar at the bottom searches the whole zone catalogue - every IANA city plus the aliases - and turns the globe to whatever is picked, centering it by setting the spin to the city's longitude and `viewLat` to its latitude, taking the short way round.

A city already on the globe is flown to immediately. One that is not is added **for this session only**: the panel geocodes it, and the globe flies there once the coordinates arrive. Nothing is written to `shell.json`, so there is no saved list to delete from, order, or migrate. Want it again, type it again.

Results are drawn over the globe rather than growing the panel, so the globe does not resize under the pointer while a search is being typed.

### Turning it off

Set `globeEnabled` to `false` on the widget's `shell.json` entry. The hero stops being a button and the globe's Loader never activates; nothing else changes.

### The footer under the globe

Two lines: the city with its time, and under it the zone with its offset. Opening the globe selects home, so the footer is never empty under a marker sitting plainly on a city.

A mark sits against the city's name, the same one the rows carry on their strips: a lit dot by day, tonight's moon by night. It is judged by this globe's own daylight, so it agrees with the dot drawn on that same city an inch above it.

It is sized off the name it stands next to rather than set in pixels, and it stands on the same baseline, so it occupies exactly the band the capital does - never above the cap, never below the letters. `tightBoundingRect` on a capital M gives the ink of the glyph; the mark is one pixel under that, which rasterises to the same 14 device pixels, because a circle's antialiased edge reads a pixel wider than a glyph's stem. Any smaller and the moon reads as a bullet point; a crescent needs room to be a crescent.

It is not placed with `anchors.baseline`: inside a Row, anchoring to a sibling whose own position depends on the Row's height is a loop, and QML settles it by dropping the dot onto the line below. A Row leaves `y` alone, so both items start at its top and the dot's underside is placed on the baseline directly - `Text.baselineOffset` is the ascent of its first line, the same number the glyph itself is drawn from.

The mark and the name are their own Row inside the line, so the gap between them can be tighter than the gaps after them - the mark belongs to the name, not to the row of facts.

There is no "daylight" or "night" word after the time: the city markers and the terminator already say it in the picture. The line cannot fit on one row - "Johannesburg Africa/Johannesburg UTC+2 7:50 PM" runs off the end of the panel - so it is two caption lines, which the footer's reserved height already holds.

The parts of that line are anchored to a named `footer` id rather than reached through `parent.parent`, because QML resolves a chain that falls a step short to `undefined` in silence.

## The hero globe

The globe in the header is drawn, not a glyph, by `MiniGlobe.qml`. A glyph cannot spin: rotating a flat image about the vertical axis squashes it to a line and flips it, which reads as a coin. A sphere keeps its circular outline and moves only its surface across it - so the disc is constant and the graticule and coastlines are re-projected as the spin advances, using the same orthographic projection as globe mode and the same `world.json`.

Landmasses are filled rather than outlined, and only rings above a size threshold are drawn: at icon size an outline is a scribble and an island is a speck of dirt on the lens. The rim is stroked last so nothing spills over it.

Both globes fill their continents from the same clipping code in `GlobeModel.js`. Neither strokes a coastline over the fill: the fill's own edge *is* the coastline, and a second pass over every ring is the expensive half. Measured on the large globe, per repaint: outlines only 8.1ms, fill plus outline 13.4ms, **fill alone 9.1ms** - so the filled look costs about 1ms over outlines, against a 16.7ms frame budget.

Filling means labels and city dots cross light land as often as dark ocean, so labels are outlined and every dot carries a dark edge.

Clipping a coastline to the visible hemisphere has to produce **one** polygon per ring. Keeping each visible run and closing it makes self-intersecting shapes whose area jumps whenever a run splits, and that is visible: continents morph and pulse at the limb, worst as the spin slows. Sutherland-Hodgman against the hemisphere keeps the ring whole, and walking the limb between an exit and the next entry (rather than cutting straight across) makes the silhouette continuous. Measured over a full rotation, the worst area change per quarter-degree of spin goes from 356 px^2 (split runs) to 278 (whole ring, chords) to **3.5** (whole ring, limb arcs) on a 2463 px^2 disc. `test/shell.d/elsewhen-globe-test.sh` holds it there.

The globe leans by `GlobeModel.AXIAL_TILT` - 23.44 degrees, the real obliquity, and the same constant the subsolar calculation uses.

It is drawn at full strength and oversized rather than sitting at text weight: as the centerpiece a dimmed thin globe just reads as washed out.

A marker shows the city you are in, in the accent color. It carries a dark edge: the marker can be nearly the same lightness as the filled continents, and without one the dot dissolves into whichever landmass it is sitting on.

**The globe opens on the city you are in.** It flies there as the panel zooms out, so the two motions - growing out of the header and turning round to home - land together rather than one after the other. If your coordinates have not arrived yet, which happens on a cold geocode cache, the request is held and runs the moment they do.

**Clicking a city row turns the globe to it** and marks it - so a tap on Tokyo swings the globe round and drops the marker on Japan. It takes the shortest way round rather than always turning forward: Los Angeles to Tokyo is 102 degrees west, not 258 east.

While the globe is showing somewhere else, clicking the header line brings it home. The whole line is the target, not just the name, and it is only live while the globe is away, so it is never a dead click target. Reopening the panel also returns it home.

The opening spin **lands on home** - the animation runs from `homeLon - 1080` to `homeLon`, three whole turns that finish with your own meridian facing you. At rest a `Binding` holds the globe there, standing down while the animation is writing the property. Until the weather script has geocoded your city the marker is hidden and it rests on Greenwich.

`Easing.OutQuart` over 1250ms puts most of the rotation in the first third and lets the rest coast out, which is what a globe flicked by hand does rather than a motor driving it at a constant rate.

## Where "here" is

The header reads "It's 10:28 AM here in Los Angeles." rather than a bare "here", which names your own city without spending a row on it. The zone comes from the same `date` probe the rows use - one extra `LOCAL|<zone>` line, from `timedatectl` - so it costs no additional process and follows a time-zone change on the next refresh.

The city name is the zone's last segment, and the tz database names zones after a *representative* city: someone in Boca Raton would read "here in New York". Tap your city on the globe to fix that: a city on this machine's zone becomes `homeCity`, and the header and home pin follow it. Tapping the zone's own city clears the choice, and a city on another zone leaves it alone, since the time beside the name is still this machine's.

## Two offsets, one line

A row's offset reads `+2h` - how far that city is from you - until you click it, and then every row reads `UTC-5` instead. Both are the same fact from different ends: the relative offset answers "how far ahead are they", the absolute one answers "where is this place", and the click is cheaper than printing both and doubling the width of the line.

It is one setting for the whole list rather than one per row. A column where each row had picked its own units would be unreadable, and the point of a column is that it can be read down. The choice is stored, so it survives a restart.

The tap target sits on the offset itself, and works because it is declared late: the drag handle covers the whole body of the row, and later siblings win the tap - the same rule the remove button relies on.

The globe's footer reads the same setting and offers the same click, so the offset under the globe is never in different units from the offset in the list you just came from, and flipping it in either place flips it in both. There the target is the zone name as well as the number: on your own home city the relative offset is blank, and a control that disappears on one city out of the list is not a control.

The globe does not own the setting. It publishes `offsetModeToggleRequested` and the panel flips it; the new mode arrives back down the same binding as every other property, so there is only one place the mode can live.

## Units and notation, on a click

The temperature and the time are both controls. Click any temperature to swap the whole list between Celsius and Fahrenheit; click any time to swap it between 12- and 24-hour. Both work the way the offset does - one setting for every row, changed where you are already reading rather than in a settings pane, and written straight to `shell.json` so it survives a restart.

One setting for all rows, not one per row, for the same reason the offsets move together: every clock here exists to be read against the others.

The starting notation follows the machine. With `hour24` unset, the locale's own short time format decides: `Qt.locale().timeFormat` gives `h:mm Ap` for `en_US` and `en_AU`, `HH:mm` for `en_GB`, `de_DE`, `fr_FR` and `zh_CN`, `H:mm` for `ja_JP` and `H.mm` for `fi_FI`. The test is the AM/PM designator rather than the case of the hour letter - `h` means 1-12 and `H` means 0-23, which is the same answer, but a locale may spell a 24-hour clock with either while a designator only ever belongs to a 12-hour one. Quoted literal text is stripped first, because some locales write the separator as `H'h'mm`.

Those patterns were read off the running shell, and the ones that matter are in `test/shell.d/elsewhen-model-test.sh` verbatim - including the detail that Qt spells the designator `Ap` and puts U+202F in front of it, not a space.

The starting unit follows the machine too. With `units` unset, `Qt.locale().measurementSystem` decides: the US system means Fahrenheit and everything else means Celsius. `en_US` reports `ImperialUSSystem`, `en_GB` reports `ImperialUKSystem` and `de_DE` and `ja_JP` report `MetricSystem`, so the rule gives Britain Celsius, which is what Britain uses for weather whatever else it measures in miles.

The rule is Qt's CLDR data and it is not a survey of thermometers: Liberia, which does use Fahrenheit day to day, reports as metric. That is what the click is for. An explicit `C` or `F` always wins over the automatic answer, so one click is the whole escape hatch, and `""` puts it back on the system's units. `Model.resolveUnits` holds those rules and `test/shell.d/elsewhen-model-test.sh` covers them, including the junk values a hand-edited `shell.json` can produce.

## Testing what the pointer does

No pointer can be injected into the running shell, but `qmltestrunner` synthesises real mouse events into an offscreen window, and the structures worth checking are small enough to rebuild in a test:

```bash
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input test/shell.d/elsewhen/qml
```

Use that full path. `/usr/bin/qmltestrunner` is the Qt5 binary; it exits 0 having run nothing and printed nothing, which looks exactly like success.

`test/shell.d/elsewhen/qml/tst_arrows.qml` settles whether a click on an item in front also reaches a `MouseArea` behind it. It does not.

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

The key catcher reports Space as "activate" and reports Return as a return *and then* an activate, so Return marks itself on the way past and the activate behind it stands down - otherwise Return would work the globe too.

Escape unwinds one layer per press rather than closing outright, so the way out of the globe is the same key as the way out of everything else. The globe's search hands the keyboard back when it closes: a hidden item keeps its focus, so otherwise the field would go on swallowing keys and the second Escape would go nowhere.

## Settings

Inline on the widget's `shell.json` entry:

| Key      | Meaning                                              |
|----------|------------------------------------------------------|
| `zones`  | `Label\|IANA name`, comma separated; blank seeds on first run |
| `hour24` | `true` or `false`; unset (the default) follows the system's time format. Click any row's time to flip it |
| `offsetMode` | `home` for the offset from you (default), `utc` for the absolute one |
| `units`  | `F` or `C`; blank (the default) follows the system's measurement units. Click any temperature to flip it |
| `globeEnabled` | `false` to remove the globe entry point (default on) |
| `homeCity` | your city for the header (blank = from the system zone); set by tapping a city on this zone on the globe |
| `smoothMotion` | drop labels and detail while the globe moves (default true) |

## IPC

```bash
omarchy-shell omarchy.elsewhen toggle
omarchy-shell omarchy.elsewhen globe                            # switch between list and globe
omarchy-shell omarchy.elsewhen times                            # JSON, one entry per row
omarchy-shell omarchy.elsewhen add America/New_York Miami
omarchy-shell omarchy.elsewhen remove America/New_York
omarchy-shell omarchy.elsewhen refresh                          # re-probe offsets
```
