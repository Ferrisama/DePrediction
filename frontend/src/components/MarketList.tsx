"use client";

import { useState, useEffect } from "react";
import { useContractRead } from "wagmi";
import { predictionMarketABI } from "../utils/predictionMarketABI";

// Replace with your deployed contract address
const CONTRACT_ADDRESS = "0x765Cd0FaB1Cdccd2997582eFAa2e88876287210e";

interface Market {
  id: number;
  question: string;
  endTime: number;
  resolved: boolean;
  yesShares: number;
  noShares: number;
}

export default function MarketList() {
  const [markets, setMarkets] = useState<Market[]>([]);

  const { data: marketCount } = useContractRead({
    address: CONTRACT_ADDRESS,
    abi: predictionMarketABI,
    functionName: "marketCount",
  });

  useEffect(() => {
    const fetchMarkets = async () => {
      if (marketCount) {
        const marketsData = await Promise.all(
          Array.from({ length: Number(marketCount) }, (_, i) =>
            fetchMarketData(i)
          )
        );
        setMarkets(marketsData);
      }
    };

    fetchMarkets();
  }, [marketCount]);

  const fetchMarketData = async (id: number): Promise<Market> => {
    const { data } = await useContractRead({
      address: CONTRACT_ADDRESS,
      abi: predictionMarketABI,
      functionName: "markets",
      args: [id],
    });

    return {
      id,
      question: data[0],
      endTime: Number(data[1]),
      resolved: data[2],
      yesShares: Number(data[3]),
      noShares: Number(data[4]),
    };
  };

  return (
    <div className="mt-8">
      <h2 className="text-2xl font-bold mb-4">Prediction Markets</h2>
      {markets.map((market) => (
        <div
          key={market.id}
          className="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4"
        >
          <h3 className="text-xl font-semibold mb-2">{market.question}</h3>
          <p>Ends: {new Date(market.endTime * 1000).toLocaleString()}</p>
          <p>Yes Shares: {market.yesShares}</p>
          <p>No Shares: {market.noShares}</p>
          <p>Status: {market.resolved ? "Resolved" : "Open"}</p>
        </div>
      ))}
    </div>
  );
}
