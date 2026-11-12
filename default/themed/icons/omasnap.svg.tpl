<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Omasnap</title>
  <desc>A dark screen seen from the front, with a region selected by crop corners: the region lifts off as a snap with a hard shadow, marked by an annotation arrow.</desc>
  <defs>
    <linearGradient id="snap" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -258)">
    <!-- The screen; one hard shadow, as Hype's slides. -->
    <rect x="72" y="108" width="368" height="252" rx="18" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="72" y="108" width="368" height="252" rx="18" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <rect x="104" y="140" width="124" height="16" rx="8" fill="{{ icon_ink }}"/>
    <rect x="104" y="172" width="80" height="16" rx="8" fill="{{ icon_ink }}" opacity=".55"/>
    <!-- The selected region, lifted off the screen. -->
    <rect x="196" y="204" width="208" height="176" rx="16" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="196" y="204" width="208" height="176" rx="16" fill="url(#snap)"/>
    <rect x="222" y="334" width="96" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <!-- Crop corners around it. -->
    <path d="M172 228V200Q172 180 192 180H220M380 180H408Q428 180 428 200V228M428 356V384Q428 404 408 404H380M220 404H192Q172 404 172 384V356" fill="none" stroke="{{ icon_mark }}" stroke-width="14" stroke-linecap="round"/>
    <!-- Annotation arrow pointing into the snap. -->
    <path d="M112 236L262 300M262 300L210 302M262 300L236 256" fill="none" stroke="{{ icon_shadow }}" stroke-width="20" stroke-linecap="round" stroke-linejoin="round" transform="translate(0 6)"/>
    <path d="M112 236L262 300M262 300L210 302M262 300L236 256" fill="none" stroke="{{ icon_orange }}" stroke-width="20" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>
