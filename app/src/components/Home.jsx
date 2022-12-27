import WalletBalance from '../components/WalletBalance';
import { useEffect, useState } from 'react';
import { getRPCErrorMessage } from '../utils/errorMessge';
import { getCurrentAccount, contract, web3, isOwner } from '../provider/web3';
import ApproveMintNFT from './ApproveMintNFT';

function Home() {
  const [totalMinted, setTotalMinted] = useState(0);
  useEffect(() => {
    totalNFTMinted();
  }, []);

  const totalNFTMinted = async () => {
    try {
      const count = await contract.methods.lastestTokenId().call();
      setTotalMinted(parseInt(count));
    } catch (e) {
      alert(getRPCErrorMessage(e));
    }
  };

  return (
    <div className='row'>
      <div className='card shadow m-5 p-2 col-4 d-flex flex-column gap-3'>
        <img src='logo.png' alt='LOGO' height={150} className='mx-auto' />
        <WalletBalance />
        <ApproveMintNFT />
      </div>
      <div className='container m-5 col'>
        <h1>All NFT</h1>
        <div className='row gy-5'>
          {Array(totalMinted + 1)
            .fill(0)
            .map((_, i) => (
              <div key={i} className='col-md-4'>
                <NFTImage tokenId={i} totalNFTMinted={totalNFTMinted} />
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}

function NFTImage({ tokenId, totalNFTMinted }) {
  const contentId = 'QmQqQrqQF1eP1KADgQaMA4YBCw27anDHvYtPNfrW36tc8z';
  const metadataURI = `${contentId}/${tokenId}.json`;
  const imageURI = `https://gateway.pinata.cloud/ipfs/${contentId}/${tokenId}.svg`;

  const [isMinted, setIsMinted] = useState(false);
  useEffect(() => {
    getMintedStatus();
  }, [isMinted]);

  const getMintedStatus = async () => {
    try {
      const result = await contract.methods.isContentOwned(tokenId).call();
      setIsMinted(result);
    } catch (e) {
      alert(getRPCErrorMessage(e));
    }
  };

  // Min token for current account
  const mintToken = async () => {
    try {
      // get current account is connecting with metamask
      const currentAccount = await getCurrentAccount();
      if (await isOwner(currentAccount)) {
        const result = await contract.methods
          .mintNFT(currentAccount, metadataURI)
          .send({ from: currentAccount });
        getMintedStatus();
        totalNFTMinted();
      } else {
        alert('Only owner or aprrove account can mint NFT');
      }
    } catch (e) {
      alert(e.message);
    }
  };

  async function getURI() {
    try {
      const uri = await contract.methods.tokenURI(tokenId).call();
      alert(uri);
    } catch (e) {
      alert(e);
    }
  }
  return (
    <div className='card shadow' style={{ width: '18rem' }}>
      <img
        className='card-img-top'
        src={isMinted ? imageURI : 'image/placeholder.png'}
      ></img>
      <div className='card-body'>
        <h5 className='card-title'>ID #{tokenId}</h5>
        {!isMinted ? (
          <button className='btn btn-primary' onClick={mintToken}>
            Mint
          </button>
        ) : (
          <button className='btn btn-secondary' onClick={getURI}>
            Taken! Show URI
          </button>
        )}
      </div>
    </div>
  );
}

export default Home;
