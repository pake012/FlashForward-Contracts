//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.21 <0.7.0;


interface Eth {
    function approve(address _spender, uint256 _amount) external returns (bool);

    function balanceOf(address _ownesr) external view returns (uint256);

    function faucet(uint256 _amount) external;

    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function allowance(address owner, address spender) external returns (uint256);
}

interface IaEth {
    function balanceOf(address _user) external view returns (uint256);

    function redeem(uint256 _amount) external;
}
