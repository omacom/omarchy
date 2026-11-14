import { makeColors } from './make-colors.js'

// omarchy-theme-set-claude-desktop publishes the current theme's colors here.
const PALETTE_PATH = '.config/Claude/omarchy-theme.json'

function mix(start, end, amount) {
  const channel = offset => {
    const from = parseInt(start.slice(offset, offset + 2), 16)
    const to = parseInt(end.slice(offset, offset + 2), 16)

    return Math.round(from + (to - from) * amount).toString(16).padStart(2, '0')
  }

  return `#${channel(1)}${channel(3)}${channel(5)}`
}

export function paletteColors(palette) {
  const isDark = palette.mode === 'dark'
  const surface = amount => mix(palette.background, isDark ? palette.foreground : '#ffffff', amount)
  const text = amount => mix(palette.foreground, palette.background, amount)

  return makeColors({
    label: 'Omarchy',
    only: palette.mode,
    roles: {
      accent: palette.accent,
      danger: palette.red,
      success: palette.green,
      // The app refuses a dark palette whose text sits on the stock, paler warning fill.
      warning: isDark ? { seed: palette.yellow, fillShade: 400 } : palette.yellow,
      pro: palette.magenta,
    },
    [palette.mode]: {
      gray: {
        anchors: {
          'surface-0': palette.background,
          'surface-1': surface(0.02),
          'surface-2': surface(0.04),
          'surface-3': surface(isDark ? 0.05 : 0.04),
          'text-primary': palette.foreground,
          'text-secondary': text(0.15),
          'text-muted': text(0.3),
        },
      },
    },
  })
}

async function palettePath($) {
  const home = await $.env.get('HOME')

  return home === undefined ? undefined : `${home}/${PALETTE_PATH}`
}

// A palette that is missing, or that makeColors refuses, leaves the look that already stands.
async function applyTheme($) {
  try {
    const palette = JSON.parse(await $.fs.read(await palettePath($)))

    await $.theme.set({ colors: paletteColors(palette).theme })
  } catch {
    return
  }
}

export function register(on) {
  on('session.start', async ($, e, next) => {
    await applyTheme($)

    return next(e)
  })

  // The session watches the palette, so a theme switch retints a running window.
  on('classic.SessionStart', async ($, e, next) => {
    const result = await next(e)
    const path = await palettePath($)

    return path === undefined ? result : { ...result, watchPaths: [...(result.watchPaths ?? []), path] }
  })

  on('classic.FileChanged', async ($, e, next) => {
    if (e.file_path === (await palettePath($))) await applyTheme($)

    return next(e)
  })
}
