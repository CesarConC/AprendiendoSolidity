from brownie import accounts

# cuando ejecutamos brownie, genera 10 cuentas. Podemos acceder a sus direcciones de wallet de esta forma
def deploy_simple_storage():
    # si hemos creado una nueva cuenta con el comando accounts new (4:35:00  del video)
    # usamos lo siguiente: account = accounts.load("nombre de la cuenta")
    account = accounts[0]
    print(account)


def main():
    deploy_simple_storage()
