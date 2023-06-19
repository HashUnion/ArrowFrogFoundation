import hardhat, { ethers } from "hardhat";

async function deploy(owner: string, verify: boolean): Promise<string> {
  const FundSharesToken = await ethers.getContractFactory("FundSharesToken");
  const fundSharesToken = await FundSharesToken.deploy(owner);
  console.info(`FundSharesToken deployed to ${fundSharesToken.address}`);

  if (verify) {
    const verifyFinanceDepartment = new Promise(f => setTimeout(f, 5000)).then(async () => {
      await hardhat.run("verify:verify", {
        address: fundSharesToken.address,
        constructorArguments: [owner],
      });
      console.info("FundSharesToken verified")
    }).catch((error) => console.error(error));
    await verifyFinanceDepartment;
  }
  return fundSharesToken.address;
};

module.exports = { deploy }
