# NetClaw PR showcase

The showcase runs through the installed NetClaw agent. Each demonstration should include the operator's prompt, the agent's actual tool use, the resulting artifact, and a screenshot from the Omarchy desktop. Record failures alongside successful results; an installed skill is not evidence of a successful external integration.

## Live interfaces to an interactive mind map

Ask NetClaw to use `pyats-network` to collect `show ip interface brief` and `show interfaces` from the authorized `iosxe-sandbox`, then use `markmap-viz` to create an interactive map grouped by operational state. Include interface names, addresses, line protocol, MTU, and available error counters. Mark missing fields as unavailable. Preserve the collected timestamp and source commands in the report.

Capture the NetClaw conversation and the rendered mind map. Expand one interface branch to show the transition from live device evidence to a navigable visual. Save the generated artifact alongside the screenshot so reviewers can explore it themselves.

## Interface health and topology

Ask NetClaw to summarize interface counters and use its supported diagram skills to illustrate observed connections. A single device with no discovered neighbors should produce an interface view, not invented topology. Explain that a single counter sample cannot establish an error rate or trend.

## NetBox intent versus live state

Use a dedicated NetBox sandbox with a site, a device matching the testbed alias, interfaces, and IP assignments. After collecting the live baseline, seed a clearly documented demo discrepancy in NetBox only. Ask NetClaw's `netbox-reconcile` skill to compare intended and observed state and produce a drift report and mind map. Keep reconciliation read-only during the demonstration.

Required connection details: NetBox URL and API token, configured privately through NetClaw. The PR must label seeded discrepancies and distinguish them from naturally observed conditions.

The provided environment is the shared public `demo.netbox.dev` instance. Begin with read-only inventory discovery there. If the Cisco sandbox is absent from its inventory, show that limitation and demonstrate the available inventory honestly; a controlled drift example requires a dedicated record or sandbox with explicit authorization to seed it.

## ServiceNow workflow

Use a dedicated ServiceNow developer instance with a demo network configuration item and a sample change record. Ask NetClaw's `servicenow-change-workflow` skill to inspect the record, correlate the collected device evidence, and draft a verification plan. Creating or updating demo records can be demonstrated when explicitly authorized; the Cisco sandbox remains read-only.

Required connection details: instance URL and a dedicated demo username/password, configured privately through NetClaw. Keep credentials, session tokens, and personal information out of screenshots and committed artifacts.

## Evidence checklist

- Record the distro revision, NetClaw revision, selected components, model, and execution time.
- Capture the desktop launcher/menu, the NetClaw conversation, and each rendered artifact.
- Preserve sanitized prompts, source command names, results, and generated files.
- Label each scenario as passed, failed, or awaiting a sandbox.
- Keep runtime configuration, raw session logs, and secret-bearing inventories outside the repository.

See [the validation record](netclaw-validation.md) for completed checks. This document defines the planned demonstrations; it does not claim they have already passed.
