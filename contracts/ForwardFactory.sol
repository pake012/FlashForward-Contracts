//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import './Forward.sol';
import './interfaces/IAave.sol';
import './interfaces/IDai.sol';
import './interfaces/iETH.sol';

/// @title Forward Factory contract
/// @notice This contract allows users to create a new (Forward contract) position into the Aave protocol
contract ForwardFactory is Ownable, Pausable {
    address payable[] public listedForwards;
    address public newPosition;

    Eth public eth;
    Dai public dai;
    IaEth public aEth;
    IaDai public aDai;
    IAaveLendingPool public aaveLendingPool;
    IAaveLendingPoolCore public aaveLendingPoolCore;
    uint256 positionID = 0;
    uint _createdForward;
    uint expirationTime;
    /* mapping(string => address) Ethername;
    mapping(string => address) Dainame; */

    enum States {WAITING, OPEN, LOCKED, SETTLED}

    /* event ForwardCreated(address contractAddress); */
    event ForwardCreated(address contractAddress);
    event ForwardPaused(address contractAddress);
    event ForwardDestroyed(address contractAddress);
    event StateChanged(States indexed state);


      ////////////////////////////////////
      //////// CONSTRUCTOR ///////////////
      ////////////////////////////////////

    constructor(
        Eth _ethAddress,
        Dai _daiAddress,
        IaEth _aEthAddress,
        IaDai _aDaiAddress,
        IAaveLendingPool _aaveLpAddress,
        IAaveLendingPoolCore _aaveLpcoreAddress)
        public {
        dai = _daiAddress;
        eth = _ethAddress;
        aEth = _aEthAddress;
        aDai = _aDaiAddress;
        aaveLendingPool = _aaveLpAddress;
        aaveLendingPoolCore = _aaveLpcoreAddress;

        // Approve for ERC20
        dai.approve(address(_aaveLpcoreAddress), type(uint256).max);
    }


      ////////////////////////////////////
      //////// POSITION SETUP ////////////
      ////////////////////////////////////

    /// @notice This contract is the foundation for any created Forward contract
    /// @dev Owner deposits token into aaveLendingPoolCore by calling deposit function
    /// @param _value Value of the position in Eth or ERC20
    /// @param _tokenName symbol of the token deposited
    /// @param _exchangeRate fixed amount of ETH or ERC20 to be received upon settlement date
    /// @param _exchangeToken symbol of the token to match the position
    /// @param _expirationTime time in minutes, hours or days that the position will be opened to be matched
    /// @param _executingTime When the position reaches settlement date


    function createForward(
        uint256 _value,
        string memory _tokenName,
        uint256 _exchangeRate,
        string memory _exchangeToken,
        uint256 _expirationTime,
        uint256 _executingTime)
        public payable onlyOwner whenNotPaused returns (Forward) {
        positionID ++;
        _createdForward = block.timestamp;
        expirationTime = _expirationTime;
        aaveLendingPool.deposit(address(eth), _value, 0);
          Forward newContract = new Forward({
          _positionID:positionID,
          _ethAddress: eth,
          _daiAddress: dai,
          _aEth: address(aEth),
          _aDai: address(aDai),
          _aaveLendingPool: address(aaveLendingPool),
          _aaveLendingPoolCore: address(aaveLendingPoolCore),
          _contractTimes: [_createdForward, _expirationTime, _executingTime],
          _value: msg.value,
          _exchangeRate: _exchangeRate
          });
          address payable newAddress = address(newContract);
          listedForwards.push(newAddress);
          newPosition = newAddress;
          emit ForwardCreated(address(msg.sender));
          return newContract;
          }



        ////////////////////////////////////
        ////////// VIEW FUNCTIONS //////////
        ////////////////////////////////////
        function getPositionState() public payable returns (States) {
            if (now < _createdForward) {
                return States.WAITING;
            }

            if (now >= _createdForward && now < expirationTime) {
                return States.OPEN;
            }

            /* if (disableContract() ) {
                return States.LOCKED;
            } */

            return States.LOCKED;
        }


        function getPositions() public view returns (address payable[] memory) {
            return listedForwards;
        }
}
