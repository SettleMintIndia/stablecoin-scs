import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

import FactoryModule from "./Factory";
import RegistryModule from "./Registry";
import PrivadoUVModule from "./PrivadoUV";

const SonyBankStableCoinModule = buildModule(
  "SonyBankStableCoinModule",
  (m) => {
    const { registry } = m.useModule(RegistryModule);
    const { factory } = m.useModule(FactoryModule);
    const { privadoUv } = m.useModule(PrivadoUVModule);

    return { registry, factory, privadoUv };
  }
);

export default SonyBankStableCoinModule;
