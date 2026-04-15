import { useDarkMode } from '../../context/DarkModeContext';

interface HeaderProps {
  isConnected: boolean;
  onDisconnect: () => void;
}

export function Header({ isConnected, onDisconnect }: HeaderProps) {
  const { isDarkMode, toggleDarkMode } = useDarkMode();

  return (
    <header className={`${isDarkMode ? 'bg-gray-900' : 'bg-white'} shadow-sm transition-colors`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
        <div className="flex items-center gap-4">
          <h1 className={`text-2xl font-semibold ${isDarkMode ? 'text-gray-200' : 'text-gray-900'}`}>
            Serial Port Controller
          </h1>
          <button
            onClick={toggleDarkMode}
            className={`p-2 rounded-full ${
              isDarkMode 
                ? 'bg-gray-800 text-yellow-400 hover:bg-gray-700' 
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            } transition-colors`}
            aria-label="Toggle dark mode"
          >
            {isDarkMode ? (
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
            ) : (
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
              </svg>
            )}
          </button>
        </div>
        {isConnected && (
          <div className="flex items-center gap-4">
            <span className={`px-3 py-1 ${
              isDarkMode 
                ? 'bg-green-900/30 text-green-400' 
                : 'bg-green-100 text-green-800'
            } rounded-full text-sm font-medium`}>
              Connected
            </span>
            <button
              onClick={onDisconnect}
              className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors"
            >
              Disconnect
            </button>
          </div>
        )}
      </div>
    </header>
  );
}