const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electron', {
  serialPort: {
    list: () => ipcRenderer.invoke('serial:list'),
    connect: (port, mode) => ipcRenderer.invoke('serial:connect', port),
    disconnect: () => ipcRenderer.invoke('serial:disconnect'),
    onData: (callback) => {
      ipcRenderer.on('serial:data', (_, data) => callback(data));
    },
    getMode: (port) => ipcRenderer.invoke('serial:getMode', port),
    writeSocket: async (packet) => {
      await ipcRenderer.invoke('serial:writeSocket', packet);
    },
    getEspBool: () => ipcRenderer.invoke('esp:get'),
    setEspBool: (value) => ipcRenderer.invoke('esp:set', value)
  }
});
