// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '../token/IToken.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PropertyGovernance is Ownable {
    struct Proposal {
        address token;
        bytes32 metadataHash;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 totalTokensAtStart;
        bool finalized;
        bool result; // true for PASSED, false for FAILED
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 indexed id, address indexed token, bytes32 metadataHash, uint256 endTime);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalFinalized(uint256 indexed proposalId, bool result, uint256 yesVotes, uint256 noVotes);

    function propose(address _token, bytes32 _metadataHash, uint256 _duration) external onlyOwner returns (uint256) {
        uint256 totalTokens = IToken(_token).totalSupply();
        uint256 proposalId = proposals.length;

        proposals.push(
            Proposal({
                token: _token,
                metadataHash: _metadataHash,
                startTime: block.timestamp,
                endTime: block.timestamp + _duration,
                yesVotes: 0,
                noVotes: 0,
                totalTokensAtStart: totalTokens,
                finalized: false,
                result: false
            })
        );

        emit ProposalCreated(proposalId, _token, _metadataHash, block.timestamp + _duration);
        return proposalId;
    }

    function castVote(uint256 _proposalId, bool _support) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.endTime, 'Voting ended');
        require(!proposal.finalized, 'Proposal finalized');
        require(!hasVoted[_proposalId][msg.sender], 'Already voted');

        uint256 weight = IToken(proposal.token).balanceOf(msg.sender);
        require(weight > 0, 'No voting power');

        if (_support) {
            proposal.yesVotes += weight;
        } else {
            proposal.noVotes += weight;
        }

        hasVoted[_proposalId][msg.sender] = true;
        emit VoteCast(_proposalId, msg.sender, _support, weight);
    }

    function finalize(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, 'Voting still active');
        require(!proposal.finalized, 'Already finalized');

        uint256 totalVotes = proposal.yesVotes + proposal.noVotes;
        uint256 quorumThreshold = (proposal.totalTokensAtStart * 20) / 100;

        if (totalVotes >= quorumThreshold && proposal.yesVotes > proposal.noVotes) {
            proposal.result = true;
        } else {
            proposal.result = false;
        }

        proposal.finalized = true;
        emit ProposalFinalized(_proposalId, proposal.result, proposal.yesVotes, proposal.noVotes);
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }
}
