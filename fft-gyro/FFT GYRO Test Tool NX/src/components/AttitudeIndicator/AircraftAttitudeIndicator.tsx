import { useData } from '../../hooks/DataProvider';

export const AircraftAttitudeDisplay: React.FC<{ isMini: boolean }> = ({ isMini }) => {
  const { getValue, axisMode } = useData();
  const AttitudeIndicator: React.FC<{ roll: number; pitch: number , isMini:boolean}> = ({ roll, pitch, isMini }) => {
    // Create pitch marks for the artificial horizon
    if(!axisMode["y"]){
      pitch = (pitch > 180 && pitch <=360) ? pitch - 360 : pitch;
    }
    const pitchMarks = [];
    for (let i = -90; i <= 90; i += 10) {
      if (i === 0) continue; // Skip center line

      const width = i % 30 === 0 ? '20%' : '15%';

      // Only add labels for major marks
      if (i % 30 === 0) {
        pitchMarks.push(
          <div
            key={`pitch-${i}`}
            className="pitch-mark"
            style={{
              position: 'absolute',
              left: '50%',
              transform: 'translateX(-50%)',
              top: `${50 - i * 0.5}%`,
              width: width,
              height: '1px',
              backgroundColor: 'white',
            }}
          >
            {isMini &&
              <>
                <span
                  style={{
                    position: 'absolute',
                    left: '22%',
                    transform: 'translateY(-50%)',
                    color: 'white',
                    fontSize: '1vw', // Responsive font size
                  }}
                >
                  {Math.abs(i)}°
                </span>
                <span
                  style={{
                    position: 'absolute',
                    right: '22%',
                    transform: 'translateY(-50%)',
                    color: 'white',
                    fontSize: '1vw', // Responsive font size
                  }}
                >
                  {Math.abs(i)}°
                </span>
              </>
            }
          </div>
        );
      } else {
        pitchMarks.push(
          <div
            key={`pitch-${i}`}
            className="pitch-mark"
            style={{
              position: 'absolute',
              left: '50%',
              transform: 'translateX(-50%)',
              top: `${50 - i * 0.5}%`,
              width: width,
              height: '2px',
              backgroundColor: 'white',
            }}
          />
        );
      }
    }

    return (
      <div
        className="attitude-indicator"
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
          borderRadius: '50%',
          border: '5px solid #444',
          overflow: 'hidden',
          backgroundColor: '#222',
          boxShadow: 'inset 0 0 20px rgba(0, 0, 0, 0.5)',
        }}
      >
        {/* Horizon (sky and ground) */}
        <div
          className="horizon"
          style={{
            position: 'absolute',
            width: '100%',
            height: '100%',
            borderRadius: '50%',
            transformOrigin: 'center',
            transform: `rotate(${-roll}deg) translateY(${pitch * 1.5}%)`,
          }}
        >
          <div
            className="sky"
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '50%',
              backgroundColor: '#5e8cd6',
            }}
          />
          <div
            className="ground"
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              width: '100%',
              height: '50%',
              backgroundColor: '#8a6642',
            }}
          />
          <div className="pitch-marks">{pitchMarks}</div>
        </div>

        {/* Airplane symbol */}
        <svg
          className="airplane-symbol"
          style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '25%',
            height: '25%',
            pointerEvents: 'none',
          }}
          viewBox="0 0 100 100"
        >
          <line x1="20" y1="50" x2="80" y2="50" stroke="white" strokeWidth="3" />
          <line x1="50" y1="20" x2="50" y2="80" stroke="white" strokeWidth="3" />
          <circle cx="50" cy="50" r="5" fill="white" />
          <line x1="35" y1="50" x2="25" y2="60" stroke="white" strokeWidth="3" />
          <line x1="35" y1="50" x2="25" y2="40" stroke="white" strokeWidth="3" />
        </svg>
      </div>
    );
  };

  return (
    <div style={{ width: '100%', height: '100%' }}>
      <AttitudeIndicator roll={getValue('x', true)} pitch={getValue('y', true)} isMini ={isMini} />
      {/* {isMini && <YawIndicator yaw={getValue('z')} />} */}
    </div>
  );
};
