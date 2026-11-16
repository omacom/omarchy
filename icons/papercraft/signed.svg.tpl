<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Signed</title>
  <desc>A document seen from the front: a pale page with lines of text, a signature on the signing line, and a sign-here tab, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The page; one hard shadow, as Hype's slides. -->
    <rect x="96" y="86" width="300" height="340" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="96" y="86" width="300" height="340" rx="20" fill="{{ icon_paper }}"/>
    <g fill="{{ icon_ink }}">
      <rect x="132" y="126" width="196" height="16" rx="8"/>
      <rect x="132" y="162" width="228" height="16" rx="8" opacity=".55"/>
    </g>
    <!-- The signature on its line. -->
    <path d="M136 336C150 290 166 238 184 250C202 262 170 330 190 332C210 334 218 276 240 276C262 276 236 318 258 318C280 318 292 290 334 270" fill="none" stroke="url(#main)" stroke-width="20" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="132" y="360" width="200" height="12" rx="6" fill="{{ icon_ink }}"/>
    <!-- Sign-here tab sticking out past the page. -->
    <path d="M344 344L370 322H438Q450 322 450 334V378Q450 390 438 390H370Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="8" stroke-linejoin="round" transform="translate(0 8)"/>
    <path d="M344 344L370 322H438Q450 322 450 334V378Q450 390 438 390H370Z" fill="{{ icon_mark }}" stroke="{{ icon_mark }}" stroke-width="8" stroke-linejoin="round"/>
    <rect x="384" y="350" width="44" height="12" rx="6" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
