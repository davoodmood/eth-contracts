// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title A title that should describe the contract/interface
/// @author Davood Hakimi Mood (aka. David Mood)
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract ITimeLock {
    function queue() external {}
    function execute() external {}
}

contract TimeLock {

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function queue() external {}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function execute() external {}
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