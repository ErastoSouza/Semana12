*** Settings ***
Resource          ../resources/api_keywords.robot
Suite Setup       Setup de Sessão da API

*** Test Cases ***
LOG-001: Realizar login com sucesso (Administrador)
    [Documentation]    Valida o login bem-sucedido de um usuário administrador.
    [Tags]    login    smoke
    &{credentials}=    Create Dictionary    email=fulano@qa.com    password=teste
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Sucesso    ${response}    200    Login realizado com sucesso
    ${token}=    Extrair Token de Autorização    ${response}
    Should Not Be Empty    ${token}

LOG-002: Realizar login com sucesso (Usuário Comum)
    [Documentation]    Valida o login bem-sucedido de um usuário comum.
    [Tags]    login    smoke
    ${resp_create}    ${payload}=    Cadastrar Novo Usuário na API
    ${credentials}=    Create Dictionary    email=${payload['email']}    password=${payload['password']}
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Sucesso    ${response}    200    Login realizado com sucesso

LOG-003: Tentar login com senha incorreta
    [Documentation]    Valida que o login falha com a senha errada.
    [Tags]    login    negative
    &{credentials}=    Create Dictionary    email=fulano@qa.com    password=senha_incorreta
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Erro    ${response}    401    Email e/ou senha inválidos

LOG-004: Tentar login com e-mail não cadastrado
    [Documentation]    Valida que o login falha com um e-mail que não existe.
    [Tags]    login    negative
    &{credentials}=    Create Dictionary    email=inexistente@email.com    password=qualquer_senha
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Erro    ${response}    401    Email e/ou senha inválidos

LOG-005: Tentar login com campo 'email' vazio
    [Documentation]    Valida a obrigatoriedade do campo email.
    [Tags]    login    negative
    &{credentials}=    Create Dictionary    email=${EMPTY}    password=senha_valida
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Erro    ${response}    400    email não pode ficar em branco

LOG-006: Tentar login com campo 'password' ausente
    [Documentation]    Valida a obrigatoriedade do campo password.
    [Tags]    login    negative
    &{credentials}=    Create Dictionary    email=usuario@email.com
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Erro    ${response}    400    password é obrigatório

LOG-007: Tentar login com formato de e-mail inválido
    [Documentation]    Valida o formato do campo de email.
    [Tags]    login    negative
    &{credentials}=    Create Dictionary    email=email-invalido    password=senha_valida
    ${response}=    Login de Usuário    ${credentials}
    Validar Resposta de Erro    ${response}    400    email deve ser um email válido
