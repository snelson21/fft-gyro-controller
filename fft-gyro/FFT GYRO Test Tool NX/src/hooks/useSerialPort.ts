import { useState, useCallback } from 'react';
import { MotorMode, MotorType, setJointWheelMode } from '../services/motor_functions';
import { useData } from './DataProvider';
import { recordingEmitter } from '../services/recordingEmitter';
// import { Mode } from 'original-fs';
import { Mode } from 'constants'
import { is } from '@react-three/fiber/dist/declarations/src/core/utils';




let recordValues = {
  fileName: 'orientation-data',
  fileType: 'csv',
  isRecording: false,
};
let gVersion: string;
let mode: Mode;

recordingEmitter.on("recordingChanged", (values) => {
  recordValues = values;
});
recordingEmitter.on("gVersion", (version:string) => {
  gVersion = version;
});
recordingEmitter.on("modeChange", (sys_mode) => {
  mode = sys_mode;
});


export function useSerialPort() {
  const [isConnected, setIsConnected] = useState(false);
  const {angleTransformation, position, setPosition, setTorqueHistory, setTemperatureHistory, setVoltageHistory, setVelocityHistory, isHomeActive, handleHome} = useData();



  let recordingCache:any = [];
  let reader: ReadableStreamDefaultReader | null = null;

  const parseSerialData = (data: string): any => {
    let parsedData
    const parts = data.toString().split(',');
    if (parts.length < 6) {
      parsedData = {
        timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false }) + `.${new Date().getMilliseconds()}`,
        roll: parseFloat(parts[1]),
        pitch: parseFloat(parts[2]),
        yaw: parseFloat(parts[3]),
      }
    } else {
      const MotorRes = MotorType === 1 ? 0.2932 : 0.088;
      const velocityRes = (MotorMode === 'wheel') ? 0.1 : 0.1113;
      parsedData = {
        timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false }) + `.${new Date().getMilliseconds()}`,
        torquex: (parseFloat(parts[6]) | (parseFloat(parts[7]) << 8)) * 0.0977,
        torquey: (parseFloat(parts[8]) | (parseFloat(parts[9]) << 8)) * 0.0977,
        torquez: (parseFloat(parts[10]) | (parseFloat(parts[11]) << 8)) * 0.0977,
        velocityx: ((parseFloat(parts[12]) | (parseFloat(parts[13]) << 8) & 1023)) * velocityRes,
        velocityy: ((parseFloat(parts[14]) | (parseFloat(parts[15]) << 8) & 1023)) * velocityRes,
        velocityz: ((parseFloat(parts[16]) | (parseFloat(parts[17]) << 8) & 1023)) * velocityRes,
        roll: (parseFloat(parts[18]) | (parseFloat(parts[19]) << 8)) * MotorRes,
        pitch: (parseFloat(parts[20]) | (parseFloat(parts[21]) << 8)) * MotorRes,
        yaw: (parseFloat(parts[22]) | (parseFloat(parts[23]) << 8)) * MotorRes,
        voltagex: parseFloat(parts[24]) / 10,
        voltagey: parseFloat(parts[25]) / 10,
        voltagez: parseFloat(parts[26]) / 10,
        temperaturex: parseFloat(parts[27]),
        temperaturey: parseFloat(parts[28]),
        temperaturez: parseFloat(parts[29]),
      }
    }

    if (recordValues.isRecording) {
      recordingCache.push(parsedData);
    } else if(recordingCache.length > 0 && !recordValues.isRecording) {
      let content = '';
      const fileExtension = recordValues.fileType;

      if (recordValues.fileType === 'csv') {
        const keys = Object.keys(recordingCache[0] || {});
        content = keys.join(',') + '\n';
        content += recordingCache.map((data: { [x: string]: any; }) =>
          keys.map(key => {
        const value = data[key];
        return typeof value === 'string' && value.match(/^\d{2}:\d{2}:\d{2}\.\d{3}$/) ? `"${value}"` : value;
          }).join(',')
        ).join('\n');
      } else {
        content = recordingCache.map((data: ArrayLike<unknown>) =>
          Object.entries(data).map(([key, value]) => {
        if (typeof value === 'string' && value.match(/^\d{2}:\d{2}:\d{2}\.\d{3}$/)) {
          return `${key}: "${value}"`;
        }
        return `${key}: ${value}`;
          }).join('\n')
        ).join('\n\n');
      }

      const blob = new Blob([content], { type: 'text/plain' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${recordValues.fileName}.${fileExtension}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      recordingCache.length = 0;
    }
    return parsedData;
  }

  const updateState = (parsed: any) => {
    if(parsed.roll === undefined && parsed.pitch === undefined && parsed.yaw === undefined){
      return;
    }

    if(gVersion === "V4" && mode === "encoders"){
      const {x,y,z} = angleTransformation(parsed.roll ?? 0, parsed.pitch ?? 0, parsed.yaw ?? 0);
      setPosition({ x, y, z });
    }else{
      setPosition({ x: parsed.roll ?? 0, y: parsed.pitch ?? 0, z: parsed.yaw ?? 0 });
    }

    const propertyCount = Object.keys(parsed).length;
    if (propertyCount > 4) {

      setTorqueHistory((prev: any[]) => {
        const updatedHistory = [
          [...prev[0], parsed.torquex ?? 0].slice(-50),
          [...prev[1], parsed.torquey ?? 0].slice(-50),
          [...prev[2], parsed.torquez ?? 0].slice(-50),
          [...prev[3], new Date().toLocaleTimeString('en-US', { minute: '2-digit', second: '2-digit' })].slice(-50),
        ];
        return updatedHistory;
      });
      setVelocityHistory((prev: any[]) => {
        const updatedHistory = [
          [...prev[0], parsed.velocityx ?? 0].slice(-50),
          [...prev[1], parsed.velocityy ?? 0].slice(-50),
          [...prev[2], parsed.velocityz ?? 0].slice(-50),
          [...prev[3], new Date().toLocaleTimeString('en-US', { minute: '2-digit', second: '2-digit' })].slice(-50),
        ];
        return updatedHistory;
      });
      setVoltageHistory((prev: any[]) => {
        const updatedHistory = [
          [...prev[0], parsed.voltagex ?? 0].slice(-50),
          [...prev[1], parsed.voltagey ?? 0].slice(-50),
          [...prev[2], parsed.voltagez ?? 0].slice(-50),
          [...prev[3], new Date().toLocaleTimeString('en-US', { minute: '2-digit', second: '2-digit' })].slice(-50),
        ];
        return updatedHistory;
      });
      setTemperatureHistory((prev: any[]) => {
        const updatedHistory = [
          [...prev[0], parsed.temperaturex ?? 0].slice(-50),
          [...prev[1], parsed.temperaturey ?? 0].slice(-50),
          [...prev[2], parsed.temperaturez ?? 0].slice(-50),
          [...prev[3], new Date().toLocaleTimeString('en-US', { minute: '2-digit', second: '2-digit' })].slice(-50),
        ];
        return updatedHistory;
      });
    }
  }

  function parseAndSetData(data: string) {
    try {
      const parsed = parseSerialData(data);
      if (!parsed) {
        return
      }
      updateState(parsed);
    } catch (error) {
      console.warn('Failed to parse data:', error);
    }
  }


  const connect = useCallback(async (portPath: string | any, initialMode: string) => {
    if(!isHomeActive) {
      handleHome()
    }
    if (window.electron) {
      try {
        const success = await window.electron.serialPort.connect(portPath);
        if (success) {
          setIsConnected(true);
          if (initialMode === "motors") {
            await setJointWheelMode("joint", [0, 0, 0], [0, 0, 0]);
          }

          // Listen for incoming data from the serial port
          window.electron.serialPort.onData((data: string) => {
            try {
              parseAndSetData(data);
            } catch (error) {
              console.log(error)
            }
          });
        } else {
        }
        return success;
      } catch (error) {
        return false;
      }
    } else {
      try {
        await portPath.open({ baudRate: 57600 });
        setIsConnected(true);
        reader = portPath.readable.getReader();

        while (true) {
          try {
            if (!reader) {
              throw new Error('Reader is null');
            }
            const { value, done } = await reader.read();
            if (done) {
              break;
            }

            if (value) {
              const data = new TextDecoder().decode(value);
              parseAndSetData(data);

            }
          } catch (parseError) {
            console.warn('Failed to parse data:', parseError);
          }
        }
      } catch (error) {
        console.error('Error reading data from the port:', error);
      }
    }
  }, []);

  const disconnect = useCallback(async () => {
    try {
      await window.electron.serialPort.disconnect();
      setIsConnected(false);
    } catch (error) {
      //console.error('Error disconnecting from the serial port:', error);
    }
  }, []);

  return {
    connect,
    disconnect,
    isConnected,
    position,
  };
}


