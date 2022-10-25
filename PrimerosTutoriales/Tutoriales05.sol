// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* GAS

Fees de transaccion = GAS usado * precio GAS
GAS es una medida de computacion. Cada operacion que realiza una transaccion tiene un coste, una cantidad de gas.
    Cuando ejecutamos toda la transaccion, lo que pagamos de fees/GAS es una suma de cada operacion * coste

GAS price = precio al que estamos dispuestos a pagar el GAS. Se mide en ETH
GAS limit = al limite de GAS que se puede llegar a gastar en un transaccion. Cuando ejecutamos una transaccion,
    enviamos una cantidad de GAS para poder realizarla. EL limite se usa para:

        Evitar que una transaccion gaste muchos recursos. Se limita el coste computacional al limitar
        la cantidad de GAS que se puede usar

El GAS limit lo pones tu al realizar la transaccion, pero el Block GAS limit lo pone la red(network)

Si te quedas sin GAS en mitad, los cambios a las variables de estado del contrato se resetean de manera que
estas siguen como estaban antes de empezar la transaccion, pero tu no recibes de vuelta el GAS usado

*/

/* FUNCIONES PUBLICAS

INPUTS

No se pueden pasar mapas o matrices [][]
Si se pueden pasar listas normales []
    No siempre funciona. Si las listas son muy grandes, no compila. Se hace esto para evitar gastar mucho GAS
    Cuantos mas elementos tenga una lista, se intuye que mas coste de computacion tendra la funcion

OUTPUTS

No se pueden devolver mapas ni matrices [][]

Tanto en inputs como en outputs debemos tener en cuenta el tamaño de las listas de 1 dimension
Debemos evitar gasto de GAS innecesario. 
Para eso se suelen poner limites al tamaño de las listas con las que se trabaja
*/

/* FUNCTION MODIFIERS

Se pone modifier en lugar de function y borrar public/private
Al final de la parte de codigo de la funcion que se quiere usar se escribe: _;
Ahora estas funciones se pueden poner en la cabecera de otra que las llama en algun momento y se puede borrar 
    la linea de codigo en la que se llamaba a estas funciones


RENTRACY HACK
Es un bucle que se produce entre 2 funciones de contratos distintos que se llaman la una a la otra
Acaban llamandose constantemente en bucle y no salen nunca
*/

contract ValueTypes {
    uint256 public u = 123;
    /*
    uint256 = 0 hasta 2**256 - 1
    uint64 = 0 hasta 2**64 - 1
    uint8 = 0 hasta 2**8 - 1
    */

    int256 public i = -1;
    /*
    int 256 = -2**255 hasta 2**255 - 1
    */

    int256 public minInt = type(int256).min;
    int256 public masxInt = type(int256).max;
}

contract Variables {
    /// las state variables se quedan guardadas en la blockchain para siempre
    uint256 public myUint = 123;

    function foo() external pure {
        /// solo existen cuando se ejecuta la funcion
        uint256 variableLocal = 456;
        variableLocal += 2;
    }

    /// son variables globales que no entiendo no tienen que ver con que las definas ni nada
    function globalVar()
        external
        view
        returns (
            address,
            uint256,
            uint256
        )
    {
        address sender = msg.sender;
        uint256 timestamp = block.timestamp;
        uint256 blockNum = block.number;
        return (sender, timestamp, blockNum);
    }
}

contract Contador {
    uint256 public contador;

    function aumentar() external {
        contador += 1;
    }

    function disminuir() external {
        contador -= 1;
    }

    function getContador() external view returns (uint256) {
        return contador;
    }
}

contract Constantes {
    /// permiten disminuir GAS porque no cambian
    uint256 public constant MY_UINT = 123;
}

contract OperadorTernario {
    function ternary(uint256 _x) external pure returns (uint256) {
        /*
        if (_x < 10) {
            return 1;
        }
        else {
            return 2;
        }
        */

        return _x < 10 ? 1 : 2;
    }
}

contract Bucles {
    function loops() external pure {
        for (uint256 i = 0; i < 10; i++) {
            // codigo
            if (i == 3) {
                // esto hace que el codigo pase a la siguiente iteracion del bucle auqnue haya cosas despues del if
                continue;
            }
            // codigo
            break;
        }
        uint256 o = 10;
        while (o < 15) {
            o++;
        }
    }
}

contract Errores {
    function testRequiere(uint256 _x) public pure {
        require(_x < 10, "x > 10");
        _x = 1;
        // requiere dice que para poder continuar con el codigo se requiere que se cumpla la condicion
    }

    function testRevert(uint256 _x) public pure {
        if (_x > 10) {
            revert("i < 10");
        }
    }

    // en nuestro programa se supone que num no cambia nunca de valor
    uint256 public num = 123;

    // con assert se comprueba que no hay ningun problema al llamar a la funcion durante la ejecucion no se cambia el valor
    function testAssert() public view {
        assert(num == 123);
    }

    function foo() public {
        // sin querer nos hemos dejado una funcion que suma 1
        num += 1;
    }

    error MyError(address caller, uint256 i);

    function testCustomError(uint256 _x) public view {
        // cuanto mayor sea el mensaje de error, mas gas se gasta
        if (_x > 10) {
            revert MyError(msg.sender, _x);
        }
        // de esta manera somos capaces de informar del error sin liarla con el gas
    }
}

contract FunctioOutputs {
    function returnMany() public pure returns (uint256, bool) {
        return (1, true);
    }

    function named() public pure returns (uint256 x, bool b) {
        return (1, true);
    }

    function assigned() public pure returns (uint256 x, bool b) {
        x = 1;
        b = true;
    }

    function destructingAssigments() public pure {
        (uint256 x, bool b) = returnMany();
        (, bool _b) = returnMany();
    }
}

contract Array {
    uint256[] public nums = [1, 2, 3];
    uint256[5] public numsFixed = [4, 5, 6, 7, 8];

    function examples() external {
        nums.push(4); // [1,2,3,4]
        uint256 x = nums[1];
        nums[2] = 777;
        delete nums[1]; // [1, 0, 777, 4]
        nums.pop(); // [1, 2, 777]
        uint256 len = nums.length;

        uint256[] memory a = new uint256[](5);
    }

    // ESTA VERSION NO ES MUY GAS FRIENDLY LA VERDAD

    uint256[] public arr;

    function exam() public {
        arr = [1, 2, 3];
        delete arr[1]; // [1, 0, 3] no queremos eso, queremos dejar 2 cosas en la lista no 3
    }

    // remove(1) ==> [1, 2, 3] => [1, 3, 3] => [1, 3]
    function remove(uint256 _index) public {
        require(_index < arr.length, "index out of bound");

        for (uint256 i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        // se borra el ultimo
        arr.pop();
    }
}

contract DiccionarioIterable {
    mapping(address => uint256) public balances;
    mapping(address => bool) public inserted;
    address[] public keys;

    function set(address _key, uint256 _val) external {
        balances[_key] = _val;

        if (!inserted[_key]) {
            inserted[_key] = true;
            keys.push(_key);
        }
    }

    function getSize() external view returns (uint256) {
        return keys.length;
    }

    function fisrt() external view returns (uint256) {
        return balances[keys[0]];
    }

    function last() external view returns (uint256) {
        return balances[keys[keys.length - 1]];
    }

    function get(uint256 _i) external view returns (uint256) {
        // se supone que _i es el indice que buscamos, no la address concreta porque esa no la tenemos
        return balances[keys[_i]];
    }
}
