<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Agent</title>
  <desc>The agents panel's robot (Material Design Icons' robot-excited) in a terminal window, as Herdr's ram, its eyes cut out to the window, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The robot. -->
    <g transform="translate(124 124) scale(11)">
      <path d="M22 14H21C21 10.13 17.87 7 14 7H13V5.73C13.6 5.39 14 4.74 14 4C14 2.9 13.11 2 12 2S10 2.9 10 4C10 4.74 10.4 5.39 11 5.73V7H10C6.13 7 3 10.13 3 14H2C1.45 14 1 14.45 1 15V18C1 18.55 1.45 19 2 19H3V20C3 21.11 3.9 22 5 22H19C20.11 22 21 21.11 21 20V19H22C22.55 19 23 18.55 23 18V15C23 14.45 22.55 14 22 14M8.68 17.04L7.5 15.86L6.32 17.04L5.14 15.86L7.5 13.5L9.86 15.86L8.68 17.04M17.68 17.04L16.5 15.86L15.32 17.04L14.14 15.86L16.5 13.5L18.86 15.86L17.68 17.04Z" fill="{{ icon_shadow }}" transform="translate(0 .73)"/>
      <!-- Shows through the eyes cut into the head. -->
      <rect x="5" y="13" width="5" height="4.5" fill="{{ icon_body }}"/>
      <rect x="14" y="13" width="5" height="4.5" fill="{{ icon_body }}"/>
      <path d="M22 14H21C21 10.13 17.87 7 14 7H13V5.73C13.6 5.39 14 4.74 14 4C14 2.9 13.11 2 12 2S10 2.9 10 4C10 4.74 10.4 5.39 11 5.73V7H10C6.13 7 3 10.13 3 14H2C1.45 14 1 14.45 1 15V18C1 18.55 1.45 19 2 19H3V20C3 21.11 3.9 22 5 22H19C20.11 22 21 21.11 21 20V19H22C22.55 19 23 18.55 23 18V15C23 14.45 22.55 14 22 14M8.68 17.04L7.5 15.86L6.32 17.04L5.14 15.86L7.5 13.5L9.86 15.86L8.68 17.04M17.68 17.04L16.5 15.86L15.32 17.04L14.14 15.86L16.5 13.5L18.86 15.86L17.68 17.04Z" fill="url(#main)"/>
    </g>
  </g>
</svg>
