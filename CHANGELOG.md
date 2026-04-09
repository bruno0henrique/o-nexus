# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-04-08
### Added
- Inicial commit do Nexus Engine
- Telas: login, admin, inventory, statistics, logistics
- Integração inicial com Supabase (AdminService)
- Registro de loja (store registration) com cópia de ID
- Correções para evitar `Symbol(dartx.map)` no Flutter Web
- Banner de ID no topbar (Admin Mode)

## [1.1.0] - 2026-04-08
### Added / Atualizações
- Alinhamento das telas de cadastro e edição de loja ao schema `public.lojas` do Supabase.
- Campos adicionados: `bairro`, `inscricao_municipal`, `telefone_suporte`.
- Autopreenchimento de CEP via ViaCEP (separa logradouro e bairro) e botão manual de busca.
- Adicionados campos `Nome da Loja` e `CNPJ` no formulário de registro, com formatador e validador.
- Correção do `FocusNode` do campo CEP para evitar LateInitializationError.
- Refatoração de `StoreDetailScreen`: controladores explícitos, seções (Identificação Fiscal, Localização, Contato e Gestão, Configurações) e payload de UPDATE completo.
- Melhoria na importação CSV para `tabela_nexus` com upsert em lotes.

### Notas
- Rode `flutter pub get` se necessário e execute o app para testar as telas de Gerenciar Lojas, criação/edição e importação CSV.

Versão: v1.1.0

