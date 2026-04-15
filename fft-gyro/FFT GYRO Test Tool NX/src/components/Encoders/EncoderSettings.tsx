import { Axis, axisMapping } from '../../hooks/constants';
import { useData } from '../../hooks/DataProvider';
import { useDarkMode } from '../../context/DarkModeContext';

const EncoderSettings: React.FC = () => {
    const { isDarkMode } = useDarkMode();
    const { toggleRadians, calibrationOffsetsFields, handleCalibrationChange, toggleOffsetMode, handleHome, isHomeActive,
        showRadians, offsetMode } = useData();

    return (
        <div className={`w-full lg:w-80 ${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg shadow p-6`}>
            <h2 className={`text-xl font-semibold mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
                Settings
            </h2>
            <div className="space-y-4">
                <div className="flex items-center justify-between p-3 rounded-lg bg-opacity-50 mb-2">
                    <label className={`text-sm font-medium ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                        Show in Radians
                    </label>
                    <button
                        onClick={() => toggleRadians()}
                        className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${showRadians
                            ? isDarkMode
                                ? 'bg-indigo-600'
                                : 'bg-indigo-500'
                            : isDarkMode
                                ? 'bg-gray-600'
                                : 'bg-gray-300'
                            }`}
                    >
                        <span
                            className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${showRadians ? 'translate-x-6' : 'translate-x-1'
                                }`}
                        />
                    </button>
                </div>

                {/* Gauges Settings */}
                <div className="space-y-3">
                    {(['x', 'y', 'z'] as Axis[]).map((axis) => (
                        <div key={axis} className="flex items-center justify-between">
                            <label className={`text-sm font-medium ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                                {axisMapping[axis as keyof typeof axisMapping].name + " Offset"}
                            </label>
                            <input
                                type="number"
                                min={-360}
                                max={360}
                                value={
                                    showRadians
                                        ? ((calibrationOffsetsFields[axis as keyof typeof calibrationOffsetsFields] * Math.PI) / 180).toFixed(2)
                                        : calibrationOffsetsFields[axis as keyof typeof calibrationOffsetsFields].toFixed(1)
                                }
                                onChange={(e) => handleCalibrationChange(axis as keyof typeof calibrationOffsetsFields, e.target.value)}
                                className={`[&::-webkit-inner-spin-button]:appearance-none w-24 px-2 py-1 text-right rounded border ${isDarkMode
                                    ? 'bg-gray-700 text-gray-200 border-gray-600'
                                    : 'bg-gray-50 text-gray-900 border-gray-300'
                                    } focus:outline-none focus:ring-2 focus:ring-indigo-500`}
                            />
                            <button
                                onClick={() => toggleOffsetMode(axis as Axis)}
                                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${offsetMode[axis]
                                    ? isDarkMode
                                        ? 'bg-indigo-600'
                                        : 'bg-indigo-500'
                                    : isDarkMode
                                        ? 'bg-gray-600'
                                        : 'bg-gray-300'
                                    }`}
                            >
                                <span
                                    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${offsetMode[axis] ? 'translate-x-6' : 'translate-x-1'
                                        }`}
                                />
                            </button>
                        </div>
                    ))}
                </div>

                <button
                    onClick={handleHome}
                    className={`w-full mt-4 py-2 px-4 rounded-lg text-white transition-colors font-medium ${isDarkMode
                        ? isHomeActive ? "bg-gray-500 hover:bg-gray-600" : "bg-indigo-600 hover:bg-indigo-700"
                        : isHomeActive ? "bg-gray-500 hover:bg-gray-600" : 'bg-indigo-500 hover:bg-indigo-600'
                        }`}
                >
                    Home
                </button>
            </div>
        </div >
    );
};

export default EncoderSettings;