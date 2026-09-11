# White-box pen-test

The white-box pass reads the source and targets a named invariant per boundary.
Each case is the concrete artifact a plugin would emit, driven through the real
validation code in `native/ward/tests/pen_test.rs`. All 14 cases pass.

## TB-8 · exec policy (positive-only argv matching)

Target: the argv tree must accept only a complete path to a reviewed terminal;
no exclusion, wildcard, normalization, or prefix-suffix semantics.

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_exec_traversal_prefix_and_overflow_are_rejected` | `$OMARCHY_PLUGIN_PATH/../etc/passwd`, `../../etc/shadow`, `./x`, `/etc/passwd`, and a non-alias token | Rejected: the token resolves only within the pinned directory; the trailing portion is guarded against `..`/`.` |
| `whitebox_exec_extra_args_and_prefix_injection_are_rejected` | a second argument, an empty argument, a null byte, an over-bound argument | Rejected: a complete argv path is required; extra/empty/null/oversized arguments fail |
| `whitebox_exec_integer_and_pattern_constraints_are_strict` | `0`, `01`, `+1`, `1.0`, `1e1` for integers; prefix/traversal/encoded/newline/over-bound for patterns | Rejected: integer and pattern constraints match whole, bounded arguments with no escaping |
| `whitebox_exec_selection_must_come_from_the_reviewed_tree` | a selection not in the tree; a parent name selected as if a leaf | Rejected: all selected names must come from the reviewed tree; a parent name is not a leaf |

The one free-text slot accepts any single string **by design** (the reviewer
chose it); the protection is against *extra* arguments, not the content of the
reviewed slot. That is the documented "argv matching is not semantic safety"
limitation, not a bug.

## TB-8 · http (exact reviewed selections)

Target: a request must match the approved origin, method, path, and query
exactly; the resolved address is pinned to defeat DNS rebinding.

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_http_scope_definition_attacks_fail_validation` | a `*` in a non-wildcard position, a subtree path not ending in `/`, a non-canonicalizing origin, credentials, a fragment, a body on GET, an unknown field | Rejected by `validate()` (a well-formed, exact scope is the only accepted shape) |
| (module test, referenced) | other host, other port, other scheme, credentials, other path segment, query value, extra query, a fragment, leading whitespace | Rejected by the private `Scope::check`, covered by `methods_origins_paths_and_required_query_filters_cannot_be_widened` |

## TB-2 · grants (fail-closed validation)

Target: a grant must cover the request exactly; a gap is a gap; an unrequested
grant is an error, not a widening.

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_grants_validation_is_fail_closed` | a missing required scope, granting the scope, then granting an unrequested capability | A gap is reported, not a `validate()` failure; granting an unrequested capability fails |
| `whitebox_grants_filesystem_access_and_target_are_independent` | a read vs a read-write grant; a write-only selection | Read does not imply write; a write-only selection is `Unsupported` (a bind also exposes reads) |

## TB-8 · settings (exact own-entry keys)

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_settings_host_structure_and_wildcards_are_rejected` | `*`, `id`, `sandbox`, `constructor`, `__proto__`, `prototype` | Rejected at validation |
| `whitebox_settings_write_is_bounded_by_approved_keys` | a write to a read-only key, a write that adds a host-structure key | Rejected: writes are bounded to approved keys; the read filter only exposes approved read keys |

## TB-8 · notification (text policy)

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_notification_text_policy_rejects_control_and_rtl` | null/newline/CR/tab in the title, a newline in the body, RTL override/embedding, empty title, oversized title/body | Rejected (or escaped): a newline is allowed in the body only; control and RTL characters are rejected |
| `whitebox_notification_packet_attacks_fail_decode` | an extra field, an `exec` field, a wrong version, a duplicate field, a carried descriptor, an oversized packet | Rejected at decode; only the well-formed shape decodes |

## TB-6 · context (one-way, bounded, finite)

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_context_bounding_is_strict` | an oversized context, a non-finite/zero/over-bar coordinate, a bad position, a panel with serial 0 / a payload when closed / an oversized payload, an unknown field | Rejected: the context is bounded, finite, and strict; a malformed context fails the worker, not the host |

## TB-6 · presentation (slot/generation state machine)

| Case | Attack | Result |
| --- | --- | --- |
| `whitebox_presentation_record_attacks_fail_decode` | generation 0, out-of-bounds dimensions, a bad scale, a missing magic, a frame with slot > 1 or serial 0, a mask over the region cap | Rejected: strict slot/generation validation; only well-formed records round-trip |
| `whitebox_presentation_buffer_attacks_fail_validation` | a buffer over the pixel cap, an odd stride, a too-small stride, a missing fd | Rejected: dimension and stride bounds are enforced; the fd is required |

## Conclusion

These cases exercise selected validation entry points. Presentation cases include sender-side rejection, not only decoder execution; the newer raw-buffer-byte test in `presentation.rs` directly exercises receiver validation. Store approval, host input admission and real worker behavior have separate tests in the [review ledger](../review-regressions.md).

Approved CLI semantics, kernel/DRM exposure and private Wayland/Qt parsing are separate residual risks. This pass does not establish containment at every boundary or a single medium-risk exception.
