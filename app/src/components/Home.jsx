import WalletBalance from '../components/WalletBalance';
import { useEffect, useState } from 'react';
import { web3 } from '../provider/web3';
import Luctq from '../artifacts/contracts/NFT/Luctq.sol/Luctq.json';

const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';

// // get the smart contract
const contract = new web3.eth.Contract(Luctq.abi, contractAddress);

function Home() {
  const [totalMinted, setTotalMinted] = useState(0);
  useEffect(() => {
    totalNFTMinted();
  }, []);

  const totalNFTMinted = async () => {
    const count = await contract.methods.lastestTokenId().call();
    setTotalMinted(parseInt(count));
  };

  const catchError = async () => {
    try {
      const tokenURI = await contract.methods.tokenURI(10).call();
    } catch (e) {
      const data = e.data;
      const txHash = Object.keys(data)[0]; // TODO improve
      const reason = data[txHash].reason;

      console.log(reason);
    }
  };

  return (
    <div>
      <WalletBalance />
      <button className='btn btn-danger' onClick={() => catchError()}>
        catchError
      </button>
      <div></div>
      <div className='w-full m-5'>
        <div className='row gy-5'>
          {Array(totalMinted + 1)
            .fill(0)
            .map((_, i) => (
              <div key={i} className='col'>
                <NFTImage tokenId={i} totalNFTMinted={totalNFTMinted} />
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}

function NFTImage({ tokenId, totalNFTMinted }) {
  const contentId = 'QmTBxFm3SU3pmWQgGzb2ApZe9oMD6amZCAkyVa6HyvMDxB';
  const metadataURI = `${contentId}/${tokenId}.json`;
  const imageURI = `https://gateway.pinata.cloud/ipfs/${contentId}/${tokenId}.png`;

  const [isMinted, setIsMinted] = useState(false);
  useEffect(() => {
    getMintedStatus();
  }, [isMinted]);

  const getMintedStatus = async () => {
    const result = await contract.methods.isContentOwned(tokenId).call();
    setIsMinted(result);
  };

  const mintToken = async () => {
    const recipient = '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC';
    const result = await contract.methods
      .mintNFT(recipient, metadataURI)
      .send({ from: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266' });
    getMintedStatus();
    totalNFTMinted();
  };

  async function getURI() {
    const uri = await contract.methods.tokenURI(tokenId).call();
    alert(uri);
  }
  return (
    <div className='card' style={{ width: '18rem' }}>
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
