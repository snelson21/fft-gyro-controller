import { useDarkMode } from '../../context/DarkModeContext';

interface PortSelectProps {
  ports: string[];
  selectedPort: string;
  onPortChange: (port: string) => void;
}

export function PortSelect({ ports, selectedPort, onPortChange }: PortSelectProps) {
  const { isDarkMode } = useDarkMode();

  return (
    <div className="mb-6">
      <label className={`block text-sm font-medium mb-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
        Available Ports
      </label>
      <div className="space-y-2 max-h-48 overflow-y-auto">
        {ports.length === 0 ? (
          <div className={`text-sm p-3 rounded-md ${
            isDarkMode ? 'bg-gray-700 text-gray-400' : 'bg-gray-50 text-gray-500'
          }`}>
            No ports available
          </div>
        ) : (
          ports.map((port) => (
            <button
              key={port}
              onClick={() => onPortChange(port)}
              className={`w-full p-3 rounded-lg border-2 text-left transition-colors ${
                selectedPort === port
                  ? isDarkMode
                    ? 'border-indigo-500 bg-indigo-900 text-indigo-300'
                    : 'border-indigo-500 bg-indigo-50 text-indigo-700'
                  : isDarkMode
                    ? 'border-gray-700 hover:border-gray-600'
                    : 'border-gray-200 hover:border-gray-300'
              }`}
            >
              <div className={`font-medium ${
                isDarkMode ? 'text-gray-200' : 'text-gray-900'
              }`}>{port}</div>
            </button>
          ))
        )}
      </div>
    </div>
  );
}