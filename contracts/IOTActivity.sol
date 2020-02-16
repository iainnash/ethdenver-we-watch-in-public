pragma solidity 0.4.24;

import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.4/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.4/vendor/Ownable.sol";

contract IOTActivity is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;

  bytes32 public blockStorage;
  uint256 public lastPersons;
  uint256 public lastDevices;
  
  event LastPersonsFulfilled(
      bytes32 indexed requestId,
      uint256 indexed lastPersons
  );
  
  event LastDevicesFulfilled(
      bytes32 indexed requestId,
      uint256 indexed lastDevices
  );

  event BlockStorageFulfilled(
    bytes32 indexed requestId,
    bytes32 indexed data
  );


  constructor() public Ownable() {
    setPublicChainlinkToken();
  }
  
  function requestBlockStorage(address _oracle, string _jobId)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), this, this.fulfillBlockStorage.selector);
    req.add("get", "https://iain.builtwithdark.com/entries");
    req.add("path", "block");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function requestLastDevices(address _oracle, string _jobId)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), this, this.fulfillLastDevices.selector);
    req.add("get", "https://iain.builtwithdark.com/bleCount");
    req.add("path", "ble");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }
  
    function requestLastPersons(address _oracle, string _jobId)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), this, this.fulfillLastPersons.selector);
    req.add("get", "https://iain.builtwithdark.com/entriesCount");
    req.add("path", "visitors");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }


  function fulfillBlockStorage(bytes32 _requestId, bytes32 _data)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit BlockStorageFulfilled(_requestId, _data);
    blockStorage = _data;
  }
  
  
  function fulfillLastPersons(bytes32 _requestId, uint256 _data)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit LastPersonsFulfilled(_requestId, _data);
    lastPersons = _data;
  }
  
  
  function fulfillLastDevices(bytes32 _requestId, uint256 _data)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit LastDevicesFulfilled(_requestId, _data);
    lastDevices = _data;
  }
  
  function getMessage() public view returns (string) {
      return bytes32ToString(blockStorage);
  }

  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    public
    onlyOwner
  {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

}