// Keep each desktop's commands and shutdown in one queue. Different desktops
// can work concurrently; a number stays reserved until shutdown succeeds.
export function createLifecycle({ leases, nest, notify = async () => {} }) {
  const pending = new Map();
  const serial = (desktop, fn) => {
    const next = (pending.get(desktop) ?? Promise.resolve()).then(fn, fn);
    pending.set(desktop, next.catch(() => {}));
    return next;
  };
  const withHandle = (handle, fn) => {
    const l = leases.byHandle.get(handle);
    if (!l) return Promise.reject(new Error(`unknown handle ${handle}`));
    return serial(l.desktop, () => {
      if (leases.byHandle.get(handle) !== l) throw new Error(`unknown handle ${handle}`);
      return fn(l);
    });
  };
  const stop = async l => {
    await nest.stop(l.desktop);
    leases.release(l.handle);
    await notify("Agent desktop closed", `${l.owner}: desktop ${l.desktop} and its managed apps have stopped.`);
  };
  const reap = async () => {
    const results = await Promise.allSettled([...leases.byHandle.values()]
      .filter(l => !leases.live(l))
      .map(l => serial(l.desktop, async () => {
        if (leases.byHandle.get(l.handle) === l && !leases.live(l)) await stop(l);
      })));
    const failures = results.filter(r => r.status === 'rejected');
    if (failures.length) throw new AggregateError(failures.map(r => r.reason), 'desktop cleanup failed');
  };
  return {
    run: (handle, fn) => withHandle(handle, async l => {
      leases.touch(handle);
      try { return await fn(l); }
      finally {
        l.lastUsed = leases.now();
        leases.save();
      }
    }),
    reap,
    claim: async owner => {
      // Allocation is synchronous, before startup yields to another request.
      const l = leases.claim(owner);
      return serial(l.desktop, async () => {
        try {
          await notify("Opening an agent desktop", `${owner}: desktop ${l.desktop} will open${nest.placement ? ` as a ${nest.placement}` : " in the background. Open Agent Desktops to watch"}.`);
          await nest.stop(l.desktop);
          await nest.start(l.desktop);
          leases.touch(l.handle);
          return l;
        } catch (error) {
          // Keep ownership if cleanup fails, so no other claim can inherit it.
          await stop(l);
          throw error;
        }
      });
    },
    release: handle => withHandle(handle, async l => { await stop(l); return l; })
  };
}
