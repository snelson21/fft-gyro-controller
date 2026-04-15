import { useState, useEffect } from 'react';
import { useDarkMode } from '../context/DarkModeContext';

interface SerialPortModalProps {
  isOpen: boolean;
  onClose: () => void;
  onPortSelect: (port: string, mode: 'motors' | 'encoders') => void;
}

export function SerialPortModal({ isOpen, onClose, onPortSelect }: SerialPortModalProps) {
  const { isDarkMode } = useDarkMode();
  const [ports, setPorts] = useState<string[]>([]);
  const [selectedPort, setSelectedPort] = useState<string>('');
  const [mode, setMode] = useState<'motors' | 'encoders'>('motors');

  useEffect(() => {
    const refreshPorts = async () => {
      try {
        const availablePorts = await window.electron.serialPort.list();
        setPorts(availablePorts);
      } catch (error) {
        //console.error('Error listing serial ports:', error);
      }
    };

    refreshPorts();
    const interval = setInterval(refreshPorts, 2000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = () => {
    if (selectedPort) {
      onPortSelect(selectedPort, mode);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black bg-opacity-50" onClick={onClose} />
      <div className={`${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg p-6 z-10 w-96 shadow-xl transition-colors`}>
        <h2 className={`text-xl font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
          Select Serial Port
        </h2>
        
        <div className="mb-4">
          <label className={`block text-sm font-medium mb-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
            Available Ports
          </label>
          <select
            className={`w-full p-2 rounded ${
              isDarkMode 
                ? 'bg-gray-700 text-white border-gray-600' 
                : 'bg-white text-gray-900 border-gray-300'
            } transition-colors`}
            value={selectedPort}
            onChange={(e) => setSelectedPort(e.target.value)}
          >
            <option value="">Select a port...</option>
            {ports.map((port) => (
              <option key={port} value={port}>{port}</option>
            ))}
          </select>
        </div>

        <div className="mb-4">
          <label className={`block text-sm font-medium mb-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
            Mode
          </label>
          <div className="flex items-center space-x-4">
            <label className={`flex items-center ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
              <input
                type="radio"
                checked={mode === 'motors'}
                onChange={() => setMode('motors')}
                className="mr-2"
              />
              Motors
            </label>
            <label className={`flex items-center ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
              <input
                type="radio"
                checked={mode === 'encoders'}
                onChange={() => setMode('encoders')}
                className="mr-2"
              />
              Encoders
            </label>
          </div>
        </div>

        <div className="flex justify-end space-x-2">
          <button
            onClick={onClose}
            className={`px-4 py-2 ${
              isDarkMode 
                ? 'text-gray-300 hover:text-white' 
                : 'text-gray-600 hover:text-gray-800'
            } transition-colors`}
          >
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            disabled={!selectedPort}
            className={`px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50 transition-colors`}
          >
            Connect
          </button>
        </div>
      </div>
    </div>
  );
}