import { useEffect, useState } from 'react';
import { createRoot } from "react-dom/client";

import { RecordingMenu } from './RecordingMenu';
import { HistoryChartReplay } from '../HistoryChartReplay/HistoryChartReplay';
import { useDarkMode } from '../../context/DarkModeContext';
import { recordingEmitter } from '../../services/recordingEmitter';

export function RecordingControls() {
  const { isDarkMode } = useDarkMode();
  const [fileType, setFileType] = useState<'csv' | 'txt'>('csv');
  const [fileName, setFileName] = useState('orientation-data');

  const [isRecording, setIsRecording] = useState(false);
  useEffect(() => {
    recordingEmitter.emit("recordingChanged", {isRecording, fileName, fileType});
  }
    , [isRecording])
  const stopRecording = () => {
    setIsRecording(false);
  };
  
  useEffect(() => {

  }, [isRecording])
  
  let win : WindowProxy  | null;

  const handleRecordClick = () => {
    if (!isRecording) {
      setIsRecording(true);
    }
  };

  const handlePlayClick = () => {
    if (win) {
      win.close();
  }
  win = window.open("", "_blank");

  if (win) {
      win.document.write("<div id='root'></div>");
      win.document.close(); // Ensure the document is fully loaded before rendering

      const container = win.document.getElementById("root");
      if (container) {
        document.querySelectorAll("link[rel='stylesheet'], style").forEach((style) => {
          win?.document.head.appendChild(style.cloneNode(true));
        });
        const root = createRoot(container);
        root.render(<HistoryChartReplay />);
      }
    }
  }

  return (
    <div className="fixed bottom-4 right-4 flex items-center gap-2 z-50">
      <div className={`transform transition-all duration-300 ease-in-out ${isRecording ? 'scale-100 opacity-100' : 'scale-95 opacity-0 pointer-events-none'}`}>
        <RecordingMenu
          isOpen={isRecording}
          isRecording={isRecording}
          onStopRecording={stopRecording}
          fileType={fileType}
          onFileTypeChange={setFileType}
          fileName={fileName}
          onFileNameChange={setFileName}
          isDarkMode={isDarkMode}
        />
      </div>

      <button
        onClick={handleRecordClick}
        className={`w-12 h-12 rounded-full flex items-center justify-center transition-all ${isRecording
            ? 'bg-red-500 animate-pulse'
            : 'bg-red-500 hover:bg-red-600'
          } shadow-lg`}
      >
        <span className="text-sm font-medium text-white">
          REC
        </span>
      </button>

      {/* <button
        onClick={handlePlayClick}
        className={`w-12 h-12 rounded-full flex items-center justify-center transition-all bg-green-500 hover:bg-green-600 shadow-lg`}
      >
        <span className="text-sm font-medium text-white">
          PLAY
        </span>
      </button> */}
    </div>
  );
}