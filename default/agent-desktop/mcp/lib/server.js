// The tool surface. One McpServer per request (stateless core): the factory is
// cheap and closes over the shared lease table and nest layer.
import { McpServer } from '@modelcontextprotocol/server';
import * as z from 'zod/v4';
import { HandleError } from './leases.js';


const text = t => ({ content: [{ type: 'text', text: t }] });
const fail = t => ({ content: [{ type: 'text', text: t }], isError: true });

function windowsText(ws) {
  if (!ws.length) return 'no windows';
  return ws.map(w => `${w.focused ? '*' : ' '} [${w.class}] ${w.title}  at ${w.x},${w.y} ${w.w}x${w.h}`).join('\n');
}

export function buildServer({ leases, nest, host, lifecycle }) {
  const placement = nest.placement || 'background desktop; open Agent Desktops from the app launcher to watch or take control';
  const server = new McpServer({ name: 'hypr-desktop', version: '1.0.0' });

  const snapshot = async (l, scale) => {
    const [png, ws] = await Promise.all([nest.capture(l.desktop, { scale }), nest.windows(l.desktop)]);
    if (nest.instance && nest.instance(l.desktop) !== l.instance) throw new Error('Desktop restarted during capture; observe again');
    const frameId = leases.newFrame(l.desktop);
    return {
      content: [
        { type: 'image', data: png.toString('base64'), mimeType: 'image/png' },
        { type: 'text', text: `frame_id ${frameId}; desktop ${l.desktop} 2560x1440${scale && scale !== 1 ? ` shown at scale ${scale}` : ''}\n${windowsText(ws)}` }
      ],
      structuredContent: { frame_id: frameId, windows: ws }
    };
  };
  const feedback = {
    observe: z.boolean().optional().describe('Return the resulting screenshot in this call, avoiding a separate observe call'),
    scale: z.number().min(0.1).max(1).optional(),
    settle_ms: z.number().int().min(0).max(2000).optional().describe('Before the resulting screenshot; default 100ms')
  };

  // Every tool that takes a handle renews the lease and maps errors to isError
  // results, so the model reads "claim again" instead of a transport failure.
  const withLease = fn => args => lifecycle.run(args.handle, async lease => {
    try {
      if (!(await nest.ready(lease.desktop))) return fail(`desktop ${lease.desktop} is not running; release this handle and claim another desktop`);
      if (nest.instance) {
        const instance = nest.instance(lease.desktop);
        if (lease.instance !== instance) leases.frames.delete(lease.desktop);
        lease.instance = instance;
      }
      const result = await fn(lease, args);
      if (!result.isError && args.observe) {
        await new Promise(resolve => setTimeout(resolve, args.settle_ms ?? 100));
        return snapshot(lease, args.scale ?? 0.5);
      }
      return result;
    } catch (e) {
      return fail(e instanceof HandleError ? e.message : `${e.message ?? e}`);
    }
  }).catch(e => fail(e.message));
  const handle = z.string().describe('handle returned by claim');
  const frame = z.string().describe('frame_id from the latest observe');

  server.registerTool('status', {
    description: `Allocated agent desktops on ${host}: running, held or free, idle time. Needs no handle.`,
    inputSchema: z.object({})
  }, async () => {
    const lines = [];
    for (const s of leases.status()) {
      const state = await nest.ready(s.desktop) ? 'ready' : 'stopped';
      const hold = s.held ? `held by ${s.owner}, idle ${Math.round(s.idleMs / 60000)} min` : `expired, cleanup pending for ${s.owner}`;
      let windows = '-';
      if (state === 'ready') {
        try { windows = String((await nest.windows(s.desktop)).length); } catch { windows = '?'; }
      }
      lines.push(`desktop ${s.desktop}: ${state}, ${hold}, windows ${windows}, ${placement}`);
    }
    return text(lines.join('\n') || 'No agent desktops allocated. Claim to start one.');
  });

  server.registerTool('claim', {
    description: 'Spawn a desktop for this task. Call again for additional desktops as needed. Returns a handle for every other tool, the desktop number, and its placement. Tell the user which desktop opened; the viewer opens automatically for the first active batch. Leases expire after 30 idle minutes; release when done.',
    inputSchema: z.object({ owner: z.string().max(80).optional().describe('who is claiming, e.g. "claude: fix login page"') })
  }, async ({ owner }) => {
    let lease;
    try { lease = await lifecycle.claim(owner); }
    catch (e) { return fail(`could not spawn desktop: ${e.message}`); }
    return {
      content: [{ type: 'text', text: `claimed desktop ${lease.desktop}; handle ${lease.handle}. Location: ${placement}.` }],
      structuredContent: { handle: lease.handle, desktop: lease.desktop, show: placement }
    };
  });

  server.registerTool('release', {
    description: 'Close this desktop and all its apps. Its browser profile is kept on disk.',
    inputSchema: z.object({ handle })
  }, async ({ handle: h }) => {
    try { const l = await lifecycle.release(h); return text(`released desktop ${l.desktop}`); } catch (e) { return fail(e.message); }
  });

  server.registerTool('open', {
    description: 'Launch a program inside the desktop and return at once. Browsers get their own profile (nothing of the user\'s is logged in). Follow with observe.',
    inputSchema: z.object({ ...feedback, handle, command: z.array(z.string()).min(1).describe('argv, e.g. ["brave", "https://example.com"]') })
  }, withLease(async (l, { command }) => {
    leases.frames.delete(l.desktop); await nest.open(l.desktop, command);
    return text(`started ${command[0]} on desktop ${l.desktop}; observe to see it`);
  }));

  server.registerTool('run', {
    description: 'Run a shell command inside the desktop (its own display and desktop session) and wait for it. For window plumbing (hyprctl clients, dispatch) or anything open does not cover.',
    inputSchema: z.object({ handle, command: z.string(), timeout_ms: z.number().int().min(100).max(120000).optional() })
  }, withLease(async (l, { command, timeout_ms }) => {
    leases.frames.delete(l.desktop);
    const r = await nest.exec(l.desktop, command, timeout_ms);
    return { ...text(`exit ${r.code}\n--- stdout\n${r.stdout}\n--- stderr\n${r.stderr}`), isError: r.code !== 0 };
  }));

  server.registerTool('observe', {
    description: 'Screenshot the desktop (cursor included) plus the window list. Returns frame_id; every coordinate tool needs the latest one, so observe again after anything changes.',
    inputSchema: z.object({ handle, scale: z.number().min(0.1).max(1).optional().describe('downscale the 2560x1440 frame, e.g. 0.5; coordinates you send back are always in full-size pixels') })
  }, withLease(async (l, { scale }) => {
    return snapshot(l, scale);
  }));

  server.registerTool('windows', {
    description: 'List the desktop\'s windows without a screenshot.',
    inputSchema: z.object({ handle })
  }, withLease(async l => text(windowsText(await nest.windows(l.desktop)))));

  const point = { ...feedback, handle, frame_id: frame, x: z.number().int().min(0).max(2559), y: z.number().int().min(0).max(1439) };
  server.registerTool('move', { description: 'Move the cursor to x,y (full-size pixels of the latest frame).', inputSchema: z.object(point) },
    withLease(async (l, a) => { leases.checkFrame(l.desktop, a.frame_id); leases.frames.delete(l.desktop); await nest.move(l.desktop, a.x, a.y); return text(`cursor at ${a.x},${a.y}`); }));

  server.registerTool('click', {
    description: 'Move to x,y and click. Observe again afterwards.',
    inputSchema: z.object({ ...point, button: z.enum(['left', 'right', 'middle']).optional() })
  }, withLease(async (l, a) => { leases.checkFrame(l.desktop, a.frame_id); leases.frames.delete(l.desktop); await nest.click(l.desktop, a.x, a.y, a.button); return text(`clicked ${a.button ?? 'left'} at ${a.x},${a.y}`); }));

  server.registerTool('scroll', {
    description: 'Move to x,y and scroll; dy positive scrolls down.',
    inputSchema: z.object({ ...point, dy: z.number().int(), dx: z.number().int().optional() })
  }, withLease(async (l, a) => { leases.checkFrame(l.desktop, a.frame_id); leases.frames.delete(l.desktop); await nest.scroll(l.desktop, a.x, a.y, a.dy, a.dx); return text(`scrolled ${a.dy},${a.dx ?? 0} at ${a.x},${a.y}`); }));

  server.registerTool('type', {
    description: 'Type text into the focused window.',
    inputSchema: z.object({ ...feedback, handle, text: z.string().min(1).max(10000) })
  }, withLease(async (l, a) => { leases.frames.delete(l.desktop); await nest.type(l.desktop, a.text); return text(`typed ${a.text.length} chars`); }));

  server.registerTool('key', {
    description: 'Press a key combo, e.g. "Return", "ctrl+l", "ctrl+shift+t", "Escape".',
    inputSchema: z.object({ ...feedback, handle, combo: z.string().min(1).max(40) })
  }, withLease(async (l, a) => { leases.frames.delete(l.desktop); await nest.key(l.desktop, a.combo); return text(`pressed ${a.combo}`); }));

  server.registerTool('wait', {
    description: 'Wait up to 30 s for the desktop to settle before observing.',
    inputSchema: z.object({ handle, ms: z.number().int().min(50).max(30000) })
  }, withLease(async (l, a) => { await new Promise(r => setTimeout(r, a.ms)); return text(`waited ${a.ms} ms`); }));

  return server;
}
