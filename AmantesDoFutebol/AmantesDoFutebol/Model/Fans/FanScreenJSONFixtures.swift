import Foundation

/// JSON contracts shared by the in-process UI-test HTTP stub and model decoding tests.
enum FanScreenJSONFixtures {
    static let list = #"""
    {"screenId":"fan-list","screenTitle":"Amantes do Futebol","screenType":"LIST",
     "sections":[{"id":"fans","components":[{"id":"fanList","type":"FAN_LIST","titleField":"name","subtitleField":"favoriteTeamId",
       "subtitleOptionsSource":{"method":"GET","path":"/api/v1/teams","valueField":"id","labelField":"name"},"selectAction":"openFanDetails"}]}],
     "actions":[{"id":"createFan","title":"Adicionar fã","role":"NAVIGATE"}]}
    """#

    static let registration = form(title: "Cadastro de fã", actionId: "submit", actionTitle: "Cadastrar fã")
    static let edit = form(title: "Editar fã", actionId: "saveChanges", actionTitle: "Salvar alterações")

    static let detail = #"""
    {"screenId":"fan-detail","screenTitle":"Detalhes do fã","screenType":"DETAIL",
     "sections":[
       {"id":"personalData","title":"Dados pessoais","components":[
         {"id":"name","type":"VALUE","field":"name","label":"Nome"},
         {"id":"email","type":"VALUE","field":"email","label":"E-mail"},
         {"id":"birthDate","type":"VALUE","field":"birthDate","label":"Data de nascimento","format":"dd/MM/yyyy"},
         {"id":"age","type":"VALUE","field":"age","label":"Idade","format":"AGE"},
         {"id":"gender","type":"VALUE","field":"gender","label":"Gênero"}]},
       {"id":"preferences","title":"Preferências e rotina","components":[
         {"id":"favoriteTeamId","type":"VALUE","field":"favoriteTeamId","label":"Time favorito",
          "optionsSource":{"method":"GET","path":"/api/v1/teams","valueField":"id","labelField":"name"}},
         {"id":"location","type":"VALUE","fields":["city","state","country"],"label":"Localização","format":"LOCATION"},
         {"id":"stadiumFrequency","type":"VALUE","field":"stadiumFrequency","label":"Frequência no estádio"}]}],
     "actions":[{"id":"editFan","title":"Editar","role":"NAVIGATE"},
       {"id":"deleteFan","title":"Excluir","role":"DELETE","requiresConfirmation":true}]}
    """#

    static let teams = #"[{"id":"FLA","name":"Flamengo"},{"id":"PAL","name":"Palmeiras"}]"#

    static let sampleFan = #"{"id":1,"name":"Ana Silva","email":"ana@example.com","birthDate":"1990-02-03","gender":"Feminino","favoriteTeamId":"FLA","city":"Rio de Janeiro","state":"RJ","country":"Brasil","stadiumFrequency":"SEMPRE"}"#

    private static func form(title: String, actionId: String, actionTitle: String) -> String {
        #"""
        {"screenId":"\#(title == "Editar fã" ? "fan-edit" : "fan-registration")","screenTitle":"\#(title)","screenType":"FORM",
         "sections":[
           {"id":"personalData","title":"Dados pessoais","components":[
             {"id":"name","type":"TEXT_FIELD","field":"name","label":"Nome","required":true},
             {"id":"email","type":"TEXT_FIELD","field":"email","label":"E-mail","required":true,"keyboard":"EMAIL"},
             {"id":"birthDate","type":"DATE_FIELD","field":"birthDate","label":"Data de nascimento","required":true,"format":"dd/MM/yyyy"},
             {"id":"gender","type":"SELECT","field":"gender","label":"Gênero","required":true,
              "options":[{"id":"Feminino","label":"Feminino"},{"id":"Masculino","label":"Masculino"},{"id":"Não Binário","label":"Não Binário"}]}]},
           {"id":"preferences","title":"Preferências e rotina","components":[
             {"id":"favoriteTeamId","type":"SELECT","field":"favoriteTeamId","label":"Time favorito","required":true,
              "optionsSource":{"method":"GET","path":"/api/v1/teams","valueField":"id","labelField":"name"}},
             {"id":"city","type":"TEXT_FIELD","field":"city","label":"Cidade","required":true},
             {"id":"state","type":"TEXT_FIELD","field":"state","label":"Estado","required":true},
             {"id":"country","type":"TEXT_FIELD","field":"country","label":"País","required":true},
             {"id":"stadiumFrequency","type":"SELECT","field":"stadiumFrequency","label":"Frequência no estádio","required":true,
              "options":[{"id":"SEMPRE","label":"Sempre"},{"id":"AS_VEZES","label":"Às vezes"},{"id":"RARAMENTE","label":"Raramente"},{"id":"NUNCA","label":"Nunca"}]}]}],
         "actions":[{"id":"\#(actionId)","title":"\#(actionTitle)","role":"SUBMIT"}]}
        """#
    }
}
