import { events, transactions } from '@amxx/graphprotocol-utils';
import { store } from '@graphprotocol/graph-ts';
import { AccessControlRoleMember, RegistryToken, RoleAdminChanged, RoleGranted, RoleRevoked } from '../generated/schema';
import { token } from "../generated/templates";
import { RoleAdminChanged as RoleAdminChangedEvent, RoleGranted as RoleGrantedEvent, RoleRevoked as RoleRevokedEvent } from '../generated/templates/token/Token';
import { TokenAdded } from "../generated/tokenregistry/TokenRegistry";
import { fetchAccessControl, fetchAccessControlRole, fetchRole } from './fetch/accesscontrol';
import { fetchAccount } from './fetch/account';
import { fetchToken } from './fetch/erc20';

export function handleTokenAdded(event: TokenAdded): void {
  let contract = fetchToken(event.params.tokenAddress)
  contract.mintType = event.params.extraData
  contract.isExternal = false;
  contract.save()

  let registryToken = new RegistryToken(event.params.tokenAddress.toHexString())
  registryToken.symbol = event.params.symbol
  registryToken.contract = contract.id
  registryToken.tokenFactory = event.params.tokenFactory
  registryToken.extraData = event.params.extraData
  registryToken.save()

  token.create(event.params.tokenAddress)
}

export function handleRoleAdminChanged(event: RoleAdminChangedEvent): void {
  let contract = fetchAccessControl(event.address)
  let accesscontrolrole = fetchAccessControlRole(contract, fetchRole(event.params.role))
  let admin = fetchAccessControlRole(contract, fetchRole(event.params.newAdminRole))
  let previous = fetchAccessControlRole(contract, fetchRole(event.params.previousAdminRole))

  accesscontrolrole.admin = admin.id
  accesscontrolrole.save()

  let ev = new RoleAdminChanged(events.id(event))
  ev.emitter = contract.id
  ev.transaction = transactions.log(event).id
  ev.timestamp = event.block.timestamp
  ev.role = accesscontrolrole.id
  ev.newAdminRole = admin.id
  ev.previousAdminRole = previous.id
  ev.save()
}

export function handleRoleGranted(event: RoleGrantedEvent): void {
  let contract = fetchAccessControl(event.address)
  let accesscontrolrole = fetchAccessControlRole(contract, fetchRole(event.params.role))
  let account = fetchAccount(event.params.account)
  let sender = fetchAccount(event.params.sender)

  let accesscontrolrolemember = new AccessControlRoleMember(accesscontrolrole.id.concat('/').concat(account.id.toHex()))
  accesscontrolrolemember.accesscontrolrole = accesscontrolrole.id
  accesscontrolrolemember.account = account.id
  accesscontrolrolemember.save()

  let ev = new RoleGranted(events.id(event))
  ev.emitter = contract.id
  ev.transaction = transactions.log(event).id
  ev.timestamp = event.block.timestamp
  ev.role = accesscontrolrole.id
  ev.account = account.id
  ev.sender = sender.id
  ev.save()
}

export function handleRoleRevoked(event: RoleRevokedEvent): void {
  let contract = fetchAccessControl(event.address)
  let accesscontrolrole = fetchAccessControlRole(contract, fetchRole(event.params.role))
  let account = fetchAccount(event.params.account)
  let sender = fetchAccount(event.params.sender)

  store.remove('AccessControlRoleMember', accesscontrolrole.id.concat('/').concat(account.id.toHex()))

  let ev = new RoleRevoked(events.id(event))
  ev.emitter = contract.id
  ev.transaction = transactions.log(event).id
  ev.timestamp = event.block.timestamp
  ev.role = accesscontrolrole.id
  ev.account = account.id
  ev.sender = sender.id
  ev.save()
}