#!/bin/bash

set -euo pipefail

# The theme browser's filtering lives in plain JavaScript so it can be checked
# here rather than only by looking at the overlay. What the QML adds on top is
# layout and key handling; what decides which themes are on screen is this.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const Catalog = requireFromRoot('shell/plugins/theme-browser/ThemeCatalog.js')

const today = new Date('2026-09-13T00:00:00Z')
const recently = '2026-09-10'
const longAgo = '2024-01-01'

const raw = JSON.stringify({
  schema_version: 1,
  themes: [
    {
      slug: 'beta', name: 'Beta Light', repo: 'https://example.com/b',
      author: 'Bo', description: 'A light one', license: null,
      mode: 'light', hue: 'orange', generation: 'hybrid', stars: 1,
      added_at: longAgo, commit: 'b1', featured: false,
      colors: { accent: '#cc6622', background: '#f7f3ec', red: '#aa0000' },
      backgrounds: { count: 2, has_video: true, total_bytes: 2097152 },
      ignored_on_install: ['kitty.conf'],
      warnings: ['IGNORED_ON_INSTALL']
    },
    {
      slug: 'alpha', name: 'Alpha', repo: 'https://example.com/a',
      author: { login: 'Ada' }, description: '', license: 'MIT',
      mode: 'dark', hue: 'blue', generation: 'native', stars: 7,
      added_at: recently, commit: 'a1', featured: true,
      colors: { accent: '#3355ff', background: '#0b0b13' },
      backgrounds: { count: 0, has_video: false, total_bytes: 0 },
      ignored_on_install: [], warnings: []
    },
    { name: 'No slug, no entry' },
    { slug: 'a;id', name: 'Not a theme name' }
  ]
})

const themes = Catalog.parseCatalog(raw)
const names = list => list.map(t => t.name).join(' ')

assertEqual(names(themes), 'beta alpha', 'every entry with a name is parsed')
assertEqual(themes.length, 2, 'an entry without a usable slug is dropped')

// The catalog says author and slug; the shell says artist and name. Both
// spellings of author have to arrive as the same field.
assertEqual(themes[0].artist, 'Bo', 'a plain author string becomes the artist')
assertEqual(themes[1].artist, 'Ada', 'an author object becomes the artist')
assertEqual(themes[1].title, 'Alpha', 'the display name is kept apart from the id')

assertDeepEqual(themes[0].palette, ['#cc6622', '#f7f3ec', '#aa0000'],
  'the palette is ordered and holds only the keys the theme declared')

const empty = Catalog.emptyFilters()

// Featured first while nobody is searching, then alphabetical.
assertEqual(names(Catalog.filterThemes(themes, empty, [], today)), 'alpha beta',
  'an unsearched list puts the featured themes first')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, search: 'light' }, [], today)), 'beta',
  'searching matches the display name')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, search: 'ADA' }, [], today)), 'alpha',
  'searching matches the artist, ignoring case')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, search: 'orange' }, [], today)), 'beta',
  'searching matches the hue')

assertEqual(names(Catalog.filterThemes(themes, { ...empty, dark: true }, [], today)), 'alpha', 'dark')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, light: true }, [], today)), 'beta', 'light')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, featured: true }, [], today)), 'alpha', 'featured')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, hue: 'orange' }, [], today)), 'beta', 'hue')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, onlyNew: true }, [], today)), 'alpha',
  'new is decided against the date the theme was listed')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, installed: true }, ['beta'], today)), 'beta',
  'installed reads the names the markers carry')

// The toggles are independent, which is what lets the command line pass a
// combination the overlay can also express.
const darkFeatured = { ...empty, dark: true, featured: true }
assertEqual(names(Catalog.filterThemes(themes, darkFeatured, [], today)), 'alpha',
  'filters combine rather than replace each other')
assertEqual(names(Catalog.filterThemes(themes, { ...empty, light: true, featured: true }, [], today)), '',
  'a combination nothing satisfies returns nothing')

// Except dark and light, which contradict: turning one on turns the other off
// rather than leaving a filter that can never match.
const afterLight = Catalog.toggleFilter(Catalog.toggleFilter(empty, 'dark'), 'light')
assert(afterLight.light && !afterLight.dark, 'choosing light turns dark off')
const afterDark = Catalog.toggleFilter(afterLight, 'dark')
assert(afterDark.dark && !afterDark.light, 'and choosing dark turns light off')
assert(!Catalog.toggleFilter(afterDark, 'dark').dark, 'a toggle toggles back off')

assertEqual(Catalog.activeCount({ ...empty, dark: true, hue: 'blue' }), 2,
  'the active count includes filters that have no chip')

// The command line hands its flags over as a payload; anything missing is off.
const fromCli = Catalog.filtersFromPayload({ search: 'dune', light: true, hue: 'orange' })
assert(fromCli.light && !fromCli.dark && !fromCli.featured, 'a payload sets only what it names')
assertEqual(fromCli.search, 'dune', 'a payload carries the search')
assertEqual(Catalog.filtersFromPayload(null).search, '', 'a missing payload is an empty filter')

// A grid is a list that wraps sideways and stops vertically, so Down on the
// last row stays put instead of jumping back to the top.
assertEqual(Catalog.movedIndex(0, 5, -1, true), 4, 'moving left off the start wraps to the end')
assertEqual(Catalog.movedIndex(4, 5, 1, true), 0, 'moving right off the end wraps to the start')
assertEqual(Catalog.movedIndex(4, 5, 3, false), 4, 'moving down past the end stops at the end')
assertEqual(Catalog.movedIndex(1, 5, -3, false), 0, 'moving up past the start stops at the start')
assertEqual(Catalog.movedIndex(0, 0, 1, true), 0, 'an empty grid has nowhere to move')

assertEqual(Catalog.humanBytes(0), '', 'no backgrounds means nothing to report')
assertEqual(Catalog.humanBytes(2097152), '2.0 MB', 'megabytes keep a decimal while they are small')
assertEqual(Catalog.humanBytes(524288), '512 KB', 'under a megabyte reads as kilobytes')

assertEqual(Catalog.warningLabel('IGNORED_ON_INSTALL'), 'ships files Omarchy will not install',
  'a validator code is spelled out')
assertEqual(Catalog.warningLabel('SOMETHING_NEW'), 'SOMETHING_NEW',
  'a code with no wording yet is shown as itself')

// The catalog is fetched over the network; a truncated or hostile answer must
// leave an empty list rather than throw inside the overlay.
assertEqual(Catalog.parseCatalog('{"themes": [').length, 0, 'malformed JSON parses to nothing')
assertEqual(Catalog.parseCatalog('').length, 0, 'an empty body parses to nothing')
assertEqual(Catalog.parseCatalog('{"generated_at":"x"}').length, 0, 'a catalog with no themes parses to nothing')
JS
