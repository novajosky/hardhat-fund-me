const { getNamedAccounts, deployments, network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]

    

    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [], // pricefeed address
        log: true,
    })

}