*** Settings ***
Resource          ../resources/api_keywords.robot
Library           Collections 

Suite Setup       Setup de Sessão da API

*** Test Cases ***
USR-001: Cadastrar novo usuário comum com sucesso
    [Documentation]    Valida o cadastro de um novo usuário não-administrador.
    [Tags]    usuarios    smoke
    ${response}=    Cadastrar Novo Usuário na API
    Validar Resposta de Sucesso    ${response[0]}    201    Cadastro realizado com sucesso
    Dictionary Should Contain Key    ${response[0].json()}    _id

USR-002: Listar todos os usuários cadastrados
    [Documentation]    Valida a listagem de todos os usuários.
    [Tags]    usuarios    smoke
    ${response}=    GET On Session    serverest    /usuarios
    Status Should Be    200    ${response}
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    usuarios

USR-003: Tentar cadastrar usuário com e-mail já existente
    [Documentation]    Valida que não é possível cadastrar usuários com e-mails duplicados.
    [Tags]    usuarios    negative
    ${resp_create}    ${payload}=    Cadastrar Novo Usuário na API
    # Tenta cadastrar um novo usuário com o mesmo e-mail do anterior
    ${payload_dup}=    Copy Dictionary    ${payload}
    Set To Dictionary    ${payload_dup}    nome=Nome Duplicado
    ${response}=    POST On Session    serverest    /usuarios    json=${payload_dup}
    Validar Resposta de Erro    ${response}    400    Este email já está sendo usado

USR-004: Excluir um usuário com sucesso
    [Documentation]    Valida a exclusão de um usuário.
    [Tags]    usuarios    smoke
    ${resp_create}    ${payload}=    Cadastrar Novo Usuário na API
    ${user_id}=    Get From Dictionary    ${resp_create.json()}    _id
    ${response}=    DELETE On Session    serverest    /usuarios/${user_id}
    Validar Resposta de Sucesso    ${response}    200    Registro excluído com sucesso

USR-005: Tentar cadastrar usuário com senha abaixo do limite
    [Documentation]    Valida a regra de negócio do tamanho mínimo da senha.
    [Tags]    usuarios    negative    boundary
    ${payload}=    Create Dictionary
    ...    nome=Usuario Senha Curta
    ...    email=senha.curta@email.com
    ...    password=1234
    ...    administrador=false
    ${response}=    POST On Session    serverest    /usuarios    json=${payload}
    Validar Resposta de Erro    ${response}    400    password deve ter no mínimo 5 caracteres

USR-006: Tentar cadastrar usuário com senha acima do limite
    [Documentation]    Valida a regra de negócio do tamanho máximo da senha.
    [Tags]    usuarios    negative    boundary

    ${payload}=    Create Dictionary
    ...    nome=Usuario Senha Longa
    ...    email=senha.longa@email.com
    ...    password=12345678901
    ...    administrador=false
    ${response}=    POST On Session    serverest    /usuarios    json=${payload}
    Validar Resposta de Erro    ${response}    400    password deve ter no máximo 10 caracteres

USR-007: Atualizar dados de um usuário existente (PUT)
    [Documentation]    Valida a atualização dos dados de um usuário.
    [Tags]    usuarios    smoke
    ${resp_create}    ${payload}=    Cadastrar Novo Usuário na API
    ${user_id}=    Get From Dictionary    ${resp_create.json()}    _id
    ${update_payload}=    Create Dictionary
    ...    nome=Nome Atualizado Pelo Teste
    ...    email=${payload['email']}
    ...    password=${payload['password']}
    ...    administrador=${payload['administrador']}
    ${response}=    PUT On Session    serverest    /usuarios/${user_id}    json=${update_payload}
    Validar Resposta de Sucesso    ${response}    200    Registro alterado com sucesso

USR-008: Buscar um usuário por ID inexistente
    [Documentation]    Valida o tratamento de erro para IDs de usuário que não existem.
    [Tags]    usuarios    negative
    ${random_id}=    Generate Random String    12    [LOWER]
    ${response}=    GET On Session    serverest    /usuarios/${random_id}    expected_status=any
    Validar Resposta de Erro    ${response}    400    Usuário não encontrado

