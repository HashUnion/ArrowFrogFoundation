import hardhat, { ethers, upgrades } from "hardhat";

async function deploy(verify: boolean): Promise<string> {
  const FinanceDepartment = await ethers.getContractFactory("FinanceDepartment");
  const financeDepartment = await upgrades.deployProxy(FinanceDepartment, {
    initializer: 'initialize',
    kind: 'uups'
  });
  await financeDepartment.deployed();
  console.info(`FinanceDepartment deployed to ${financeDepartment.address}`);

  if (verify) {
    const verifyFinanceDepartment = new Promise(f => setTimeout(f, 5000)).then(async () => {
      await hardhat.run("verify:verify", {
        address: await (hardhat as any).upgrades.erc1967.getImplementationAddress(financeDepartment.address),
        constructorArguments: [],
      });
      console.info("FinanceDepartment verified")
    }).catch((error) => console.error(error));
    await verifyFinanceDepartment;
  }
  return financeDepartment.address;
};

async function upgrade(proxyAddress: string, verify: boolean) {
  if (proxyAddress == undefined || proxyAddress.length <= 0) throw Error("INVAILD PROXY_ADDRESS")

  const FinanceDepartment = await ethers.getContractFactory("FinanceDepartment");
  const implementationAddress = await upgrades.prepareUpgrade(proxyAddress, FinanceDepartment, { kind: 'uups' });
  console.info(`FinanceDepartment upgraded to ${implementationAddress.valueOf()}`);

  if (verify) {
    const verifyFinanceDepartment = new Promise(f => setTimeout(f, 5000)).then(async () => {
      await hardhat.run("verify:verify", {
        address: implementationAddress,
        constructorArguments: [],
      });
      console.info(`FinanceDepartment verified`)
    }).catch((error) => console.error(error));
    await verifyFinanceDepartment;
  }
}

async function setFundSharesToken(contract: string, fundSharesToken: string) {
  const FinanceDepartment = await ethers.getContractFactory("FinanceDepartment");
  const financeDepartment = FinanceDepartment.attach(contract);
  await financeDepartment.setFundSharesToken(fundSharesToken);
  console.info(`Fund shares token set to ${fundSharesToken}`);
};

module.exports = { deploy, upgrade, setFundSharesToken }
