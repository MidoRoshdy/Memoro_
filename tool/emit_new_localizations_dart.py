#!/usr/bin/env python3
"""Emit Dart snippets for newly merged AppLocalizations keys only."""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("merge_l10n", ROOT / "tool" / "merge_l10n.py")
mod = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(mod)
EXTRA_EN = mod.EXTRA_EN
EXTRA_AR = mod.EXTRA_AR

METHODS = {
    "medMedicationsCount": "medMedicationsCount(int count)",
    "medProgressFraction": "medProgressFraction(int current, int total)",
    "notifDoseAt": "notifDoseAt(String time)",
    "callMember": "callMember(String name)",
    "familyMemberEncouragement": "familyMemberEncouragement(String name)",
}


def dart_quote(s: str) -> str:
    return (
        s.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
        .replace("\r", "")
        .replace("$", "\\$")
    )


def dart_quote_template(s: str) -> str:
    """Like dart_quote but keep $ for `${name}` interpolation."""
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "")


def abstract_block() -> str:
    lines: list[str] = []
    for k in sorted(EXTRA_EN.keys()):
        if k.startswith("@"):
            continue
        v = str(EXTRA_EN[k])
        doc = v.replace("\n", " ").replace("'", "\\'")[:120]
        if k in METHODS:
            lines.append(f"  /// **'{doc}'**")
            lines.append(f"  String {METHODS[k]};")
        else:
            lines.append(f"  /// **'{doc}'**")
            lines.append(f"  String get {k};")
    return "\n".join(lines)


def dart_template_from_arb(v: str) -> str:
    """ARB ICU placeholders {name} -> Dart string interpolation ${name}."""
    t = v.replace("{count}", "${count}")
    t = t.replace("{current}", "${current}")
    t = t.replace("{total}", "${total}")
    t = t.replace("{time}", "${time}")
    t = t.replace("{name}", "${name}")
    return dart_quote_template(t)


def impl_block(extra: dict[str, str]) -> str:
    lines: list[str] = []
    for k in sorted(extra.keys()):
        if k.startswith("@"):
            continue
        v = str(extra[k])
        if k == "medMedicationsCount":
            lines.append(
                "  @override\n  String medMedicationsCount(int count) => "
                f"'{dart_template_from_arb(v)}';"
            )
        elif k == "medProgressFraction":
            lines.append(
                "  @override\n  String medProgressFraction(int current, int total) => "
                f"'{dart_template_from_arb(v)}';"
            )
        elif k == "notifDoseAt":
            lines.append(
                "  @override\n  String notifDoseAt(String time) => " f"'{dart_template_from_arb(v)}';"
            )
        elif k == "callMember":
            lines.append(
                "  @override\n  String callMember(String name) => " f"'{dart_template_from_arb(v)}';"
            )
        elif k == "familyMemberEncouragement":
            lines.append(
                "  @override\n  String familyMemberEncouragement(String name) => "
                f"'{dart_template_from_arb(v)}';"
            )
        else:
            lines.append(f"  @override\n  String get {k} => '{dart_quote(v)}';")
    return "\n\n".join(lines) + "\n"


def main() -> None:
    out = ROOT / "tool" / "_generated_l10n_snippets.txt"
    out.write_text(
        "=== ABSTRACT (after submitLabel) ===\n"
        + abstract_block()
        + "\n\n=== AppLocalizationsEn ===\n"
        + impl_block(EXTRA_EN)
        + "\n=== AppLocalizationsAr ===\n"
        + impl_block(EXTRA_AR),
        encoding="utf-8",
    )
    print("Wrote", out, "lines", len(out.read_text().splitlines()))


if __name__ == "__main__":
    main()
