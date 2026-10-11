# Amantes do Futebol (iOS — SDUI)

Aplicativo iOS de cadastro e pesquisa acadêmica sobre pessoas fãs de futebol. Compartilha os dados e as funcionalidades do cliente CDUI; a estrutura das telas é recebida da API SDUI e renderizada pelo app. O cliente controla navegação e executa as operações de dados.

## Funcionalidades

- Lista de fãs com nome e time favorito, atualizável por gesto de atualização.
- Cadastro pelo botão flutuante **+**.
- Detalhes do fã com data em `DD/MM/AAAA` e idade calculada.
- Edição iniciada pelo botão **Editar**.
- Exclusão iniciada pelo botão **Excluir**, com confirmação.
- Dados: nome, e-mail, nascimento, gênero, time favorito, cidade, estado, país e frequência no estádio.
- Times carregados de `/api/v1/teams`; gêneros Feminino, Masculino e Não Binário.

## Arquitetura SDUI

A API fornece definições para lista, cadastro, detalhes e edição. O app interpreta os componentes `FAN_LIST`, `TEXT_FIELD`, `DATE_FIELD`, `SELECT` e `VALUE`. As opções de times são consultadas na fonte indicada pela configuração. A navegação, validação local, formatação da data e chamadas CRUD permanecem no cliente.

## Executar

Inicie a API SDUI em `http://localhost:8080` e abra `AmantesDoFutebol/AmantesDoFutebol.xcodeproj` no Xcode. O scheme compartilhado é `AmantesDoFutebol`. Requisitos: Xcode 16 ou superior e iOS 17 ou superior.

## Endpoints consumidos

- Configuração de telas: `/api/v1/ui/fans/list-screen`, `/api/v1/ui/fans/registration-screen`, `/api/v1/ui/fans/{id}/detail-screen` e `/api/v1/ui/fans/{id}/edit-screen`.
- Dados: `/api/v1/fans`, `/api/v1/fans/{id}` e `/api/v1/teams`.
- Operações: `POST /api/v1/fans`, `PUT /api/v1/fans/{id}` e `DELETE /api/v1/fans/{id}`.

A data é enviada à API em `AAAA-MM-DD` e apresentada ao usuário em `DD/MM/AAAA`. A frequência usa os valores `SEMPRE`, `AS_VEZES`, `RARAMENTE` e `NUNCA`.

## Testes

Execute a suíte pelo Xcode com `Command + U` ou pelo terminal:

```sh
xcodebuild test -project AmantesDoFutebol/AmantesDoFutebol.xcodeproj \
  -scheme AmantesDoFutebol \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Os testes não exigem a API nem o banco de dados em execução. Os UI tests iniciam o app com `--ui-testing`; nesse modo, um `URLProtocol` fornece respostas JSON determinísticas ao `FanAPIService` real. Os contratos JSON são compartilhados com os testes de decodificação para reduzir divergências entre as telas simuladas e o parsing do cliente.
