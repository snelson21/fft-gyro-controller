export interface ElectronAPI {
  serialPort: {
    list: () => Promise<string[]>;
    connect: (port: string) => Promise<boolean>;
    disconnect: () => Promise<void>;
    onData: (callback: (data: string ) => void) => void;
    getMode: (port:string) => Promise<any>;
    writeSocket:  (packet:Int8Array) => Promise<any>;
    setEspBool: (value: boolean) => boolean;
    getEspBool: () => boolean;
  }
}

declare global {
  interface Window {
    electron: ElectronAPI;
  }
}