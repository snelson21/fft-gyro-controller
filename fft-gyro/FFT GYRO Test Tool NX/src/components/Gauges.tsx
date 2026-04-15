import React, { useEffect, useRef } from 'react';
import { CircularGauge } from './CircularGauge';
import { PillToggle } from './PillToggle';
import { useData } from '../hooks/DataProvider';
import { useDarkMode } from '../context/DarkModeContext';
import { Axis, axisMapping } from '../hooks/constants';


//TODO: use re-render on position change

const Gauges: React.FC = () => {
    const { mode, inverted, toggleInverted, showRadians, axisMode, toggleAxisMode, getValue, position, setDataHistory, gVersion } = useData();
    const { isDarkMode } = useDarkMode();

    let showRadiansMod = (showRadians && mode === "encoders");

    const axisMapping_V4 = {
        x: { name: 'Motor 1', description: 'Rotation around longitudinal axis' },
        y: { name: 'Motor 2', description: 'Rotation around lateral axis' },
        z: { name: 'Motor 3', description: 'Rotation around vertical axis' }
      };

    //   const lastUpdateRef = useRef(0);
      
      useEffect(() => {
        setDataHistory(prev => {
            const TEN_SECONDS_AGO = Date.now() - (10000 ); 
            const updatedHistory = [...prev, { ...position, x: getValue("x"), y: getValue("y"), z: getValue("z"), timestamp: Date.now()}];
            return updatedHistory.filter(point => point.timestamp !== undefined && point.timestamp >= TEN_SECONDS_AGO); 
          });
    }, [position]);
      
    return (
        <div className={`flex-1 ${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg shadow p-6`}>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {['x', 'y', 'z'].map((axis) => {
                    const axisKey: Axis = axis as Axis;
                    const value = getValue(axisKey);
                    let axisLabel: string;
                    
                    if(mode === "motors" && gVersion === "V4"){
                        axisLabel = axisMapping_V4[axisKey].name;
                    }else{
                        axisLabel = axisMapping[axisKey].name;
                    }

                    const axisDescription = axisMapping[axisKey].description;
                    const valueDisplay = `${value.toFixed(showRadians ? 2 : 1)}${showRadians ? ' rad' : '°'}`;
                    const buttonStyles = inverted[axisKey]
                        ? isDarkMode
                            ? 'bg-indigo-900 text-indigo-300'
                            : 'bg-indigo-100 text-indigo-700'
                        : isDarkMode
                            ? 'bg-gray-600 text-gray-300 hover:bg-gray-500'
                            : 'bg-gray-200 text-gray-700 hover:bg-gray-300';

                    return (
                        <div
                            key={axis}
                            className={`p-6 ${isDarkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-lg relative`}
                        >
                            <div className="flex items-center justify-between mb-4">
                                <div className="flex items-baseline gap-2">
                                    <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                                        {axisLabel}
                                    </span>
                                    <span className="text-lg font-semibold text-indigo-500">
                                        {valueDisplay}
                                    </span>
                                </div>
                                <button
                                    onClick={() => toggleInverted(axisKey)}
                                    className={`px-2 py-1 text-xs rounded ${buttonStyles} transition-colors`}
                                >
                                    {inverted[axisKey as keyof typeof inverted] ? 'Inverted' : 'Normal'}
                                </button>
                            </div>
                            <div className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-400'} mb-4`}>
                                {axisDescription}
                            </div>

                            <div className="flex flex-col gap-4">
                                <CircularGauge
                                    value={value}
                                    size={240}
                                    showRadians={showRadiansMod}
                                    axisMode={axisMode[axisKey]}
                                />
                                <PillToggle onToggle={toggleAxisMode} axisKey={axisKey} value={axisMode[axisKey]} />
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

export default Gauges;