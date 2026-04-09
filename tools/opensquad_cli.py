#!/usr/bin/env python3
import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQUADS_DIR = ROOT / 'squads'
MEMORY_DIR = ROOT / '_opensquad' / '_memory'
COMPANY_FILE = MEMORY_DIR / 'company.md'
PREFERENCES_FILE = MEMORY_DIR / 'preferences.md'


def list_squads():
    if not SQUADS_DIR.exists():
        return []
    items = []
    for p in SQUADS_DIR.iterdir():
        if p.is_dir():
            items.append(p.name)
    return items


def show_main_menu():
    print('\nOpções Opensquad:')
    print('1. Create a new squad')
    print('2. Run an existing squad')
    print('3. My squads')
    print('4. More options')
    print('\nType a number or a command (e.g. "/opensquad run <name>")')


def handle_command(cmd: str):
    cmd = cmd.strip()
    if cmd.startswith('/opensquad'):
        parts = cmd.split()
        if len(parts) == 1:
            show_main_menu()
            return 0
        action = parts[1]
        if action == 'help':
            print('Use: /opensquad, /opensquad run <name>, /opensquad list')
            return 0
        if action == 'list':
            squads = list_squads()
            if not squads:
                print('Nenhum squad encontrado.')
            else:
                print('Squads:')
                for s in squads:
                    print('-', s)
            return 0
        if action == 'run' and len(parts) >= 3:
            name = parts[2]
            squad_path = SQUADS_DIR / name
            if not squad_path.exists():
                print('Squad não encontrado:', name)
                return 2
            print('Executando runner para squad:', name)
            # call the runner script
            runner = ROOT / 'tools' / 'opensquad_runner.py'
            proc = subprocess.run(['python', str(runner), '--squad', str(squad_path), '--step', 'ingest'], capture_output=True, text=True)
            print(proc.stdout)
            if proc.returncode != 0:
                print('Runner retornou código', proc.returncode)
                print(proc.stderr)
            return proc.returncode
        print('Comando não reconhecido:', cmd)
        return 3
    else:
        # numeric menu choices
        if cmd == '1':
            print('Fluxo de criação de squad não implementado aqui.')
            return 0
        if cmd == '2':
            squads = list_squads()
            if not squads:
                print('Nenhum squad disponível para rodar.')
                return 0
            print('Escolha um squad:')
            for i, s in enumerate(squads, 1):
                print(f"{i}. {s}")
            return 0
        if cmd == '3':
            squads = list_squads()
            if not squads:
                print('Nenhum squad encontrado.')
            else:
                print('Meus squads:')
                for s in squads:
                    print('-', s)
            return 0
        if cmd == '4':
            print('Mais opções: skills, edit-company, settings, help')
            return 0
        print('Entrada não reconhecida.')
        return 4


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--cmd', help='Execute a single command (ex: "/opensquad")')
    args = p.parse_args()

    if args.cmd:
        code = handle_command(args.cmd)
        raise SystemExit(code)

    # Interactive mode
    print('Welcome to Opensquad (CLI)')
    if not COMPANY_FILE.exists() or not PREFERENCES_FILE.exists():
        print('\nAviso: company.md ou preferences.md ausente. Rode /opensquad edit-company para configurar.')
    show_main_menu()
    try:
        while True:
            inp = input('\n> ').strip()
            if inp in ('quit', 'exit'):
                print('Saindo.')
                break
            handle_command(inp)
    except KeyboardInterrupt:
        print('\nSaindo.')


if __name__ == '__main__':
    main()
