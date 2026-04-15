import { Canvas } from "@react-three/fiber";
import { useGLTF } from "@react-three/drei";
import { useEffect, useRef } from "react";
import * as THREE from "three";
import { useData } from "../hooks/DataProvider";

function Model({ isExt }: { isExt: boolean }) {
  const { scene } = useGLTF("assets/quadcopter_drone" + (isExt ? "_ext" : "") + ".glb"); // Change to your model path
  const modelRef = useRef<THREE.Object3D>(null);
  const {position , getValue} = useData()

  useEffect(() => {
    if (modelRef.current) {
      modelRef.current.rotation.set(
        getValue("y", true, true) * (Math.PI / 180),
        getValue("z", true) * (Math.PI / 180),
        getValue("x", true, true) * (Math.PI / 180),
      );
    }
  }, [position]);

  return <primitive object={scene} ref={modelRef}  scale = {2.5}/>;
}

export default function ThreeModel({ isExt }: { isExt: boolean }) {
  return (
    <Canvas camera={{ position: [0, 0, 5] }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[5, 5, 5]} />
      <Model isExt={isExt} />
    </Canvas>
  );
}
