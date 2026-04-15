import React, { useState } from 'react';
import { FileModal } from './FileModal';
import Papa from "papaparse";
import HistoryChart from '../HistoryChart/HistoryChart';
// import { useDarkMode } from '../../context/DarkModeContext';
// import { Line } from 'react-chartjs-2';
// import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js';

// Register necessary components for Chart.js
// ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

// interface HistoryChartProps {
//   dataHistory: Array<{
//     timestamp: number;
//     x?: number;
//     y?: number;
//     z?: number;
//   }>;
//   showRadians: boolean;
//   axisMode: boolean;
// }

export const HistoryChartReplay: React.FC = () => {
    const [data, setData] = useState<any[]>([]);
    // const {isDarkMode} = useDarkMode();
    const handleCloseFile = () => {
        setData([]);
    }



    return (   
        <div className={`min-h-screen flex flex-col relative ${false ? 'bg-gray-950' : 'bg-gray-100'}`}>
            <FileModal
                data={data}
                setData={setData}
            />
            <main className={`flex-1 ${false ? 'bg-gray-950' : 'bg-gray-50'} p-6 transition-colors ${data.length == 0 ? 'blur pointer-events-none' : ''}`}>
            <div className="fixed top-4 right-4 z-50">
                        {data.length !=0 && (

                                    <button
                                        onClick={handleCloseFile}
                                        className="px-3 py-1 bg-red-500 text-white text-sm rounded-full hover:bg-red-600 transition-colors"
                                    >
                                        Close File
                                    </button>

                                
                            )}
                </div>

                <div className="max-w-7xl mx-auto">
                    <HistoryChart dataHistory={data} showRadians={false} axisMode ={false}/>
                </div>
            </main> 
        </div>
    );
};
