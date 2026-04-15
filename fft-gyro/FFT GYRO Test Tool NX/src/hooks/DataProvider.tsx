import React, { createContext, useContext, useState, ReactNode } from "react";
import { ChartConfig, Position } from "./constants";
import { MotorType, setJointWheelMode, setMotorMode } from "../services/motor_functions";

// Define types
type Mode = "encoders" | "motors"; // Add more modes if needed
type Axis = "x" | "y" | "z";

// Define the shared state structure
interface DataContextType {
    mode: Mode;
    saveMode: (newMode: Mode) => void;
    showRadians: boolean;
    toggleRadians: () => void;
    inverted: { x: boolean; y: boolean; z: boolean };
    toggleInverted: (axis: Axis) => void;
    axisMode: { x: boolean; y: boolean; z: boolean };
    toggleAxisMode: (axis: Axis) => void;
    position: { x: number; y: number; z: number };
    changePosition: (axis: Axis, value: number) => void;
    getValue: (axis: Axis, isDron?: boolean, forceInverted?:boolean) => number;
    calibrationOffsetsFields: { x: number; y: number; z: number };
    handleCalibrationChange: (axis: Axis, value: string) => void;
    toggleOffsetMode: (axis: Axis) => void;
    handleHome: () => void;
    isHomeActive: boolean;
    offsetMode: { x: boolean; y: boolean; z: boolean };
    dataHistory: Array<Position>;
    charts: Array<ChartConfig>;
    setPosition: (position: Position) => void;
    setCharts: (charts: Array<ChartConfig>) => void;
    setDataHistory: (data: Array<Position> | ((prev: Array<Position>) => Array<Position>)) => void;
    setVelocityHistory: (velocityHistory: number[][] | ((prev: number[][]) => number[][])) => void;
    setTorqueHistory: (torqueHistory: number[][] | ((prev: number[][]) => number[][])) => void;
    setTemperatureHistory: (temperatureHistory: number[][] | ((prev: number[][]) => number[][])) => void;
    setVoltageHistory: (voltageHistory: number[][] | ((prev: number[][]) => number[][])) => void;
    velocityHistory: number[][];
    torqueHistory: number[][];
    temperatureHistory: number[][];
    voltageHistory: number[][];
    motorsMode: 'joint' | 'wheel';
    handleMotorModeChange: (mode: 'joint' | 'wheel') => void;
    angleTransformation: (Data1:number,Data2:number,Data3:number) => Position;
    gVersion: string;
    setGVersion: (version: string) => void;
    positionValues: number[];
    setPositionValues: (positionValues: number[]) => void;

}

// Create context
const DataContext = createContext<DataContextType | undefined>(undefined);

// Define props for DataProvider
interface DataProviderProps {
    children: ReactNode;
}

// ✅ Fix: Ensure function correctly returns JSX.Element

export const DataProvider = ({ children }: DataProviderProps): JSX.Element => {
    const [mode, setMode] = useState<Mode>("motors");
    const [showRadians, setShowRadians] = useState(false);
    const [inverted, setInverted] = useState({ x: false, y: false, z: false });
    const [axisMode, setAxisMode] = useState({ x: false, y: false, z: false });
    const [position, setPosition] = useState<Position>({ x: 0, y: 0, z: 0 });
    const [dataHistory, setDataHistory] = useState<Array<Position>>([]);
    const [calibrationOffsetsFields, setCalibrationOffsetsFields] = useState({ x: 0, y: 0, z: 0 });
    const [offsetMode, setOffsetMode] = useState({ x: false, y: false, z: false });
    const [isHomeActive, setIsHomeActive] = useState(false);
    const [calibrationOffsets, setCalibrationOffsets] = useState({ x: 0, y: 0, z: 0 });
    const [velocityHistory, setVelocityHistory] = useState<number[][]>([[0], [0], [0], [0]]);
    const [torqueHistory, setTorqueHistory] = useState<number[][]>([[0], [0], [0], [0]]);
    const [temperatureHistory, setTemperatureHistory] = useState<number[][]>([[0], [0], [0], [0]]);
    const [voltageHistory, setVoltageHistory] = useState<number[][]>([[0], [0], [0], [0]]);

    const initalMotorData = MotorType === 0 ? 180 : 150;
    const [positionValues, setPositionValues] = useState([initalMotorData, initalMotorData, initalMotorData]);
    const [gVersion, setGVersion] = useState<string>("V1");

    const [charts, setCharts] = useState<Array<ChartConfig>>(
        [
            { id: 'presentSpeed', label: 'Present Speed(%)', visible: true, color: 'rgb(75, 192, 192)', lower_limit: 0, upper_limit: 120, step_magnitude: 30 },
            { id: 'torqueLimit', label: 'Torque Limit', visible: true, color: 'rgb(255, 99, 132)', lower_limit: 0, upper_limit: 100, step_magnitude: 30 },
            { id: 'temperature', label: 'Temperature', visible: true, color: 'rgb(53, 162, 235)', lower_limit: 0, upper_limit: 100, step_magnitude: 30 },
            { id: 'voltage', label: 'Voltage', visible: true, color: 'rgb(255, 159, 64)', lower_limit: 0, upper_limit: 20, step_magnitude: 5 },
        ]
    );
    const [motorsMode, setMotorsMode] = useState<'joint' | 'wheel'>('joint');
    const handleMotorModeChange = (mode: 'joint' | 'wheel') => {
        setMotorsMode(mode);
        setJointWheelMode(mode, [200, 200, 200], [200, 200, 200]);
        setMotorMode(mode);
    }

    const handleCalibrationChange = (axis: Axis, value: string) => {
        console.log(typeof value)
        const numValue = parseFloat(value);
        const newValue = showRadians ? (numValue * 180) / Math.PI : numValue;
        setCalibrationOffsetsFields((prev) => ({
            ...prev,
            [axis]: newValue,
        }));
        // if (isHomeActive) {
        //     setCalibrationOffsets(calibrationOffsetsFields);
        // }
    };

    function matrixProduct(firstMatrix: number[][], secondMatrix: number[][]): number[][] {
        const result: number[][] = Array.from({ length: firstMatrix.length }, () =>
            new Array(secondMatrix[0].length).fill(0));

        for (let row = 0; row < result.length; row++) {
            for (let col = 0; col < result[row].length; col++) {
                for (let i = 0; i < secondMatrix.length; i++) {
                    result[row][col] += firstMatrix[row][i] * secondMatrix[i][col];
                }
            }
        }
        return result;
    }

    function angleTransformation(Data1: number, Data2: number, Data3: number): Position {
        const e1 = Data1 * (Math.PI / 180);
        const e2 = Data2 * (Math.PI / 180);
        const e3 = Data3 * (Math.PI / 180);

        const Rot_X = [
            [1, 0, 0],
            [0, Math.cos(e1), -Math.sin(e1)],
            [0, Math.sin(e1), Math.cos(e1)]
        ];

        const Rot_Y = [
            [Math.cos(e2), 0, Math.sin(e2)],
            [0, 1, 0],
            [-Math.sin(e2), 0, Math.cos(e2)]
        ];

        const Rot_Z = [
            [Math.cos(e3), -Math.sin(e3), 0],
            [Math.sin(e3), Math.cos(e3), 0],
            [0, 0, 1]
        ];

        const Rot_Global = matrixProduct(Rot_Y, matrixProduct(Rot_X, Rot_Z));

        const e_1 = [[1], [0], [0]];
        const e_2 = [[0], [1], [0]];
        const e_3 = [[0], [0], [1]];

        const i = matrixProduct(Rot_Global, e_1);
        const j = matrixProduct(Rot_Global, e_2);
        const k = matrixProduct(Rot_Global, e_3);

        let Roll = 0;
        let Pitch = 0;
        let Yaw = 0;

        if (k[2][0] > 0) {
            Roll = Math.acos(Math.sqrt(j[0][0] ** 2 + j[1][0] ** 2)) * Math.sign(j[2][0]);
        } else {
            Roll = (Math.PI - Math.acos(Math.sqrt(j[0][0] ** 2 + j[1][0] ** 2))) * Math.sign(j[2][0]);
        }

        Pitch = -Math.acos(Math.sqrt(i[0][0] ** 2 + i[1][0] ** 2)) * Math.sign(i[2][0]);

        if (i[1][0] > 0) {
            Yaw = Math.acos(i[0][0] / Math.sqrt(i[0][0] ** 2 + i[1][0] ** 2));
        } else {
            Yaw = 2 * Math.PI - Math.acos(i[0][0] / Math.sqrt(i[0][0] ** 2 + i[1][0] ** 2));
        }

        const valores = [Roll * (180 / Math.PI), Pitch * (180 / Math.PI), Yaw * (180 / Math.PI)];

        return { x: valores[0], y: valores[1], z: valores[2] };
    }

    // Functions to update state
    const saveMode = (newMode: Mode) => setMode(newMode);
    const toggleRadians = () => setShowRadians((prev) => !prev);
    const toggleInverted = (axis: Axis) => setInverted((prev) => ({ ...prev, [axis]: !prev[axis] }));
    const toggleAxisMode = (axis: Axis) => setAxisMode((prev) => ({ ...prev, [axis]: !prev[axis] }));
    const toggleOffsetMode = (axis: Axis) =>
        setOffsetMode((prev) => ({ ...prev, [axis]: !prev[axis] }));
    const changePosition = (axis: Axis, value: number) =>
        setPosition((prev) => ({ ...prev, [axis]: prev[axis] + value }));
    const angleQuotient = (angle: number, axisMode: boolean) => {
        let offset = 180;
        let total_angle = 360;

        if(MotorType == 1){
            offset = 150;
            total_angle = 300;
        }
        let value_quotient = angle - (Math.floor((angle) / total_angle) * total_angle);

        if(mode == "encoders"){

            if (!axisMode) {
                return value_quotient;
            } else {
                return (value_quotient > 180) ? value_quotient - 360 : value_quotient ;
            }
        }else{

            if (!axisMode) {
                return value_quotient;
            } else {
                return value_quotient - offset;
            }
        }
    };

    const getValue = (axis: Axis, isDron: boolean = false, forceInverted = false) => {

        let offset_angle = 180;
        let total_angle = 360;

        if(MotorType == 1){
            offset_angle = 150;
            total_angle = 300;
        }

        if (!position) return 0;
        let offset = (offsetMode[axis] && mode ==="encoders") ? calibrationOffsetsFields[axis] : 0;
        let calibration_offsets = (mode === "encoders") ? calibrationOffsets[axis] : 0;
        let value = angleQuotient(position[axis] + calibration_offsets + offset, axisMode[axis]);
        if (!axisMode[axis]) {
            value = (forceInverted? !inverted[axis] : inverted[axis])  ? total_angle - value : value;
        } else {
            value = (forceInverted? !inverted[axis] : inverted[axis]) ? -value : value;
        }
        if (showRadians && !isDron && mode === "encoders") {
            return (value * Math.PI) / 180;
        } else {
            return value;
        }
    };


    const handleHome = () => {
        const prevHomeActive = isHomeActive;
        setIsHomeActive(!isHomeActive);
        if (!prevHomeActive) {
            setCalibrationOffsets({
                x: 0,
                y: 0,
                z: 0,
            });
            return;
        }

        setCalibrationOffsets({
            x: -1 * angleQuotient(position.x, axisMode['x']),
            y: -1 * angleQuotient(position.y, axisMode['y']),
            z: -1 * angleQuotient(position.z, axisMode['z']),
        });
    };

    return React.createElement(
        DataContext.Provider,
        {
            value: {
                mode,
                saveMode,
                showRadians,
                toggleRadians,
                inverted,
                toggleInverted,
                axisMode,
                toggleAxisMode,
                position,
                setPosition,
                changePosition,
                getValue,
                calibrationOffsetsFields,
                handleCalibrationChange,
                toggleOffsetMode,
                handleHome,
                isHomeActive,
                offsetMode,
                dataHistory,
                setDataHistory,
                setVelocityHistory,
                setTorqueHistory,
                setTemperatureHistory,
                setVoltageHistory,
                charts,
                setCharts,
                velocityHistory,
                torqueHistory,
                temperatureHistory,
                voltageHistory,
                handleMotorModeChange,
                motorsMode,
                angleTransformation,
                gVersion,
                setGVersion,
                positionValues,
                setPositionValues,
            }
        },
        children
    );
};

// Custom hook to use the global data
export const useData = (): DataContextType => {
    const context = useContext(DataContext);
    if (!context) {
        throw new Error("useData must be used within a DataProvider");
    }
    return context;
};
