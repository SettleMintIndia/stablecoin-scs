import {
  decimals as decimalTool,
  decimals,
  events,
  transactions,
} from "@amxx/graphprotocol-utils";
import { Address, store } from "@graphprotocol/graph-ts";
import {
  AccessControlRoleMember,
  RoleAdminChanged,
  RoleGranted,
  RoleRevoked,
  TokenTransfer,
} from "../generated/schema";
import {
  AddressExemptStatusChanged as AddressExemptStatusChangedEvent,
  AddressFrozen as AddressFrozenEvent,
  AddressThawed as AddressThawedEvent,
  Approval as ApprovalEvent,
  BurnTargetChanged as BurnTargetChangedEvent,
  CapChanged as CapChangedEvent,
  FeeChanged as FeeChangedEvent,
  FeeRecipientChanged as FeeRecipientChangedEvent,
  MintSourceChanged as MintSourceChangedEvent,
  Paused as PausedEvent,
  RescueRecipientChanged as RescueRecipientChangedEvent,
  ComplianceAdded as ComplianceAddedEvent,
  ComplianceRemoved as ComplianceRemovedEvent,
  RoleAdminChanged as RoleAdminChangedEvent,
  RoleGranted as RoleGrantedEvent,
  RoleRevoked as RoleRevokedEvent,
  TokensFrozen as TokensFrozenEvent,
  TokensThawed as TokensThawedEvent,
  Transfer as TransferEvent,
  Unpaused as UnpausedEvent,
} from "../generated/templates/token/Token";
import {
  fetchAccessControl,
  fetchAccessControlRole,
  fetchRole,
} from "./fetch/accesscontrol";
import { fetchAccount } from "./fetch/account";
import {
  fetchToken,
  fetchTokenApproval,
  fetchTokenBalance,
} from "./fetch/erc20";
import { deleteExemptAddress, fetchExemptAddress } from "./fetch/exemptAddress";
import { deleteFrozenAddress, fetchFrozenAddress } from "./fetch/frozenAddress";

export function handleTransfer(event: TransferEvent): void {
  let contract = fetchToken(event.address);
  let ev = new TokenTransfer(events.id(event));
  ev.emitter = contract.id;
  ev.transaction = transactions.log(event).id;
  ev.timestamp = event.block.timestamp;
  ev.contract = contract.id;

  ev.value = decimals.toDecimals(event.params.value, contract.decimals);
  ev.valueExact = event.params.value;

  if (event.params.from == Address.zero()) {
    contract.totalSupplyExact = contract.totalSupplyExact.plus(
      event.params.value
    );
    contract.totalSupply = decimals.toDecimals(
      contract.totalSupplyExact,
      contract.decimals
    );
  } else {
    let from = fetchAccount(event.params.from);
    let balance = fetchTokenBalance(contract, from);
    balance.valueExact = balance.valueExact.minus(event.params.value);
    balance.value = decimals.toDecimals(balance.valueExact, contract.decimals);
    balance.save();

    ev.from = from.id;
    ev.fromBalance = balance.id;
  }

  if (event.params.to == Address.zero()) {
    contract.totalSupplyExact = contract.totalSupplyExact.minus(
      event.params.value
    );
    contract.totalSupply = decimals.toDecimals(
      contract.totalSupplyExact,
      contract.decimals
    );
  } else {
    let to = fetchAccount(event.params.to);
    let balance = fetchTokenBalance(contract, to);
    balance.valueExact = balance.valueExact.plus(event.params.value);
    balance.value = decimals.toDecimals(balance.valueExact, contract.decimals);
    balance.save();

    ev.to = to.id;
    ev.toBalance = balance.id;
  }

  // if (event.params.from != Address.zero() && event.params.to != Address.zero()) {
  //   const volume = new TokenVolume('dummy-id');
  //   volume.token = contract.id;
  //   volume.volume = event.params.value;
  //   volume.save();
  // }

  ev.save();
  contract.save();
}

export function handleApproval(event: ApprovalEvent): void {
  let contract = fetchToken(event.address);

  let owner = fetchAccount(event.params.owner);
  let spender = fetchAccount(event.params.spender);
  let approval = fetchTokenApproval(contract, owner, spender);
  approval.valueExact = event.params.value;
  approval.value = decimals.toDecimals(event.params.value, contract.decimals);
  approval.save();
}

export function handleAddressExemptStatusChanged(
  event: AddressExemptStatusChangedEvent
): void {
  let contract = fetchToken(event.address);

  if (event.params._exempt) {
    let exemptAddress = fetchExemptAddress(contract, event.params._address);
    exemptAddress.isExempt = true;
    exemptAddress.save();
  } else {
    deleteExemptAddress(contract, event.params._address);
  }
}

export function handleAddressFrozen(event: AddressFrozenEvent): void {
  let contract = fetchToken(event.address);
  let exemptAddress = fetchFrozenAddress(contract, event.params._userAddress);

  exemptAddress.isFrozen = true;
  exemptAddress.save();
}

export function handleAddressThawed(event: AddressThawedEvent): void {
  let contract = fetchToken(event.address);
  deleteFrozenAddress(contract, event.params._userAddress);
}

export function handleBurnTargetChanged(event: BurnTargetChangedEvent): void {
  let contract = fetchToken(event.address);

  contract.burnTarget = event.address;
  contract.save();
}

export function handleCapChanged(event: CapChangedEvent): void {
  let contract = fetchToken(event.address);

  contract.cap = decimals.toDecimals(event.params.cap, contract.decimals);
  contract.capExact = event.params.cap;

  contract.save();
}

export function handleFeeChanged(event: FeeChangedEvent): void {
  let contract = fetchToken(event.address);

  if (event.params._feeType == 0) {
    contract.mintFeePercentage = decimalTool.toDecimals(
      event.params._feePercentage,
      contract.decimals
    );
    contract.mintFeePercentageExact = event.params._feePercentage;
  } else if (event.params._feeType == 1) {
    contract.burnFeePercentage = decimalTool.toDecimals(
      event.params._feePercentage,
      contract.decimals
    );
    contract.burnFeePercentageExact = event.params._feePercentage;
  } else if (event.params._feeType == 2) {
    contract.transferFeePercentage = decimalTool.toDecimals(
      event.params._feePercentage,
      contract.decimals
    );
    contract.transferFeePercentageExact = event.params._feePercentage;
  }

  contract.save();
}

export function handleFeeRecipientChanged(
  event: FeeRecipientChangedEvent
): void {
  let contract = fetchToken(event.address);
  contract.feeRecipient = event.params._feeRecipient;
  contract.save();
}

export function handleMintSourceChanged(event: MintSourceChangedEvent): void {
  let contract = fetchToken(event.address);
  contract.mintSource = event.params._mintSource;
  contract.save();
}

export function handlePaused(event: PausedEvent): void {
  let contract = fetchToken(event.address);
  contract.paused = true;
  contract.save();
}

export function handleUnpaused(event: UnpausedEvent): void {
  let contract = fetchToken(event.address);
  contract.paused = false;
  contract.save();
}

export function handleTokensFrozen(event: TokensFrozenEvent): void {
  let contract = fetchToken(event.address);
  let account = fetchAccount(event.params._userAddress);
  let balance = fetchTokenBalance(contract, account);
  balance.frozenValueExact = balance.frozenValueExact.plus(
    event.params._amount
  );
  balance.frozenValue = decimals.toDecimals(
    balance.frozenValueExact,
    contract.decimals
  );
  balance.save();
}

export function handleTokensThawed(event: TokensThawedEvent): void {
  let contract = fetchToken(event.address);
  let account = fetchAccount(event.params._userAddress);
  let balance = fetchTokenBalance(contract, account);
  balance.frozenValueExact = balance.frozenValueExact.minus(
    event.params._amount
  );
  balance.frozenValue = decimals.toDecimals(
    balance.frozenValueExact,
    contract.decimals
  );
  balance.save();
}

export function handleRescueRecipientChanged(
  event: RescueRecipientChangedEvent
): void {
  let contract = fetchToken(event.address);
  let rescueRecipient = fetchAccount(event.params._rescueRecipient);
  contract.rescueRecipient = rescueRecipient.id;
  contract.save();
}

export function handleComplianceAdded(event: ComplianceAddedEvent): void {
  let contract = fetchToken(event.address);
  let complianceAdded = fetchAccount(event.params._compliance);
  contract.complianceAdded = complianceAdded.id;
  contract.complianceStatus = true;
  contract.save();
}
export function handleComplianceRemoved(event: ComplianceRemovedEvent): void {
  let contract = fetchToken(event.address);
  let complianceRemove = fetchAccount(event.params._compliance);
  contract.complianceAdded = complianceRemove.id;
  contract.complianceStatus = false;
  contract.save();
}
export function handleRoleAdminChanged(event: RoleAdminChangedEvent): void {
  let contract = fetchAccessControl(event.address);
  let accesscontrolrole = fetchAccessControlRole(
    contract,
    fetchRole(event.params.role)
  );
  let admin = fetchAccessControlRole(
    contract,
    fetchRole(event.params.newAdminRole)
  );
  let previous = fetchAccessControlRole(
    contract,
    fetchRole(event.params.previousAdminRole)
  );

  accesscontrolrole.admin = admin.id;
  accesscontrolrole.save();

  let ev = new RoleAdminChanged(events.id(event));
  ev.emitter = contract.id;
  ev.transaction = transactions.log(event).id;
  ev.timestamp = event.block.timestamp;
  ev.role = accesscontrolrole.id;
  ev.newAdminRole = admin.id;
  ev.previousAdminRole = previous.id;
  ev.save();
}

export function handleRoleGranted(event: RoleGrantedEvent): void {
  let contract = fetchAccessControl(event.address);
  let accesscontrolrole = fetchAccessControlRole(
    contract,
    fetchRole(event.params.role)
  );
  let account = fetchAccount(event.params.account);
  let sender = fetchAccount(event.params.sender);

  let accesscontrolrolemember = new AccessControlRoleMember(
    accesscontrolrole.id.concat("/").concat(account.id.toHex())
  );
  accesscontrolrolemember.accesscontrolrole = accesscontrolrole.id;
  accesscontrolrolemember.account = account.id;
  accesscontrolrolemember.save();

  let ev = new RoleGranted(events.id(event));
  ev.emitter = contract.id;
  ev.transaction = transactions.log(event).id;
  ev.timestamp = event.block.timestamp;
  ev.role = accesscontrolrole.id;
  ev.account = account.id;
  ev.sender = sender.id;
  ev.save();
}

export function handleRoleRevoked(event: RoleRevokedEvent): void {
  let contract = fetchAccessControl(event.address);
  let accesscontrolrole = fetchAccessControlRole(
    contract,
    fetchRole(event.params.role)
  );
  let account = fetchAccount(event.params.account);
  let sender = fetchAccount(event.params.sender);

  store.remove(
    "AccessControlRoleMember",
    accesscontrolrole.id.concat("/").concat(account.id.toHex())
  );

  let ev = new RoleRevoked(events.id(event));
  ev.emitter = contract.id;
  ev.transaction = transactions.log(event).id;
  ev.timestamp = event.block.timestamp;
  ev.role = accesscontrolrole.id;
  ev.account = account.id;
  ev.sender = sender.id;
  ev.save();
}
