import { useDarkMode } from '../../context/DarkModeContext';

interface ModeSelectProps {
  mode: string;
  title: string;
  options: Array<Option>;
  handleChange?: (option: string) => void;
}

interface Option {
  title: string;
  desc?: string;
  imgUrl?: string;
}

export function ModeSelect({ mode, title, options, handleChange }: ModeSelectProps) {
  const { isDarkMode } = useDarkMode();

  return (
    <div className="mb-6">
      <label className={`block text-sm font-medium mb-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
        {title}
      </label>
      <div className="grid grid-cols-2 gap-4">
        {options.map((option: Option) =>
          <button
            onClick={() => { handleChange && handleChange(option.title) }}
            className={`p-4 rounded-lg border-2 transition-colors ${mode.toLowerCase() === option.title.toLowerCase()
              ? isDarkMode
                ? 'border-indigo-500 bg-indigo-900 text-indigo-300'
                : 'border-indigo-500 bg-indigo-50 text-indigo-700'
              : isDarkMode
                ? 'border-gray-700 hover:border-gray-600'
                : 'border-gray-200 hover:border-gray-300'
              }`}
          >
            <div className={`font-medium ${isDarkMode ? 'text-gray-200' : 'text-gray-900'}`}>{option.title}</div>
            {option.desc &&
              <div className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                {option.desc}
              </div>
            }
            {option.imgUrl &&
              <img src={option.imgUrl}/>
            }
          </button>
        )}
      </div>
    </div>
  );
}