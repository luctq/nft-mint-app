import { useEffect, useState } from 'react';
import { web3 } from '../provider/web3';
function WalletBalance() {
  const [balance, setBalance] = useState();

  const getBalance = async () => {
    const [account] = await window.ethereum.request({
      method: 'eth_requestAccounts',
    });
    const balance = await web3.eth.getBalance('account');

    setBalance(web3.utils.fromWei(balance, 'ether'));
  };

  return (
    <div className='card'>
      <div className='card-body'>
        <h5 className='card-title'>Your Balance: {balance}</h5>
        <button className='btn btn-success' onClick={() => getBalance()}>
          Show My Balance
        </button>
      </div>
    </div>
  );
}

export default WalletBalance;
