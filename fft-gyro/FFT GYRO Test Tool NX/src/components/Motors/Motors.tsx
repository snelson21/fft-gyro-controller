import React, { useState } from 'react';
import { useData } from '../../hooks/DataProvider';
import { useDarkMode } from '../../context/DarkModeContext';
import { Axis, chartOptions } from '../../hooks/constants';

import Gauges from '../Gauges';
import { setMotorPosition, SetVelocity, EmergencyStop, MotorType, setMotorType, SetTorque, isStopped } from '../../services/motor_functions';
import { Line } from 'react-chartjs-2';


const Motors: React.FC = () => {

    return (
        <div className="flex flex-col lg:flex-row h-full gap-6 p-4">
            <MainContent />
            <SidebarControls />
        </div>
    );
};

const MainContent: React.FC = () => {
    return (
        <div className="flex-1 h-auto rounded-lg shadow p-6">
            <div className="grid grid-cols-1 gap-6">
                <ChartButtons />
                <Gauges />
                <ChartsSection />
            </div>
        </div>
    );
};

const ChartButtons: React.FC = () => {
    const { setCharts, charts } = useData();
    const { isDarkMode } = useDarkMode();
    const toggleChart = (chartId: string) => {
        setCharts(charts.map(chart =>
            chart.id === chartId ? { ...chart, visible: !chart.visible } : chart
        ));
    };
    return (
        <div className="fixed left-0 top-1/2 -translate-y-1/2 z-50">
            <div className="space-y-2 group">
                {charts.map((chart) => (
                    <button
                        key={chart.id}
                        onClick={() => toggleChart(chart.id)}
                        className="relative flex items-center"
                    >
                        <div
                            className={`w-12 h-12 flex items-center justify-center rounded-r-lg transition-colors duration-200 ${isDarkMode
                                ? chart.visible
                                    ? 'bg-gray-700'
                                    : 'bg-gray-800'
                                : chart.visible
                                    ? 'bg-white'
                                    : 'bg-gray-200'
                                }`}
                        >
                            <div
                                className={`w-8 h-8 relative ${chart.visible ? 'opacity-100' : 'opacity-50'
                                    }`}
                            >
                                <div
                                    className="absolute inset-0 rounded-l-full"
                                    style={{
                                        clipPath: 'polygon(0 0, 50% 0, 50% 100%, 0 100%)',
                                        backgroundColor: chart.color,
                                    }}
                                />
                                <div
                                    className={`absolute right-0 top-0 bottom-0 w-1/2 ${isDarkMode ? 'bg-gray-700' : 'bg-gray-200'
                                        }`}
                                />
                            </div>
                        </div>
                        <div
                            className={`absolute left-full top-0 h-12 px-4 flex items-center rounded-r-lg whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-200 ${isDarkMode ? 'bg-gray-700' : 'bg-white'
                                }`}
                        >
                            <span className={chart.visible ? 'opacity-100' : 'opacity-50'}>
                                {chart.label}
                            </span>
                        </div>
                    </button>
                ))}
            </div>
        </div>
    );
};

const ChartsSection: React.FC = () => {
    const { isDarkMode } = useDarkMode();
    const { mode, charts, velocityHistory, torqueHistory, temperatureHistory, voltageHistory, gVersion } = useData();
    const generateMotorData = (data: number[][]) => {
        return {
            labels: data[3],
            datasets: [
                {
                    label: (mode === "motors" && gVersion === "V4") ? '1' : 'R',
                    data: data[0],
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    fill: true,
                    tension: 0,
                    stepped: false,
                },
                {
                    label: (mode === "motors" && gVersion === "V4") ? '2' : 'P',
                    data: data[1],
                    borderColor: 'rgb(153, 102, 255)',
                    backgroundColor: 'rgba(153, 102, 255, 0.2)',
                    fill: true,
                    tension: 0,
                    stepped: false,
                },
                {
                    label: (mode === "motors" && gVersion === "V4") ? '3' : 'Y',
                    data: data[2],
                    borderColor: 'rgb(255, 159, 64)',
                    backgroundColor: 'rgba(255, 159, 64, 0.2)',
                    fill: true,
                    tension: 0,
                    stepped: false,
                },
            ],
        };
    };


    return (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {charts
                .filter((chart) => chart.visible)
                .map((chart) => {
                    let data: number[][] = [];
                    switch (chart.id) {
                        case 'presentSpeed':
                            data = velocityHistory;
                            break;
                        case 'torqueLimit':
                            data = torqueHistory;
                            break;
                        case 'temperature':
                            data = temperatureHistory;
                            break;
                        case 'voltage':
                            data = voltageHistory;
                            break;
                        default:
                            break;
                    }

                    return (
                        <div
                            key={chart.id}
                            className={`p-2 ${isDarkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-lg`}
                            style={{ height: '100%', width: '100%' }}
                        >
                            <Line
                                options={{
                                    ...chartOptions,
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    animation: {
                                        duration: 0,
                                    },
                                    plugins: {
                                        ...chartOptions.plugins,
                                        legend: {
                                            ...chartOptions.plugins?.legend,
                                            position: "top",
                                            title: {
                                                display: true,
                                                text: chart.label,
                                                color: isDarkMode ? 'white' : 'black',
                                                font: {
                                                    size: 16,
                                                },
                                            }
                                        },
                                    },
                                    scales: {
                                        y: {
                                            min: chart.lower_limit,
                                            max: chart.upper_limit,
                                            ticks: {
                                                stepSize: chart.step_magnitude,
                                            },
                                        },
                                    },
                                }}
                                data={generateMotorData(data)}
                                style={{ height: '100%', width: '100%' }}
                            />
                        </div>
                    );
                })}
        </div>
    );
};


const SidebarControls: React.FC = () => {
    const { motorsMode, handleMotorModeChange, setPositionValues } = useData();
    const [paddingTop, setPaddingTop] = React.useState<string | undefined>(undefined);

    const handleSetMotorType = (e: React.ChangeEvent<HTMLSelectElement>) => {
        setMotorType(parseInt(e.target.value));
        const initalMotorData = MotorType === 0 ? 180 : 150;
        setPositionValues([initalMotorData, initalMotorData, initalMotorData]);
    };

    React.useEffect(() => {
        const updatePaddingTop = () => {
            const disconnectModal = document.getElementById("disconnectModal");
            if (disconnectModal) {
                const modalRect = disconnectModal.getBoundingClientRect();
                const elementRect = document.getElementById("selectContainer")?.getBoundingClientRect();
                if (elementRect && modalRect.bottom > elementRect.top && modalRect.right > elementRect.left && modalRect.left < elementRect.right) {
                    setPaddingTop(`${modalRect.height - 32}px`);
                    return;
                }
            }
            setPaddingTop(undefined);
        };

        updatePaddingTop();
        window.addEventListener("resize", updatePaddingTop);
        return () => {
            window.removeEventListener("resize", updatePaddingTop);
        };
    }, []);

    return (
        <div id='selectContainer' className="w-full lg:w-80 bg-white dark:bg-gray-800 rounded-lg shadow p-6" >
            <div
                className="flex flex-col gap-4"
                style={{
                    paddingTop: paddingTop,
                }}
            >
                <select
                    className="rounded px-2 py-1 text-sm border dark:border-gray-600"
                    value={motorsMode}
                    onChange={(e) => handleMotorModeChange(e.target.value as 'joint' | 'wheel')}
                    disabled={!isStopped}
                >
                    <option value="joint">Joint Mode</option>
                    <option value="wheel">Wheel Mode</option>
                </select>
                <select
                    className="rounded px-2 py-1 text-sm border dark:border-gray-600"
                    value={MotorType}
                    onChange={handleSetMotorType}
                    disabled={!isStopped}
                >
                    <option value={0}>MX28T</option>
                    <option value={1}>AX12 A</option>
                </select>
                <div className="flex-grow transition-all duration-300 ease-in-out">
                    {motorsMode === 'joint' && <JointModeControls />}
                    {motorsMode === 'wheel' && <WheelModeControls />}
                </div>
                <button
                    className="w-full bg-red-600 text-white p-3 rounded-lg font-bold hover:bg-red-700 transition-colors duration-200 mt-auto"
                    onClick={() => { EmergencyStop(motorsMode, [0, 0, 0]) }}
                >
                    STOP
                </button>
            </div>
        </div>
    );
};

const JointModeControls: React.FC = () => {
    return (
        <div className="space-y-4 animate-fade-in">
            <TorqueLimit />
            <PositionControl />
        </div>
    );
};

const WheelModeControls: React.FC = () => {
    return (
        <div className="space-y-4 animate-fade-in">
            <VelocityControl />
        </div>
    );
};

const TorqueLimit: React.FC = () => {
    const { isDarkMode } = useDarkMode();
    const { mode, gVersion } = useData();
    const [torqueValues, setTorqueValues] = useState([25, 25, 25]);

    const labelColor = isDarkMode ? 'text-gray-400' : 'text-gray-600';

    const sliderStyles = "w-3/4 cursor-pointer accent-blue-500";
    const buttonStyles = "w-full bg-blue-600 text-white p-2 rounded hover:bg-blue-700 transition-colors duration-200";

    let orientations;

    if (mode === "motors" && gVersion === 'V4') {
        orientations = ['Motor 1', 'Motor 2', 'Motor 3']
    } else {
        orientations = ['Roll', 'Pitch', 'Yaw'];
    }

    const inputBg = isDarkMode ? 'bg-gray-800' : 'bg-gray-100';
    const textColor = isDarkMode ? 'text-white' : 'text-gray-900';
    const borderColor = isDarkMode ? 'border-gray-700' : 'border-gray-200';
    const inputStyles = `w-1/4 ${inputBg} ${textColor} p-1 rounded text-sm border ${borderColor} focus:outline-none focus:ring-2 focus:ring-blue-500`;
    const handleTorqueChange = (index: number, value: number) => {
        const newValues = [...torqueValues];
        newValues[index] = Math.min(Math.max(value, 0), 100);
        setTorqueValues(newValues);
    };


    return (
        <div className="flex flex-col gap-2">
            <label className={`text-xs font-semibold ${labelColor}`}>
                Torque Limit (0% - 100%)
            </label>
            {[0, 1, 2].map((index) => (
                <div key={index} className="flex flex-col gap-1">
                    <span className={`text-xs ${labelColor} font-medium`}>
                        {orientations[index]}
                    </span>
                    <div className="flex items-center gap-2">
                        <input
                            type="range"
                            min="0"
                            max="100"
                            className={sliderStyles}
                            value={torqueValues[index]}
                            onChange={(e) => handleTorqueChange(index, Number(e.target.value))}
                        />
                        <input
                            type="number"
                            min="0"
                            max="100"
                            className={inputStyles}
                            value={torqueValues[index]}
                            onChange={(e) => handleTorqueChange(index, Number(e.target.value))}
                        />
                    </div>
                </div>
            ))}
            <button className={buttonStyles} onClick={() => SetTorque(torqueValues)}>
                SET TORQUE LIMIT
            </button>
        </div>
    );
};

const PositionControl: React.FC = () => {
    const { isDarkMode } = useDarkMode();
    const { mode, axisMode, inverted, gVersion, positionValues, setPositionValues } = useData();
    const [velocityValues, setVelocityValues] = useState([5, 5, 5]);
    const [showTooltip, setShowTooltip] = useState([false, false, false]);
    const labelColor = isDarkMode ? 'text-gray-400' : 'text-gray-600';
    const [showPopup, setShowPopup] = useState([false, false, false]);

    const sliderStyles = "w-3/4 cursor-pointer accent-blue-500";
    const buttonStyles = "w-full bg-blue-600 text-white p-2 rounded hover:bg-blue-700 transition-colors duration-200";

    let orientations;

    if (mode === "motors" && gVersion === 'V4') {
        orientations = ['Motor 1', 'Motor 2', 'Motor 3']
    } else {
        orientations = ['Roll', 'Pitch', 'Yaw'];
    }

    const inputBg = isDarkMode ? 'bg-gray-800' : 'bg-gray-100';
    const textColor = isDarkMode ? 'text-white' : 'text-gray-900';
    const borderColor = isDarkMode ? 'border-gray-700' : 'border-gray-200';
    const inputStyles = `w-1/4 ${inputBg} ${textColor} p-1 rounded text-sm border ${borderColor} focus:outline-none focus:ring-2 focus:ring-blue-500`;
    const handlePositionChange = (index: number, value: number, motorUpperLimit: number, motorLowerLimit: number) => {
        const newValues = [...positionValues];
        newValues[index] = Math.min(Math.max(value, motorLowerLimit), motorUpperLimit);
        setPositionValues(newValues);
    };
    const getMotorUperLimit = (axisKey: Axis) => {
        if (axisMode[axisKey] === true) {
            return MotorType === 0 ? 180 : 150;
        }
        return MotorType === 0 ? 360 : 300;
    }

    const getMotorLowerLimit = (axisKey: Axis) => {
        if (axisMode[axisKey] === true) {
            return MotorType === 0 ? -180 : -150;
        }
        return 0;
    }

    const getAxisKey = (index: number) => {
        switch (index) {
            case 0:
                return 'x';
            case 1:
                return 'y';
            case 2:
                return 'z';
            default:
                return 'x';
        }
    };

    return (
        <div className="flex flex-col gap-2">
            <label className={`text-xs font-semibold ${labelColor}`}>

                Position (0° - {MotorType === 0 ? 360 : 300}°)
            </label>
            {[0, 1, 2].map((index) => (
                <div key={index} className="flex flex-col gap-1">
                    <span className={`text-xs ${labelColor} font-medium`}>
                        {orientations[index] + (axisMode[getAxisKey(index)] === true ? ` (${getMotorLowerLimit(getAxisKey(index))}°, ${getMotorUperLimit(getAxisKey(index))}°)` : '')}
                    </span>
                    <div className="flex items-center gap-2">
                        <input
                            type="range"
                            min={getMotorLowerLimit(getAxisKey(index))}
                            max={getMotorUperLimit(getAxisKey(index))}
                            className={sliderStyles}
                            value={positionValues[index]}
                            onChange={(e) =>
                                handlePositionChange(index, Number(e.target.value), getMotorUperLimit(getAxisKey(index)), getMotorLowerLimit(getAxisKey(index)))
                            }
                        />

                        <input
                            type="number"
                            min={getMotorLowerLimit(getAxisKey(index))}
                            max={getMotorUperLimit(getAxisKey(index))}
                            className={inputStyles}
                            value={positionValues[index]}
                            onChange={(e) =>
                                handlePositionChange(index, Number(e.target.value), getMotorUperLimit(getAxisKey(index)), getMotorLowerLimit(getAxisKey(index)))
                            }
                        />
                    </div>
                    <div className="flex gap-2 relative" style={{ justifyContent: "flex-end" }}>
                        Velocity
                        <input
                            type="number"
                            min="0"
                            max="114"
                            className={inputStyles}
                            value={velocityValues[index]}
                            onChange={(e) => {
                                setVelocityValues((prev) => {
                                    const newValues = [...prev];
                                    newValues[index] = Math.min(Math.max(Number(e.target.value), 0), 114);
                                    return newValues;
                                });
                                setShowPopup((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = true;
                                    return newTooltipState;
                                });
                                setShowTooltip((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = true;
                                    return newTooltipState;
                                });
                            }}
                            onBlur={() =>
                                setShowTooltip((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = false;
                                    return newTooltipState;
                                })
                            }
                        />
                        {showTooltip[index] && (
                            <div className="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-700 text-white text-xs rounded px-2 py-1 shadow-lg whitespace-nowrap">
                                Recommended Velocity [0, 30]
                            </div>
                        )}
                        {velocityValues[index] > 30 && showPopup[index] && (
                            <div className="absolute top-12 left-1/2 transform -translate-x-1/2 bg-red-600 text-white text-sm rounded px-4 py-2 shadow-lg z-50">
                                <p>
                                    Please use the recommended [0, 30] velocity to avoid damaging the motor.
                                </p>
                                <div className="flex justify-end gap-2 mt-2">
                                    <button
                                        className="bg-gray-200 text-gray-800 px-3 py-1 rounded hover:bg-gray-300"
                                        onClick={() => {
                                            setShowPopup((prev) => {
                                                const newTooltipState = [...prev];
                                                newTooltipState[index] = false;
                                                return newTooltipState;
                                            });
                                            const correctedValue = 30;
                                            setVelocityValues((prev) => {
                                                const newValues = [...prev];
                                                newValues[index] = Math.min(Math.max(Number(correctedValue), 0), 114);
                                                return newValues;
                                            });
                                        }}
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        className="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
                                        onClick={() => {
                                            setShowPopup((prev) => {
                                                const newTooltipState = [...prev];
                                                newTooltipState[index] = false;
                                                return newTooltipState;
                                            });
                                        }}
                                    >
                                        Continue
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            ))}
            <button
                className={buttonStyles}
                onClick={() => setMotorPosition(positionValues, axisMode, inverted, velocityValues)}
            >
                SET POSITION
            </button>
        </div>
    );
};

const VelocityControl: React.FC = () => {
    const { mode, gVersion } = useData();
    const { isDarkMode } = useDarkMode();
    const [velocityValues, setVelocityValues] = useState([0, 0, 0]);
    const [showTooltip, setShowTooltip] = useState([false, false, false]);
    const [showPopup, setShowPopup] = useState([false, false, false]);

    const labelColor = isDarkMode ? 'text-gray-400' : 'text-gray-600';

    const sliderStyles = "w-3/4 cursor-pointer accent-blue-500";
    const buttonStyles = "w-full bg-blue-600 text-white p-2 rounded hover:bg-blue-700 transition-colors duration-200";
    let orientations
    if (mode === "motors" && gVersion === 'V4') {
        orientations = ['Motor 1', 'Motor 2', 'Motor 3']
    } else {
        orientations = ['Roll', 'Pitch', 'Yaw'];
    }
    const inputBg = isDarkMode ? 'bg-gray-800' : 'bg-gray-100';
    const textColor = isDarkMode ? 'text-white' : 'text-gray-900';
    const borderColor = isDarkMode ? 'border-gray-700' : 'border-gray-200';
    const inputStyles = `w-1/4 ${inputBg} ${textColor} p-1 rounded text-sm border ${borderColor} focus:outline-none focus:ring-2 focus:ring-blue-500`;
    const handleVelocityChange = (index: number, value: number) => {
        const newValues = [...velocityValues];
        newValues[index] = Math.min(Math.max(value, -114), 114);
        setVelocityValues(newValues);
    };
    return (
        <div className="flex flex-col gap-2">
            <label className={`text-xs font-semibold ${labelColor}`}>
                Velocity (-114 RPM , 114 RPM)
            </label>
            {[0, 1, 2].map((index) => (
                <div key={index} className="flex flex-col gap-1">
                    <span className={`text-xs ${labelColor} font-medium`}>
                        {orientations[index]}
                    </span>
                    <div className="flex items-center gap-2 relative">
                        <input
                            type="range"
                            min="-114"
                            max="114"
                            className={`${sliderStyles} ${Math.abs(velocityValues[index]) > 30 ? 'accent-red-500' : 'accent-blue-500'}`}
                            value={velocityValues[index]}
                            onChange={(e) => {
                                setShowPopup((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = true;
                                    return newTooltipState;
                                });
                                handleVelocityChange(index, Number(e.target.value));
                                setShowTooltip((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = true;
                                    return newTooltipState;
                                });
                            }}
                            onBlur={() => setShowTooltip((prev) => {
                                const newTooltipState = [...prev];
                                newTooltipState[index] = false;
                                return newTooltipState;
                            })}
                        />
                        <input
                            type="number"
                            min="-124"
                            max="124"
                            className={inputStyles + " align-right"}
                            value={velocityValues[index]}
                            onChange={(e) => {
                                setShowPopup((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = true;
                                    return newTooltipState;
                                });
                                handleVelocityChange(index, Number(e.target.value));
                                setShowTooltip((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = true;
                                    return newTooltipState;
                                });
                            }}
                            onBlur={() =>
                                setShowTooltip((prev) => {
                                    const newTooltipState = [...prev];
                                    newTooltipState[index] = false;
                                    return newTooltipState;
                                })
                            }
                        />
                        {showTooltip[index] && (
                            <div className="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-700 text-white text-xs rounded px-2 py-1 shadow-lg whitespace-nowrap">
                                Recommended Velocity [-30, 30]
                            </div>
                        )}
                        {Math.abs(velocityValues[index]) > 30 && showPopup[index] && (
                            <div className="absolute top-12 left-1/2 transform -translate-x-1/2 bg-red-600 text-white text-sm rounded px-4 py-2 shadow-lg z-50">
                                <p>
                                    Please use the recommended [-30, 30] velocity to avoid damaging the motor.
                                </p>
                                <div className="flex justify-end gap-2 mt-2">
                                    <button
                                        className="bg-gray-200 text-gray-800 px-3 py-1 rounded hover:bg-gray-300"
                                        onClick={() => {
                                            setShowPopup((prev) => {
                                                const newTooltipState = [...prev];
                                                newTooltipState[index] = false;
                                                return newTooltipState;
                                            }
                                            );
                                            const correctedValue = velocityValues[index] > 30 ? 30 : -30;
                                            handleVelocityChange(index, correctedValue);
                                        }}
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        className="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
                                        onClick={() => {
                                            setShowTooltip((prev) => {
                                                const newTooltipState = [...prev];
                                                showPopup[index] = false;
                                                return newTooltipState;
                                            });
                                        }}
                                    >
                                        Continue
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            ))}
            <button
                className={buttonStyles}
                onClick={() => SetVelocity(velocityValues)}
            >
                SET VELOCITY
            </button>
        </div>
    );
};

export default Motors;