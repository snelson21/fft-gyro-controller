import React from 'react';
import Gauges from '../Gauges';
import { useData } from '../../hooks/DataProvider';
import { useDarkMode } from '../../context/DarkModeContext';
import HistoryChart from '../HistoryChart/HistoryChart';
import EncodersSettings from './EncoderSettings'; // Adjust the path as needed

const Encoders: React.FC = () => {
    const { dataHistory } = useData();
    const getHistoryCharts = () => {
        const { isDarkMode } = useDarkMode();
        const { showRadians, axisMode } = useData();
        const { trueIndexes, falseIndexes } = separateAxisIndexes(axisMode)
        const showTwoTables = trueIndexes.length > 0 && falseIndexes.length > 0;

        const trueData = dataHistory.map((record) => {
            const filteredRecord: any = { timestamp: record.timestamp };
            falseIndexes.forEach((key) => {
                filteredRecord[key] = record[key as keyof typeof record];
            });
            return filteredRecord;
        });

        const falseData = dataHistory.map((record) => {
            const filteredRecord: any = { timestamp: record.timestamp };
            trueIndexes.forEach((key) => {
                filteredRecord[key] = record[key as keyof typeof record];
            });
            return filteredRecord;
        });


        return (
            <>
                <div className={`flex gap-6 mt-2`}>
                    {trueIndexes.length > 0 && (
                        <div
                            className={`flex-1 ${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg shadow`}
                            style={{ minWidth: "48%" }} // Enforce equal widths
                        >
                            <HistoryChart
                                dataHistory={showTwoTables ? trueData : dataHistory}
                                showRadians={showRadians}
                                axisMode={showTwoTables ? false : true}
                            />
                        </div>
                    )}
                    {falseIndexes.length > 0 && (
                        <div
                            className={`flex-1 ${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg shadow`}
                            style={{ minWidth: "48%" }} // Enforce equal widths
                        >
                            <HistoryChart
                                dataHistory={showTwoTables ? falseData : dataHistory}
                                showRadians={showRadians}
                                axisMode={showTwoTables ? true : false}
                            />
                        </div>
                    )}
                </div>
            </>
        );

    }

    const separateAxisIndexes = (axisMode: Record<string, boolean>) => {
        const trueIndexes: string[] = [];
        const falseIndexes: string[] = [];

        Object.entries(axisMode).forEach(([key, value]) => {
            if (value) {
                trueIndexes.push(key);
            } else {
                falseIndexes.push(key);
            }
        });

        return { trueIndexes, falseIndexes };
    };

    return (
        <>
            <div className="flex flex-col lg:flex-row gap-6">
                <Gauges />
                <EncodersSettings />
            </div>
            {getHistoryCharts()}
        </>
    );
};

export default Encoders;

