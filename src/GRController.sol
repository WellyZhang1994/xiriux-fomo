// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { Ownable } from "openzeppelin/access/Ownable.sol";

contract GRController is Ownable {

    enum RoomType{
        GENERAL,
        VIP
    }

    enum BetOption{
        HEADS,
        TAILS,
        NONFINISHED
    }

    struct Broom {
        uint256 roomId;
        uint256 createTime;
        uint256 endTime;
        uint256 heads;
        uint256 tails;
        string name;
        string description;
        string headsOption;
        string tailsOption;
        BetOption result;
        RoomType roomType;
    }

    struct BetHistory {
        uint256 betId;
        uint256 time;
        uint256 betAmount;
        uint256 resultAmount;
        BetOption option;
        bool isWin;
        bool isClaim;
    }

    uint256 private _currentRoomId = 0;
    uint256 private _currentBetId = 0;

    mapping(address => uint256) monthlyBetLimit;
    mapping(address => uint256) monthlyBet;

    mapping(address=> mapping(uint256 => bool)) isBet;
    mapping(address => uint256[]) betHistoryByUser;
    mapping(uint256 => BetHistory) betHistoryDetail;

    uint256[] public roomIds;
    mapping(uint256 => Broom) public roomDatails;

    function createBetRoom(string calldata _name, 
        string calldata _description, 
        RoomType _roomType,
        string calldata _headsOption,
        string calldata _tailsOption
    )  external onlyOwner{

        uint256 _createTimestamp = block.timestamp;
        _currentRoomId += 1;
        Broom memory tempBroom = Broom(
            {   
                roomId: _currentRoomId,
                createTime: _createTimestamp,
                endTime: _createTimestamp + 1 hours,
                heads: 0,
                tails: 0,
                name: _name,
                description: _description,
                headsOption: _headsOption,
                tailsOption: _tailsOption,
                result: BetOption.NONFINISHED,
                roomType: _roomType
            }
        );

        roomIds.push(_currentRoomId);
        roomDatails[_currentRoomId] = tempBroom;
    }

    function closeBetRoom(uint256 _roomId, BetOption _option) external onlyOwner {
        uint256 _currentTimeStamp = block.timestamp;
        Broom storage broom = roomDatails[_roomId];
        require(_currentTimeStamp >= broom.endTime, "X: This room is openning!");
        broom.result = _option;
    }

    function checkResult(uint256 _roomId, uint256 _betHistoryId) external returns (bool) {
        uint256 _currentTimeStamp = block.timestamp;
        Broom memory broom = roomDatails[_roomId];
        require(isBet[msg.sender][broom.roomId], "X: You don't bet any amount in this room!");
        require(_currentTimeStamp >= broom.endTime, "X: This room is openning!");

        BetHistory storage _betHistory = betHistoryDetail[_betHistoryId];
        if(_betHistory.option == broom.result) { 
            _betHistory.isWin = true; 
            _betHistory.resultAmount = 0;
            return true;
        }
        else { 
            _betHistory.isWin = false;
            _betHistory.resultAmount = 0; 
            return false;
        }
    }

    function bet(uint256 _roomId, uint256 _amount, BetOption _option) external {

        require(monthlyBet[msg.sender] + _amount <= monthlyBetLimit[msg.sender],"X: BetAmount must lower than monthly bet limit!");
        uint256 _currentTimeStamp = block.timestamp;
        Broom storage broom = roomDatails[_roomId];
        require(_currentTimeStamp <= broom.endTime, "X: This room is finished!");
        require(isBet[msg.sender][broom.roomId] == false, "X: Can only be bet once!");

        isBet[msg.sender][broom.roomId] = true;
        if(_option == BetOption.HEADS) { broom.heads += _amount; }
        else if(_option == BetOption.TAILS) { broom.tails += _amount; }
        else { revert("X: Can only choose heads or tails"); }

        _currentBetId += 1;
        BetHistory memory tempBetHistory = BetHistory(
            {
                betId: _currentBetId,
                time: _currentTimeStamp,
                betAmount: _amount,
                resultAmount: 0,
                option: _option,
                isWin: false,
                isClaim: false
            }
        );
        betHistoryByUser[msg.sender].push(_currentBetId);
        betHistoryDetail[_currentBetId] = tempBetHistory;
    }
}