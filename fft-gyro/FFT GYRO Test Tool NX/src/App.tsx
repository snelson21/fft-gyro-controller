import { MainContent } from './components/Layout/MainContent';
import { useSerialPort } from './hooks/useSerialPort';
import { useDarkMode } from './context/DarkModeContext';
import { RecordingControls } from './components/Recording/RecordingControls';
import { ConnectionModal } from './components/ConnectionModal/ConnectionModal';
import DisconnectBtn from './components/DisconnectBtn';
import DarkMode from './components/DarkMode';
import Encoders from './components/Encoders/Encoders';
import { useData } from './hooks/DataProvider';
import Motors from './components/Motors/Motors';
import SidePanel from './components/Encoders/SidePanel';

export default function App() {
  const { isDarkMode, toggleDarkMode } = useDarkMode();
  const { mode, saveMode } = useData();
  const { connect, disconnect, isConnected } = useSerialPort();
  const handleDisconnect = () => {
    disconnect();
  };
  return (
    <div className={`min-h-screen flex flex-col relative ${isDarkMode ? 'bg-gray-950' : 'bg-gray-100'}`}>
      <div id='disconnectModal' className="fixed top-4 right-4 z-50">
        <div className={`flex items-center gap-3 ${isDarkMode ? 'bg-gray-900/50' : 'bg-white/50'} backdrop-blur-sm px-4 py-2 rounded-full shadow-lg`}>
          <DisconnectBtn  isConnected={isConnected} isDarkMode={isDarkMode} handleDisconnect={handleDisconnect} />
          <DarkMode isDarkMode={isDarkMode} toggleDarkMode={toggleDarkMode} />
        </div>
      </div>
      <ConnectionModal
        isOpen={!isConnected} onPortSelect={connect} modeSelect={saveMode}
      />
      <MainContent isBlurred={!isConnected}>
        {mode === 'encoders' ?
        <>
          <Encoders/>
          <SidePanel />
        </>
          :
          <Motors/>
        }

        <RecordingControls/>
      </MainContent>
    </div>
  );
}