pragma solidity ^0.4.17;

contract CampaignFactory{
    address[] public deployedCampaigns;
    function createCampaign(uint _minC) public {
        address newAd = new Campaign(_minC,msg.sender);
        deployedCampaigns.push(newAd);
    }
    
    function getDeployedCampaings() public view returns(address[]){
        return deployedCampaigns;
    }
}

contract Campaign {
    
    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) hasVoted;
    }
    
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    Request[] public requests;
    uint public contibutersCount;
    
    modifier onlyManager(){
        require(msg.sender == manager);
        _;
    }
    modifier isContributer(){
        require(approvers[msg.sender]== true);
        _;
    }
    
    function getContractMoney()public view returns(uint){
        return (address(this).balance);
    }
    
    function Campaign(uint _mC,address creator) public {
        manager = creator;
        minimumContribution = _mC;
    }
    
    function contribute()public payable{
        require(msg.value>=minimumContribution);
        approvers[msg.sender] = true;
        contibutersCount++;
    }
    
    function createRequest(string _des,uint _val, address _recipient) public onlyManager{
        Request memory newRequest = Request({
            description:_des,
            value:_val,
            recipient:_recipient,
            complete:false,
            approvalCount:0
        });
        requests.push(newRequest);
    }
    
    function approveRequest(uint index) public payable isContributer{
        Request storage wantedRequest = requests[index];
        require(!(wantedRequest.hasVoted[msg.sender]));
        
        wantedRequest.hasVoted[msg.sender]=true;
        wantedRequest.approvalCount++;
        
        if(wantedRequest.approvalCount >  (contibutersCount/2) && contibutersCount > 1){
            finalizeRequest(wantedRequest);
        }
    }
    
    function finalizeRequest(Request storage _freq) private  {
        require(!_freq.complete);
        _freq.complete = true;
        _freq.recipient.transfer(_freq.value);
    }
}