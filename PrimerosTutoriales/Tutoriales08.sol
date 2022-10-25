// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* Simple contract
contract HelloWorld {
    string public myString = 'HelloWorld';
} 
*/
/* Tipos variables
contract Variables {
    bool public boolean = true;
    uint public u = 7;          // uint = uint256 0 to 2**256 - 1
                                // uint8 0 to 2**8 - 1
                                // uint16 0 to 2**16 - 1
    int public i = -7;          // int = int256 -2**255 to 2**255 - 1
                                // int8 -2**7 to 2**7 - 1
    // Conseguir el maximo y el minimo valor que puede tener un entero
    int public minInt = type(int).min;
    int public maxInt = type(int).max;
    // Valores no completos
    //address public addr = 0x5555;
    //bytes32 public b32 = 0x32;
}
*/
/*
Funciones simples
contract FunctionIntro {
    // external significa que se puede llamar cuando hacemos deploy, igual que un public
    // pure = readonly, no escribe nada en la blockchain
    function add(uint x, uint y) external pure returns (uint) {
        return x + y;
    }

    function sub(uint x, uint y) external pure returns (uint) {
        return x - y;
    }

}
*/
/*
contract StateVariables {
    // Estas variables almacenan datos en la blockchain
    uint public myUint;

    function foo() external {
        // Esta no se guarda en la blockchain, solo se usa dentro de la función
        uint variableLocalNoState = 0
    }
}
*/
/* Variables globales que se usan para sacar info y demas
contract GlobalVariables {
    function globalVars() external view returns (address, uint, uint) {
        // guarda la direccion de la cartera que utiliza el contrato
        address sender = msg.sender;
        uint timestamp = block.timestamp;
        uint blockNum = block.number;
        return (sender, timestamp, blockNum);
    }
}
*/
