<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>AFK</title>
  <desc>The letters AFK in a terminal window, in the accent over a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <g id="logo"><rect x="156" y="246" width="20" height="20" rx="5"/><rect x="176" y="246" width="20" height="20" rx="5"/><rect x="136" y="266" width="20" height="20" rx="5"/><rect x="196" y="266" width="20" height="20" rx="5"/><rect x="136" y="286" width="20" height="20" rx="5"/><rect x="196" y="286" width="20" height="20" rx="5"/><rect x="136" y="306" width="20" height="20" rx="5"/><rect x="156" y="306" width="20" height="20" rx="5"/><rect x="176" y="306" width="20" height="20" rx="5"/><rect x="196" y="306" width="20" height="20" rx="5"/><rect x="136" y="326" width="20" height="20" rx="5"/><rect x="196" y="326" width="20" height="20" rx="5"/><rect x="136" y="346" width="20" height="20" rx="5"/><rect x="196" y="346" width="20" height="20" rx="5"/><rect x="136" y="366" width="20" height="20" rx="5"/><rect x="196" y="366" width="20" height="20" rx="5"/><rect x="236" y="246" width="20" height="20" rx="5"/><rect x="256" y="246" width="20" height="20" rx="5"/><rect x="276" y="246" width="20" height="20" rx="5"/><rect x="296" y="246" width="20" height="20" rx="5"/><rect x="236" y="266" width="20" height="20" rx="5"/><rect x="236" y="286" width="20" height="20" rx="5"/><rect x="236" y="306" width="20" height="20" rx="5"/><rect x="256" y="306" width="20" height="20" rx="5"/><rect x="276" y="306" width="20" height="20" rx="5"/><rect x="236" y="326" width="20" height="20" rx="5"/><rect x="236" y="346" width="20" height="20" rx="5"/><rect x="236" y="366" width="20" height="20" rx="5"/><rect x="336" y="246" width="20" height="20" rx="5"/><rect x="396" y="246" width="20" height="20" rx="5"/><rect x="336" y="266" width="20" height="20" rx="5"/><rect x="376" y="266" width="20" height="20" rx="5"/><rect x="336" y="286" width="20" height="20" rx="5"/><rect x="356" y="286" width="20" height="20" rx="5"/><rect x="336" y="306" width="20" height="20" rx="5"/><rect x="376" y="306" width="20" height="20" rx="5"/><rect x="336" y="326" width="20" height="20" rx="5"/><rect x="396" y="326" width="20" height="20" rx="5"/><rect x="336" y="346" width="20" height="20" rx="5"/><rect x="396" y="346" width="20" height="20" rx="5"/><rect x="336" y="366" width="20" height="20" rx="5"/><rect x="396" y="366" width="20" height="20" rx="5"/></g>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The title bar's own marks, as this set draws any window. -->
    <g fill="{{ icon_mark }}">
      <circle cx="104" cy="116" r="7"/>
      <circle cx="128" cy="116" r="7"/>
    </g>
    <use href="#logo" fill="{{ icon_shadow }}" transform="translate(0 10)"/>
    <use href="#logo" fill="url(#main)"/>
  </g>
</svg>
