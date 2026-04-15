import React from 'react';
import { useDarkMode } from '../../context/DarkModeContext';

interface MainContentProps {
  isBlurred: boolean;
  children: React.ReactNode;
}

export function MainContent({ isBlurred, children }: MainContentProps) {
  const { isDarkMode } = useDarkMode();
  
  return (
    <main className={`flex-1 min-h-screen flex flex-col items-center justify-center ${isDarkMode ? 'bg-gray-950' : 'bg-gray-50'} p-6 transition-colors ${isBlurred ? 'blur pointer-events-none' : ''}`}>
      <div className="flex-1 h-full w-full max-w-7xl flex flex-col">
        {children}
      </div>
    </main>

  );
}