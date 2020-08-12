//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IAave.sol';
import './interfaces/IDai.sol';
import './interfaces/iETH.sol';
import './Token.sol';

/// @title The contract for a created Forward position
/// @dev This contract will manage a position
contract Forward is ERC20, Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    enum States {WAITING, OPEN, LOCKED, SETTLED}

    Eth public eth;
    Dai public dai;
    IaEth public aEth;
    IaDai public aDai;
    IAaveLendingPool public aaveLendingPool;

    uint256 public maxInterest = 0;
    uint256 public placedForward;
    uint256 public expirationTime;
    uint256 public executingTime;
    Token[] public tokenAddresses;

    string public _name;
    string public _symbol;

    ////////////////////////////
    //////// EVENTS ////////////
    ////////////////////////////

    event ForwardPaused(address contractAddress);
    event ForwardDestroyed(address contractAddress);
    event ParticipantEntered(address indexed participant);
    event ParticipantWithdrawn(address indexed participant);
    event StateChanged(States state);

    ////////////////////////////
    //////// MODIFIERS /////////
    ////////////////////////////

    modifier checkState(States requiredState) {
        require(setState() == requiredState, 'function cannot be called at this time');
        _;
    }

    ////////////////////////////////////
    //////// CONSTRUCTOR ///////////////
    ////////////////////////////////////
    constructor(
        Eth _ethAddress,
        Dai _daiAddress,
        uint256 _positionID,
        address _aEth,
        address _aDai,
        address _aaveLendingPool,
        address _aaveLendingPoolCore,
        uint256[3] memory _contractTimes,
        uint256 _value,
        uint256 _exchangeRate
        )
        ERC20(_name, _symbol) public {
        // externals
        eth = _ethAddress;
        dai = _daiAddress;
        aEth = IaEth(_aEth);
        aDai = IaDai(_aDai);
        aaveLendingPool = IAaveLendingPool(_aaveLendingPool);

        // approvals
        dai.approve(_aaveLendingPoolCore, type(uint256).max);

        //locking the aETH from Alice//
        transferFrom(msg.sender, address(this), _value);

        // pass arguments to public variables
        placedForward = _contractTimes[0];
        expirationTime = _contractTimes[1];
        executingTime = _contractTimes[2];
}

    ////////////////////////////////////
    ////////// STATE SETTER ////////////
    ////////////////////////////////////
    function setState() public returns (States) {
        if (now < placedForward) {
            return States.WAITING;
        }

        if (now >= placedForward && now < expirationTime) {
            return States.OPEN;
        }

        if (disableContract() ) {
            return States.LOCKED;
        }

        if (now > executingTime ) {
            return States.SETTLED;
        }

        return States.LOCKED;
    }

     ////////////////////////////////////
    //////// SETTING A CONTRACT /////////
    ////////////////////////////////////

    //placeBet;
    function matchOffer(uint256 _amount) external payable
    checkState(States.OPEN) whenNotPaused {
      //require statements to be defined//
        aaveLendingPool.deposit(address(dai), _amount, 0);
        transferFrom(msg.sender, address(this), _amount);
    }


    ////////////////////////////////////
   //////// CLAIMING A CONTRACT ////////
   ////////////////////////////////////

   function claim(uint256 _amount) external payable onlyOwner checkState(States.SETTLED) {
     //require statements to be defined//
     aaveLendingPool.redeem(_amount);
   }



    ////////////////////////////////////
    ///////INTEREST COMPUTATION/////////
    ////////////////////////////////////




    ////////////////////////////////////
    //////// INTERNAL FUNCTIONS ////////
    ////////////////////////////////////

    function destroy() public onlyOwner whenPaused {
        selfdestruct(msg.sender);
        emit ForwardDestroyed(address(msg.sender));
    }

    function disablePosition(address payable marketAddress)
        public
        onlyOwner
        returns (bool)
    {
        emit ForwardPaused(marketAddress);
        return Forward(marketAddress).disableContract();
    }


  function disableContract() public onlyOwner whenNotPaused returns (bool) {
      _pause();
  }

  function enableContract() public onlyOwner whenPaused returns (bool) {
      _unpause();
  }

  receive() external payable {}

  fallback() external payable {}

}
