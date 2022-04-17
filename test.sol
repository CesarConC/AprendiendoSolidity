pragma solidity 0.8.10;


contract MiContracto {
    uint public x = 21;
    address public lastSender;

    /// balance de las cuentas que interactuan con el contrato
    mapping (address => uint) private balances;

    /// depositar dinero desde una cuenta
    function depositar() external payable{
        balances[msg.sender] += msg.value;
    }
    /// extraer dinero a una cuenta. no pueden retirar mas dinero del que han puesto
    function withdraw(address payable addr, uint amount) public payable{

        require(balances[addr] >= amount);
        (bool sent, bytes memory data) = addr.call{value: amount}("");
        require(sent, "No se puede completar la accion");

        balances[msg.sender] -= amount;
    }

    function setX(uint _x) public {
        x = _x;
    }

    /// external payable indica que esta funcion puede recibir dinero desde fuera, desde una cuenta u otro contrato
    /// msg sirve para acceder a informacion acerca de la cuenta que ha llamado al contrato/funcion
    function recibir() external payable {
        lastSender = msg.sender;
    }

    /// view indica que la funcion es solo de lectura y no puede realizar ningun cambio
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /// address payable indica que esa direccion puede recibir dinero
    function pay(address payable addr) public payable {
        /// ("") podemos poner un mensaje al enviar el dinero
        /// sent indica si se ha podido enviar o no
        /// dentro de call se puede pasar la cantidad que se quiere enviar, el gas que se quiere enviar...
        (bool sent, bytes memory data) = addr.call{value: 1 ether}("");
        /// require mira el valor de la variable. Si es true continua con el codigo, si no lanza excepcion
        require(sent, "Error sending money");
    }




}