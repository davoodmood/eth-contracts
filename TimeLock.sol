// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title A title that should describe the contract/interface
/// @author Davood Hakimi Mood (aka. David Mood)
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract ITimeLock {
    address public owner;

    function _checkNotOwner() private {}
    function queue() external {}
    function execute() external {}
}

contract TimeLock {

    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint256 blockTimeStamp, uint256 timeStamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimeStamp, uint256 timeStamp);
    error TimestampExpiredError(uint256 blockTimeStamp, uint256 expiresAt);

    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        string func,
        bytes data,
        uint timestamp
    );

    event Executed(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        string func,
        bytes data,
        uint timestamp
    );

    event Cancel(
        bytes32 indexed txId,
    );

    
    uint32 public constant MIN_DELAY;
    uint32 public constant MAX_DELAY;
    uint32 public constant GRACE_PERIOD;

    address public owner;
    mapping(address => bool) public queued;

    constructor() {
        owner = msg.sender;
        MIN_DELAY = 2 weeks;
        MAX_DELAY = 30 days;
        GRACE_PERIOD = 1000;
    }

    function _checkNotOwner() private {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
    }

    modifier onlyOwner() {
        _checkNotOwner();
        _;
    }

    function getTxId(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure returns(bytes32 txId) {
        return keccack256(
            abi.encode(
                _target, _value, _func, _data, _timestamp
            )
        );
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function queue (
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external onlyOwner {
        // create tx id
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check tx id  is unique
        if(queued[txId]) {
            revert AlreadyQueuedError(txId);
        }
        // check timestamp
        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }
        // queue tx 
        queued[txId] = true;

        emit Queue(
            txId, _target, _value, _func, _data, _timestamp
        );
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function execute(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable onlyOwner returns(bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        // check tx is queued
        if (!queued[txId]) {
            revert NotQueuedError(txId);
        }

        // check block.timestamp > _timestamp
        if (
             block.timestamp < _timestamp
        ) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }

        // ---------|---------------------------|------------
        // timestamp                 timestamp + grace period
        uint64 gracePeriod = GRACE_PERIOD; 
        if (block.timestamp > _timestamp + gracePeriod) {
            revert TimestampExpiredError(block.timestamp, _timestamp + gracePeriod);
        }

        // delete tx from queue
        queued[txId] = false;

        // execute the tx
        bytes memory data;
        if (bytes[_func].length > 0) {
            data = abi.encodePacked(
                bytes4(keccack256(bytes(_func))), 
                _data
            );
        } else {
            data = _data;
        }

        (bool ok, bytes memory response) = _target.call{value: _value}(data);
        if (!ok) {
            revert TxFailedError();
        }

        emit Executed(txId, _target, _value, _func, _data, _timestamp);

        return response;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        if (!queued[_txId]) {
            revert NotQueuedError(_txId);
        }

        queued[_txId] = false;
        emit Cancel(_txId);
    }

    receive() external payable {}
}

contract useTimeLockExample {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function exampleCheck() external {
        require(msg.sender == timeLock);

        // more code here e.g. 
        // - upgrade contracts
        // - transfer funds
        // - switch price oracle

    }
}