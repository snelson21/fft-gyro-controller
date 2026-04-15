const { app, BrowserWindow, ipcMain } = require('electron');
const { read } = require('fs');
const path = require('path');
const { SerialPort } = require('serialport');
const { ReadlineParser } = require('@serialport/parser-readline');

let mainWindow;
let serialConnection = null;
let esp = false;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  // mainWindow.loadURL('http://localhost:5173');
  mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));

// mainWindow.webContents.openDevTools();
}

app.whenReady().then(() => {
  createWindow()
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});


// IPC Handlers

ipcMain.handle('esp:get', () => {
  return esp;
});

ipcMain.handle('esp:set', (_, value) => {
  esp = Boolean(value);
  console.log('ESP value set to:', esp);
  return esp;
});

ipcMain.handle('serial:getMode', (_, path) => {
  return new Promise((resolve) => {
    const tempPort = new SerialPort({
      path,
      baudRate: 57600
    });

    if (esp) {
      const parser = tempPort.pipe(new ReadlineParser({
        delimiter: '\{',
        encoding: 'latin1'
      }));

      parser.on('data', (data) => {
        try {
          const dataBuffer = Buffer.from(data, 'latin1');
          const parsedMotorData = Array.from(new Uint8Array(dataBuffer));
          tempPort.close();
          resolve(parsedMotorData[1]);
        } catch (error) {
          console.error('Error parsing data:', error);
          tempPort.close();
          resolve(null);
        }
      });
    } else {
      tempPort.on('data', (data) => {
        try {
          const parsedMotorData = Array.from(new Uint8Array(data));
          tempPort.close();
          resolve(parsedMotorData[1]);
        } catch (error) {
          console.error('Error processing data:', error);
          tempPort.close();
          resolve(null);
        }
      });
    }
  });
});

ipcMain.handle('serial:writeSocket', (_, packet) => {
  return new Promise((resolve, reject) => {
    const buffer = Buffer.from(packet);
    serialConnection.write(buffer, function (err) {
      if (err) {
        console.log('Error on write: ', err.message);
        reject(err);
      } else {
        resolve(true);
      }
    });
  });
});


ipcMain.handle('serial:list', async () => {
  try {
    const ports = await SerialPort.list();
    return ports
      .filter(port => port.manufacturer)
      .map(port => `${port.path} - ${port.manufacturer}`);
  } catch (error) {
    return [];
  }
});
const readingBuffer = [];

ipcMain.handle('serial:connect', async (_, portPath) => {
  try {
    readingBuffer.length = 0;
    if (serialConnection) {
      await new Promise(resolve => serialConnection.close(resolve));
    }
    serialConnection = new SerialPort({
      path: portPath,
      baudRate: 57600
    });

    if (esp) {
      const parser = serialConnection.pipe(new ReadlineParser({
        delimiter: '\{',
        encoding: 'latin1'
      }));

      parser.on('data', (data) => {
        try {
          const dataBuffer = Buffer.from(data, 'latin1');
          const parsedMotorData = Array.from(new Uint8Array(dataBuffer));

          if (parsedMotorData.length === 31) {
            if (parsedMotorData[1] != 2) {
              mainWindow.webContents.send('serial:data', parsedMotorData.toString());
            } else {
              mainWindow.webContents.send('serial:data', parsedMotorData.toString());
            }
          }
        } catch (error) {
          console.error('Error parsing data:', error);
        }
      });
    } else {
      serialConnection.on('data', (data) => {
        try {
          const parsedMotorData = Array.from(new Uint8Array(data));

          if (parsedMotorData.length === 32) {
            if (data[1] != 2) {
              mainWindow.webContents.send('serial:data', parsedMotorData.toString());
            } else {
              mainWindow.webContents.send('serial:data', data.toString());
            }
          }
        } catch (error) {
          console.error('Error processing data:', error);
        }
      });
    }
    return true;
  } catch (error) {
    console.error(error);
    return false;
  }
});

ipcMain.handle('serial:disconnect', async () => {
  if (serialConnection) {
    await new Promise(resolve => serialConnection.close(resolve));
    serialConnection = null;
  }
});
// in the main process: