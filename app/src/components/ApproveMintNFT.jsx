import { useEffect, useState } from 'react';
import { web3 } from '../provider/web3';
import { getCurrentAccount, contract, isOwner } from '../provider/web3';
import { getRPCErrorMessage } from '../utils/errorMessge';

function ApproveMintNFT() {
  const [address, setAddress] = useState('');
  const [validateMessage, setValidateMessage] = useState('');

  const getBalance = async () => {
    const [account] = await window.ethereum.request({
      method: 'eth_requestAccounts',
    });
    const balance = await web3.eth.getBalance('account');
  };

  const approveAccount = async () => {
    const currentAccount = await getCurrentAccount();
    // console.log(currentAccount);
    // console.log(await isOwner(currentAccount));
    if (!address) {
      setValidateMessage('You must type address to approve');
    } else {
      try {
        if (await isOwner(currentAccount)) {
          await contract.methods
            .setApprovedOperator(address, true)
            .send({ from: currentAccount });
          alert(`Approve permission mint nft succcess for account ${address}`);
          setAddress('');
        } else {
          alert('Only owner can approve');
        }
      } catch (e) {
        alert(e);
      }
    }
  };

  const rejectAccount = async () => {
    const currentAccount = await getCurrentAccount();
    if (!address) {
      setValidateMessage('You must type address to reject');
    } else {
      try {
        await contract.methods
          .setApprovedOperator(address, false)
          .send({ from: currentAccount });
        alert(`Reject permission mint nft succcess for account ${address}`);
        setAddress('');
      } catch (e) {
        alert(e);
      }
    }
  };

  return (
    <div className='card w-full'>
      <div className='card-body'>
        <h5 className='card-title'>Approve or Reject to other account</h5>
        <div className='input-group gap-1'>
          <input
            type='text'
            className='form-control'
            placeholder='Wallet address'
            onChange={(event) => {
              setValidateMessage('');
              setAddress(event.target.value);
            }}
          />
          <div className='input-group-append'>
            <button
              className='btn btn-success'
              onClick={() => approveAccount()}
            >
              Aprrove
            </button>
            <button className='btn btn-danger' onClick={() => rejectAccount()}>
              Reject
            </button>
          </div>
        </div>
        <p className='text-danger'>{validateMessage}</p>
      </div>
    </div>
  );
}

export default ApproveMintNFT;
