// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerReviewIncentives {
    address public owner;
    uint256 public rewardAmount = 1 ether; // Example reward amount
    
    enum ReviewStatus { Pending, Approved, Rejected }
    
    struct Review {
        address reviewer;
        string content;
        ReviewStatus status;
        uint256 reward;
    }
    
    mapping(address => Review[]) public reviews;
    mapping(address => uint256) public rewards;
    mapping(address => bool) public hasReviewed;
    
    event ReviewSubmitted(address indexed reviewer, uint256 reviewId);
    event ReviewEvaluated(address indexed reviewer, uint256 reviewId, ReviewStatus status);
    event RewardDistributed(address indexed reviewer, uint256 amount);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    function submitReview(string memory content) external {
        require(!hasReviewed[msg.sender], "Review already submitted");
        
        reviews[msg.sender].push(Review({
            reviewer: msg.sender,
            content: content,
            status: ReviewStatus.Pending,
            reward: 0
        }));
        
        hasReviewed[msg.sender] = true;
        emit ReviewSubmitted(msg.sender, reviews[msg.sender].length - 1);
    }
    
    function evaluateReview(address reviewer, uint256 reviewId, ReviewStatus status) external onlyOwner {
        Review storage review = reviews[reviewer][reviewId];
        require(review.status == ReviewStatus.Pending, "Review already evaluated");
        
        review.status = status;
        if (status == ReviewStatus.Approved) {
            review.reward = rewardAmount;
            rewards[reviewer] += rewardAmount;
        }
        
        emit ReviewEvaluated(reviewer, reviewId, status);
    }
    
    function withdrawRewards() external {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to withdraw");
        
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
        
        emit RewardDistributed(msg.sender, reward);
    }
    
    receive() external payable {}
    
    function setRewardAmount(uint256 amount) external onlyOwner {
        rewardAmount = amount;
    }
}

