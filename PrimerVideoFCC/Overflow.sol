// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Overflow {
    function overflow() public view returns (uint8) {
        // uint 8 tiene un rango de 0 a 255 creo. Como el máximo es 255, si hacemos que devuelva un 255 sale todo bien
        uint8 big = 255;

        // si le sumamos 1 de esta forma, no salta error. Creo que salta error porque hay que pasarlo a uint8
        //uint8 bigg = 255 + 1;

        // si por el contrario le sumamos 1 a 255 sienbdo ambos uint8, tenemos overflow porque 255 es el valor máximo que puede coger
        // el resultado de esto es 0 por el overflow
        uint8 biggg = 255 + uint8(1);
        // el resutlado de esto es 99
        uint8 bigggg = 255 + uint8(100);

        return big;
    }
}
