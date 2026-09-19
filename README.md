# Brasileirão iOS App

## Visão Geral

Aplicativo iOS nativo para acompanhamento de jogos de futebol, desenvolvido com **SwiftUI** e as tecnologias mais recentes do ecossistema Apple, como parte do desafio de código da Globo.com.

## Funcionalidades

-   **Listagem de jogos:** Tela com a lista dos jogos e filtros dinâmicos controlados pela API.
-   **Detalhes da partida:** Visualização de detalhes da partida, incluindo placar, local e "Lance a Lance".
-   **Suporte Offline:** O aplicativo utiliza SwiftData para criar um cache local dos dados, permitindo que o usuário visualize os jogos mesmo sem conexão com a internet.
- **Atualização de Dados:** Capacidade de atualizar a lista de jogos via "Pull-to-Refresh" para buscar as últimas informações da API.
- **Carregamento de Imagens:** Carregamento assíncrono e cache dos escudos dos times usando Kingfisher.

## Arquitetura e Decisões de Design

-   **MVVM + Services:** A arquitetura principal é a Model-View-ViewModel, complementada por uma camada de Serviços para responsabilidades como rede e persistência, mantendo as Views e ViewModels limpas.
-   **Cliente de UI Guiada pelo Servidor (SDUI):** A tela de listagem de jogos é um "renderizador" flexível. Ela não possui lógica de filtro fixa; em vez disso, ela constrói a UI com base na estrutura de grupos enviada pela API. Isso permite que a forma de exibição dos jogos seja alterada remotamente.
-   **SwiftData como Cache e Fonte da Verdade:** O app sincroniza os dados da API com um banco de dados local robusto usando SwiftData. As telas de detalhes leem diretamente desta fonte de verdade local, garantindo a funcionalidade offline e a consistência dos dados.
-   **Internacionalização:** O aplicativo foi preparado para múltiplos idiomas (Inglês, Português, Espanhol) utilizando **String Catalogs (`.xcstrings`)**, a tecnologia moderna da Apple para localização. Todas as strings visíveis para o usuário, incluindo formatos de data relativa ("Hoje", "Amanhã"), foram abstraídas para chaves de localização, permitindo uma tradução fácil e garantindo que a formatação de datas e horas respeite as configurações regionais do dispositivo do usuário.
-   **Injeção de Dependência e Testabilidade:** O uso de protocolos (ex: `NetworkServiceProtocol`) e injeção de dependência no `ViewModel` permite que a lógica de negócio seja testada de forma isolada, "mocando" a camada de rede.

## Stack de Tecnologias

-   **Swift 5 / Xcode 16+**
-   **SwiftUI:** Para a construção declarativa da interface.
-   **SwiftData:** Para persistência local, cache e suporte offline.
-   **Swift Testing:** Framework moderno utilizado para os testes de unidade.
-   **Kingfisher:** Para carregamento e cache de imagens da rede de forma eficiente.
-   **Target Mínimo:** iOS 17.0

## Estrutura do Projeto

O código está organizado em pastas que refletem a arquitetura do aplicativo:
-   `App`: Ponto de entrada e configuração.
-   `Screens`: Contém as telas principais, com suas Views e ViewModels agrupados por funcionalidade.
-   `Components`: Views SwiftUI pequenas e reutilizáveis.
-   `Model`: As classes `@Model` do SwiftData.
-   `Service`: Onde reside a lógica de Rede, DTOs e a sincronização com o banco (DataUpdater).
-   `Extensions`: Extensões de tipos nativos para funcionalidades auxiliares.

## Como Rodar o Projeto

**Pré-requisitos:**
-   macOS com Xcode 16.0 ou superior.
-   A API do Brasileirão deve estar rodando localmente em `http://localhost:8080`.

**Passos:**
1.  Navegue até a pasta `ios-app/`.
2.  Abra o arquivo `Brasileirao.xcodeproj`.
3.  Selecione um simulador de iPhone (ex: iPhone 15 Pro) e clique em "Run" (ou `Command + R`).

## Testes

O projeto inclui testes de unidade para a lógica principal do `ViewModel`.
-   Os testes foram escritos com o novo framework **Swift Testing**.
-   A camada de rede é "mocada" para garantir que os testes de unidade sejam rápidos e independentes.

Para rodar os testes, abra o projeto no Xcode e pressione `Command + U`.

## **Consideração Importante: App Transport Security (ATS) Exception**

Ao tentar carregar os escudos dos times fornecidos pela `s.glbimg.com`, foi encontrado o erro **"The resource could not be loaded because the App Transport Security policy requires the use of a secure connection."**

* **Problema:** O iOS (a partir do iOS 9) exige por padrão que todas as conexões de rede usem HTTPS (`https://`) por motivos de segurança. Os URLs dos escudos da Globo.com fornecidos no desafio são HTTP (`http://`).
* **Solução para o Desafio (Workaround):** Para permitir o carregamento dessas imagens HTTP durante o desenvolvimento para este desafio, uma exceção de App Transport Security (ATS) foi adicionada à configuração do projeto (que é incorporada no `Info.plist` gerado).
    * A exceção permite que o aplicativo se conecte de forma insegura ao domínio `s.glbimg.com`.
    * Essa configuração pode ser encontrada em: **Project Navigator > Nome do Projeto (Target) > Aba "Info" > "App Transport Security Settings" > "Exception Domains" > `s.glbimg.com`**.
* **Como seria corrigido em um ambiente de produção:**
    1.  **Opção Recomendada (Ideal):** A forma correta e segura de resolver isso em um aplicativo de produção seria garantir que as URLs das imagens sejam fornecidas via **HTTPS**. Isso envolveria solicitar à fonte dos dados que forneça URLs HTTPS, ou usar um serviço de proxy/CDN que possa servir as imagens via HTTPS a partir da fonte HTTP original.
    2.  **Opção Alternativa (Se HTTPS Direto não for possível):** Se não for possível obter as imagens via HTTPS, uma API backend poderia baixar essas imagens, armazená-las em um servidor seguro (ex: AWS S3, Cloudinary) e então fornecer URLs HTTPS dessas imagens armazenadas para o aplicativo iOS. Esta abordagem centraliza o risco de segurança no backend e permite que o frontend se comunique sempre via HTTPS.

## Melhorias Futuras

Se houvesse mais tempo para evoluir este MVP, as seguintes melhorias seriam priorizadas:

-   **Testes de UI (XCUITest):** A estrutura para testes de UI foi criada, mas a implementação foi adiada para focar na entrega dos testes de unidade, que validam a lógica de negócio. Um próximo passo seria finalizar a injeção de dados mock para a suíte de UI Tests e validar os fluxos de navegação e interação do usuário de forma automatizada.
-   **Tratamento de Erros de UI:** Melhorar a experiência do usuário para diferentes cenários de erro (ex: mostrar uma tela específica para "sem conexão com a internet" em vez do alerta genérico).
-   **Acessibilidade:** Adicionar suporte completo a VoiceOver e Dynamic Type para garantir que o aplicativo seja acessível a todos os usuários.
-   **Migração de Dados (SwiftData):** Implementar um `SchemaMigrationPlan` para lidar com futuras alterações no modelo de dados de forma segura, sem que os usuários percam seus dados cacheados entre as atualizações do app.
-   **Animações e Transições:** Adicionar animações mais fluidas e transições customizadas entre as telas para refinar a experiência do usuário.