"use client";

import { useState } from "react";
import { useContractWrite } from "wagmi";
import { predictionMarketABI } from "../utils/predictionMarketABI";

const CONTRACT_ADDRESS = "0x765Cd0FaB1Cdccd2997582eFAa2e88876287210e";

export default function CreateMarket() {
  const [question, setQuestion] = useState("");
  const [duration, setDuration] = useState("");

  const {
    write: createMarket,
    isLoading,
    isSuccess,
  } = useContractWrite({
    address: CONTRACT_ADDRESS,
    abi: predictionMarketABI,
    functionName: "createMarket",
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    createMarket({
      args: [question, BigInt(Number(duration) * 24 * 60 * 60)], // Convert days to seconds
    });
  };

  return (
    <div className="mt-8">
      <h2 className="text-2xl font-bold mb-4">Create New Market</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label
            htmlFor="question"
            className="block text-sm font-medium text-gray-700"
          >
            Question
          </label>
          <input
            type="text"
            id="question"
            value={question}
            onChange={(e) => setQuestion(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
            required
          />
        </div>
        <div>
          <label
            htmlFor="duration"
            className="block text-sm font-medium text-gray-700"
          >
            Duration (in days)
          </label>
          <input
            type="number"
            id="duration"
            value={duration}
            onChange={(e) => setDuration(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
            required
          />
        </div>
        <button
          type="submit"
          disabled={isLoading}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
        >
          {isLoading ? "Creating..." : "Create Market"}
        </button>
      </form>
      {isSuccess && (
        <div className="mt-4 text-green-600">Market created successfully!</div>
      )}
    </div>
  );
}
