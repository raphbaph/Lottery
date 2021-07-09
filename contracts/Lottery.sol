pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable{
    using SafeMathChainlink for uint256;
    AggregatorV3Interface internal ethUsdPriceFeed;

    enum LOTTERY_STATE {OPEN, CLOSED, DRAWING}
    LOTTERY_STATE public lotteryState;

    uint256 internal usdEntryFee;
    uint256 public randomness;
    uint256 public fee;
    bytes32 public keyHash;
    address public recentWinner;
    address payable[] public players;
    event RequestedRandomness(bytes32 requestId);

    constructor(address _ethUsdPriceFeedContract, address _vrfCoordinator, address _link, bytes32 _keyHash) 
        VRFConsumerBase(
            _vrfCoordinator,
            _link
        ) public {
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeedContract);
        usdEntryFee = 50;
        lotteryState = LOTTERY_STATE.CLOSED;
        fee = 1 * 10 ** 17; //0.1 LINK
        keyHash = _keyHash;
    }

    function enter() public payable{
        require(msg.value >= getEntranceFee(), "Lottery: Not enough ETH!");
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery: Not open to enter!");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns(uint256 fee_ ){
        uint256 precision = 1 * 10 ** 18;
        uint256 price = getLatestEthUsdPrice();
        fee_ = (precision / price) * ( usdEntryFee * 100000000);
    }

    function getLatestEthUsdPrice() public view returns(uint256 price_){
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = ethUsdPriceFeed.latestRoundData();
        price_ = uint256(price);
    }

    function startLottery() public onlyOwner{
        require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery: already open!");
        lotteryState = LOTTERY_STATE.OPEN;
        randomness = 0;
    }

    function endLottery() public onlyOwner{
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery: already closed!");
        lotteryState = LOTTERY_STATE.DRAWING;
        pickWinner();
    }

   function pickWinner() private returns (bytes32) {
       require(lotteryState == LOTTERY_STATE.DRAWING, "Lottery: not drawing!");
       bytes32 requestId = requestRandomness(keyHash, fee);
       emit RequestedRandomness(requestId);
   } 

   function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
       require(randomness > 0, "Lottery: random number = 0");
        uint256 index = randomness % players.length;
        players[index].transfer(address(this).balance);
        recentWinner = players[index];
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
   }
}