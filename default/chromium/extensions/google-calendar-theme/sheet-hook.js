// Runs in the page's world, where Google adds stylesheet rules with insertRule.
// No MutationObserver reports those, so each call is announced on the sheet's
// owner element for content.js to rescan that sheet.
(() => {
  const SHEET_EVENT = 'omarchy-calendar-sheet-change';

  for (const proto of [CSSStyleSheet.prototype, CSSGroupingRule.prototype]) {
    const insertRule = proto.insertRule;
    proto.insertRule = function (...args) {
      const index = insertRule.apply(this, args);
      (this.parentStyleSheet ?? this).ownerNode?.dispatchEvent(new Event(SHEET_EVENT));
      return index;
    };
  }
})();
