import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { DarkModeProvider } from './context/DarkModeContext';
import './index.css';
import { DataProvider } from './hooks/DataProvider';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <DarkModeProvider>
      <DataProvider>
        <App />
      </DataProvider>
    </DarkModeProvider>
  </React.StrictMode>
);