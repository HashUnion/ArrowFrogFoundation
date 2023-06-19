// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IFinanceDepartment {
    function setFundSharesToken(address token_) external;

    function addAcceptableToken(
        address token_,
        uint256 inValue_,
        uint256 outValue_
    ) external;

    function removeAcceptableToken(address token_) external;

    function setAcceptableTokenPrice(
        address token_,
        uint256 inValue_,
        uint256 outValue_
    ) external;

    function getStake(address token_) external view returns (uint256);

    function getAcceptableTokenPrice(
        address token_
    ) external view returns (uint256 inValue_, uint256 outValue_);

    function stake(address token_, uint256 amount_) external payable;

    function withdraw(address token_, uint256 amount_) external;
}
