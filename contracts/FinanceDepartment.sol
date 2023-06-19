// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IFinanceDepartment.sol";
import "./FundSharesToken.sol";

import "hardhat/console.sol";

contract FinanceDepartment is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    IFinanceDepartment
{
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    struct AcceptableToken {
        uint256 id;
        address token;
        uint256 inValue;
        uint256 outValue;
    }

    address private _fundSharesToken;
    Counters.Counter private _acceptableTokenIdCounter;
    mapping(uint256 => AcceptableToken) private _acceptableTokens;
    mapping(uint256 => mapping(address => uint256)) _stakings;

    function __FinanceDepartment_init() internal onlyInitializing {
        __UUPSUpgradeable_init();
        __Ownable_init();
        __FinanceDepartment_init_unchained();
    }

    function __FinanceDepartment_init_unchained() internal onlyInitializing {}

    function _authorizeUpgrade(
        address /*newImplementation_*/
    ) internal override onlyOwner {}

    function initialize() external initializer {
        _transferOwnership(msg.sender);
    }

    receive() external payable {}

    event SetFundSharesToken(address token_);

    function setFundSharesToken(address token_) external {
        _fundSharesToken = token_;
        emit SetFundSharesToken(token_);
    }

    event AddAcceptableToken(
        address token_,
        uint256 inValue_,
        uint256 outValue_
    );

    function addAcceptableToken(
        address token_,
        uint256 inValue_,
        uint256 outValue_
    ) external onlyOwner {
        _acceptableTokenIdCounter.increment();
        uint256 id = _acceptableTokenIdCounter.current();
        _acceptableTokens[id].id = id;
        _acceptableTokens[id].token = token_;
        _acceptableTokens[id].inValue = inValue_;
        _acceptableTokens[id].outValue = outValue_;
        emit AddAcceptableToken(token_, inValue_, outValue_);
    }

    function _getAcceptableTokens()
        internal
        view
        returns (AcceptableToken[] memory)
    {
        AcceptableToken[] memory tokens = new AcceptableToken[](
            _acceptableTokenIdCounter.current()
        );
        for (uint256 i; i < _acceptableTokenIdCounter.current(); i++) {
            tokens[i] = _acceptableTokens[i + 1];
        }
        return tokens;
    }

    function _getAcceptableToken(
        address token_
    ) internal view returns (AcceptableToken memory) {
        AcceptableToken[] memory tokens = _getAcceptableTokens();
        for (uint256 i; i < tokens.length; i++) {
            if (tokens[i].token == token_) return tokens[i];
        }
        revert("token not accepted");
    }

    event RemoveAcceptableToken(address token_);

    function removeAcceptableToken(address token_) external onlyOwner {
        AcceptableToken memory token = _getAcceptableToken(token_);
        delete _acceptableTokens[token.id];
        emit RemoveAcceptableToken(token_);
    }

    function getAcceptableTokenList() external returns (address[] memory) {}

    event SetAcceptableTokenPrice(
        address token_,
        uint256 inValue_,
        uint256 outValue_
    );

    function setAcceptableTokenPrice(
        address token_,
        uint256 inValue_,
        uint256 outValue_
    ) external onlyOwner {
        AcceptableToken memory token = _getAcceptableToken(token_);
        _acceptableTokens[token.id].inValue = inValue_;
        _acceptableTokens[token.id].outValue = outValue_;
        emit SetAcceptableTokenPrice(token_, inValue_, outValue_);
    }

    function _getAcceptableTokenPrice(
        uint256 tokenId_
    ) internal view returns (uint256 inValue_, uint256 outValue_) {
        return (
            _acceptableTokens[tokenId_].inValue,
            _acceptableTokens[tokenId_].outValue
        );
    }

    function getAcceptableTokenPrice(
        address token_
    ) external view returns (uint256 inValue_, uint256 outValue_) {
        AcceptableToken memory token = _getAcceptableToken(token_);
        return _getAcceptableTokenPrice(token.id);
    }

    event Stake(address operator_, address token_, uint256 amount_);

    function stake(address token_, uint256 amount_) external payable {
        if (token_ == address(0x0)) {
            require(msg.value >= amount_, "insufficient available balance");
        } else {
            IERC20 erc20Token = IERC20(token_);
            require(
                erc20Token.allowance(msg.sender, address(this)) >= amount_,
                "insufficient available balance"
            );
            erc20Token.safeTransferFrom(msg.sender, address(this), amount_);
        }
        AcceptableToken memory token = _getAcceptableToken(token_);
        (uint256 inValue, uint256 outValue) = _getAcceptableTokenPrice(
            token.id
        );
        uint256 fundSharesAmount = (amount_ * outValue) / inValue;
        require(fundSharesAmount > 0, "below the minimum share");
        _stakings[token.id][msg.sender] += amount_;
        FundSharesToken(_fundSharesToken).mint(msg.sender, fundSharesAmount);
        emit Stake(msg.sender, token_, amount_);
    }

    function _getStake(uint256 tokenId_) internal view returns (uint256) {
        return _stakings[tokenId_][msg.sender];
    }

    function getStake(address token_) external view returns (uint256) {
        AcceptableToken memory token = _getAcceptableToken(token_);
        return _getStake(token.id);
    }

    event Withdraw(address operator_, address token_, uint256 amount_);

    function withdraw(address token_, uint256 amount_) external {
        AcceptableToken memory token = _getAcceptableToken(token_);
        uint256 stakeAmount = _getStake(token.id);
        require(stakeAmount >= amount_, "insufficient available stake");
        (uint256 inValue, uint256 outValue) = _getAcceptableTokenPrice(
            token.id
        );
        uint256 fundSharesAmount = (amount_ * outValue) / inValue;
        require(fundSharesAmount > 0, "below the minimum share");
        FundSharesToken fundSahres = FundSharesToken(_fundSharesToken);
        require(
            fundSahres.balanceOf(msg.sender) >= fundSharesAmount,
            "insufficient available fund shares"
        );
        _stakings[token.id][msg.sender] -= amount_;
        FundSharesToken(_fundSharesToken).burn(msg.sender, fundSharesAmount);
        if (token_ == address(0x0)) {
            payable(msg.sender).transfer(amount_);
        } else {
            IERC20(token_).safeTransfer(msg.sender, amount_);
        }
        emit Withdraw(msg.sender, token_, amount_);
    }
}
