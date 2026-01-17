const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("Starting MonadCLOB deployment...\n");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), "ETH\n");

  // 1. Deploy MonadCLOB
  console.log("Deploying MonadCLOB...");
  const MonadCLOB = await hre.ethers.getContractFactory("MonadCLOB");
  const monadCLOB = await MonadCLOB.deploy();
  await monadCLOB.waitForDeployment();
  const clobAddress = await monadCLOB.getAddress();
  console.log("MonadCLOB deployed to:", clobAddress);

  // 2. Deploy mock tokens (for testnet)
  console.log("\nDeploying mock tokens...");

  const MockERC20 = await hre.ethers.getContractFactory("MockERC20");

  const monadToken = await MockERC20.deploy("Monad Token", "MONAD", 18);
  await monadToken.waitForDeployment();
  const monadAddress = await monadToken.getAddress();
  console.log("MONAD Token deployed to:", monadAddress);

  const usdcToken = await MockERC20.deploy("USD Coin", "USDC", 6);
  await usdcToken.waitForDeployment();
  const usdcAddress = await usdcToken.getAddress();
  console.log("USDC Token deployed to:", usdcAddress);

  const wethToken = await (await hre.ethers.getContractFactory("MockWETH")).deploy();
  await wethToken.waitForDeployment();
  const wethAddress = await wethToken.getAddress();
  console.log("WETH Token deployed to:", wethAddress);

  // 3. Create MONAD/USDC pair
  console.log("\nCreating MONAD/USDC trading pair...");
  const tickSize = hre.ethers.parseUnits("0.01", 6); // 0.01 USDC tick size
  const minOrderSize = hre.ethers.parseEther("1"); // 1 MONAD minimum order

  const createPairTx = await monadCLOB.createPair(
    monadAddress,
    usdcAddress,
    tickSize,
    minOrderSize
  );
  await createPairTx.wait();

  const pairId = await monadCLOB.getPairId(monadAddress, usdcAddress);
  console.log("MONAD/USDC pair created with ID:", pairId);

  // 4. Fund test accounts
  console.log("\nFunding test accounts...");
  const fundAmount = hre.ethers.parseEther("10000");
  const fundAmountUSDC = hre.ethers.parseUnits("10000", 6);

  const accounts = await hre.ethers.getSigners();
  const testAccounts = accounts.slice(0, 5); // Fund first 5 accounts

  for (const account of testAccounts) {
    await monadToken.mint(account.address, fundAmount);
    await usdcToken.mint(account.address, fundAmountUSDC);
    console.log(`Funded ${account.address}`);
  }

  // 5. Save deployment info
  console.log("\nSaving deployment information...");

  const deploymentInfo = {
    network: hre.network.name,
    chainId: (await hre.ethers.provider.getNetwork()).chainId.toString(),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      MonadCLOB: {
        address: clobAddress,
        abi: "artifacts/contracts/MonadCLOB.sol/MonadCLOB.json"
      },
      MONAD: {
        address: monadAddress,
        symbol: "MONAD",
        decimals: 18
      },
      USDC: {
        address: usdcAddress,
        symbol: "USDC",
        decimals: 6
      },
      WETH: {
        address: wethAddress,
        symbol: "WETH",
        decimals: 18
      }
    },
    pairs: {
      "MONAD/USDC": {
        pairId: pairId,
        token0: monadAddress,
        token1: usdcAddress,
        tickSize: tickSize.toString(),
        minOrderSize: minOrderSize.toString()
      }
    }
  };

  // Save to deployments directory
  const deploymentsDir = path.join(__dirname, "..", "deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  const deploymentFile = path.join(deploymentsDir, `${hre.network.name}.json`);
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));
  console.log(`Deployment info saved to: ${deploymentFile}`);

  // Copy ABI to frontend constants (if frontend directory exists)
  const frontendConstantsDir = path.join(__dirname, "..", "frontend", "lib", "core", "constants");
  if (fs.existsSync(path.join(__dirname, "..", "frontend"))) {
    if (!fs.existsSync(frontendConstantsDir)) {
      fs.mkdirSync(frontendConstantsDir, { recursive: true });
    }

    // Read ABI from artifacts
    const artifactPath = path.join(__dirname, "..", "artifacts", "contracts", "MonadCLOB.sol", "MonadCLOB.json");
    if (fs.existsSync(artifactPath)) {
      const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));

      // Create Dart constant file
      const dartContent = `// Auto-generated contract constants
// Generated: ${deploymentInfo.timestamp}
// Network: ${hre.network.name}

const String CLOB_CONTRACT_ADDRESS = '${clobAddress}';
const String MONAD_TOKEN_ADDRESS = '${monadAddress}';
const String USDC_TOKEN_ADDRESS = '${usdcAddress}';
const String WETH_TOKEN_ADDRESS = '${wethAddress}';

const String MONAD_USDC_PAIR_ID = '${pairId}';

const List<dynamic> CLOB_CONTRACT_ABI = ${JSON.stringify(artifact.abi, null, 2)};

const Map<String, dynamic> DEPLOYMENT_INFO = ${JSON.stringify(deploymentInfo, null, 2)};
`;

      const dartFile = path.join(frontendConstantsDir, "contract_constants.dart");
      fs.writeFileSync(dartFile, dartContent);
      console.log(`Contract constants saved to: ${dartFile}`);
    }
  }

  console.log("\n==============================================");
  console.log("Deployment Summary");
  console.log("==============================================");
  console.log("Network:", hre.network.name);
  console.log("MonadCLOB:", clobAddress);
  console.log("MONAD Token:", monadAddress);
  console.log("USDC Token:", usdcAddress);
  console.log("WETH Token:", wethAddress);
  console.log("MONAD/USDC Pair ID:", pairId);
  console.log("==============================================\n");

  console.log("Next steps:");
  console.log("1. Verify contracts on block explorer (if available)");
  console.log("2. Run stress test: npx hardhat run scripts/stress-test.js --network", hre.network.name);
  console.log("3. Start frontend: cd frontend && flutter run -d chrome");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
