import { task } from "hardhat/config"
import { boolean, string } from "hardhat/internal/core/params/argumentTypes";

task("upgrade_finance_department", "Upgrade FinanceDepartment contract")
    .addParam("proxyAddress", "Proxy address", undefined, string, false)
    .addParam("verify", "Verify contract", false, boolean, true)
    .setAction(async (taskArguments, hre, runSuper) => {
        await hre.run("compile");
        const financeDepartment = require("../scripts/finance_department");
        await financeDepartment.upgrade(taskArguments.proxyAddress, taskArguments.verify);
    });