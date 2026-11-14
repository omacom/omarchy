<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Gliff</title>
  <desc>A computer screen on a stand seen from the front: a screen in the main color with a pale pointer on it, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The stand. -->
    <rect x="236" y="330" width="40" height="64" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="236" y="330" width="40" height="64" fill="{{ icon_paper }}"/>
    <rect x="164" y="382" width="184" height="28" rx="14" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="164" y="382" width="184" height="28" rx="14" fill="{{ icon_paper }}"/>
    <!-- The screen; one hard shadow, as Hype's slides. -->
    <rect x="76" y="96" width="360" height="248" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="96" width="360" height="248" rx="22" fill="url(#main)"/>
    <!-- The pointer driving it from another machine, raised off the screen. -->
    <path d="M222 140V286L258 252L284 306L316 291L290 238H340Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="16" stroke-linejoin="round" transform="translate(0 8)"/>
    <path d="M222 140V286L258 252L284 306L316 291L290 238H340Z" fill="{{ icon_paper }}" stroke="{{ icon_paper }}" stroke-width="16" stroke-linejoin="round"/>
  </g>
</svg>
