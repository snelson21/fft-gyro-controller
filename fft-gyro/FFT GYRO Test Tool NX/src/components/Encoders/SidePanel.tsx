import { createRoot } from "react-dom/client";
import { DataProvider, useData } from "../../hooks/DataProvider";
import ThreeModel from "../ThreeModel";
import { AircraftAttitudeDisplay } from "../AttitudeIndicator/AircraftAttitudeIndicator";

let win: WindowProxy | null = null;;
const handleOpenTreeModel = () => {
    if (win && !win.closed) {
      win.focus();
      return;
    }
  
    win = window.open("", "_blank", "width=600,height=400");
    if (win) {
      win.document.write("<div id='root'></div>");
      win.document.close(); // Ensure the document is fully loaded before rendering
  
      const container = win.document.getElementById("root");
      if (container) {
        // Copy styles from main window to the new window
        document.querySelectorAll("link[rel='stylesheet'], style").forEach((style) => {
          win?.document.head.appendChild(style.cloneNode(true));
        });
  
        // Render the TreeModel inside the new window, wrapped in DataProvider
        const root = createRoot(container);
        root.render(
          <DataProvider> 
            <ThreeModel isExt={true} />
          </DataProvider>
        );
      }
    }
  };


export default function SidePanel() {
    const { getValue } = useData();
    return (
        <div style={{ borderRadius: "10rem", width: "7vw", height:"40vh" }} className="fixed left-0 top-1/2 transform -translate-y-1/2 flex flex-col items-center bg-gray-100 text-gray-800 shadow-lg w-100 h-80 px-2">
            {/* Top Circle with 3D Model */}
            <div style={{ width: "7vw", height: "7vw" }} className="w-20 h-20 rounded-full bg-white shadow-xl flex items-center justify-center absolute top-0"
                onClick={() => { handleOpenTreeModel() }}
                >
                <ThreeModel isExt={false} />
            </div>

            {/* Center Section with Roll, Pitch, Yaw */}
            <div className="flex flex-col items-center justify-center text-xs text-center flex-grow space-y-2 my-10">
                <p>Roll: {getValue("x").toFixed(1)}°</p>
                <p>Pitch: {getValue("y").toFixed(1)}°</p>
                <p>Yaw: {getValue("z").toFixed(1)}°</p>
            </div>

            {/* Bottom Circle with Extra Component */}
            <div style={{ width: "7vw", height: "7vw" }} className="w-20 h-20 rounded-full bg-white shadow-xl flex items-center justify-center absolute bottom-0">
                <AircraftAttitudeDisplay isMini={false} />
            </div>
        </div>
    );
}

