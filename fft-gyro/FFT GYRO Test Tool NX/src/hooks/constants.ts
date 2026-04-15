export interface Position {
    timestamp?: number;
    x: number;
    y: number;
    z: number;
    roll?: number;
    pitch?: number;
    yaw?: number;
    torquex?: number;
    torquey?: number;
    torquez?: number;
    voltagex?: number;
    voltagey?: number;
    voltagez?: number;
    temperaturex?: number;
    temperaturey?: number;
    temperaturez?: number;
    velocityx?: number;
    velocityy?: number;
    velocityz?: number;
}


export type Axis = 'x' | 'y' | 'z';

export type Mode = 'encoders' | 'motors';

export interface ChartConfig {
    id: string;
    label: string;
    visible: boolean;
    color: string;
    lower_limit: number;
    upper_limit: number;
    step_magnitude: number;
}


export const axisMapping = {
    x: { name: 'Roll', description: 'Rotation around longitudinal axis' },
    y: { name: 'Pitch', description: 'Rotation around lateral axis' },
    z: { name: 'Yaw', description: 'Rotation around vertical axis' }
};


// export const chartOptions = {
//     responsive: true,
//     animation: false,
//     plugins: {
//         legend: {
//             position: 'top' as const,
//         },
//     },
//     scales: {
//         y: {
//             beginAtZero: true,
//         },
//     },
// };

export const chartOptions = {

    responsive: true,
  
    animation: false,
  
    plugins: {
  
      legend: {
  
        position: "top",
  
      },
  
    },
  
    scales: {
  
      y: {
  
        beginAtZero: true,
  
      },
  
    },
  
  };