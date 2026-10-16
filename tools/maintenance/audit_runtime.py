"""Audit the issue-26 relocation against its immutable baseline (Python stdlib)."""
from pathlib import Path
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = json.loads((ROOT / "tools/maintenance/runtime-layout.json").read_text(encoding="utf-8"))
TEXT = {".gd", ".tscn", ".tres", ".gdshader", ".gdshaderinc", ".godot", ".py", ".ps1", ".json", ".cfg"}

def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])

def main():
    baseline = MANIFEST["baseline"]
    renames = MANIFEST["renames"]
    removed = set(MANIFEST["removed"])
    original = [p for p in git("ls-tree", "-r", "--name-only", baseline).decode().splitlines()]
    errors, preserved, assets = [], [], []
    # Read a single Git archive rather than one process per resource.
    import io, tarfile
    with tarfile.open(fileobj=io.BytesIO(git("archive", baseline)), mode="r:") as archive:
        for old in original:
            if old.startswith("docs/") or old == "README.md" or old in removed:
                continue
            new = renames.get(old, old)
            target = ROOT / new
            if not target.is_file():
                errors.append("Missing retained file: " + new)
                continue
            source = archive.extractfile(old).read()
            actual = target.read_bytes()
            if Path(old).suffix in TEXT:
                expected = source.decode("utf-8-sig").replace("\r\n", "\n")
                for before, after in sorted(renames.items(), key=lambda item: -len(item[0])):
                    expected = expected.replace(before, after)
                actual_text = actual.decode("utf-8-sig").replace("\r\n", "\n")
                if actual_text != expected:
                    errors.append("Change beyond path relocation: " + new)
            elif actual != source:
                errors.append("Binary/UID changed: " + new)
            preserved.append(new)
            if old.startswith(("assets/", "art/source/")):
                assets.append(new)
    for retired in removed:
        if (ROOT / retired).exists():
            errors.append("Retired file still present: " + retired)
    for old in renames:
        if (ROOT / old).exists():
            errors.append("Old path still present: " + old)
    # Conservative closure: literal res paths, implicit global GDScript types,
    # and ResourceLoader dependencies (including serialized binary .res scripts).
    texts = {}
    for folder in ("scripts", "scenes", "config", "shaders", "materials", "tests", "tools"):
        for path in (ROOT / folder).rglob("*"):
            if path.is_file() and path.suffix in TEXT:
                texts[path.relative_to(ROOT).as_posix()] = path.read_text(encoding="utf-8-sig")
    texts["project.godot"] = (ROOT / "project.godot").read_text(encoding="utf-8")
    classes = {match.group(1): p for p, text in texts.items()
               if p.endswith(".gd") and (match := re.search(r"^class_name\s+(\w+)", text, re.M))}
    graph = {p: set(re.findall(r"res://([\w./-]+)", text)) |
             {classes[word] for word in set(re.findall(r"\b\w+\b", text)) & classes.keys()}
             for p, text in texts.items()}
    resource_file = ROOT / "work/issue26/resources.json"
    if not resource_file.exists():
        raise SystemExit("Run tests/run_runtime_resources.gd first for binary dependencies")
    resources = json.loads(resource_file.read_text(encoding="utf-8"))
    errors.extend(resources["failures"])
    for path, deps in resources["dependencies"].items():
        graph.setdefault(path, set()).update(deps)
    def closure(roots):
        seen, todo = set(), list(roots)
        while todo:
            path = todo.pop()
            if path in seen:
                continue
            seen.add(path)
            todo.extend(graph.get(path, set()) - seen)
        return seen
    active = closure(["project.godot"])
    regression = closure([p for p in texts if p.startswith("tests/")]) - active
    source_tools = sorted(p for p in original if p.startswith(("tools/p6a37/", "tools/p6a50/", "art/source/")))
    dynamic_prefixes = []
    for owner, deps in graph.items():
        for dep in deps:
            if dep.startswith(("work/", ".godot/")):
                continue  # generated outputs, not imported resources
            if not (ROOT / dep).exists():
                target = ROOT / dep
                if target.parent.is_dir() and any(target.parent.glob(target.name + "*")):
                    dynamic_prefixes.append({"owner": owner, "prefix": dep})
                else:
                    errors.append(f"Missing reference: {owner} -> {dep}")
    result = {"baseline": baseline, "relocated_files": len(renames), "removed_files": len(removed),
              "preserved_files_checked": len(preserved), "asset_source_files_unchanged": len(assets),
              "resource_load_checks": resources["checks"], "errors": sorted(set(errors)),
              "active": sorted(active), "regression_only": sorted(regression),
              "source_tools": source_tools, "removed": sorted(removed), "dynamic_prefixes": dynamic_prefixes,
              "limits": "Conservative static graph plus Godot dependencies; native tests cover dynamic factories. Historical assets and source provenance remain unchanged."}
    output = ROOT / "work/issue26/audit.json"
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps({k:v for k,v in result.items() if not isinstance(v,list) or k=="errors"}, ensure_ascii=False))
    raise SystemExit(1 if errors else 0)

if __name__ == "__main__":
    main()
