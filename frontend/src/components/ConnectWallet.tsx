"use client";

import { useState, useEffect } from "react";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { metaMask } from "wagmi/connectors";

export default function ConnectWallet() {
  const { address, isConnected } = useAccount();
  const { connect, error: connectError } = useConnect();
  const { disconnect } = useDisconnect();
  const [isMetaMaskInstalled, setIsMetaMaskInstalled] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      setIsMetaMaskInstalled(!!window.ethereum?.isMetaMask);
    }
  }, []);

  const handleConnect = async () => {
    try {
      await connect({ connector: metaMask() });
    } catch (error) {
      console.error("Failed to connect:", error);
    }
  };

  if (!isMetaMaskInstalled) {
    return (
      <div className="text-red-500">
        MetaMask is not installed. Please install MetaMask to use this app.
      </div>
    );
  }

  if (isConnected) {
    return (
      <div className="flex flex-col items-center justify-center p-4">
        <p>Connected to {address}</p>
        <button
          onClick={() => disconnect()}
          className="mt-2 px-4 py-2 bg-red-500 text-white rounded"
        >
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center justify-center p-4">
      <button
        onClick={handleConnect}
        className="px-4 py-2 bg-blue-500 text-white rounded"
      >
        Connect Wallet
      </button>
      {connectError && (
        <p className="text-red-500 mt-2">Error: {connectError.message}</p>
      )}
    </div>
  );
}
