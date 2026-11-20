<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Fantasi</title>
  <desc>A dark tile of night sky with an aurora on it: a wavy hem in the main color and seven rays in the highlight rising off it, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <!-- The sky; one hard shadow, as Hype's slides. -->
  <rect x="40" y="34" width="432" height="432" rx="100" fill="{{ icon_shadow }}" transform="translate(0 10)"/>
  <rect x="40" y="34" width="432" height="432" rx="100" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3.600"/>
  <!-- The rays, each standing on the hem below it. -->
  <g fill="{{ icon_shadow }}" transform="translate(0 8)">
    <rect x="102" y="170" width="28" height="152" rx="14"/>
    <rect x="150" y="110" width="28" height="224" rx="14"/>
    <rect x="198" y="150" width="28" height="170" rx="14"/>
    <rect x="246" y="96" width="28" height="180" rx="14"/>
    <rect x="294" y="130" width="28" height="112" rx="14"/>
    <rect x="342" y="84" width="28" height="145" rx="14"/>
    <rect x="390" y="150" width="28" height="88" rx="14"/>
  </g>
  <g fill="{{ icon_mark }}">
    <rect x="102" y="170" width="28" height="152" rx="14"/>
    <rect x="150" y="110" width="28" height="224" rx="14"/>
    <rect x="198" y="150" width="28" height="170" rx="14"/>
    <rect x="246" y="96" width="28" height="180" rx="14"/>
    <rect x="294" y="130" width="28" height="112" rx="14"/>
    <rect x="342" y="84" width="28" height="145" rx="14"/>
    <rect x="390" y="150" width="28" height="88" rx="14"/>
  </g>
  <!-- The hem, raised off the sky. -->
  <path d="M104 362C168 398 212 372 256 326S356 262 408 286" fill="none" stroke="{{ icon_shadow }}" stroke-width="48" stroke-linecap="round" transform="translate(0 10)"/>
  <path d="M104 362C168 398 212 372 256 326S356 262 408 286" fill="none" stroke="url(#main)" stroke-width="48" stroke-linecap="round"/>
</svg>
