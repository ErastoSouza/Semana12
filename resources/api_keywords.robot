*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    BuiltIn 
Variables  variables.py

*** Keywords ***
Setup de Sessão da API
    [Documentation]    Cria uma sessão reutilizável para a API ServerRest.
    Create Session    serverest    ${BASE_URL}    disable_warnings=1

Login de Usuário
    [Arguments]    ${credentials}
    [Documentation]    Realiza o login de um usuário e retorna a resposta.
    ${response}=    POST On Session
    ...    serverest
    ...    /login
    ...    json=${credentials}
    ...    expected_status=any
    [Return]    ${response}

Extrair Token de Autorização
    [Arguments]    ${response}
    [Documentation]    Extrai o token 'authorization' do corpo da resposta.
    ${token}=    Get From Dictionary    ${response.json()}    authorization
    [Return]    ${token}

Cadastrar Novo Usuário na API
    [Arguments]    ${is_admin}=${False}
    [Documentation]    Cadastra um novo usuário (comum por padrão) e retorna a resposta.
    ${payload}=    Call Method    variables    get_new_user_payload    is_admin=${is_admin}

    ${response}=    POST On Session
    ...    serverest
    ...    /usuarios
    ...    json=${payload}
    ...    expected_status=any
    [Return]    ${response}    ${payload}

Validar Resposta de Erro
    [Arguments]    ${response}    ${expected_status}    ${expected_message}
    [Documentation]    Valida o status code e a mensagem de erro da resposta.
    Status Should Be    ${expected_status}    ${response}
    ${json_response}=    Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${json_response}    message    ${expected_message}

Validar Resposta de Sucesso
    [Arguments]    ${response}    ${expected_status}    ${expected_message}
    [Documentation]    Valida o status code e a mensagem de sucesso da resposta.
    Status Should Be    ${expected_status}    ${response}
    ${json_response}=    Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${json_response}    message    ${expected_message}

Cadastrar Novo Produto na API
    [Arguments]    ${auth_token}
    [Documentation]    Cadastra um novo produto usando um token de admin.
    ${payload}=    Call Method    variables    get_new_product_payload

    ${headers}=    Create Dictionary    Authorization=${auth_token}
    ${response}=    POST On Session
    ...    serverest
    ...    /produtos
    ...    json=${payload}
    ...    headers=${headers}
    ...    expected_status=any
    [Return]    ${response}    ${payload}

