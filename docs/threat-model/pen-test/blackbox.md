# Docs-derived negative cases

These seven historical cases were designed from the plugin authoring contract and implemented in `native/ward/tests/pen_test_blackbox.rs`. They invoke host validation functions; they do not execute malicious plugins through the whole runtime. The “black-box” filename describes the design approach, not end-to-end penetration-test coverage.

| Case | Actual boundary reached | What it does not establish |
| --- | --- | --- |
| `blackbox_a_plugin_cannot_self_approve_a_host_file_grant` | Constructs filesystem grants and validates request/selection consistency | Does not call Store approval, select signing keys, mount a worker or exercise installation classification |
| `blackbox_a_plugin_cannot_add_arguments_to_a_reviewed_command` | Exec argument-tree matching rejects extra arguments | Does not make an admitted CLI semantically safe or constrain its dependencies |
| `blackbox_a_plugin_cannot_request_an_unapproved_http_origin` | HTTP scope-definition validation | Does not send a hostile request through the broker; scope/request matching has separate module tests |
| `blackbox_a_plugin_cannot_write_a_read_only_or_host_structure_key` | Setting-key validation and selected write checks | Does not exercise a real persisted shell-settings transaction |
| `blackbox_a_plugin_cannot_smuggle_markup_into_a_notification` | Notification text construction and escaping | Does not send a real desktop notification |
| `blackbox_a_plugin_cannot_get_a_malformed_or_oversized_context` | Context parser/validator | Does not let a worker publish host context; normal context is host-produced |
| `blackbox_a_plugin_cannot_traverse_out_of_its_assets` | Lexical PATH token resolution and matching | Does not prove mutable DATA symlink confinement; sealed input consumption now has separate tests |

See the [review regression ledger](../review-regressions.md) for the real Store, CLI, worker, host-job and private-display tests added after the review. These cases are useful bounded guards, not proof of complete boundary containment.
