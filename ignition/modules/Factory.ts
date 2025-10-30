import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";
import RegistryModule from "./Registry";

const WALLET_CREATOR = vars.get("WALLET_CREATOR");

const FactoryModule = buildModule(
  "FactoryModule",
  (m) => {
    const { registry } = m.useModule(RegistryModule);
    const factory = m.contract("Factory", [registry]);

    const factoryRole = m.staticCall(registry, "FACTORY_ROLE");
    m.call(registry, "grantRole", [factoryRole, factory]);

    const tokenCreationRole = m.staticCall(factory, "TOKEN_CREATION_ROLE");
    m.call(factory, "grantRole", [tokenCreationRole, WALLET_CREATOR]);

    return { factory };
  }
);

export default FactoryModule;
