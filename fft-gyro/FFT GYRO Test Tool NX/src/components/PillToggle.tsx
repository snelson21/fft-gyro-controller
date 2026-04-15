import   { useState } from 'react';

interface PillToggle {
  onToggle:any;
  axisKey:any;
  value:any;

}


export function PillToggle({ onToggle, axisKey, value}: PillToggle) {
  const [isActive] = useState(false);
  
  const options = ["Origin", "Centered"]

  
  return (
    <div className="flex flex-col items-center gap-4">
      <button 
        onClick={() => onToggle(axisKey)}
        className="relative bg-gray-200 rounded-full p-1 w-48 h-12 transition-colors duration-200 ease-in-out"
      >
        {/* Sliding Background */}
        <div
          className={`
            absolute top-1 h-10 w-24
            rounded-full bg-blue-500
            transition-all duration-300 ease-in-out
            ${value ? 'left-24' : 'left-1'} 
          `}
        />
        
        {/* Button Labels */}
        <div className="relative flex justify-between text-sm font-medium">
          <span className={`flex items-center justify-center w-24 h-10 z-10 transition-colors duration-200 
            ${!value ? 'text-white' : 'text-gray-700'}`}>
            {options[isActive? 1 : 0]}
          </span>
          <span className={`flex items-center justify-center w-24 h-10 z-10 transition-colors duration-200 
            ${value ? 'text-white' : 'text-gray-700'}`}>
            {options[isActive ? 0 : 1]}
          </span>
        </div>
      </button>
      
     
    </div>
  );
};