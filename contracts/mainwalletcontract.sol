pragma solidity ^0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IYDAI {
  function deposit(uint _amount) external;
  function withdraw(uint _amount) external;
  function balanceOf(address _address) external view returns(uint);
  function getPricePerFullShare() external view returns(uint);
}

contract Wallet {
  address admin;
  IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IYDAI yDai = IYDAI(0xC2cB1040220768554cf699b0d863A3cd4324ce32);

  constructor() public {
    admin = msg.sender;
  }

  function invest(uint amount) external {
    dai.transferFrom(msg.sender, address(this), amount);
    _invest(amount);
  }

  function pay(uint amount, address recipient ) external {
    require(msg.sender == admin, 'only admin');
    uint balanceShares = yDai.balanceOf(address(this));
    yDai.withdraw(balanceShares);
    dai.transfer(recipient, amount);
    uint balanceDai = dai.balanceOf(address(this));
    if(balanceDai > 0) {
      _invest(balanceDai);
    }
  }

  function _invest(uint amount) internal {
    dai.approve(address(yDai), amount);
    yDai.deposit(amount);
  }

  function balance() external view returns(uint) {
    uint price = yDai.getPricePerFullShare();
    uint balanceShares = yDai.balanceOf(address(this));
    return balanceShares * price;
  }
}