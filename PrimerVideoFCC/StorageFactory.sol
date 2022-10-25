// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// tienen que estar en la misma carpeta
import "./SimpleStorage.sol";

// el "is" es la manera de añadir herencia sobre un contrato

contract StorageFactory is SimpleStorage {
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        // creamos un objeto del tipo del contrato que hemos importado
        SimpleStorage simpleS = new SimpleStorage();
        simpleStorageArray.push(simpleS);
    }

    function sfStore(uint256 _simpleSIndex, uint256 _simpleSNumber) public {
        // para interactuar con un contrato necesitamos su direccion y su ABI

        // estas lineas son las que explicaron al pricipio y sobre las que baso la explicacion de abajo
        //SimpleStorage nuevoSStorage = SimpleStorage(address(simpleStorageArray[_simpleSIndex]));
        //nuevoSStorage.store(_simpleSNumber);

        // Nosotros tenemos la variable de tipo SimpleStorage que es un array que va a guardar objetos de
        // tipo SimpleStorage, que es el contrato que habíamos hecho.
        // En esta funcion cogemos el contrato guardado en el indice _simpleIndex, y al coger ese indice de la
        // lista nos devuelve una address. Con esa address creamos otro contrato (linea 20) y lo guardamos en la variable
        // nuevoSStorage
        // despues sobre ese nuevo contrato ejecutamos la funcion store.

        //  En python, para que el cambio se ejecutase y se guardase correctamente,
        // el objeto que sacamos de la lista habría que meterlo otra vez. En Solidity no hace falta.
        // Despues de ejecutar store, no hace falta guardar nuevoSStorage en el array porque se actualiza solo el valor

        // el codigo actualizado es este

        SimpleStorage(address(simpleStorageArray[_simpleSIndex])).store(
            _simpleSNumber
        );
    }

    function sfGet(uint256 _simpleSIndex) public view returns (uint256) {
        // cuando ejecutamos esta función después de haber ejecutado la store, el valor que hemos guardado al usar sfStore se guarda
        // automaticamente en el array. Al usar esta funcion, miramos en el indice que sea y obtenemos el valor sin problema

        return
            SimpleStorage(address(simpleStorageArray[_simpleSIndex]))
                .retreive();
    }
}
