<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>OmO</title>
  <desc>A cat in a terminal window.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="cat" d="M156 241l-5-85q0-12 11-6l60 38q34-9 68 0l60-38q11-6 11 6l-5 85q15 20 15 48c0 52-45 76-115 76s-115-24-115-76q0-28 15-48z"/>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <rect x="76" y="100" width="360" height="328" rx="22" fill="{{ icon_shadow }}"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <use href="#cat" transform="translate(0 8)" fill="{{ icon_shadow }}"/>
    <use href="#cat" fill="url(#main)"/>
    <path d="M191 282q16-20 32 0m66 0q16-20 32 0" fill="none" stroke="{{ icon_body }}" stroke-width="8" stroke-linecap="round"/>
  </g>
</svg>
