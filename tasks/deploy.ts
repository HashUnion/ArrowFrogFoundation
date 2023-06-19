import { task } from "hardhat/config"
import { boolean } from "hardhat/internal/core/params/argumentTypes";

task("deploy_finance_department", "Deploy FinanceDepartment contract")
    .addParam("verify", "Verify contract", false, boolean, true)
    .setAction(async (taskArguments, hre, runSuper) => {
        await hre.run("compile");
        const financeDepartment = require("../scripts/finance_department");
        const fundSharesToken = require("../scripts/fund_shares_token");
        const financeDepartmentContract = await financeDepartment.deploy(taskArguments.verify);
        const fundSharesTokenContract = await fundSharesToken.deploy(financeDepartmentContract, taskArguments.verify);
        await financeDepartment.setFundSharesToken(financeDepartmentContract, fundSharesTokenContract);
    });