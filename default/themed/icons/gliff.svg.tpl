<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Gliff</title>
  <desc>A screen on a stand seen from the front: a window on the dark screen and a pointer reaching into it from another machine, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The stand. -->
    <rect x="236" y="340" width="40" height="52" fill="{{ icon_edge }}"/>
    <rect x="168" y="384" width="176" height="24" rx="12" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="168" y="384" width="176" height="24" rx="12" fill="{{ icon_edge }}"/>
    <!-- The screen; one hard shadow, as Hype's slides. -->
    <rect x="72" y="100" width="368" height="248" rx="18" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="72" y="100" width="368" height="248" rx="18" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- A window on the remote desktop. -->
    <rect x="104" y="132" width="220" height="152" rx="14" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="104" y="132" width="220" height="152" rx="14" fill="url(#main)"/>
    <rect x="128" y="156" width="96" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <rect x="128" y="182" width="140" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".2"/>
    <!-- The pointer driving it. -->
    <path d="M272 214V354L306 322L332 376L362 362L336 308H382Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="14" stroke-linejoin="round" transform="translate(0 8)"/>
    <path d="M272 214V354L306 322L332 376L362 362L336 308H382Z" fill="{{ icon_mark }}" stroke="{{ icon_mark }}" stroke-width="14" stroke-linejoin="round"/>
  </g>
</svg>
