import { constants, decimals as decimalTool } from '@amxx/graphprotocol-utils';
import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
  Account,
  TokenApproval,
  TokenBalance,
  TokenContract,
} from "../../generated/schema";
import { Token } from "../../generated/tokenregistry/Token";
import { fetchAccount } from "./account";

export function fetchToken(address: Address): TokenContract {
  let contract = TokenContract.load(address);

  if (contract == null) {
    let endpoint = Token.bind(address);
    let name = endpoint.name();
    let symbol = endpoint.symbol();
    let decimals = endpoint.decimals();
    let paused = endpoint.paused();

    let mintFeePercentage = endpoint.mintFeePercentage();
    let burnFeePercentage = endpoint.burnFeePercentage();
    let transferFeePercentage = endpoint.transferFeePercentage();
    let totalSupply = endpoint.totalSupply();
    let cap = endpoint.cap();

    let burnTargetAddress = endpoint.burnTarget();
    const burnTarget = fetchAccount(burnTargetAddress);

    let mintSourceAddress = endpoint.mintSource();
    const mintSource = fetchAccount(mintSourceAddress);

    let feeRecipientAddress = endpoint.feeRecipient();
    const feeRecipient = fetchAccount(feeRecipientAddress);

    let rescueRecipientAddress = endpoint.rescueRecipient();
    const rescueRecipient = fetchAccount(rescueRecipientAddress);

    // Common
    contract = new TokenContract(address);
    contract.asAccount = address;

    contract.name = name;
    contract.symbol = symbol;
    contract.decimals = decimals;
    contract.paused = paused;

    contract.mintSource = mintSource.id;
    contract.feeRecipient = feeRecipient.id;
    contract.rescueRecipient = rescueRecipient.id;
    contract.burnTarget = burnTarget.id;

    contract.cap = decimalTool.toDecimals(cap, decimals);
    contract.capExact = cap

    contract.totalSupply = decimalTool.toDecimals(BigInt.zero(), decimals);
    contract.totalSupplyExact = BigInt.zero();

    contract.mintFeePercentage = decimalTool.toDecimals(mintFeePercentage, decimals);
    contract.mintFeePercentageExact = mintFeePercentage;

    contract.burnFeePercentage = decimalTool.toDecimals(burnFeePercentage, decimals);
    contract.burnFeePercentageExact = burnFeePercentage;

    contract.transferFeePercentage = decimalTool.toDecimals(transferFeePercentage, decimals);
    contract.transferFeePercentageExact = transferFeePercentage;


    contract.save();

    let account = fetchAccount(address);
    account.asToken = address;
    account.save();
  }

  return contract as TokenContract;
}

export function fetchTokenBalance(
  contract: TokenContract,
  account: Account | null
): TokenBalance {
  let id = contract.id
    .toHex()
    .concat("/")
    .concat(account ? account.id.toHex() : "totalSupply");
  let balance = TokenBalance.load(id);

  if (balance == null) {
    balance = new TokenBalance(id);
    balance.contract = contract.id;
    balance.account = account ? account.id : null;
    balance.value = constants.BIGDECIMAL_ZERO;
    balance.valueExact = constants.BIGINT_ZERO;
    balance.frozenValue = constants.BIGDECIMAL_ZERO;
    balance.frozenValueExact = constants.BIGINT_ZERO;
    balance.save();
  }

  return balance as TokenBalance;
}


export function fetchTokenApproval(
  contract: TokenContract,
  owner: Account,
  spender: Account
): TokenApproval {
  let id = contract.id
    .toHex()
    .concat("/")
    .concat(owner.id.toHex())
    .concat("/")
    .concat(spender.id.toHex());
  let approval = TokenApproval.load(id);

  if (approval == null) {
    approval = new TokenApproval(id);
    approval.contract = contract.id;
    approval.owner = owner.id;
    approval.spender = spender.id;
    approval.value = constants.BIGDECIMAL_ZERO;
    approval.valueExact = constants.BIGINT_ZERO;
  }

  return approval as TokenApproval;
}
