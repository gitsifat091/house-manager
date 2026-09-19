# -*- coding: utf-8 -*-
"""Find blocks of commented-out Dart and optionally delete them.

The distinction that matters is commented-out *code* versus a comment that
explains something. This only removes runs of plain `//` lines that look
overwhelmingly like source, and never touches `///` doc comments, `/* */`
blocks, or short remarks.

    python deadcode.py --dry-run     list what would go
    python deadcode.py --apply       remove it
"""
import io
import os
import re
import sys

SEP = os.sep

# Signals that a commented line is source rather than prose.
CODE_PAT = re.compile(
    r"(;\s*$|\{\s*$|^\s*\}|\)\s*;?\s*,?\s*$|=>|\breturn\b|\bfinal\b|\bconst\b|"
    r"\bimport\b|\bclass\b|\bvoid\b|\bWidget\b|\bawait\b|\basync\b|\bif\s*\(|"
    r"\bfor\s*\(|\bsetState\b|\bNavigator\b|\bBuildContext\b|\bcontext\b|"
    r"\b(Future|Stream|String|int|double|bool|List|Map)\s*<|"
    r"^\s*@override|\bstyle:|\bchild:|\bchildren:|\bpadding:|\bcolor:|"
    r"^\s*\w+:\s|=\s)"
)

# A comment line, but not a doc comment.
def is_comment(line):
    s = line.strip()
    return s.startswith("//") and not s.startswith("///")


def content_of(line):
    """Strip however many `//` prefixes have accumulated."""
    s = line.strip()
    while s.startswith("//"):
        s = s[2:].lstrip()
    return s


def runs(lines):
    """Maximal runs of comment lines, allowing blank lines inside."""
    out = []
    i = 0
    n = len(lines)
    while i < n:
        if not is_comment(lines[i]):
            i += 1
            continue
        start = i
        last_comment = i
        j = i
        while j < n:
            if is_comment(lines[j]):
                last_comment = j
                j += 1
            elif lines[j].strip() == "":
                j += 1
            else:
                break
        out.append((start, last_comment))
        i = last_comment + 1
    return out


def classify(lines, start, end):
    """(n_comment_lines, code_ratio, double_commented)."""
    comments = [l for l in lines[start:end + 1] if is_comment(l)]
    if not comments:
        return 0, 0.0, False
    contents = [content_of(l) for l in comments]
    coded = sum(1 for c in contents if c and CODE_PAT.search(c))
    nonempty = sum(1 for c in contents if c)
    ratio = coded / nonempty if nonempty else 0.0
    doubled = any(l.strip().startswith("// //") for l in comments)
    return len(comments), ratio, doubled


def should_delete(n, ratio, doubled):
    if doubled and n >= 2:
        return True          # re-commented code, unambiguous
    if n >= 4 and ratio >= 0.55:
        return True
    if n >= 12 and ratio >= 0.4:
        return True          # long blocks are old file versions
    return False


def process(path, apply):
    raw = open(path, "rb").read().decode("utf-8")
    crlf = raw.count("\r\n")
    nl = "\r\n" if crlf > (raw.count("\n") - crlf) else "\n"
    lines = raw.replace("\r\n", "\n").split("\n")

    doomed = []
    for start, end in runs(lines):
        n, ratio, doubled = classify(lines, start, end)
        if not should_delete(n, ratio, doubled):
            continue
        # A run can pick up a prose note that belongs to the live code just
        # below it ("add this method" sitting above the method). Trim any
        # trailing comment lines that carry no code signal.
        e = end
        while e > start:
            line = lines[e]
            if line.strip() == "":
                e -= 1
                continue
            c = content_of(line)
            if c and CODE_PAT.search(c):
                break
            e -= 1
        if e > start:
            doomed.append((start, e, n, ratio))

    if not doomed:
        return 0, []

    removed = 0
    keep = [True] * len(lines)
    for start, end, n, _r in doomed:
        for k in range(start, end + 1):
            keep[k] = False
        removed += (end - start + 1)

    if apply:
        out = [l for l, k in zip(lines, keep) if k]
        # collapse 3+ blank lines left behind into one
        squashed = []
        blanks = 0
        for l in out:
            if l.strip() == "":
                blanks += 1
                if blanks > 2:
                    continue
            else:
                blanks = 0
            squashed.append(l)
        open(path, "wb").write(nl.join(squashed).encode("utf-8"))

    return removed, doomed


def main():
    apply = "--apply" in sys.argv
    total = 0
    files = 0
    report = []
    for root, _d, names in os.walk("lib"):
        for name in sorted(names):
            if not name.endswith(".dart"):
                continue
            path = os.path.join(root, name).replace(SEP, "/")
            removed, doomed = process(path, apply)
            if removed:
                files += 1
                total += removed
                report.append((path, removed, len(doomed)))

    for path, removed, blocks in sorted(report, key=lambda r: -r[1]):
        print("%-58s %5d lines in %d blocks" % (path, removed, blocks))
    print("")
    print("%s %d lines across %d files" % (
        "removed" if apply else "would remove", total, files))


if __name__ == "__main__":
    main()
