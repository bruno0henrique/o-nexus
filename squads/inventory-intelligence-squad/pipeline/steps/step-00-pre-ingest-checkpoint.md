# Step 00 — Pre-ingest Checkpoint (Injeção de arquivo)

Objetivo:
- Permitir injetar um arquivo CSV externo na pasta `input/` antes da etapa de ingestão.

Como usar:
- Automático via arquivo de checkpoint:
  - Crie o arquivo `squads/inventory-intelligence-squad/output/pre_ingest_checkpoint.md` com a linha:

    inject_path: C:/caminho/para/arquivo.csv

  - Ao executar o runner (`tools/opensquad_runner.py`) com `--step ingest` ou `--step all`, o runner copiará o arquivo indicado para `squads/inventory-intelligence-squad/input/` (nome `injected_<basename>` se já existir um arquivo com mesmo nome).

- Via variável de ambiente (CI / automação):
  - Exporte `INJECT_FILE_PATH` apontando para o CSV antes de rodar o runner.

- Interativo (modo manual):
  - Se nenhum checkpoint nem variável estiverem presentes, o runner pedirá o caminho do CSV no prompt. Pressione Enter para pular e usar os CSVs já presentes em `input/`.

Observações:
- A injeção copia o arquivo para `input/` — o runner continuará selecionando o CSV mais recente naquele diretório.
- Este checkpoint é opcional; se não for usado, o comportamento antigo (usar o CSV mais recente em `input/`) permanece.
