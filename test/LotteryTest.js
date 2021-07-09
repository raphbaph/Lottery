
const { assert } = require('chai')
const truffleAssert = require('truffle-assertions')

contract('Lottery', accounts => {
    const Lottery = artifacts.require('Lottery')
    const VRFCoordinatorMock = artifacts.require('VRFCoordinatorMock')
    const MockPriceFeed = artifacts.require('MockV3Aggregator')

    const { LinkToken } = require('@chainlink/contracts/truffle/v0.4/LinkToken')

    const defaultAccount = accounts[0]
    const player1 = accounts[1]
    const player2 = accounts[2]
    const player3 = accounts[3]

    let lottery, vrfCoordinatorMock, seed, link, keyhash, fee, mockPriceFeed

    describe('#requests a random number', () =>{
        let price='200000000000'
        beforeEach(async () =>{
            keyhash = '0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4'
            fee = '100000000000000000'
            seed = 123
            mockPriceFeed = await MockPriceFeed.new(8, price, {from: defaultAccount})
            link = await LinkToken.new( {from: defaultAccount} )
            vrfCoordinatorMock = await VRFCoordinatorMock.new(link.address, {from: defaultAccount})
            lottery = await Lottery.new(mockPriceFeed.address, vrfCoordinatorMock.address, link.address, keyhash)
        })

        it('starts in a closed state', async () => {
            console.log("Here now!")
            // assert(await Lottery.lotteryState() == 1)
        })
    })
})