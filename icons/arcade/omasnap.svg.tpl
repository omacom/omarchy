<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512" shape-rendering="crispEdges">
  <title>Omasnap</title>
  <desc>A screenshot in pixels: a dark screen with a region in the main color lifted out of it between crop corners in the highlight.</desc>
  <!-- A 16 by 16 grid of 28 unit pixels. Each color is one path of rectangles,
       with a hairline stroke of its own so no seam shows between neighbors. -->
  <path fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" d="M172 200h224v28h-224zM172 228h28v140h-28zM368 228h28v140h-28zM200 340h168v28h-168z"/>
  <path fill="{{ icon_main }}" stroke="{{ icon_main }}" d="M200 228h168v56h-168zM200 284h56v56h-56zM312 284h56v56h-56zM256 312h56v28h-56z"/>
  <path fill="{{ icon_main_end }}" stroke="{{ icon_main_end }}" d="M256 284h56v28h-56z"/>
  <path fill="{{ icon_mark }}" stroke="{{ icon_mark }}" d="M144 172h56v28h-56zM368 172h56v28h-56zM144 200h28v28h-28zM396 200h28v28h-28zM144 340h28v56h-28zM396 340h28v56h-28zM172 368h28v28h-28zM368 368h28v28h-28z"/>
  <path fill="{{ icon_body }}" stroke="{{ icon_body }}" d="M60 88h280v28h-280zM60 116h28v196h-28zM200 116h140v84h-140zM88 144h112v28h-112zM88 172h56v140h-56zM144 228h28v84h-28z"/>
  <path fill="{{ icon_edge }}" stroke="{{ icon_edge }}" d="M32 60h336v28h-336zM32 88h28v252h-28zM340 88h28v112h-28zM60 312h112v28h-112z"/>
  <path fill="{{ icon_ink }}" stroke="{{ icon_ink }}" d="M88 116h112v28h-112z"/>
</svg>
