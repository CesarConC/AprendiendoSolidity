// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 favoriteNumber = 5;

    struct People {
        uint256 favNumber;
        string name;
    }

    // si le meters un numero en los corchetes egneras un array de dimensiones predefinidas y como maximo tendra esa longitud
    People[] public people;
    // srive para evitar tener que hacer for de una lista
    mapping(string => uint256) public nameToFavNum;

    function retreive() public view returns (uint256) {
        return favoriteNumber;
    }

    function store(uint256 _favNum) public {
        favoriteNumber = _favNum;
    }

    function addPerson(string memory _name, uint256 _favNumber) public {
        people.push(People({favNumber: _favNumber, name: _name}));
        nameToFavNum[_name] = _favNumber;
    }
}
