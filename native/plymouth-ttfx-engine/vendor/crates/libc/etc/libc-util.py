#!/usr/bin/env python3
"""Helper utilities for common libc tasks."""

import argparse
import copy
import datetime as dt
from enum import StrEnum
import functools
import json
import os
import pprint
import re
import subprocess as sp
import sys
from dataclasses import dataclass
from inspect import cleandoc
from multiprocessing import Pool
from pathlib import Path

REPO_OWNER = "rust-lang"
REPO = "libc"


def main() -> None:
    p = argparse.ArgumentParser(
        description="Utilities for helping with libc development"
    )
    sub = p.add_subparsers(required=True)

    p_cat = sub.add_parser(
        "check-all-targets",
        aliases=["cat"],
        help="run `cargo check` on some or all targets (see subcommand help for more)",
        description=CheckAllTargets.__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p_cat.add_argument("package", help="specify the package to build")
    p_cat.add_argument("-o", "--only", help="filter tested targets by this regex")
    p_cat.add_argument("-s", "--skip", help="skip targets matching this regex")
    p_cat.add_argument(
        "cargo_args",
        nargs="*",
        metavar="cargo-args",
        help="extra arguments for `cargo check`",
    )
    p_cat.set_defaults(
        func=lambda args: CheckAllTargets.prepare().check_all_targets(
            package=args.package,
            only=args.only,
            skip=args.skip,
            cargo_args=args.cargo_args,
        )
    )

    p_rel = sub.add_parser(
        "relabel",
        help="replace the stable-nominated label with stable-applied",
        description=Relabel.__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p_rel.add_argument(
        "pr_number", metavar="pr-number", help="pull request for the backport"
    )
    p_rel.set_defaults(func=lambda args: Relabel(pr_number=args.pr_number).execute())

    p_log = sub.add_parser(
        "make-changelog",
        help="collect changelog entries",
        description=MakeChangelog.__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    p_log.add_argument(
        "--old-tag",
        metavar="old-tag",
        help="tag of the previous revision to serve as the changelog base",
        required=True,
    )
    p_log.add_argument(
        "--new-ref",
        metavar="new-ref",
        help="ref to compare to the old tag",
        default="libc-0.2",
    )
    p_log.set_defaults(
        func=lambda args: MakeChangelog(
            old_tag=args.old_tag, new_ref=args.new_ref
        ).execute()
    )

    p_bkp = sub.add_parser(
        "backport",
        help="prepare to cherry pick to `libc-0.2` (see subcommand help for more)",
        description=Backporter.__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p_bkp.add_argument(
        "--branch", help="branch to backport to, must not be checked out", required=True
    )
    p_bkp.set_defaults(
        func=lambda args: Backporter(branch=args.branch).start_backports()
    )

    s = sub.add_parser(
        "backport-pr-description",
        help="create a PR description for a backport branch",
        description=Backporter.backport_pr_description.__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    s.add_argument("--branch", help="name of the backport branch", required=True)
    s.set_defaults(func=lambda args: Backporter.backport_pr_description(args.branch))

    p_amd = sub.add_parser(
        "add-backport-trailer",
        help='add "(backport ...)" to the previous commit',
        description=Backporter.add_backport_trailer.__doc__,
    )
    p_amd.add_argument("pick", help="commit that was cherry picked")
    p_amd.set_defaults(func=lambda args: Backporter.add_backport_trailer(args.pick))

    p_seq = sub.add_parser(
        "_sequence-editor",
        help="hook to update the rebase todo, meant for internal use",
    )
    p_seq.add_argument("path", help="path to the rebase todo")
    p_seq.set_defaults(func=lambda args: Backporter.sequence_editor(args.path))

    args = p.parse_args()
    args.func(args)


@dataclass(kw_only=True)
class Relabel:
    """
    Replace the stable-nominated label with stable-applied, given the number of
    a PR listing backported PRs.

    The backport PR should have a list of items like `* http://.../libc/pull/1234`.
    """

    pr_number: int

    def execute(self) -> None:
        num = self.pr_number
        j = check_output(
            [
                "gh",
                "pr",
                "view",
                f"https://github.com/{REPO_OWNER}/{REPO}/pull/{num}",
                "--json=baseRefName,body,state,title",
            ]
        )
        d = json.loads(j)
        base: str = d["baseRefName"]
        body: str = d["body"]
        state: str = d["state"]
        title: str = d["title"]

        if state != "MERGED":
            print(f'expected MERGED state; got {state} for "{title}" (#{num})')
            exit(1)
        if base != "libc-0.2":
            print(f'expected libc-0.2 base ref; got {base} for "{title}" (#{num})')
            exit(1)

        print(f'Relabling PRs listed in {num} "{title}"')

        to_relabel = []
        for line in body.splitlines():
            if not re.match(r"^[-*]\s*http", line):
                continue

            match = re.match(
                r"^[-*]\s*https?://github.com/rust-lang/libc/pull/(\d+)", line
            )
            if match is None:
                print(
                    f"{E.YEL}Line `{line}` does not match expected link pattern{E.RST}"
                )
                continue

            num = int(match.group(1))
            to_relabel.append(num)

        # `gh` requests can be pretty slow, parallelize to help with large lists
        with Pool() as p:
            p.map(Relabel.do_relabel_inner, to_relabel)

        print("Finished relabeling")

    @staticmethod
    def do_relabel_inner(num: int):
        j = check_output(["gh", "pr", "view", pr_url(num), "--json=state,title,labels"])
        d = json.loads(j)
        state: str = d["state"]
        title: str = d["title"]
        labels: list[str] = [i["name"] for i in d["labels"]]

        if state != "MERGED":
            print(
                f'{E.YEL}expected MERGED state; got {state} for "{title}" (#{num}){E.RST}'
            )
            return
        if "stable-nominated" not in labels:
            print(
                f'{E.YEL}`stable-nominated` not in labels for "{title}" (#{num}){E.RST}'
            )

        # Use check_output to eat the stdout since otherwise `gh` draws a spinner that
        # messes up interleaved stdout.
        check_output(
            [
                "gh",
                "pr",
                "edit",
                "--remove-label=stable-nominated",
                "--add-label=stable-applied",
                pr_url(num),
            ]
        )


@dataclass(kw_only=True)
class MakeChangelog:
    """
    Prepare a template with commits merged between `old-tag` and `new-ref`, for
    appending to the changelog.
    """

    old_tag: str
    new_ref: str

    def execute(self) -> None:
        old_tag: str = self.old_tag
        new_ref: str = self.new_ref
        date = dt.datetime.now(dt.UTC).strftime("%Y-%m-%d")
        split = old_tag.split(".")
        split[2] = str(int(split[2]) + 1)  # increment patch version
        next_tag = ".".join(split)

        ret = cleandoc(f"""
            ## [{next_tag}](https://github.com/rust-lang/libc/compare/{old_tag}...{next_tag}) - {date}

            ### Support
            ### Added
            ### Deprecated
            ### Fixed
            ### Changed
            ### Removed
            ### Other
        """)
        ret += "\n\n"

        changes = check_output(
            [
                "git",
                "log",
                f"{old_tag}..{new_ref}",
                "--no-merges",
                "--oneline",
                "--reverse",
            ],
        ).splitlines()

        print(
            f"Generating changelog for {old_tag}..{new_ref}. Make sure {new_ref} "
            "is up to date!"
        )

        for logline in changes:
            sha = logline.split()[0]
            summary = check_output(["git", "log", sha, "--format=%s", "-1"], quiet=True)
            body = check_output(["git", "log", sha, "--format=%b", "-1"], quiet=True)
            summary = summary.strip()
            body = body.strip()

            link = None

            # Extract expected trailers
            orig_sha_opt = re.search(r"\(cherry picked from commit (\w+)\)", body, re.M)
            url_opt = re.search(r"^\(backport <(.*)>\)", body, re.M)

            # Prefer a PR URL if available
            if url_opt is not None:
                pr_url = url_opt[1]
                pr_opt = re.match(
                    rf"https://github.com/{REPO_OWNER}/{REPO}/pull/(\d+)", pr_url
                )
                if pr_opt is not None:
                    pr_num = pr_opt[1]
                    link = f"[#{pr_num}]({pr_url})"

            # If there is no PR URL, link the backported commit
            if link is None and orig_sha_opt is not None:
                orig_sha = orig_sha_opt[1]
                short = orig_sha[:12]
                link = f"[{short}](https://github.com/rust-lang/libc/commit/{orig_sha})"

            # If there is no PR URL or cherry pick commit, link the commit itself
            if link is None:
                patch_sha = check_output(["git", "rev-parse", sha], quiet=True).strip()
                short = patch_sha[:12]
                link = (
                    f"[{short}](https://github.com/rust-lang/libc/commit/{patch_sha})"
                )

            line = f"- {summary} ({link})"

            ret += "\n"
            ret += line

        print(
            "Copy the below to CHANGELOG.md, then sort log messages into the "
            "relevant categories:\n"
        )
        print(ret)


@dataclass(kw_only=True)
class CheckAllTargets:
    """
    Run `cargo check` on all targets, possibly with filtering.

    Query `rustc` for a list of supported targets, then run `cargo check` on each.
    `-Zbuild-std` is used if the toolchain is not installed.

    This uses a pinned toolchain and a separate target directory in
    `~/.cache/libc-build`. This is done to avoid accidental cache deletion with `cargo
    clean` or invalidation by changing toolchain, since the initial build takes so long
    that it can be worth keeping the cache around.

    The pinned toolchain can be overridden by setting RUSTC_CACHE_TOOLCHAIN.
    """

    toolchain: str
    targets: list["RustcTarget"]
    checks: list["CheckInvocation"]
    failure_limit: int

    FREEBSD_VERSIONS = [13, 14, 15]

    # Targets that don't pass for one reason or another
    BROKEN_TARGETS = [
        # libc problems
        ("aarch64-unknown-nto-qnx800", "libc error, unsupported arch"),
        ("aarch64.*-gnu_ilp32.*time_bits=64", "libc error, time64 mismatches"),
        ("armv6k-nintendo-3ds", "libc error, stat missing"),
        ("armv7-sony-vita-newlibeabihf", "libc error, stat missing"),
        ("csky.*gnu.*time_bits=64", "libc error, time64 mismatches"),
        ("i686-pc-nto-qnx700", "libc error, unsupported arch"),
        ("managarm-mlibc", "libc error, unresolved import"),
        ("x86_64-lynx-lynxos178", "libc error, unresolved import"),
        ("x86_64-pc-nto-qnx800", "libc error, unsupported arch"),
        ("x86_64-unknown-linux-none", "libc error, unresolved import"),
        # rustc problems
        ("xtensa-esp32.*", "target string mismatch in rustc"),
        ("amdgcn-amd-amdhsa", "unsupported instructions with some CPUs"),
        # llvm problems
        ("m68k-unknown-.*", "llvm crash building core"),
        ("mipsisa32r6(el)?-.*", "llvm crash building core"),
    ]

    # Flags that always need to be passed to specific targets
    EXTRA_TARGET_FLAGS = {
        # Target CPU must be specified
        "avr-none": ["-Ctarget-cpu=atmega328p"],
        # Emits a lot of warnings
        "hexagon-unknown-qurt": ["-Aunused_imports"],
    }

    @staticmethod
    def prepare() -> "CheckAllTargets":
        """Build a list of checks."""
        toolchain = CheckAllTargets.get_cache_toolchain()
        target_dir = cache_dir() / "libc-build" / toolchain
        all_targets = RustcTarget.fetch_all(toolchain)
        installed_targets = check_output(
            [
                "rustup",
                "target",
                "list",
                "--installed",
                f"--toolchain={toolchain}",
            ]
        ).splitlines()
        checks: list[CheckInvocation] = []

        # Add a check for each target and, if applicable, a variant for any cfg options
        # that also make sense to check.
        for t in all_targets:
            base = CheckInvocation(
                target=t.triple,
                name="",
                target_dir=target_dir,
                attributes={},
                installed=t.triple in installed_targets,
                skip=[],
                extra_rustflags=[],
            )

            new_checks = [base]

            # When doing variants, use a separate target directory because otherwise
            # running twice with different `RUSTFLAGS` is a cache miss.

            if t.os_ == "freebsd":
                new_checks.clear()
                for vers in CheckAllTargets.FREEBSD_VERSIONS:
                    new = copy.deepcopy(base)
                    new.attributes = base.attributes | {"freebsd": str(vers)}
                    new.target_dir = base.target_dir / f"freebsd-{vers}"
                    new.extra_rustflags = base.extra_rustflags + [
                        f'--cfg=libc_unstable_freebsd_version="{vers}"'
                    ]

                    new_checks.append(new)

            if t.env == "gnu" and t.bits == 32:
                new = copy.deepcopy(base)
                new.attributes = base.attributes | {"time_bits": "64"}
                new.target_dir = base.target_dir / "time64"
                new.extra_rustflags = base.extra_rustflags + [
                    '--cfg=libc_unstable_gnu_time_bits="64"'
                ]
                new_checks.append(new)

            if t.env == "musl" and t.bits == 32:
                new = copy.deepcopy(base)
                new.attributes = base.attributes | {"time_bits": "64"}
                new.target_dir = base.target_dir / "time64"
                new.extra_rustflags = base.extra_rustflags + [
                    "--cfg=libc_unstable_musl_v1_2_3"
                ]
                new_checks.append(new)

            # Update the name field and check whether there are any targets that we
            # always need to skip, or that need flags.
            for check in new_checks:
                if len(check.attributes) == 0:
                    check.name = f"{check.target} (default)"
                else:
                    attrs = ",".join(f"{k}={v}" for (k, v) in check.attributes.items())
                    check.name = f"{check.target} ({attrs})"

                for pat, reason in CheckAllTargets.BROKEN_TARGETS:
                    if check.pattern_matches(pat):
                        check.skip.append(reason)

                for pat, flags in CheckAllTargets.EXTRA_TARGET_FLAGS.items():
                    if check.pattern_matches(pat):
                        check.extra_rustflags.extend(flags)

            checks.extend(new_checks)

        return CheckAllTargets(
            toolchain=toolchain,
            targets=all_targets,
            checks=checks,
            failure_limit=5,
        )

    def check_all_targets(
        self,
        *,
        package: str,
        only: str | None = None,
        skip: str | None = None,
        cargo_args: list[str] = [],
    ) -> None:
        """Run checks from the populated list."""
        checks = self.checks
        ran = 0
        passed = 0
        skipped = 0
        failures = []
        matched_only_already_skipped = []

        if only is not None:
            for t in checks:
                if t.pattern_matches(only):
                    if t.skip:
                        matched_only_already_skipped.append(t.name)
                    continue
                t.skip.append("does not match --only pattern")

        if skip is not None:
            for t in checks:
                if not t.pattern_matches(skip):
                    continue
                t.skip.append("matches --skip pattern")

        # `sum(1 for _ in ...)` seems to be the best way to get an iterator's count
        total = sum(1 for _ in (t for t in checks if not t.skip))

        # List skips first so the interesting output is together at the bottom
        checks.sort(key=lambda t: len(t.skip) == 0)

        env = os.environ.copy()
        env_rustflags = env.get("RUSTFLAGS")

        for t in checks:
            fulldesc = f"{t.name} ({ran + 1} / {total})"

            if len(t.skip) > 0:
                print(f"{E.YEL}Skipping {fulldesc} ({", ".join(t.skip)}){E.RST}")
                skipped += 1
                continue

            print(f"{E.CY_B}Checking {fulldesc}{E.RST}")

            extra_args = [] if t.installed else ["-Zbuild-std=core"]
            common_args = [
                f"--package={package}",
                f"--target={t.target}",
            ]

            # We aim to be warning-free
            rustflags = ["-Dwarnings"]
            rustflags += t.extra_rustflags

            # Allow forwarding rustflags
            if env_rustflags is not None:
                rustflags += [env_rustflags]

            print(f"    {E.GRN_D}Running build{E.RST}")

            try:
                run(
                    [
                        "cargo",
                        f"+{self.toolchain}",
                        "check",
                        f"--target-dir={t.target_dir}",
                    ]
                    + common_args
                    + extra_args
                    + cargo_args,
                    env=env | {"RUSTFLAGS": " ".join(rustflags)},
                )
                ok = True
            except sp.CalledProcessError:
                ok = False

            ran += 1

            if ok:
                passed += 1
            else:
                print(f"{E.RED_B}failed: {t.target}{E.RST}")
                failures.append(t.name)

            if len(failures) > self.failure_limit:
                break

        print(
            f"finished checking {ran} targets. {passed} passed, "
            f"{len(failures)} failed, {skipped} skipped"
        )
        if len(matched_only_already_skipped) > 0:
            print(
                f"note: {len(matched_only_already_skipped)} targets matched `--only` "
                "but were already skipped"
            )

        if len(failures) > 0:
            print("failures:")
            pprint.pp(failures)

    @staticmethod
    def get_cache_toolchain() -> str:
        # Arbitrary but reasonably recent default if unset.
        return os.environ.get("RUSTC_CACHE_TOOLCHAIN") or "nightly-2026-06-24"


@dataclass(kw_only=True)
class CheckInvocation:
    """Config for a single invocation of `cargo check`."""

    target: str
    name: str  # target plus attributes
    target_dir: Path
    installed: bool
    attributes: dict[str, str]
    # skip reasons, empty if we shouldn't skip
    skip: list[str]
    extra_rustflags: list[str]

    def pattern_matches(self, pat: str) -> bool:
        """Ensure pattern matching is applied consistently"""
        assert self.name != ""
        return re.search(pat, self.name) is not None


@dataclass(kw_only=True)
class Backporter:
    """Prepare an interactive rebase that will cherry pick commits to `libc-0.2`.

    This loosely does the following:

    * Create a git worktree at `.libc-backports`
    * Switch to the specified branch
    * Start an interactive rebase that runs `git cherry-pick -x <sha>` for each needed
      commit, then modify the commit to add the `(cherry picked from ...)` and
      `(backport ...)` trailers.

    An interactive rebase is used because it's a nice way to create and execute a series
    of shell commands with a chance to resolve conflicts and continue as needed.

    Because it is standard `git rebase`, it is possible to use typical options like
    `git rebase --edit-todo` if it pauses due to conflicts.
    """

    branch: str

    WORKTREE_DIR = ".libc-backports"
    WORKTREE_GIT = ["git", "-C", WORKTREE_DIR]
    GQL_QUERY = """
        query ($endCursor: String) {
          repository(name: "libc", owner: "rust-lang") {
            pullRequests(
              first: 25
              after: $endCursor
              baseRefName: "main"
              states: MERGED
              labels: ["stable-nominated"]
              # Ordering by merge date is not supported, we need to re-sort after fetch.
              orderBy: {field: CREATED_AT, direction: ASC}
            ) {
              nodes {
                title
                number
                state
                url
                author {
                  login
                }
                mergedAt
                mergeCommit {
                  oid
                  committedDate
                  messageHeadline
                  author {
                    name
                    user {
                      login
                    }
                  }
                }
                commits(first: 100) {
                  totalCount
                  nodes {
                    commit {
                      oid
                      committedDate
                      messageHeadline
                      author {
                        name
                        user {
                          login
                        }
                      }
                    }
                  }
                }
              }
              pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
    """

    def start_backports(self) -> None:
        self.ensure_local_updated()

        try:
            self.ensure_branch()
            self.ensure_worktree()
            self.prepare_rebase_todo()
            seq_ed = "../etc/libc-util.py _sequence-editor"
            run(
                self.WORKTREE_GIT + ["rebase", "-i", "libc-0.2"],
                env=os.environ | {"GIT_SEQUENCE_EDITOR": seq_ed},
            )
            # Give the user a chance to delete picks if desired
            print("Presenting rebase todo to user for review...")
            run(self.WORKTREE_GIT + ["rebase", "--edit-todo"])
            run(self.WORKTREE_GIT + ["rebase", "--continue"])
        except sp.CalledProcessError:
            msg = f"""
                {E.YEL}Rebase failed or incomplete; check the git error above for
                details.

                If git stopped because of a conflict or other resolvable error, change
                to the worktree directory at {self.WORKTREE_DIR}. From there, you can
                resolve conflicts or `git rebase --quit` to stop trying to backport the
                rest of the commits.

                If needed, `git worktree remove .libc-backports` will allow you to
                delete the branch and start from scratch.{E.RST}
            """
            print("\n" + mstr(msg))
            exit(1)

    def prepare_rebase_todo(self) -> None:
        """Create a rebase todo list and cache it, to be picked up by the sequence
        editor.
        """
        # Start with a break so we can `--edit-todo`
        rebase_todo = "break\n"
        commit_map = ""

        pull_requests = self.fetch_needs_backport_list()
        for pr in pull_requests:
            last_sha = pr.merge_commit.oid
            parents = check_output(
                ["git", "log", last_sha, "--format=%P", "-1"], quiet=True
            ).split()

            # If we have a merge commit, take only the second (incoming) commit.
            if len(parents) > 2:
                eprint("Can't backport commits with >1 parent")
                exit(1)
            if len(parents) == 2:
                last_sha = parents[1]

            # The commit list is not what we actually want to cherry pick; it has the
            # refs for the commits in the PR but not the ref after merge. The PR's
            # "merge" commit is the last commit on `main` from this PR, so we can
            # work backwards; given N commits, `merge_sha~(N-1)` will be the first PR
            # from the commit on `main`.
            for i in reversed(range(len(pr.commits))):
                n_back = len(pr.commits) - i - 1
                pick_sha = check_output(
                    ["git", "rev-parse", f"{last_sha}~{n_back}"], quiet=True
                ).strip()
                subject = check_output(
                    ["git", "log", pick_sha, "--format=%s", "-1"], quiet=True
                ).strip()
                pick_short = pick_sha[:12]
                rebase_todo += (
                    f"exec printf '{E.CY_B.u}picking from PR{pr.number}: {pick_short} "
                    f'"{subject}"{E.RST.u}\\n\''
                    "\n"
                    f'pick {pick_short}  # pick "{subject}"'
                    "\n"
                    f"exec ../etc/libc-util.py add-backport-trailer {pick_short}"
                    "\n\n"
                )
                commit_map += f"{pick_sha} {pr.number}\n"

        todo_path = self.rebase_todo_tmp_path()
        # may need to create `target/libc-util`
        todo_path.parent.parent.mkdir(exist_ok=True)
        todo_path.parent.mkdir(exist_ok=True)
        todo_path.write_text(rebase_todo)

        self.commit_map_path().write_text(commit_map)

    def fetch_needs_backport_list(self) -> list["PullRequest"]:
        """Fetch PRs labeled `stable-nominated` via the GraphQL API"""
        s = check_output(
            [
                "gh",
                "api",
                "graphql",
                "--paginate",
                "--slurp",
                "-f",
                "query=" + self.GQL_QUERY,
            ]
        )
        j: list[dict] = json.loads(s)

        # The result is paginated so we get nested lists. Extract the data we want
        # then flatten.
        pages = [page["data"]["repository"]["pullRequests"]["nodes"] for page in j]
        pr_nodes = [pr_node for page in pages for pr_node in page]

        pull_requests: list[PullRequest] = []
        for pr in pr_nodes:
            commits = [node["commit"] for node in pr["commits"]["nodes"]]

            new = PullRequest(
                title=pr["title"],
                number=int(pr["number"]),
                state=pr["state"],
                url=pr["url"],
                author_username=pr["author"]["login"],
                merged_at=pr["mergedAt"],
                merge_commit=Commit.from_object(pr["mergeCommit"]),
                commits=[Commit.from_object(c) for c in commits],
            )

            total_commits = int(pr["commits"]["totalCount"])
            new_commit_count = len(new.commits)
            if total_commits != new_commit_count:
                print(
                    f"limit reached: {total_commits} total commits but could "
                    f"only fetch {new_commit_count}"
                )
                exit(1)

            pull_requests.append(new)

        # Oldest to newest
        pull_requests.sort(key=lambda pr: pr.merged_at)
        return pull_requests

    def ensure_local_updated(self) -> None:
        """Sanity check that whatever we want to rebase onto is actually updated, and
        fetch `main` to ensure cherry pick sources exist locally."""

        run(["git", "fetch", repo_fetch_url(), "main"])
        run(["git", "fetch", repo_fetch_url(), "libc-0.2"])
        upstream = check_output(["git", "rev-parse", "FETCH_HEAD"]).strip()
        local = check_output(["git", "rev-parse", "libc-0.2"]).strip()

        if upstream != local:
            print(
                f"local libc-0.2@{local[:12]} does not match upstream/libc-0.2@{upstream[:12]}!"
                "Fetch before retrying."
            )
            exit(1)

    def ensure_branch(self) -> None:
        """Create the branch if it doesn't exist."""
        try:
            run(["git", "branch", self.branch, "libc-0.2"], stderr=sp.PIPE)
        except sp.CalledProcessError:
            pass

    def ensure_worktree(self) -> None:
        """Set up a worktree pointing to the target branch."""
        # Prune in case the directory was deleted without going via git.
        run(["git", "worktree", "prune"])

        try:
            print("creating worktree")
            run(
                ["git", "worktree", "add", ".libc-backports", self.branch],
                stderr=sp.PIPE,
            )
        except sp.CalledProcessError:
            print("worktree already exists, checking out branch")
            run(self.WORKTREE_GIT + ["switch", self.branch])

    @staticmethod
    def sequence_editor(path: str) -> None:
        """The script-y way to construct a rebase is by setting the "sequence editor" to
        a script that gets the rebase todo path. That's all this function does, the
        needed contents have already been written.
        """

        print(f"editing rebase todo at {path}")

        txt = "\n\n"
        txt += Backporter.rebase_todo_tmp_path().read_text()

        with Path(path).open("a") as f:
            f.write(txt)

    @staticmethod
    def add_backport_trailer(pick: str) -> None:
        """Add `(backport ...)` to the previous commit, using `(cherry picked from ...)`
        to know where the commit came from.
        """
        head_summary = check_output(["git", "log", "-1", "HEAD", "--format=%s"]).strip()
        pick_summary = check_output(["git", "log", "-1", pick, "--format=%s"]).strip()
        head_message = check_output(["git", "log", "-1", "HEAD", "--format=%B"]).strip()
        head = check_output(["git", "rev-parse", "HEAD"]).strip()
        pick = check_output(["git", "rev-parse", pick]).strip()

        existing_pick_msg = re.search(
            r"^\(cherry picked from commit (\w+)\)", head_message, re.M
        )
        existing_backport_msg = re.search(r"^\(backport.*\)", head_message, re.M)

        if existing_pick_msg is not None:
            print(
                f"{E.YEL}Commit {head} already contains cherry-pick trailer; "
                f"skipping{E.RST}"
            )
            return

        if existing_backport_msg is not None:
            print(
                f"{E.YEL}Commit {head} already contains backport trailer; "
                f"skipping{E.RST}"
            )
            return

        if head_summary != pick_summary:
            print(
                f"{E.YEL}Commit {head} summary does not match pick {pick} "
                f"summary; skipping{E.RST}"
            )
            return

        commit_map = Backporter.commit_map_path().read_text()
        pr = None
        for line in commit_map.splitlines():
            if not line.startswith(pick):
                continue
            _, _, pr = line.partition(" ")
            break

        if pr is None:
            print(f"{E.YEL}could not locate PR for picked commit {pick}{E.RST}")
            return

        new_message = head_message.strip()
        new_message += f"\n\n(backport <{pr_url(int(pr))}>)"
        new_message += f"\n(cherry picked from commit {pick})\n"
        run(["git", "commit", "--amend", "--message", new_message])

    @staticmethod
    def backport_pr_description(branch: str) -> None:
        """List all backported commits for a branch, for pasting into the PR body."""
        commits = check_output(["git", "log", f"libc-0.2..{branch}", "--format=%b"])
        urls = {x[1] for x in re.finditer(r"^\(backport <(.*)>\)", commits, re.M)}
        urls = sorted(list(urls))

        s = "Backport the following:\n\n"
        for url in urls:
            s += f"* {url}\n"

        print(s)

    @staticmethod
    def rebase_todo_tmp_path() -> Path:
        """Rebase todo to be appended to the default"""
        return Path(__file__).parent.parent / "target" / "libc-util" / "rebase-todo.txt"

    @staticmethod
    def commit_map_path() -> Path:
        """List of `<sha> <pr_number>` mappings."""
        return Path(__file__).parent.parent / "target" / "libc-util" / "commit-map.txt"


@dataclass(kw_only=True)
class RustcTarget:
    """Config queried from rustc."""

    triple: str
    arch: str
    os_: str | None
    env: str | None
    bits: int

    @staticmethod
    @functools.cache
    def get_one(toolchain: str, triple: str) -> "RustcTarget":
        target_cfg = check_output(
            ["rustc", f"+{toolchain}", "--print=cfg", f"--target={triple}"], quiet=True
        )
        return RustcTarget(
            triple=triple,
            arch=re.findall(r'target_arch="(.*)"', target_cfg)[0],
            env=re.findall(r'target_env="(.*)"', target_cfg)[0],
            os_=re.findall(r'target_os="(.*)"', target_cfg)[0],
            bits=int(re.findall(r'target_pointer_width="(.*)"', target_cfg)[0]),
        )

    @staticmethod
    @functools.cache
    def fetch_all(toolchain: str) -> list["RustcTarget"]:
        """Collect all targets for a given toolchain."""
        all_targets = check_output(
            ["rustc", f"+{toolchain}", "--print=target-list"]
        ).splitlines()

        # Iterating targets is really slow, throw some threads at it.
        with Pool() as p:
            ret = p.starmap(RustcTarget.get_one, [(toolchain, t) for t in all_targets])

        ret.sort(key=lambda t: t.triple)
        return ret


@dataclass(kw_only=True)
class PullRequest:
    """Pull request built from a GitHub GraphQL API response"""

    title: str
    number: int
    state: str
    url: str
    author_username: str
    merged_at: str
    merge_commit: "Commit"
    commits: list["Commit"]


@dataclass(kw_only=True)
class Commit:
    """Commit built from a GitHub GraphQL API response"""

    oid: str
    committed_date: str
    subject: str
    author_name: str
    author_username: str | None

    def __post_init__(self) -> None:
        # Give some protection against multiline summaries, since that may confuse
        # scripts or log messages.
        self.subject = trunc_lines(self.subject)
        self.author_name = trunc_lines(self.author_name)
        if self.author_username is not None:
            self.author_username = trunc_lines(self.author_username)

    @staticmethod
    def from_object(obj) -> "Commit":
        user = obj["author"]["user"]
        return Commit(
            oid=obj["oid"],
            committed_date=obj["committedDate"],
            subject=obj["messageHeadline"],
            author_name=obj["author"]["name"],
            author_username=user["login"] if user is not None else None,
        )


class E(StrEnum):
    """ANSI escapes."""

    YEL = "\033[33m"
    GRN = "\033[32m"

    # Bright colors
    CY_B = "\033[1;36m"
    YEL_B = "\033[1;33m"
    RED_B = "\033[1;31m"

    # Dimmed colors
    DIM = "\033[2m"
    YEL_D = "\033[2;33m"
    GRN_D = "\033[2;32m"

    RST = "\033[0m"

    @property
    def u(self) -> str:
        """Unescape, for passing to shell printf."""
        return self.replace("\033", "\\033")


@functools.cache
def cache_dir() -> Path:
    xdg_cache = os.environ.get("XDG_CACHE_DIR")
    if xdg_cache is not None:
        return Path(xdg_cache)
    return Path.home() / ".cache"


def repo_fetch_url() -> str:
    return f"https://github.com/{REPO_OWNER}/{REPO}.git"


def pr_url(num: int) -> str:
    return f"https://github.com/{REPO_OWNER}/{REPO}/pull/{num}"


def mstr(s: str) -> str:
    """Message string: clean an indented string and convert singular `\\n`s to spaces."""
    return re.sub(r"(\S)\n(\S)", r"\1 \2", cleandoc(s))


def check_output(args: list[str], *, quiet: bool = False, **kw) -> str:
    if not quiet:
        xtrace(args, env=kw.get("env"))
    return sp.check_output(args, encoding="utf8", text=True, **kw)


def run(args: list[str], *, quiet: bool = False, **kw) -> sp.CompletedProcess:
    if not quiet:
        xtrace(args, env=kw.get("env"))
    return sp.run(args, check=True, text=True, **kw)


def xtrace(args: list[str], *, env: dict[str, str] | None) -> None:
    """Print commands before running them."""
    astr = " ".join(str(arg) for arg in args)

    # GQL commands are long, trim the next line
    astr = trunc_lines(astr)

    if env is None:
        eprint(f"{E.DIM}+ {astr}{E.RST}")
    else:
        envdiff = set(env.items()) - set(os.environ.items())
        estr = " ".join(f"{k}='{v}'" for (k, v) in envdiff)
        eprint(f"{E.DIM}+ {estr} {astr}{E.RST}")


def trunc_lines(s: str) -> str:
    """If >1 line, replace other lines with `...`."""
    first, _, rest = s.partition("\n")
    if rest != "":
        first += " ..."
    return first


def eprint(*args, **kw) -> None:
    print(*args, file=sys.stderr, **kw)


if __name__ == "__main__":
    main()
