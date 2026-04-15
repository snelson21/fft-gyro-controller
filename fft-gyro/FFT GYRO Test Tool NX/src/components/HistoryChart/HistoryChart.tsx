import React, { useState } from 'react';
import { Line } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

interface HistoryChartProps {
  dataHistory: Array<{
    timestamp: number;
    x?: number;
    y?: number;
    z?: number;
  }>;
  showRadians: boolean;
  axisMode: boolean;
}

const HistoryChart: React.FC<HistoryChartProps> = ({ dataHistory, showRadians = false, axisMode }) => {
  const [selectedOption, setSelectedOption] = useState<"real-time" | "1-second" | "5-seconds" | "10-seconds">("1-second");

  const getFilteredHistory = (
    historyOption: "real-time" | "1-second" | "5-seconds" | "10-seconds",
    dataHistory: Array<{
      timestamp: number;
      x?: number;
      y?: number;
      z?: number;
    }>
  ) => {
    const now = Date.now();

    switch (historyOption) {
      case "real-time":
        return dataHistory.slice(-150);

      case "1-second":
        return dataHistory.filter(point => point.timestamp >= now - 1000);

      case "5-seconds": {
        const filtered = dataHistory.filter(point => point.timestamp >= now - 5000);
        const step = Math.max(1, Math.floor(filtered.length / 80));
        return filtered.filter((_, index) => index % step === 0);
      }

      case "10-seconds": {
        const filtered = dataHistory.filter(point => point.timestamp >= now - 10000);
        const step = Math.max(1, Math.floor(filtered.length / 80));
        return filtered.filter((_, index) => index % step === 0);
      }


      default:
        return dataHistory;
    }
  };

  const filteredData = getFilteredHistory(selectedOption, dataHistory);
  const chartData = {
    labels: filteredData.map((data) => new Date(data.timestamp).toLocaleTimeString()),
    datasets: [
      {
        label: 'Roll',
        data: filteredData.map((data) => data.x),
        borderColor: 'rgb(75, 192, 192)',
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        fill: true,
        tension: 0,
        stepped: false,
      },
      {
        label: 'Pitch',
        data: filteredData.map((data) => data.y),
        borderColor: 'rgb(153, 102, 255)',
        backgroundColor: 'rgba(153, 102, 255, 0.2)',
        fill: true,
        tension: 0,
        stepped: false,
      },
      {
        label: 'Yaw',
        data: filteredData.map((data) => data.z),
        borderColor: 'rgb(255, 159, 64)',
        backgroundColor: 'rgba(255, 159, 64, 0.2)',
        fill: true,
        tension: 0,
        stepped: false,
      },
    ],
  };

  let upper_limit = showRadians ? 2 * Math.PI : 360;
  upper_limit = axisMode ? upper_limit / 2 : upper_limit;
  let stepMagnitude = showRadians ? 0.26 : 15;
  let lower_limit = axisMode ? -180 : 0;
  lower_limit = showRadians ? (lower_limit * Math.PI) / 180 : lower_limit;


  return (
    <div className="w-full h-96 flex flex-col">
      <div className="m-4">
        <label htmlFor="historyOptions" className="mr-2">History Timeframe:</label>
        <select
          id="historyOptions"
          value={selectedOption}
          onChange={(e) => setSelectedOption(e.target.value as "real-time" | "1-second" | "5-seconds" | "10-seconds")}
          className="border rounded px-2 py-1"
        >
          <option value="real-time">Real-time</option>
          <option value="1-second">1 Second</option>
          <option value="5-seconds">5 Seconds</option>
          <option value="10-seconds">10 Seconds</option>
        </select>
      </div>
      <div className="chart-container flex-1">
        <Line
          data={chartData}
          options={{
            responsive: true,
            maintainAspectRatio: false,
            scales: {
              x: {
                min: 0,
                max: 360,
                ticks: {
                  stepSize: 10,
                },
              },
              y: {
                min: lower_limit,
                max: upper_limit,
                ticks: {
                  stepSize: stepMagnitude,
                },
              },
            },
            plugins: {
              legend: {
                position: 'top' as const,
              },
            },
            animation: false,
          }}
        />
      </div>
    </div>

  );
};

export default HistoryChart;
