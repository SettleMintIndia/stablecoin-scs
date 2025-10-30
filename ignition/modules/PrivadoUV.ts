import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const PrivadoUVModule = buildModule("PrivadoUVModule", (m) => {
  const privadoUv = m.contract("PrivadoIdUniversalVerifier", [
    "0x70696036CA1868B42155b06235F95549667Eb0BE",
  ]);
  // m.call(privadoUv, "setRequestId", [1719574130928, 1719574130928]);
  return { privadoUv };
});

export default PrivadoUVModule;
