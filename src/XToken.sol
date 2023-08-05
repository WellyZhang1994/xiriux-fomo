// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { ERC20 } from "openzeppelin/token/ERC20/ERC20.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";


contract XToken is ERC20, Ownable{
    
    uint8 internal _decimals;
    constructor(string memory name, string memory symbol, uint8 decimalsValue) ERC20(name, symbol) {
        _decimals = decimalsValue;
    }
}