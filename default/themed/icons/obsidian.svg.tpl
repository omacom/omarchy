<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Obsidian</title>
  <desc>A shard of volcanic glass seen from the front: a cut stone in the main color, its facets lighter where they face up and darker where they face down, one facet in the highlight, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The stone; one hard shadow, as Hype's slides. -->
    <path d="M256 76L368 170L392 304L284 436L192 414L124 284L160 152Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="16" stroke-linejoin="round" transform="translate(0 10)"/>
    <path d="M256 76L368 170L392 304L284 436L192 414L124 284L160 152Z" fill="url(#main)" stroke="url(#main)" stroke-width="16" stroke-linejoin="round"/>
    <!-- Facets facing up, lit. -->
    <path d="M160 152L256 76L248 214Z" fill="{{ icon_paper }}" opacity=".45"/>
    <path d="M256 76L368 170L248 214Z" fill="{{ icon_paper }}" opacity=".18"/>
    <!-- Facets facing down, in shade. -->
    <path d="M392 304L284 436L276 330Z" fill="{{ icon_shadow }}" opacity=".3"/>
    <path d="M284 436L192 414L276 330Z" fill="{{ icon_shadow }}" opacity=".5"/>
    <!-- The facet that catches the light. -->
    <path d="M192 414L124 284L248 214L276 330Z" fill="{{ icon_mark }}" stroke="{{ icon_mark }}" stroke-width="4" stroke-linejoin="round"/>
  </g>
</svg>
