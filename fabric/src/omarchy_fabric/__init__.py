"""omarchy-fabric: a policy-governed agent-to-physical layer for Omarchy.

Agents (over MCP) never talk to devices directly. Every physical action goes
through the same pipeline: resolve -> validate -> policy -> (approval) ->
execute -> audit. Device backends (Home Assistant, Matter, GPIO, simulator)
are adapters underneath that pipeline.
"""

__version__ = "0.1.0"
