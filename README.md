# nexus_engine

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Sobre esta cópia (versão v1.1.0)

Atualizei o projeto para alinhar as telas de gerenciamento de lojas ao schema
do Supabase (`public.lojas`) e adicionei melhorias práticas para facilitar o
cadastro e a sincronização de inventário.

- Versão: **v1.1.0** (2026-04-08)
- Resumo das mudanças principais:
  - Alinhamento das telas de cadastro e edição ao schema `public.lojas`.
  - Campos adicionados: `bairro`, `inscricao_municipal`, `telefone_suporte`.
  - CEP auto-fill via ViaCEP (separa logradouro e bairro) e botão de busca.
  - Adição de `Nome da Loja` e `CNPJ` com formatador/validador no formulário.
  - Refatoração de `StoreDetailScreen` para controladores explícitos e seções.
  - Importação CSV para `tabela_nexus` com upsert em lotes (mais robusta).

### Como testar rapidamente


1. Rode:

```bash
flutter pub get
flutter run -d chrome
```

2. No app, abra **Gerenciar Lojas**:
	- Crie uma nova loja (preencha `Nome da Loja`, `CNPJ`, CEP etc.).
	- Teste o botão de pesquisa de CEP ou insira um CEP e tire o foco do campo
	  para preencher endereço e bairro automaticamente.

3. Edite uma loja e use a opção de sincronizar CSV para importar inventário
	(verifique se o CSV tem `sku_id` como coluna obrigatória).

4. Confirme que o banco no Supabase recebeu os campos adicionais e que o
	`id` da loja foi gerado (UUID) e está relacionado aos registros em
	`tabela_nexus`.

Se quiser, posso criar um PR com estas mudanças, adicionar instruções mais
detalhadas, ou gerar um changelog separado para releases.

