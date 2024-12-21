// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnersAsMentorsRewardSystem {
    address public owner;
    
    struct Mentor {
        address mentorAddress;
        string name;
        uint256 totalRewards;
        uint256 learnersMentored;
    }
    
    mapping(address => Mentor) public mentors;
    mapping(address => bool) public isMentor;
    mapping(address => uint256) public rewardsBalance;
    
    event MentorRegistered(address mentorAddress, string name);
    event LearnerMentored(address mentor, address learner, uint256 reward);
    event RewardClaimed(address mentor, uint256 rewardAmount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyMentor() {
        require(isMentor[msg.sender] == true, "You must be a registered mentor");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // Function to register as a mentor
    function registerAsMentor(string memory name) public {
        require(isMentor[msg.sender] == false, "You are already a mentor");
        
        mentors[msg.sender] = Mentor({
            mentorAddress: msg.sender,
            name: name,
            totalRewards: 0,
            learnersMentored: 0
        });
        
        isMentor[msg.sender] = true;
        
        emit MentorRegistered(msg.sender, name);
    }
    
    // Function to reward a mentor when they mentor a learner
    function rewardMentor(address mentorAddress, uint256 rewardAmount) public onlyOwner {
        require(isMentor[mentorAddress] == true, "Address is not a registered mentor");
        
        rewardsBalance[mentorAddress] += rewardAmount;
        mentors[mentorAddress].totalRewards += rewardAmount;
        mentors[mentorAddress].learnersMentored++;
        
        emit LearnerMentored(msg.sender, mentorAddress, rewardAmount);
    }
    
    // Function for mentor to claim rewards
    function claimReward() public onlyMentor {
        uint256 rewardAmount = rewardsBalance[msg.sender];
        require(rewardAmount > 0, "No rewards to claim");
        
        rewardsBalance[msg.sender] = 0;
        payable(msg.sender).transfer(rewardAmount);
        
        emit RewardClaimed(msg.sender, rewardAmount);
    }
    
    // Function to fund the contract (Owner only)
    function fundContract() public payable onlyOwner {}

    // Fallback function to handle ether sent to the contract
    receive() external payable {}
}
