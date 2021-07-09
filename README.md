# Lottery
Chainlink fueled ETH lottery with real-time USD based entry fee

Using smartcontractkit/box Chainlink truffle box.
All dependencies not part of this project
Use truffle unbox smartcontractkit/box and npm install to get necessary packages.

Lottery accepts entry if opened by owner (LOTTERY_STATE.OPEN)
Owner can choose to initiate draw, true random number is requested via VRFCoordinator.
Winner is chosen.

Entry fee is 50 USD worth of ETH minimum.
Computed based on real time price feeds.
