const Forward = artifacts.require('./Forward.sol');
const ForwardFactory= artifacts.require('./ForwardFactory.sol');
// const DaiMockup = artifacts.require('DaiMockup');
// const aTokenMockup = artifacts.require('aTokenMockup');
// const RealitioMockup = artifacts.require('RealitioMockup.sol');

// kovan addresses
const aaveCashAddressKovan = '0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD';
const aaveAtokenAddressKovan = '0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a';
const aETHAddressKovan = '0xD483B49F2d55D2c53D32bE6efF735cB001880F79'; //aETH
const aaveLendingPoolAddressKovan = '0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c';
const aaveLendingPoolCoreAddressKovan = '0x95D1189Ed88B380E319dF73fF00E479fcc4CFa45';
const realitioAddressKovan = '0x50E35A1ED424aB9C0B8C7095b3d9eC2fb791A168';
// const uniswapRouterKovan = '0xf164fC0Ec4E93095b804a4795bBe1e041497b92a';
const uniswapRouterKovan = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
const daiAddressKovan = '0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD';
const ETHAddressKovan = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';

// // market details DUMMY/TESTING DATA ONLY, NOT FOR MAINNET
const createForward = 0;
const marketOpeningTime = 0;
const marketResolutionTime = 0;
const positionID = 0;
const value = 1;
const exchangeRate = 0;
// const arbitrator = '0xd47f72a2d1d0E91b0Ec5e5f5d02B2dc26d00A14D'; // kleros mainnet address.
// const numberOfOutcomes = 2;
// const owner = '0xCb4BF048F1Aaf4E0C05b0c77546fE820F299d4Fe';
// const question = 'Who will win the 2020 US General Election␟"Donald Trump","Joe Biden"␟news-politics␟en_US';
// const eventName = 'Who will win the 2020 US General Election';

// Currently deploying MBMarket directly. Ultimately it will deploy MBMarketFactory
module.exports = function (deployer) {
    deployer.deploy(
      ForwardFactory,
      ETHAddressKovan,
      daiAddressKovan,
      aETHAddressKovan,
      aaveAtokenAddressKovan,
      aaveLendingPoolAddressKovan,
      aaveLendingPoolCoreAddressKovan
      ).then(function(){
        return deployer.deploy(
          Forward,
          ETHAddressKovan,
          daiAddressKovan,
          positionID,
          aETHAddressKovan,
          aaveAtokenAddressKovan,
          aaveLendingPoolAddressKovan,
          aaveLendingPoolCoreAddressKovan,
          [marketOpeningTime,
          marketResolutionTime,
          createForward],
          value,
          exchangeRate)
        });
      };


  // market deploy
  // deployer.deploy(
  //   MBMarket,
  //   daiAddressKovan,
  //   aaveAtokenAddressKovan,
  //   aaveLendingPoolAddressKovan,
  //   aaveLendingPoolCoreAddressKovan,
  //   realitioAddressKovan,
  //   eventName,
  //   marketOpeningTime,
  //   marketResolutionTime,
  //   arbitrator,
  //   question,
  //   numberOfOutcomes);
