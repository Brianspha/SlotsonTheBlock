//This is the token users are going to get 
//when they win in the slots game
pragma solidity ^0.4.21;
contract StandardERC20
{
//Returns a specific users Dogo token balance
function GetBalance(address user) constant returns (uint256 balance);
//Returns the total number of Dogos available
function GetTotalDogosAvailable () constant returns (uint256 balance);
//Transfers a certain amount of Dogos to the specified account
function Transfer (address recipient,uint256 amount) returns (bool success);
//Transfers a certain amount of Dogos from one account to another 
function TransferFrom (address from,address to,uint256 amount) returns (bool success);
//Aprove allows a user to withdraw from the owners account multiple times up untill the max available balance
//if the function is called again it overwrites the current allowance with the amount being withdrawn
function Approve(address recipient,uint256 amount) constant returns (bool success);
//Returns the Max amount recipient is allowed to withdraw from the owner account
function Allowance(address owner,address recipient) constant returns  (uint256 amnt);

//triggered when Dogos are being transfered
event TransferEvent(address indexed from,address indexed to,uint256 amnt);
//triggered when a user approves another user to withdraw dogos from their account
event ApprovalEvent(address indexed owner,address indexed recipient,uint256 amount);

}
contract DogoLogEventsInterface
{
    //Just Holds a collection of log Events to be used by the DogoContract
    //triggered when we create a new Dogo 
    event DogoCreated(address indexed fom,address indexed to,uint256 amount);
    event DogoIcoEvent(Dogo indexed dogo);
}
//Used triggered when Ether is being transfered from one account to another
contract TokenRecipt
{
    uint256 public Balance;
    event RecievedEthers(address indexed from,uint256 amnt);
    event NewEtherBalance(address indexed from,uint256 amount,uint256 newBalance);
    
    function () payable
    {
      emit RecievedEthers(msg.sender,msg.value);
      Balance += msg.value; //add ethers to our balance
      emit NewEtherBalance(msg.sender,msg.value,Balance);
    }
}
contract ERC20 is StandardERC20,TokenRecipt
{

  uint8 public constant Decimals =18;
  uint256 TotalTokens = 10000000;
  address public owner;
  mapping(address => uint256) Balances;//keeps track of all Dogo holders balances
  mapping (address => mapping(address => uint256)) Allowed;// gets a users list of allowed recipients to withdraw from their account
  event Owner(address indexed owner);
  
function ERC20()
{
    owner=msg.sender;
    Balances[owner]=TotalTokens;
}  
function GetTotalDogosAvailable() constant returns (uint256 bal)
{
      bal=Balances[owner];
}
function GetBalance(address user) constant returns (uint256 balance)
{
    balance =Balances[user];
}
//Transfers a certain amount of Dogos to the specified account
function Transfer (address recipient,uint256 amount) returns (bool success)
{
    if(Balances[msg.sender] >amount && amount >0)
    {
        Balances[msg.sender] -= amount;
        Balances[recipient] += amount;
        TransferEvent(msg.sender,recipient,amount);
        success=true;
    }
    else
    {
        success=false;
    }
}
//Transfers a certain amount of Dogos from one account to another 
function TransferFrom (address from,address to,uint256 amount) returns (bool success)
{
    if(Balances[from] >= amount && Allowed[from][msg.sender]> amount && amount >0 && Balances[to] +amount >Balances[to])
    {
     Balances[to] += amount;
     Balances[from] -=amount;
     Allowed[from][msg.sender] -=amount;//reduce the owners balance
     emit TransferEvent(from,to,amount);
     success=true;
    }
    else
    {
    success=false;
    }
    
}
//Aprove allows a user to withdraw from the owners account multiple times up untill the max available balance
//if the function is called again it overwrites the current allowance with the amount being withdrawn
function Approve(address recipient,uint256 amount) constant returns (bool success)
{
    Allowed[msg.sender][recipient]=amount;
    ApprovalEvent(msg.sender,recipient,amount);
    success=true;
}
//Returns the Max amount recipient is allowed to withdraw from the owner account
function Allowance(address owner,address recipient) constant returns  (uint256 amnt)
{
 amnt = Allowed[owner][recipient];
 
 }

 
}

contract Dogo is ERC20
{
  string public constant Symbol ="D";
  string public constant Name ="Dogos";
  string public Version="0.1";
  address public OwnerAddress;
  function Dogo ()
  {
      
  }
  function Transfer (address to,address from,uint256 amount) returns (bool success)
  {
      return super.Transfer(to,amount);//call the parent transfer method defined in the ERC20 contract
  }
    
  function Approve (address recipient,uint256 amount) constant returns (bool succes)
  {
      return super.Approve(recipient,amount);//call the parent Approval function
  }
  function GetBalance(address owner) constant returns (uint256 amount)
  {
      return super.GetBalance(owner);
  }
  //Sets the owner of the Dogo token
  function SetDogoOwner(address owner) returns (bool succes)
  {
      require(owner != address(0)); //ensure the address is not invalid 
      OwnerAddress=owner;
      succes=true;
  }
  function SellDogos(address recipient,uint256 amount) returns (bool succes)
  {
      require(amount >0);//ensure that the amount is not negative
      require(msg.sender == OwnerAddress);//only the owner is allowed to sell Dogos i.e. the address that holds all the Dogo Tokens
      Balances[recipient] +=amount;
      TotalTokens +=amount;
      Transfer(0x0,owner,amount);//log the current transfer of tokens
      Transfer(owner,recipient,amount);
      succes=true;
  }
}
contract DogoContract is DogoLogEventsInterface
{
    ///Stores balances of all users that buy Dogo tokens
    Dogo public DogoICO;
    uint256 public TotalSupply;
    uint256 public DogoCreationCap;
    address public EthFundDeposit;//the owner of the Dogo Token this is used to transfer Eth each time the Token is bought
    address DogoICOAddress;
    uint256 public DogoExchangeRate;

    
    function DogoContract (uint256 rate,address icoAdd,address OwnerOfDogo) 
    {
        DogoExchangeRate=rate;
        DogoICOAddress=icoAdd;
        EthFundDeposit=OwnerOfDogo;
        DogoICO=Dogo(icoAdd);
        DogoIcoEvent(DogoICO);
        emit DogoIcoEvent(DogoICO);
        DogoCreationCap=50000;
        
    }
    
    function CreateDogoICO(address to,uint256 amount) returns (bool succes)
    {
        emit DogoCreated(0x0,to,amount);//log function call
        return DogoICO.SellDogos(to,amount);
    }
    //Takes Ethers and Creates new Dogo Tokens
    function CreateDogos(address recipient,uint256 amount) internal
    {
      require(DogoCreationCap > TotalSupply);
      require(amount>0);
      uint256 Dogos = DogoExchangeRate *amount;
      //the below if statement checks if we have exceeded the initial cap we defined for the total number of dogos we want
      //initialy bought
      if(Dogos>amount && TotalSupply+Dogos>DogoCreationCap) //check for overflow as well
      {
          uint256 DogosToAllocate = DogoCreationCap-TotalSupply;
          require(DogosToAllocate <DogoCreationCap);//check for overflow
          uint256 DogosToRefund = Dogos-DogosToAllocate;
          TotalSupply=DogoCreationCap;//ensure that we never go above the initial cap
          uint256 EthersToRefund =DogosToRefund/DogoExchangeRate;
          require(CreateDogoICO(recipient,DogosToAllocate));
          msg.sender.transfer(EthersToRefund);//refund user
          EthFundDeposit.transfer(this.balance);//Transfer all the Ether raised from selling Dogos to the owner
          return;
      }   
      TotalSupply=(TotalSupply+Dogos);
      require(CreateDogoICO(recipient,Dogos));
      EthFundDeposit.transfer(this.balance);
    }
    function () payable
    {
    
      CreateDogos(msg.sender,msg.value);
    }
}
contract Slots 
{
    struct Gambler
    {
        address owner;
        bytes32 username; //user name to be used when logging into the website
        bytes32 passowrd;//password associated with the account
        uint256 TotalWinings;//The total number of dogos the gambler has won
        uint256 CurrentBalance;//used to check if the user has any balance to play the slots machine
        bool Created;//used to check if the gambler instance is active or not
    }
    uint256 DefualtWinTokens=10;//no of tokens added each time a user wins due to change in the future
    mapping (address => Gambler) Gamblers;//keeps track of all registered Gamblers
    mapping (bytes32 => address) UserNames;//keeps track of all gamblers usernames
    address currentGambler;
    DogoContract DogoICO;
    //Constructor
    function Slots ()
    {

    }
    function RegisterGambler(address id,string usern,string pass) returns (bool succes)
    {
        require(id != address(0));//malicious address
        currentGambler=id;
        require(!Gamblers[currentGambler].Created);//Must not be active i.e. registered
        DogoICO=DogoContract(currentGambler);
        Gamblers[currentGambler]=Gambler(currentGambler,stringToBytes32(usern),stringToBytes32(pass),0,0,true);
        UserNames[stringToBytes32(usern)]=id;
        succes=true;
    }
    
    function Login(string usrname,string pass) view returns (bool succes)
    {
        bytes32 name =stringToBytes32(usrname);
        bytes32 pas =stringToBytes32(pass);
        require(name != 0x0);
        require(pas != 0x0);
        address usr = UserNames[name];
        require(Gamblers[usr].Created);//must have an active account
        require(Gamblers[usr].passowrd == pas&& Gamblers[usr].username == name);//passwords and username must match
        succes =true;
    }
    //Used for when loading the profile of the user this login function is only called when we have verified
    //That the user is inface valid i.e. registered
    function VerifiedLogin(string usrname,string password) constant returns (address id,string username,uint256 twinings,uint256 currentbalance)
    {
        bytes32 name =stringToBytes32(usrname);
        bytes32 pas =stringToBytes32(password);
        address usr = UserNames[name];
        require(Gamblers[usr].Created);//must have an active account
        require(Gamblers[usr].passowrd == pas&& Gamblers[usr].username == name);//passwords and username must match
        id=usr;
        username=usrname;
        twinings=Gamblers[usr].TotalWinings;
        currentbalance=Gamblers[usr].CurrentBalance;
    }
    function PurchaseTokens(uint256 amount) returns (bool success)
    {
        require(this.balance >=amount);
        if(amount <0)
        {
            revert();//fallback cannot buy negative amount
        }
        currentGambler.transfer(amount);
        Gamblers[msg.sender].CurrentBalance +=amount;//increase total dogos on hand 
        success=true;
    }
    function AddToWinnings(address recipient) returns (bool success) 
    {
        require(recipient != address(0));
        Gamblers[recipient].TotalWinings +=DefualtWinTokens;
        success=true;
    }

   function stringToBytes32(string memory source) returns (bytes32 result)
   {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}
function bytes32ToString(bytes32 x) constant returns (string) {
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
}