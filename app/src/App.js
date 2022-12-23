import Home from './components/Home';
import InstallWallet from './components/InstallWallet';

function App() {
  if (window.ethereum) {
    return <Home />;
  } else {
    return <InstallWallet />;
  }
}

export default App;
