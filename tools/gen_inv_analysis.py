import json, pathlib, sys

run_id = sys.argv[1] if len(sys.argv) > 1 else "2026-04-08-040742"
dest = pathlib.Path(f"squads/inventory-intelligence-squad/output/{run_id}")
v1 = dest / "v1"

audit = json.loads((v1 / "audit_results.json").read_text(encoding="utf-8"))
san   = json.loads((v1 / "sanitized_data.json").read_text(encoding="utf-8"))
raw   = json.loads((v1 / "raw_ingested_data.json").read_text(encoding="utf-8"))

inv = {
    "run_id": run_id,
    "loja_id": "ba16d5e2-4ca7-4fc3-8eae1-80985948df59",
    "raw": raw,
    "sanitized": san,
    "audit": audit
}
out = json.dumps(inv, ensure_ascii=False, indent=2)
(v1 / "inventory_analysis.json").write_text(out, encoding="utf-8")
(dest / "inventory_analysis.json").write_text(out, encoding="utf-8")
print(f"inventory_analysis.json gerado em {dest}")
