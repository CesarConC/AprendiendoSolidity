import json
import os
from solcx import compile_standard, install_solc
from web3 import Web3
from dotenv import load_dotenv

"""
    Para poder usar el .env hay que instalar pip install python-dotenv
    Permite cargar datos del fichero .env 
"""
load_dotenv()

# Hace falta poner esto para que python te deje ejecutar y leer el archivo .sol
install_solc("0.6.0")

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
file.close()

"""
    Ahora hay que compilar el archiuvo .sol igual que se hace en Remix
    Para ello usamos una libreria: pip install py-solc-x
"""

# Simplemente es lo que hay que poner
compiled_sol_code = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)

"""
    Esta linea no hace falta utilizarla mas, creo que es solo para que veamos
    como se fuarda la info. No entiendo por que el json en el pc de torre se 
    ve fatal

    with open("compiled_code.json", "w") as file:
        json.dump(compiled_sol_code, file)
"""

# Se saca del contrato compilado la info que necesitamos: bytecode y el abi
bytecode = compiled_sol_code["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

abi = compiled_sol_code["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

"""
    Hay que descargar Ganache de internet e instalarlo
    Despues instalar el paquete web3
"""

# Conectarnos a la blockchain que hemos creado en ganache-cli
# La direccion aparece al final, donde dice listening on
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

# Necesitamos tener el chainid. En Ganache pone otro, pero con ese no funciona. Solo funciona con este
chain_id = 1337

# Datos para simular una cartera/usuario. He cogido la primera cuenta
my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
private_key = os.getenv("PRIVATE_KEY")

# Contrato creado en python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)

# Get latest transaction nos da el nonce, que nos sirve para poder hacer transacciones
nonce = w3.eth.getTransactionCount(my_address)

transaction = SimpleStorage.constructor().buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce,
    }
)

# Las transacciones hay que firmarlas para que se pueda verificar que fui yo quien la hizo
signed_tx = w3.eth.account.sign_transaction(transaction, private_key)

# Obtenemos el hash y mandamos la transaccion a la blockchain
print("Deploying contract...")
tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)

# Esta bien esperar a que se complete el procesamiento al mandarla
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("Deployed!!")

"""
    Para trabajar con un contrato e interactuar con el, hacen falta
        La direccion del contrato
        Su ABI
"""

simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

"""
    En la blockchain podemos interactuar de dos maneras
        Call: simlar hacer una llamada y obtener un return. No cambian el estado de la red
        Transact: hacemos un cambio de estado
    En Remix, los botones azules una vez compilado y despues del deploy son calls. Los naranjas son transacts

    Si haces call, estas simulando que ejecutas cosas sobre el contrato. Por ejemplo, en el contrato tenemos la
    funcion store que recibe un parametro y modifica el numero que la funcion retrieve devuelve.
    Si ejecutamos store usando store(15).call() no estamos modificando el estado, de manera que no se va a guardar el
    cambio. Para ejecutar una funcion que modifica el estado, hay que usar transact. Para ello, hay que crear una nueva transaccion
    de la misma manera que hacemos para hacer deploy: creas la transaccion, la firmas y la mandas a la red generando el hash
"""

print(simple_storage.functions.retrieve().call())

"""
    El nonce es un numero que solo se puede usar una vez (teoria de clase de ciber). Como el nonce lo estamos sacando del
    numero de bloques he hemos generado (creo), y para generar la transaccion de arriba (crear el contrato/subirlo) usamos la variable nonce,
    ahora hace falta sumarle 1 para usarla de nuevo en este caso
"""

print("Updating contract...")
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce + 1,
    }
)

signed_store_transaction = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)

print("Updated!!")
store_transaction_hash = w3.eth.send_raw_transaction(
    signed_store_transaction.rawTransaction
)
store_transaction_receipt = w3.eth.wait_for_transaction_receipt(store_transaction_hash)

"""
    Ahora hemos ejecutado un cambio en el estado de nuestra red y se actualiza el valor de 
    la variable que hemos modificado
    En Ganache la transaccion de ejecutar la funcion store se etiqueta con contract call
"""
print(simple_storage.functions.retrieve().call())
