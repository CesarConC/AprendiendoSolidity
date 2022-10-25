// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/interface/SafeMAthChainlink.sol";

// de ese import sacamos un archivo que en lugar de empezar por contract empieza por interface
// las interface tienen funciones que no tiene contenido, simplemente tienen definidos los parametros que toman y el return que hacen
// las interface se compilan a una ABI (application binary interface), que le indica tanto a solidity como a otros lenguajes de programacion
// como pueden interactuar con otros contratos. En solidity, hay que especificar a un contrato como puede interactuar con otro porque por si mismo no sabe

contract FundMe {
    address public owner;

    // evita el overflow de los uint
    using SafeMathChainlink for uint256;

    // el mapping permite asociar y guardar una cantidad de dinero a una direccion
    mapping(address => uint256) public addressToAmountFunded;
    // la lista permite guardar las direcciones que se van guardando en el contrato
    address[] public funders;

    constructor() public {
        // como el construtor se ejecuta nada mas crear el contrato, quien crea el contrato es el msg.sender porque es quien lo llama
        owner = msg.sender;
    }

    // payable hace que pueda usarse para pagar
    // el msg.value es la cantidad que mandas al smart contract
    // en remix es la cantidad que pones en Value en la pestaña donde haces deploy

    // esto va genial si quieres guardar valores en wei, pero si quieres
    // guardarlo en otra cosa como USD hay que hacer otras cosas

    function fund() public payable {
        // el 10 se eleva a 18 porque es la forma de pasarlo a las unidades de wei
        // 18 decimales vaya
        uint256 minimumUSD = 50 * 10**18;

        // si no se cumple la condicion se revierte la ejecucion y se manda el mensaje
        require(
            getConversionRates(msg.value) >= minimumUSD,
            "Gasta mas ETH cabron"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        // guardamos la nueva direccion en la lista
        // en el video no tienen en cuenta que vamos a meter la misma direccion cada vez que se llame a la funcion aunque ya este guardada
        funders.push(msg.sender);
    }

    // los modifiers permiten modificar funciones de forma declarativa dentro del codigo
    // en este caso, tenemos que la funcion a la que le hemos puesto esta etiqueta debe cumplir lo que hay en el modifier antes de poder continuar
    // para continuar se escribe _;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        // address(this) coge la direccion del contrato que se esta ejecutando, es decir, este
        // con esta linea le madnamos a quioen sea que este llamando a la funcion TODO el dinero del contrato

        require(
            msg.sender == owner,
            "No eres el creador del contrato. No me robes"
        );
        msg.sender.transfer(address(this).balance);
        // hay que restaurar todos los valores del mapping a 0
        // para eso hacemos un for sobre la lista de direcciones y con cada una de ellas accedemos al mapping y vamos borrando
        // habra muchas direcciones repetidas si han llamado a la funcion fund mas de una vez
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }

    function getVersion() public view returns (uint256) {
        // podemos crear objetos de tipo AggregatorV3Interface porque hemos importado el contrato/interface y podemos usarlo
        // para psarle una direccion nos tenemos que ir a docs.chain.link/docs/ethereum-addresses/
        // ahi buscamos la red en la que estemos haciendo las pruebas del contrato y buscamos el par que queramos

        // en esta linea decimos que tenemos un contrato definido en la interface que hemos importado en la direccion que le pasamos entre parentesis
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        // si de verdad existe (la direccion es correcta) se genera el objeto y podemos interactuar con sus funciones
        return priceFeed.version();

        // si queremos hacer deploy de esto, hay que cambiar el environtment a injected porque estamos utilizando datos de una testnet. En este caso es la de rinbee creo
    }

    function getPrice() public view returns (uint256) {
        // esta funcion hace lo siguiente
        // estamos interactuando con un oracle y nos facilita informacion de cualquier moneda en tiempo real
        // en el caso del video, queremos saber el valor de ETH/USD
        // para ello creamos esta funcion dentro de nuestro contrato

        // generamos el objeto del tipo del contrato del oracle
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        // ejecutamos su funcion de obtener precio
        // como hemos puesto la direccion de ETH/USD en la testnet de Ringbee, nos dara el valor de esa moneda en ese par

        // esta forma de llamar a la funcion da warnings porque no usamos todos los valores dentro de la funcion

        //(
        //uint80 roundId,
        //int256 answer,
        //uint256 startedAt,
        //uint256 updatedAt,
        //uint80 answeredInRound
        //) = priceFeed.latestRoundData();

        // para que no de problemas, podemos hacer lo siguiente
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        // el valor es el answer, y hay que convertirlo porque queremos devolver otro tipo de entero
        //return uint256(answer);
        // este return devuelve un numero muy grande porque no hay decimales en solidity.
        // en el video devuelve 248155877123 dolares sin ningun punto decimal
        // que pasado a dolares con decimales es 2.482,55877123 dolares
        // siempre esta multiplicado por 10 ** 8

        return uint256(answer * 10000000000);
        // si devolvemos esto asi estamos pasando el resultado a wei, que es la unidad mas pequeña de eth
        // esto añade coste de gas al contrato porque ahy que ahcer una operacion mas y realmente no es necesaria
    }

    function getConversionRates(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        // hay que dividir por ese numero porque tanto ethPrice como ethAmount vienne multiplicados por eso
        // al final estamos multiplicando dos veces, y solo queremos 1
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }
}
