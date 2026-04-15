import { useEffect, useRef, useState } from "react";
import * as d3 from "d3";
import { useDarkMode } from "../context/DarkModeContext";
import { MotorType } from "../services/motor_functions";
import { useData } from '../hooks/DataProvider';

interface CircularGaugeProps {
  value: number;
  size?: number;
  showRadians?: boolean;
  axisMode: boolean;
}

export function CircularGauge({ value, size = 200, showRadians = false, axisMode = false }: CircularGaugeProps) {
  const svgRef = useRef<SVGSVGElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const { isDarkMode } = useDarkMode();
  const { mode } = useData();
  const [dynamicSize, setDynamicSize] = useState(size);

  useEffect(() => {
    const handleResize = () => {
      if (containerRef.current) {
        const newSize = Math.min(containerRef.current.offsetWidth, 300); // Max 300px
        setDynamicSize(newSize);
      }
    };

    handleResize(); // Set initial size
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  useEffect(() => {
    if (!svgRef.current) return;

    d3.select(svgRef.current).selectAll("*").remove();

    const margin = 30;
    const radius = (dynamicSize - margin * 2) / 2;
    const center = dynamicSize / 2;

    const svg = d3.select(svgRef.current).attr("width", dynamicSize).attr("height", dynamicSize);

    const gauge = svg.append("g").attr("transform", `translate(${center},${center})`);

    gauge.append("circle")
      .attr("r", radius)
      .attr("fill", "none")
      .attr("stroke", isDarkMode ? "#4B5563" : "#E5E7EB")
      .attr("stroke-width", 2);

for (let angle = 0; angle < 360; angle += 30) {
  const isMainTick = angle % 90 === 0;
  const tickLength = isMainTick ? radius * 0.1 : radius * 0.07;
  const labelDistance = radius + radius * 0.12;

  const angleRad = ((angle - 270) * Math.PI) / 180;
  const x1 = (radius - tickLength) * Math.cos(angleRad);
  const y1 = (radius - tickLength) * Math.sin(angleRad);
  const x2 = radius * Math.cos(angleRad);
  const y2 = radius * Math.sin(angleRad);

  gauge.append("line")
    .attr("x1", x1)
    .attr("y1", y1)
    .attr("x2", x2)
    .attr("y2", y2)
    .attr("stroke", isDarkMode ? "#9CA3AF" : "#6B7280")
    .attr("stroke-width", isMainTick ? 2 : 1);

  const labelX = labelDistance * Math.cos(angleRad);
  const labelY = labelDistance * Math.sin(angleRad);
 

  let labelText = "";
  if (MotorType == 1) {
    if(angle!==0){
      labelText = showRadians ?
      (((axisMode ? angle - 180 : angle - 30) / 180) % 2).toFixed(1) + "π" :
      `${axisMode ? angle - 180 : angle - 30}°`;

    }
  } else {
    if(mode == "encoders"){
      labelText = showRadians ? (((axisMode ? ((angle > 180) ? angle - 360 : angle) : angle) / 180) % 2).toFixed(1) + "π" : ` ${axisMode ? ((angle > 180) ? angle - 360 : angle) : angle}°`;
    }else{
      labelText = showRadians ? (((axisMode ? angle - 180 : angle) / 180) % 2).toFixed(1) + "π" : `${axisMode ? angle - 180 : angle}°`;
    }
  }


  gauge.append("text")
    .attr("x", labelX)
    .attr("y", labelY)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "middle")
    .attr("fill", isDarkMode ? "#D1D5DB" : "#374151")
    .attr("font-size", `${dynamicSize * 0.06}px`)
    .text(labelText);
}

    const needleLength = radius - 10;
    const valueInDegrees = (showRadians && mode === "encoders") ? (value * 180) / Math.PI : value;
    const needleAngle = (mode == "encoders") ? ((valueInDegrees - (axisMode ? -90 : (MotorType !== 1 ? 270 : 240))) * Math.PI) / 180 : ((valueInDegrees - (axisMode ? 90 : (MotorType !== 1 ? 270 : 240))) * Math.PI) / 180
    // mode == "encoders"
    // if(true){
    //   let needleAngle = ((valueInDegrees - (axisMode ? -90 : (MotorType !== 1 ? 270 : 240))) * Math.PI) / 180;
    // }else{
    //   let needleAngle = ((valueInDegrees - (axisMode ? 90 : (MotorType !== 1 ? 270 : 240))) * Math.PI) / 180;
    // }

    const needleX = needleLength * Math.cos(needleAngle);
    const needleY = needleLength * Math.sin(needleAngle);

    gauge.append("line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", needleX)
      .attr("y2", needleY)
      .attr("stroke", "#EF4444")
      .attr("stroke-width", 2);

    gauge.append("circle")
      .attr("r", 5)
      .attr("fill", "#EF4444");

  }, [value, dynamicSize, isDarkMode, showRadians]);

  return (
    <div ref={containerRef} className="w-full max-w-xs mx-auto">
      <svg ref={svgRef} className="block mx-auto" />
    </div>
  );
}
