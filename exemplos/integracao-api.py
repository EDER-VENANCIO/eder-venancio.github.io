"""
Projeto: Integração com API REST
Objetivo: consultar dados externos, validar a resposta
e tratar erros de comunicação.

Exemplo demonstrativo para portfólio.
"""

import json
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def consultar_usuario(usuario_id: int) -> dict | None:
    """Consulta um usuário em uma API REST pública."""

    url = f"https://jsonplaceholder.typicode.com/users/{usuario_id}"

    requisicao = Request(
        url,
        headers={"Accept": "application/json"},
        method="GET",
    )

    try:
        with urlopen(requisicao, timeout=10) as resposta:
            if resposta.status != 200:
                print(f"Resposta inesperada: HTTP {resposta.status}")
                return None

            dados = json.loads(resposta.read().decode("utf-8"))

            if not isinstance(dados, dict) or "id" not in dados:
                print("A API retornou dados em formato inesperado.")
                return None

            return dados

    except HTTPError as erro:
        print(f"Erro HTTP: {erro.code}")
    except URLError as erro:
        print(f"Falha de conexão: {erro.reason}")
    except (TimeoutError, OSError) as erro:
        print(f"Erro de comunicação: {erro}")
    except (json.JSONDecodeError, UnicodeDecodeError):
        print("Não foi possível interpretar a resposta da API.")

    return None


if __name__ == "__main__":
    usuario = consultar_usuario(1)

    if usuario:
        print("Integração concluída com sucesso.")
        print(f"ID: {usuario['id']}")
        print(f"Nome: {usuario.get('name', 'Não informado')}")
        print(f"E-mail: {usuario.get('email', 'Não informado')}")
