"use client";

import ConnectWallet from "../components/ConnectWallet";
import MarketList from "../components/MarketList";
import CreateMarket from "../components/CreateMarket";

export default function Home() {
  return (
    <div className="min-h-screen bg-black-100 py-6 flex flex-col justify-center sm:py-12">
      <div className="relative py-3 sm:max-w-xl sm:mx-auto">
        <div className="absolute inset-0 bg-gradient-to-r from-cyan-400 to-blue-400 shadow-lg transform -skew-y-6 sm:skew-y-0 sm:-rotate-6 sm:rounded-3xl"></div>
        <div className="relative px-4 py-10 bg-grey shadow-lg sm:rounded-3xl sm:p-20">
          <h1 className="text-2xl font-bold mb-5 text-center">
            Decentralized Prediction Market
          </h1>
          <ConnectWallet />
          <CreateMarket />
          <MarketList />
        </div>
      </div>
    </div>
  );
}
