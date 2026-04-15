import React from 'react';

interface DisconnectBtnProps {
    isConnected: boolean;
    isDarkMode: boolean;
    handleDisconnect: () => void;
}

const DisconnectBtn: React.FC<DisconnectBtnProps> = ({ isConnected, isDarkMode, handleDisconnect }) => {
    return (
        <>
            {isConnected && (
                <div id='disconnectModal'>
                    <span
                        className={`px-3 py-1 ${
                            isDarkMode
                                ? 'bg-green-900/30 text-green-400'
                                : 'bg-green-100 text-green-800'
                        } rounded-full text-sm font-medium`}
                    >
                        Connected
                    </span>
                    {window.electron !== undefined && (
                        <button
                            onClick={handleDisconnect}
                            className="px-3 py-1 bg-red-500 text-white text-sm rounded-full hover:bg-red-600 transition-colors"
                        >
                            Disconnect
                        </button>
                    )}
                </div>
            )}
        </>
    );
};

export default DisconnectBtn;