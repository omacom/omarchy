// todo_write: the task list OpenCode, Omp and Claude Code give their models.
// The model writes the whole list each time, which models keep straight more
// reliably than item-by-item edits. The list lives in the tool results, so it
// follows the session through /tree and /fork, and it shows above the editor
// while anything on it is still open. Subagents don't get it: their work is
// one item on their parent's list.

import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

type Status = "pending" | "in_progress" | "completed" | "cancelled";

interface Todo {
  content: string;
  status: Status;
}

interface TodoDetails {
  todos: Todo[];
  error?: string;
}

const TodoWriteParams = Type.Object({
  todos: Type.Array(
    Type.Object({
      content: Type.String({ description: "What to do, as a short imperative" }),
      status: StringEnum(["pending", "in_progress", "completed", "cancelled"] as const),
    }),
    { description: "The complete list, replacing the previous one. An empty list clears it." },
  ),
});

const open = (todo: Todo) => todo.status === "pending" || todo.status === "in_progress";

// Todo text is drawn in the terminal, so escape sequences, control characters
// and direction overrides a model copied from a page don't get through.
function clean(text: string): string {
  return text
    .replace(/\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)?/g, "")
    .replace(/[\x00-\x1f\x7f‪-‮⁦-⁩]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function mark(todo: Todo, theme: Theme): string {
  switch (todo.status) {
    case "completed":
      return `${theme.fg("success", "✓")} ${theme.fg("dim", todo.content)}`;
    case "cancelled":
      return `${theme.fg("dim", "✗")} ${theme.fg("dim", todo.content)}`;
    case "in_progress":
      return `${theme.fg("accent", "▸")} ${theme.fg("text", todo.content)}`;
    default:
      return `${theme.fg("dim", "○")} ${theme.fg("muted", todo.content)}`;
  }
}

function summary(todos: Todo[]): string {
  const done = todos.filter((todo) => !open(todo)).length;
  return `${done}/${todos.length} done`;
}

export default function (pi: ExtensionAPI) {
  if (process.env.OMARCHY_PI_SUBAGENT) return;

  let todos: Todo[] = [];

  const showWidget = (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;
    if (!todos.some(open)) {
      ctx.ui.setWidget("omarchy-todos", undefined);
      return;
    }
    ctx.ui.setWidget("omarchy-todos", (_tui, theme) => {
      const lines = [theme.fg("muted", `Todos ${summary(todos)}`), ...todos.map((todo) => `  ${mark(todo, theme)}`)];
      return new Text(lines.join("\n"), 0, 0);
    });
  };

  // The list as of the current point on the branch: the last todo_write's.
  const restore = (ctx: ExtensionContext) => {
    todos = [];
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type !== "message") continue;
      const message = entry.message;
      if (message.role !== "toolResult" || message.toolName !== "todo_write") continue;
      const details = message.details as TodoDetails | undefined;
      if (details && !details.error) todos = details.todos;
    }
    showWidget(ctx);
  };

  pi.on("session_start", async (_event, ctx) => restore(ctx));
  pi.on("session_tree", async (_event, ctx) => restore(ctx));

  pi.registerTool({
    name: "todo_write",
    label: "Todos",
    description:
      "Write the task list for the current work, replacing the previous list. Each item has content and a status: pending, in_progress, completed or cancelled.",
    promptSnippet: "Plan and track multi-step work as a todo list",
    promptGuidelines: [
      "Use todo_write proactively for work with three or more distinct steps, or when the user gives several tasks at once; skip todo_write for a single small task or a question.",
      "With todo_write, keep exactly one item in_progress, mark each item completed as soon as it is done, cancel items that no longer apply rather than dropping them, and add items you discover along the way.",
      "Call todo_write only when the list changes, in the same response as your next real tool call rather than as a turn of its own.",
    ],
    parameters: TodoWriteParams,
    executionMode: "sequential",

    // Some model servers send the array as a JSON string.
    prepareArguments(args) {
      const input = (args ?? {}) as { todos?: unknown };
      if (typeof input.todos !== "string") return args as never;
      try {
        return { ...input, todos: JSON.parse(input.todos) } as never;
      } catch {
        return args as never;
      }
    },

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const next = params.todos.map((todo) => ({ content: clean(todo.content), status: todo.status }));
      if (next.some((todo) => todo.content === "")) {
        return {
          content: [{ type: "text" as const, text: "Error: every todo needs content" }],
          details: { todos, error: "every todo needs content" } as TodoDetails,
          isError: true,
        };
      }
      todos = next;
      showWidget(ctx);

      // The model just wrote the list, so it gets a summary back rather than its own list again.
      const current = todos.find((todo) => todo.status === "in_progress");
      const text = todos.length === 0
        ? "Todos cleared."
        : `Todos updated: ${summary(todos)}.${current ? ` In progress: ${current.content}` : ""}`;
      return {
        content: [{ type: "text" as const, text }],
        details: { todos } as TodoDetails,
      };
    },

    renderCall(args, theme) {
      const count = Array.isArray(args.todos) ? args.todos.length : 0;
      return new Text(theme.fg("toolTitle", theme.bold("todos ")) + theme.fg("muted", `${count} item${count === 1 ? "" : "s"}`), 0, 0);
    },

    renderResult(result, _options, theme) {
      const details = result.details as TodoDetails | undefined;
      if (!details) {
        const first = result.content[0];
        return new Text(first?.type === "text" ? first.text : "", 0, 0);
      }
      if (details.error) return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);
      if (details.todos.length === 0) return new Text(theme.fg("dim", "Cleared"), 0, 0);
      return new Text(details.todos.map((todo) => mark(todo, theme)).join("\n"), 0, 0);
    },
  });

  pi.registerCommand("todos", {
    description: "Show the todo list on the current branch",
    handler: async (_args, ctx) => {
      const symbol = { completed: "✓", cancelled: "✗", in_progress: "▸", pending: "○" };
      const text = todos.length
        ? `${summary(todos)}\n${todos.map((todo) => `${symbol[todo.status]} ${todo.content}`).join("\n")}`
        : "No todos";
      ctx.ui.notify(text, "info");
    },
  });
}
