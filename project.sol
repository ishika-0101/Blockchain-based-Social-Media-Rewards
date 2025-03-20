// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialMediaRewards {

    struct Post {
        uint256 id;
        address creator;
        string content;
        uint256 likes;
        uint256 shares;
        uint256 rewardBalance;
    }

    uint256 public postCounter;
    mapping(uint256 => Post) public posts;
    mapping(address => uint256) public tokenBalances;

    event PostCreated(uint256 postId, address creator, string content);
    event Liked(uint256 postId, address liker);
    event Shared(uint256 postId, address sharer);
    event Rewarded(uint256 postId, address creator, uint256 rewardAmount);
    event TokenTransferred(address from, address to, uint256 amount);

    modifier postExists(uint256 _postId) {
        require(posts[_postId].id != 0, "Post does not exist");
        _;
    }

    modifier hasEnoughTokens(address _user, uint256 _amount) {
        require(tokenBalances[_user] >= _amount, "Insufficient tokens");
        _;
    }

    // Create a new post
    function createPost(string memory _content) external {
        postCounter++;
        posts[postCounter] = Post({
            id: postCounter,
            creator: msg.sender,
            content: _content,
            likes: 0,
            shares: 0,
            rewardBalance: 0
        });

        emit PostCreated(postCounter, msg.sender, _content);
    }

    // Like a post
    function likePost(uint256 _postId) external postExists(_postId) {
        posts[_postId].likes += 1;
        uint256 reward = 1 * 10**18; // 1 token reward for like
        posts[_postId].rewardBalance += reward;
        tokenBalances[msg.sender] -= reward; // Deduct token from liker
        tokenBalances[posts[_postId].creator] += reward; // Reward creator

        emit Liked(_postId, msg.sender);
        emit TokenTransferred(msg.sender, posts[_postId].creator, reward);
    }

    // Share a post
    function sharePost(uint256 _postId) external postExists(_postId) {
        posts[_postId].shares += 1;
        uint256 reward = 2 * 10**18; // 2 tokens reward for share
        posts[_postId].rewardBalance += reward;
        tokenBalances[msg.sender] -= reward; // Deduct token from sharer
        tokenBalances[posts[_postId].creator] += reward; // Reward creator

        emit Shared(_postId, msg.sender);
        emit TokenTransferred(msg.sender, posts[_postId].creator, reward);
    }

    // Reward a post's creator manually (can be used for other forms of engagement)
    function rewardCreator(uint256 _postId, uint256 _amount) external hasEnoughTokens(msg.sender, _amount) postExists(_postId) {
        tokenBalances[msg.sender] -= _amount; // Deduct reward amount from sender
        tokenBalances[posts[_postId].creator] += _amount; // Transfer to post creator
        
        emit Rewarded(_postId, posts[_postId].creator, _amount);
        emit TokenTransferred(msg.sender, posts[_postId].creator, _amount);
    }

    // View a post's details
    function getPostDetails(uint256 _postId) external view returns (Post memory) {
        return posts[_postId];
    }

    // Add tokens to the contract (for minting new tokens)
    function depositTokens(uint256 _amount) external {
        tokenBalances[msg.sender] += _amount;
    }

    // Check token balance
    function getTokenBalance(address _user) external view returns (uint256) {
        return tokenBalances[_user];
    }
}
