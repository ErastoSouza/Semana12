from faker import Faker

fake = ('pt_BR')


BASE_URL = "http://localhost:3000"

def get_variables():
    """Retorna um dicionário com as variáveis globais."""
    return {
        "BASE_URL": BASE_URL,
    }

def get_new_user_payload(is_admin=False):
    """Gera um payload de usuário com dados aleatórios."""
    return {
        "nome": fake.name(),
        "email": fake.email(),
        "password": fake.password(length=10),
        "administrador": str(is_admin).lower()
    }

def get_new_product_payload():
    """Gera um payload de produto com dados aleatórios."""
    return {
        "nome": f"Produto Teste {fake.ean(length=8)}",
        "preco": fake.random_int(min=10, max=500),
        "descricao": fake.sentence(nb_words=5),
        "quantidade": fake.random_int(min=1, max=100)
    }
