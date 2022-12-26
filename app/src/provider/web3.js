import Luctq from '../artifacts/contracts/NFT/Luctq.sol/Luctq.json';
const Web3 = require('web3');
export const web3 = new Web3(window.ethereum);

export const getCurrentAccount = async () => {
  const [account] = await web3.eth.getAccounts();
  return account;
};
const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';

// get the smart contract
export const contract = new web3.eth.Contract(Luctq.abi, contractAddress);

export const isOwner = async (address) => {
  const owner = await contract.methods.owner().call();
  return address === owner;
};
