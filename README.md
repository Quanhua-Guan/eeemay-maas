# 👛 MultiSigMagician (MaltiSig as Service)

> EeeMay is learning 🚀 Thanks to [stevenpslade](https://github.com/stevenpslade), my repo was based on my learning from his [maas](https://github.com/stevenpslade/maas) repo.


# 🏄‍♂️ Quick Start

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone the code:

```bash
git clone https://github.com/Quanhua-Guan/eeemay-maas.git maas
cd maas
```

> install and start your 👷‍ Hardhat chain:

```bash
cd maas
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd maas
yarn start
```

> in a third ternal window, start your backend:

```
cd maas
yarn backend
```

> in a fourth terminal window, 🛰 deploy your contract:

```bash
cd maas
yarn deploy
```

> Open `http://localhost:3000/`, the MultiSigMagician and his magical MaltiSigWallet are alive.

# 🧙‍♂️ MultiSigMagician.sol
Make sure you go through the code at least one time, knowning that MultiSigMagician will create and keep track of each MultiSigWallet.

# 👛 MultiSigWallet.sol
- First, bake up `MultiSigWallet.sol` file to any where you like.
- Second, go through the code and comments, understanding the logic.
- ❤️ DELETE ALL CODE:  in `MultiSigWallet.sol` delete all solidity code, but keep the comments there.
- Write the code yourself again based on your understanding of `MultiSigWallet`, you may change the class name, function name, etc (although it may leads to frontend failed, try to fix them by yourself, and you will learn more about React).

You may do this part multiple times if you like. 

Play with it at `http://localhost:3000/`.

# 🤖 Backend
You can use [Heroku](https://www.heroku.com/). (You can skip this part if you are not interested).
1. you need to create your account,
2. create a app, 
3. deploy the backend code (take a look of the code at `packeges/backend/` or fork and use this [repo](https://github.com/Quanhua-Guan/EeeMay-maas-backend.git), the code is the same),
4. when deploy done, make sure your backend app is up, then get the deployed app server url and  replace `https://backend-eeemay-maas.herokuapp.com/` with your server url in `App.jsx`.
5. If you have any problem, take a look of [Heroku supports](https://devcenter.heroku.com/).

# ⚙️ Test & Deploy & Build & Surge
- `yarn test` make sure you pass all test cases.
- Change `defaultNetwork` (in `packages/hardhat/hardhat.config.js` line `30`) from `localhost` to `rinkeby`.
- Change `initialNetwork` (in `packages/react-app/src/App.jsx` line 62) from `NETWORKS.localhost` to `NETWORKS.rinkeby`.
- `yarn deploy` or `yarn deploy --reset` as your wish.
- `yarn build` and `yarn surge`

# ❤️ Finally, I can help
Twitter [@xinmuheart](https://twitter.com/xinmuheart)  (follow me will be appreciated)
Telegrame [@EeeMay](https://telegram.me/EeeeMay)

