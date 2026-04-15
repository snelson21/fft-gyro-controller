
interface RecordingMenuProps {
  isOpen: boolean;
  isRecording: boolean;
  onStopRecording: () => void;
  fileType: 'csv' | 'txt';
  onFileTypeChange: (type: 'csv' | 'txt') => void;
  fileName: string;
  onFileNameChange: (name: string) => void;
  isDarkMode: boolean;
}

export function RecordingMenu({
  isOpen,
  isRecording,
  onStopRecording,
  fileType,
  onFileTypeChange,
  fileName,
  onFileNameChange,
  isDarkMode
}: RecordingMenuProps) {
  const handleStopRecording = () => {
    onStopRecording();
  };

  if (!isOpen) return null;

  return (
    <div
      className={`flex items-center gap-2 px-2 py-1.5 rounded-lg shadow-lg ${
        isDarkMode ? 'bg-gray-900' : 'bg-white'
      }`}
    >
      <div className="flex items-center gap-2">
        <div>
          <input
            type="text"
            value={fileName}
            onChange={(e) => onFileNameChange(e.target.value)}
            placeholder="File name"
            className={`px-2 py-1 rounded-md text-sm w-32 ${
              isDarkMode
                ? 'bg-gray-800 text-gray-200 border-gray-700'
                : 'bg-gray-50 text-gray-900 border-gray-300'
            } border focus:outline-none focus:ring-2 focus:ring-indigo-500`}
          />
        </div>

        <select
          value={fileType}
          onChange={(e) => onFileTypeChange(e.target.value as 'csv' | 'txt')}
          className={`px-2 py-1 rounded-md text-sm ${
            isDarkMode
              ? 'bg-gray-800 text-gray-200 border-gray-700'
              : 'bg-gray-50 text-gray-900 border-gray-300'
          } border focus:outline-none focus:ring-2 focus:ring-indigo-500`}
        >
          <option value="csv">CSV</option>
          <option value="txt">Text</option>
        </select>

        {isRecording && (
          <button
            onClick={handleStopRecording}
            className="px-3 py-1 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors flex items-center gap-1.5"
          >
            <div className="w-2.5 h-2.5 bg-white rounded-sm" />
            <span className="font-medium">STOP</span>
          </button>
        )}
      </div>
    </div>
  );
}