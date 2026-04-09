#!/usr/bin/env python3
import argparse
import csv
import glob
import json
import os
import sys
from pathlib import Path
from datetime import datetime

def ingest_latest_csv(squad_path: Path, run_dir: Path):
	input_dir = squad_path / 'input'
	output_dir = run_dir
	output_dir.mkdir(parents=True, exist_ok=True)

	pattern = str(input_dir / '*.csv')
	files = glob.glob(pattern)
	if not files:
		print('Nenhum arquivo CSV encontrado em', input_dir)
		return 1

	latest = max(files, key=os.path.getmtime)
	print('Arquivo CSV selecionado:', latest)

	rows = []
	with open(latest, newline='', encoding='utf-8') as f:
		reader = csv.DictReader(f)
		for r in reader:
			rows.append(r)

	out_path = output_dir / 'raw_ingested_data.json'
	with open(out_path, 'w', encoding='utf-8') as out:
		json.dump(rows, out, ensure_ascii=False, indent=2)

	print('Ingestão completa. Saída:', out_path)
	return 0


def pre_ingest_checkpoint(squad_path: Path, run_dir: Path):
	"""Optional first checkpoint: allow the operator to inject a CSV file
	into the squad `input/` before ingestion. The checkpoint can be provided
	via environment variable `INJECT_FILE_PATH` or via a file
	`output/pre_ingest_checkpoint.md` containing a line `inject_path: ...`.

	If neither is present, the function prompts the user (interactive).
	The injected file is copied into `input/` and named `injected_<basename>`
	if a file with the same name already exists.
	"""
	import shutil
	import os

	input_dir = squad_path / 'input'
	input_dir.mkdir(parents=True, exist_ok=True)

	# 1) check env
	inject = os.getenv('INJECT_FILE_PATH')

	# 2) check checkpoint file
	cp = squad_path / 'output' / 'pre_ingest_checkpoint.md'
	if not inject and cp.exists():
		with open(cp, 'r', encoding='utf-8') as f:
			for line in f:
				if line.strip().startswith('inject_path:'):
					inject = line.split(':', 1)[1].strip()
					break

	# 3) interactive prompt if still not set
	if not inject:
		try:
			inject = input('Pre-ingest checkpoint — caminho do CSV para injetar (Enter para pular): ').strip()
		except Exception:
			inject = ''

	if not inject:
		print('Nenhuma injeção de arquivo solicitada; seguindo com o diretório `input/`.')
		return 0

	src = Path(inject)
	if not src.exists():
		print('Arquivo para injeção não encontrado:', src)
		return 2

	dest_name = src.name
	dest = input_dir / dest_name
	if dest.exists():
		dest = input_dir / f'injected_{dest_name}'

	try:
		shutil.copy2(src, dest)
		print('Arquivo injetado em', dest)
		return 0
	except Exception as e:
		print('Falha ao copiar arquivo de injeção:', e)
		return 3


def main():
	p = argparse.ArgumentParser(description='Opensquad runner (minimal)')
	p.add_argument('--squad', required=True, help='Caminho relativo para a pasta do squad')
	p.add_argument('--step', choices=['ingest','sanitize','audit','all'], default='ingest')
	p.add_argument('--run-name', help='Nome da pasta de execução (opcional)')
	args = p.parse_args()

	squad_path = Path(args.squad)
	if not squad_path.exists():
		print('Squad não encontrado:', squad_path)
		sys.exit(2)

	# Determine run_name: CLI arg > ENV RUN_NAME > pre_ingest_checkpoint.md > timestamp
	run_name = None
	if args.run_name:
		run_name = args.run_name
	elif os.getenv('RUN_NAME'):
		run_name = os.getenv('RUN_NAME')
	else:
		cp = squad_path / 'output' / 'pre_ingest_checkpoint.md'
		if cp.exists():
			try:
				with open(cp, 'r', encoding='utf-8') as f:
					for line in f:
						if line.strip().startswith('run_name:'):
							run_name = line.split(':',1)[1].strip()
							break
			except Exception:
				pass
	if not run_name:
		run_name = datetime.now().strftime('%Y-%m-%d-%H%M%S')

	run_dir = squad_path / 'output' / run_name
	run_dir.mkdir(parents=True, exist_ok=True)
	(run_dir / 'v1').mkdir(parents=True, exist_ok=True)

	def sanitize_data(squad_path: Path, run_dir: Path):
		raw = run_dir / 'raw_ingested_data.json'
		out = run_dir / 'v1' / 'sanitized_data.json'
		if not raw.exists():
			print('Arquivo raw_ingested_data.json não encontrado, execute ingest primeiro.')
			return 2
		import json
		with open(raw, 'r', encoding='utf-8') as f:
			rows = json.load(f)

		# Basic sanitization: trim strings, infer numeric columns and convert
		if not rows:
			print('Nenhum registro para sanitizar.')
			with open(out, 'w', encoding='utf-8') as o:
				json.dump([], o, ensure_ascii=False, indent=2)
			return 0

		# Determine numeric-like columns
		cols = list(rows[0].keys())
		numeric_cols = set()
		for c in cols:
			all_numeric = True
			for r in rows:
				v = r.get(c, '')
				if v is None or v == '':
					continue
				try:
					float(str(v).replace(',','').replace('€','').replace('$',''))
				except Exception:
					all_numeric = False
					break
			if all_numeric:
				numeric_cols.add(c)

		sanitized = []
		for r in rows:
			nr = {}
			for k, v in r.items():
				if isinstance(v, str):
					v2 = v.strip()
				else:
					v2 = v
				if k in numeric_cols and v2 not in (None, ''):
					try:
						nr[k] = float(str(v2).replace(',','').replace('€','').replace('$',''))
					except Exception:
						nr[k] = v2
				else:
					nr[k] = v2
			sanitized.append(nr)

		with open(out, 'w', encoding='utf-8') as o:
			json.dump(sanitized, o, ensure_ascii=False, indent=2)
		# Also copy sanitized to run root for backward compatibility
		with open(run_dir / 'sanitized_data.json', 'w', encoding='utf-8') as o2:
			json.dump(sanitized, o2, ensure_ascii=False, indent=2)
		print('Sanitização completa. Saída:', out)
		return 0

	def audit_data(squad_path: Path, run_dir: Path):
		import json
		san = run_dir / 'v1' / 'sanitized_data.json'
		out = run_dir / 'v1' / 'audit_results.json'
		if not san.exists():
			print('Arquivo sanitized_data.json não encontrado, execute sanitize primeiro.')
			return 2
		with open(san, 'r', encoding='utf-8') as f:
			rows = json.load(f)

		audit = {}
		audit['row_count'] = len(rows)
		if rows:
			cols = list(rows[0].keys())
			missing = {c: 0 for c in cols}
			for r in rows:
				for c in cols:
					if r.get(c) in (None, '', []):
						missing[c] += 1
			audit['missing_per_column'] = missing

			# simple anomaly detection: numeric columns with negative or zero values
			anomalies = []
			for i, r in enumerate(rows):
				for c, v in r.items():
					if isinstance(v, (int, float)):
						if v <= 0:
							anomalies.append({'row': i, 'column': c, 'value': v})
			audit['anomalies_sample'] = anomalies[:20]
		else:
			audit['missing_per_column'] = {}
			audit['anomalies_sample'] = []

		with open(out, 'w', encoding='utf-8') as o:
			json.dump(audit, o, ensure_ascii=False, indent=2)
		# write audit to run root for compatibility
		with open(run_dir / 'audit_results.json', 'w', encoding='utf-8') as o2:
			json.dump(audit, o2, ensure_ascii=False, indent=2)
		print('Auditoria completa. Saída:', out)
		return 0

	if args.step == 'ingest' or args.step == 'all':
		# Run pre-ingest checkpoint to allow injecting a CSV before ingest
		code = pre_ingest_checkpoint(squad_path, run_dir)
		if code != 0 and code != 2:
			pass
		code = ingest_latest_csv(squad_path, run_dir)
		if code != 0:
			 sys.exit(code)
	if args.step == 'sanitize' or args.step == 'all':
		code = sanitize_data(squad_path, run_dir)
		if code != 0:
			sys.exit(code)
	if args.step == 'audit' or args.step == 'all':
		code = audit_data(squad_path, run_dir)
		if code != 0:
			sys.exit(code)

	# Para agora, só implementamos 'ingest'. Passos subsequentes podem ser implementados se desejar.
	print('Runner finalizado.')

if __name__ == '__main__':
	main()
