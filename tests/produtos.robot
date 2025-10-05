*** Settings ***
Resource          ../resources/api_keywords.robot
Library           Collections 

Suite Setup       Setup de Sessão da API

*** Variables ***
&{ADMIN_CREDENTIALS}    email=fulano@qa.com    password=teste

*** Test Cases ***
PROD-001: Cadastrar novo produto com sucesso
    [Documentation]    Valida o cadastro de um novo produto por um admin.
    [Tags]    produtos    smoke
    ${resp_login}=    Login de Usuário    ${ADMIN_CREDENTIALS}
    ${token}=    Extrair Token de Autorização    ${resp_login}
    ${response}=    Cadastrar Novo Produto na API    ${token}
    Validar Resposta de Sucesso    ${response[0]}    201    Cadastro realizado com sucesso
    Dictionary Should Contain Key    ${response[0].json()}    _id

PROD-002: Tentar cadastrar produto sem autenticação
    [Documentation]    Valida que não é possível cadastrar produtos sem um token.
    [Tags]    produtos    negative    security
    # --- CORREÇÃO AQUI: Montamos o payload manualmente ---
    ${payload}=    Create Dictionary
    ...    nome=Produto Sem Auth
    ...    preco=150
    ...    descricao=Desc
    ...    quantidade=20
    ${response}=    POST On Session    serverest    /produtos    json=${payload}    expected_status=any
    Validar Resposta de Erro    ${response}    401    Token de acesso ausente, inválido ou expirado

PROD-003: Tentar cadastrar produto com usuário comum
    [Documentation]    Valida que um usuário comum não pode cadastrar produtos.
    [Tags]    produtos    negative    security
    ${resp_user}    ${payload_user}=    Cadastrar Novo Usuário na API
    ${credentials}=    Create Dictionary    email=${payload_user['email']}    password=${payload_user['password']}
    ${resp_login}=    Login de Usuário    ${credentials}
    ${token}=    Extrair Token de Autorização    ${resp_login}
    ${headers}=    Create Dictionary    Authorization=${token}
    # --- CORREÇÃO AQUI: Montamos o payload manualmente ---
    ${payload_prod}=    Create Dictionary
    ...    nome=Produto User Comum
    ...    preco=200
    ...    descricao=Desc
    ...    quantidade=10
    ${response}=    POST On Session    serverest    /produtos    json=${payload_prod}    headers=${headers}    expected_status=any
    Validar Resposta de Erro    ${response}    403    Rota exclusiva para administradores

PROD-004: Tentar cadastrar produto com nome duplicado
    [Documentation]    Valida que não é possível cadastrar produtos com nomes duplicados.
    [Tags]    produtos    negative
    ${resp_login}=    Login de Usuário    ${ADMIN_CREDENTIALS}
    ${token}=    Extrair Token de Autorização    ${resp_login}
    ${resp_prod}    ${payload_prod}=    Cadastrar Novo Produto na API    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    # Tenta cadastrar o mesmo produto novamente
    ${response}=    POST On Session    serverest    /produtos    json=${payload_prod}    headers=${headers}    expected_status=any
    Validar Resposta de Erro    ${response}    400    Já existe produto com esse nome

PROD-005: Listar todos os produtos cadastrados
    [Documentation]    Valida a listagem de todos os produtos.
    [Tags]    produtos    smoke
    ${response}=    GET On Session    serverest    /produtos
    Status Should Be    200    ${response}
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    produtos

PROD-006: Tentar cadastrar produto com campo obrigatório ausente
    [Documentation]    Valida a obrigatoriedade do campo nome.
    [Tags]    produtos    negative
    ${resp_login}=    Login de Usuário    ${ADMIN_CREDENTIALS}
    ${token}=    Extrair Token de Autorização    ${resp_login}
    # --- CORREÇÃO AQUI: Montamos o payload manualmente ---
    ${payload}=    Create Dictionary
    ...    preco=100
    ...    descricao=Desc
    ...    quantidade=50
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response}=    POST On Session    serverest    /produtos    json=${payload}    headers=${headers}    expected_status=any
    Validar Resposta de Erro    ${response}    400    nome é obrigatório

PROD-007: Tentar cadastrar produto com tipo de dado inválido
    [Documentation]    Valida o tipo de dado do campo 'preco'.
    [Tags]    produtos    negative
    ${resp_login}=    Login de Usuário    ${ADMIN_CREDENTIALS}
    ${token}=    Extrair Token de Autorização    ${resp_login}
    # --- CORREÇÃO AQUI: Montamos o payload manualmente ---
    ${payload}=    Create Dictionary
    ...    nome=Produto Preco Invalido
    ...    preco=cem_reais
    ...    descricao=Desc
    ...    quantidade=15
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response}=    POST On Session    serverest    /produtos    json=${payload}    headers=${headers}    expected_status=any
    Validar Resposta de Erro    ${response}    400    preco deve ser um número

PROD-008: Tentar excluir um produto que faz parte de um carrinho
    [Documentation]    Valida que um produto em um carrinho não pode ser excluído.
    [Tags]    produtos    negative    integration
    # --- SETUP ---
    # 1. Login como Admin para obter token de admin
    ${resp_login_admin}=    Login de Usuário    ${ADMIN_CREDENTIALS}
    ${token_admin}=    Extrair Token de Autorização    ${resp_login_admin}
    # 2. Cadastrar um novo produto com o token de admin
    ${resp_prod}    ${payload_prod}=    Cadastrar Novo Produto na API    ${token_admin}
    ${product_id}=    Get From Dictionary    ${resp_prod.json()}    _id
    # 3. Cadastrar um novo usuário comum
    ${resp_user}    ${payload_user}=    Cadastrar Novo Usuário na API
    # 4. Login como usuário comum para obter seu token
    ${credentials_user}=    Create Dictionary    email=${payload_user['email']}    password=${payload_user['password']}
    ${resp_login_user}=    Login de Usuário    ${credentials_user}
    ${token_user}=    Extrair Token de Autorização    ${resp_login_user}
    # 5. Adicionar o produto ao carrinho do usuário comum
    ${cart_payload}=    Create Dictionary    produtos=${{[Create Dictionary    idProduto=${product_id}    quantidade=1]}}
    ${headers_user}=    Create Dictionary    Authorization=${token_user}
    POST On Session    serverest    /carrinhos    json=${cart_payload}    headers=${headers_user}
    # --- ACTION ---
    # 6. Tentar excluir o produto usando o token de admin
    ${headers_admin}=    Create Dictionary    Authorization=${token_admin}
    ${response}=    DELETE On Session    serverest    /produtos/${product_id}    headers=${headers_admin}    expected_status=any
    # --- VALIDATION ---
    Validar Resposta de Erro    ${response}    400    Não é permitido excluir produto que faz parte de carrinho

