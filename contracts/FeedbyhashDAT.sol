// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FeedbyhashDAT {
    address public owner;
    address public writer;

    struct RewardRecord {
        address sender;
        uint256 amount;
        uint8 status;
        uint256 updatedAt;
        uint256 updates;
    }

    mapping(uint256 => RewardRecord) public rewards;

    event RewardRecorded(
        uint256 indexed rewardId,
        address indexed sender,
        uint256 amount,
        uint8 status,
        uint256 timestamp
    );

    event WriterUpdated(address indexed oldWriter, address indexed newWriter);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier onlyWriter() {
        require(msg.sender == writer, "only writer");
        _;
    }

    constructor(address initialOwner, address initialWriter) {
        require(initialOwner != address(0), "owner required");
        require(initialWriter != address(0), "writer required");
        owner = initialOwner;
        writer = initialWriter;
    }

    function setWriter(address newWriter) external onlyOwner {
        require(newWriter != address(0), "writer required");
        address old = writer;
        writer = newWriter;
        emit WriterUpdated(old, newWriter);
    }

    function recordReward(
        uint256 rewardId,
        uint256 amount,
        uint8 status
    ) external onlyWriter {
        RewardRecord storage r = rewards[rewardId];
        r.sender = msg.sender;
        r.amount = amount;
        r.status = status;
        r.updatedAt = block.timestamp;
        r.updates += 1;

        emit RewardRecorded(
            rewardId,
            msg.sender,
            amount,
            status,
            block.timestamp
        );
    }

    function recordRewardsBatch(
        uint256[] calldata rewardIds,
        uint256[] calldata amounts,
        uint8[] calldata statuses
    ) external onlyWriter {
        uint256 len = rewardIds.length;
        require(len == amounts.length, "length mismatch");
        require(len == statuses.length, "length mismatch");

        for (uint256 i = 0; i < len; i++) {
            RewardRecord storage r = rewards[rewardIds[i]];
            r.sender = msg.sender;
            r.amount = amounts[i];
            r.status = statuses[i];
            r.updatedAt = block.timestamp;
            r.updates += 1;

            emit RewardRecorded(
                rewardIds[i],
                msg.sender,
                amounts[i],
                statuses[i],
                block.timestamp
            );
        }
    }
}

