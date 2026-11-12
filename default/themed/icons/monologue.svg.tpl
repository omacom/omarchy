<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="80 70 352 352">
  <title>Monologue</title>
  <desc>A recording button set into a pale metal ring on a transparent background.</desc>
  <defs>
    <linearGradient id="metal" x1="190" y1="96" x2="300" y2="411" gradientUnits="userSpaceOnUse">
      <stop stop-color="{{ icon_paper }}"/>
      <stop offset=".35" stop-color="{{ mix icon_paper icon_ink 15% }}"/>
      <stop offset=".7" stop-color="{{ mix icon_paper icon_ink 45% }}"/>
      <stop offset="1" stop-color="{{ mix icon_paper icon_ink 75% }}"/>
    </linearGradient>
    <linearGradient id="metalEdge" x1="200" y1="88" x2="300" y2="408" gradientUnits="userSpaceOnUse">
      <stop stop-color="{{ icon_paper }}"/>
      <stop offset="1" stop-color="{{ mix icon_ink icon_shadow 40% }}"/>
    </linearGradient>
    <linearGradient id="socket" x1="240" y1="120" x2="270" y2="384" gradientUnits="userSpaceOnUse">
      <stop stop-color="{{ mix icon_red icon_shadow 70% }}"/>
      <stop offset="1" stop-color="{{ mix icon_red icon_shadow 35% }}"/>
    </linearGradient>
    <radialGradient id="button" cx=".36" cy=".2" r=".83">
      <stop stop-color="{{ mix icon_red icon_paper 50% }}"/>
      <stop offset=".38" stop-color="{{ mix icon_red icon_paper 15% }}"/>
      <stop offset=".72" stop-color="{{ icon_red }}"/>
      <stop offset="1" stop-color="{{ mix icon_red icon_shadow 35% }}"/>
    </radialGradient>
    <linearGradient id="buttonEdge" x1="210" y1="123" x2="290" y2="370" gradientUnits="userSpaceOnUse">
      <stop stop-color="{{ mix icon_red icon_paper 60% }}"/>
      <stop offset=".5" stop-color="{{ mix icon_red icon_paper 20% }}"/>
      <stop offset="1" stop-color="{{ mix icon_red icon_shadow 45% }}"/>
    </linearGradient>
    <linearGradient id="sheen" x1="210" y1="129" x2="242" y2="261" gradientUnits="userSpaceOnUse">
      <stop stop-color="{{ icon_paper }}" stop-opacity=".46"/>
      <stop offset="1" stop-color="{{ icon_paper }}" stop-opacity="0"/>
    </linearGradient>
  </defs>
  <!-- Nested shadows, bevel, and inset socket give the button a physical depth. -->
  <ellipse cx="256" cy="260" rx="159" ry="159" fill="{{ icon_shadow }}" opacity=".32"/>
  <circle cx="256" cy="246" r="158" fill="url(#metal)" stroke="url(#metalEdge)" stroke-width="3"/>
  <circle cx="256" cy="246" r="135" fill="url(#socket)"/>
  <circle cx="256" cy="253" r="126" fill="{{ mix icon_red icon_shadow 55% }}"/>
  <circle cx="256" cy="244" r="125" fill="url(#button)" stroke="url(#buttonEdge)" stroke-width="2"/>
  <path d="M150 217c10-48 51-82 101-82 43 0 80 25 98 62-30-18-63-20-96-7-38 16-70 29-103 27Z" fill="url(#sheen)"/>
  <path d="M175 155a122 122 0 0 1 114-26" fill="none" stroke="{{ icon_paper }}" stroke-width="3" stroke-linecap="round" opacity=".55"/>
</svg>
