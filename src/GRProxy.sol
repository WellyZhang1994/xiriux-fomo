// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { Ownable } from "openzeppelin/access/Ownable.sol";

contract GRProxy is Ownable {
    
    bytes32 constant private _SLOTADDRESS = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    constructor(address _implementation) {
        _setSlotToAddress(_SLOTADDRESS, _implementation);
    }

    fallback() external payable virtual {
        _delegate(_getSlotToAddress(_SLOTADDRESS));
    }

    receive() external payable {}

    function upgradeTo(address _newImpl) public virtual onlyOwner(){
        _setSlotToAddress(_SLOTADDRESS, _newImpl);
    }

    function upgradeToAndCall(address _newImpl, bytes memory data) public virtual onlyOwner{
        _setSlotToAddress(_SLOTADDRESS, _newImpl);
        (bool success, ) = _newImpl.delegatecall(data);
        require(success);
    }

    function _delegate(address _implementation) private {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _setSlotToUint256(bytes32 _slot, uint256 value) private {
        assembly {
            sstore(_slot, value)
        }
    }

    function _setSlotToAddress(bytes32 _slot, address value) private {
        assembly {
        sstore(_slot, value)
        }
    }

    function _getSlotToAddress(bytes32 _slot) private view returns (address value) {
        assembly {
        value := sload(_slot)
        }
    }
}
