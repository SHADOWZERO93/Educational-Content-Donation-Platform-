// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduDonationPlatform {
    // Declare a struct to store information about educational content
    struct Content {
        string title;
        string description;
        uint256 totalDonations;
        address creator;
    }

    // Mapping to store content based on its ID
    mapping(uint256 => Content) public contents;

    // Mapping to track donations made by users for each content
    mapping(uint256 => mapping(address => uint256)) public donations;

    // Event to log new donations
    event DonationReceived(uint256 indexed contentId, address indexed donor, uint256 amount);

    // Variable to keep track of content ID
    uint256 public contentCount;

    // Function to add new educational content
    function addContent(string memory _title, string memory _description) public {
        contentCount++;
        contents[contentCount] = Content({
            title: _title,
            description: _description,
            totalDonations: 0,
            creator: msg.sender
        });
    }

    // Function to donate to a specific educational content
    function donate(uint256 _contentId) public payable {
        require(_contentId > 0 && _contentId <= contentCount, "Content does not exist.");
        require(msg.value > 0, "Donation must be greater than zero.");

        // Update the total donations for the content
        contents[_contentId].totalDonations += msg.value;

        // Update the donor's contribution to the content
        donations[_contentId][msg.sender] += msg.value;

        // Emit an event to log the donation
        emit DonationReceived(_contentId, msg.sender, msg.value);
    }

    // Function to withdraw funds by content creator (the owner of the content)
    function withdrawFunds(uint256 _contentId) public {
        require(_contentId > 0 && _contentId <= contentCount, "Content does not exist.");
        require(contents[_contentId].creator == msg.sender, "Only the content creator can withdraw funds.");

        uint256 amountToWithdraw = contents[_contentId].totalDonations;
        require(amountToWithdraw > 0, "No funds available to withdraw.");

        // Reset the total donations after withdrawal
        contents[_contentId].totalDonations = 0;

        // Transfer funds to the content creator
        payable(msg.sender).transfer(amountToWithdraw);
    }

    // Function to get details of a specific content
    function getContentDetails(uint256 _contentId) public view returns (string memory title, string memory description, uint256 totalDonations, address creator) {
        require(_contentId > 0 && _contentId <= contentCount, "Content does not exist.");

        Content memory content = contents[_contentId];
        return (content.title, content.description, content.totalDonations, content.creator);
    }

    // Function to get the donation amount from a specific donor to a specific content
    function getDonationAmount(uint256 _contentId, address _donor) public view returns (uint256) {
        require(_contentId > 0 && _contentId <= contentCount, "Content does not exist.");
        return donations[_contentId][_donor];
    }
}
