import { useState, useEffect } from 'react';
import { PortSelect } from './PortSelect';
import { useDarkMode } from '../../context/DarkModeContext';
import { ModeSelect } from './OptionSelect';
import { Mode } from '../../hooks/constants';
import { useData } from '../../hooks/DataProvider';
import { recordingEmitter } from '../../services/recordingEmitter';

interface ConnectionModalProps {
  isOpen: boolean;
  onPortSelect: (port: string | any, initalMode: string) => void;
  modeSelect: (newMode: Mode) => void;
}

export function ConnectionModal({ isOpen, onPortSelect, modeSelect }: ConnectionModalProps) {
  const { isDarkMode } = useDarkMode();
  const { mode, saveMode, gVersion, setGVersion } = useData();
  const [ports, setPorts] = useState<string[]>([]);
  const [selectedPort, setSelectedPort] = useState<string>('');
  const [webPort, setWebPort] = useState<any>(undefined);
  const [esp, setEsp] = useState<boolean>(false);

  useEffect(() => {
    getElectronPorts();
    fetchEspState();
  }, []);

  const fetchEspState = async () => {
    if (window.electron) {
      try {
        const espState = await window.electron.serialPort.getEspBool();
        setEsp(espState);
      } catch (error) {
        console.error('Error fetching ESP state:', error);
      }
    }
  };

  const toggleEspState = async () => {
    if (window.electron) {
      try {
        const updatedEspState = await window.electron.serialPort.setEspBool(!esp);
        setEsp(updatedEspState);
      } catch (error) {
        console.error('Error updating ESP state:', error);
      }
    }
  };

  const getElectronPorts = () => {
    if (!window.electron) return;
    const fetchPorts = async () => {
      try {
        const availablePorts = await window.electron.serialPort.list();
        setPorts(availablePorts);
      } catch (error) {
        console.error('Error fetching ports:', error);
      }
    };
    fetchPorts();
    const interval = setInterval(fetchPorts, 2000);
    return () => clearInterval(interval);
  };

  const handleSetGVersion = (version: string) => {
    recordingEmitter.emit('gVersion', version);
    setGVersion(version);
  };

  const handleSelectedPort = async (port: any) => {
    const cleanedPort: string = port.split('-')[0].trim();
    const newMode = await window.electron.serialPort.getMode(cleanedPort);
    modeSelect(mode);
    setSelectedPort(port);
    recordingEmitter.emit('modeChange', newMode == 1 ? 'motors' : 'encoders');

    saveMode(newMode == 1 ? 'motors' : 'encoders');
  };

  const handleBrowserSerialList = async () => {
    if ((navigator as any).serial) {
      try {
        const port = await (navigator as any).serial.requestPort();
        if (webPort && webPort.connected) {
        }
        await port.open({ baudRate: 57600 });
        const reader = port.readable.getReader();
        const { value } = await reader.read();
        await reader.releaseLock();
        await port.close();
        saveMode(value[1] == 1 ? 'motors' : 'encoders');
        setWebPort(port);
      } catch (error) {
        console.error('Error accessing the serial port:', error);
      }
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-gray-900 bg-opacity-75">
      <div className={`${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-xl p-8 w-full max-w-md transition-colors`}>
        <h2 className={`text-2xl font-bold mb-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
          Connect to Device
          {!window.electron && (
            <button
              onClick={handleBrowserSerialList}
              className={`p-2 rounded-full ${
                isDarkMode
                  ? 'bg-gray-800 text-yellow-400 hover:bg-gray-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              } transition-colors`}
              aria-label="Toggle dark mode"
            >
              <svg
                className="w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
                />
              </svg>
            </button>
          )}
        </h2>
        {window.electron && (
          <PortSelect
            ports={ports}
            selectedPort={selectedPort}
            onPortChange={handleSelectedPort}
          />
        )}
        <div className="flex items-center mb-4">
          <span className={`mr-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>ESP</span>
          <button
            onClick={toggleEspState}
            className={`w-12 h-6 flex items-center rounded-full p-1 ${
              esp ? (isDarkMode ? 'bg-indigo-600' : 'bg-indigo-500') : 'bg-gray-400'
            }`}
          >
            <div
              className={`w-4 h-4 bg-white rounded-full shadow-md transform ${
          esp ? 'translate-x-6' : ''
              } transition-transform`}
            ></div>
          </button>
        </div>
        <ModeSelect
          mode={gVersion.toString()}
          title="Gyro Version"
          options={[
            { title: 'V1', imgUrl: './assets/V1.jpg' },
            { title: 'V4', imgUrl: './assets/V4.PNG' },
          ]}
          handleChange={handleSetGVersion}
        />
        <ModeSelect
          mode={mode}
          title="Operation Mode (Auto detected)"
          options={[
            { title: 'Motors', desc: 'Control motor movements' },
            { title: 'Encoders', desc: 'Read encoder values' },
          ]}
        />
        <button
          onClick={() =>
            onPortSelect(
              window.electron ? selectedPort.split('-')[0].trim() : webPort,
              mode
            )
          }
          disabled={
            (window.electron && !selectedPort) || (!window.electron && !webPort)
          }
          className={`w-full py-3 px-4 ${
            isDarkMode
              ? 'bg-indigo-600 hover:bg-indigo-700'
              : 'bg-indigo-500 hover:bg-indigo-600'
          } text-white rounded-lg font-medium
          focus:outline-none focus:ring-2 focus:ring-indigo-500 
          focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed
          transition-colors`}
        >
          Connect
        </button>
      </div>
    </div>
  );
}
