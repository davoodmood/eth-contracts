// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

/// @title A title that should describe the contract/interface
/// @author Davood Hakimi Mood (aka. David Mood)
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract Vault {
    
    /// @notice When user deposits, we mint shares (tokens), when user withdraws we burn shares (tokens)
    /// @dev Explain to a developer any extra details
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function _mint(address _to, uint _amount) private {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function _burn(address _from, uint _amount) private {
        totalSupply -= _amount;
        balanceOf[_from] -= _amount;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function deposit(uint _amount) external {
        uint shares;
        if (totalSupply == 0) {
            shares = amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
        /*
            a = amount
            B = balance of token before deposit
            T = total supply
            s = shares to mint

            (T + s) / T = (a + B) / B

            s = aT / B
        */
    }

    function withdraw(uint256 _shares) external {

        uint amount = _shares * token.balanceOf(address(this)) / totalSupply;

        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
        
        /*
            a = amount
            B = balance of token before withdraw
            T = total supply
            s = shares to burn

            (T - s) / T = (B - a) / B
            
            a = sB / T
            Amount to Withdraw = #shares multiplied by Balance of shares in this contract  _devided by_  total shares
        */
    }
}