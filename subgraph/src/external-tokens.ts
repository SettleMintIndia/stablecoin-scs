import {
  decimals as decimalTool,
  events,
  transactions,
  constants,
} from "@amxx/graphprotocol-utils";
import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
  TokenContract,
  TokenBalance,
  TokenTransfer,
  TokenApproval,
} from "../generated/schema";
import {
  Transfer as TransferEvent,
  Approval as ApprovalEvent,
} from "../generated/usdc-token/ERC20";
import { ERC20 } from "../generated/usdc-token/ERC20";
import { fetchAccount } from "./fetch/account";

function fetchExternalToken(address: Address): TokenContract {
  let contract = TokenContract.load(address);

  if (contract == null) {
    let endpoint = ERC20.bind(address);
    
    // Try to get token details, with fallbacks for tokens that might not implement all methods
    let nameResult = endpoint.try_name();
    let symbolResult = endpoint.try_symbol();
    let decimalsResult = endpoint.try_decimals();
    let totalSupplyResult = endpoint.try_totalSupply();

    let name = nameResult.reverted ? "Unknown" : nameResult.value;
    let symbol = symbolResult.reverted ? "Unknown" : symbolResult.value;
    let decimals = decimalsResult.reverted ? 18 : decimalsResult.value;
    let totalSupply = totalSupplyResult.reverted ? BigInt.zero() : totalSupplyResult.value;

    // Determine token type based on contract address
    let tokenType = "Unknown";
    if (address.toHexString().toLowerCase() == "0x41e94eb019c0762f9bfcf9fb1e58725bfb0e7582") {
      tokenType = "USDC";
      name = "USD Coin";
      symbol = "USDC";
      decimals = 6;
    } else if (address.toHexString().toLowerCase() == "0xb8e9bdef4431a147df3e099d7961715b997bf8b6") {
      tokenType = "USDT";
      name = "Tether USD";
      symbol = "USDT";
      decimals = 6;
    }

    // Create contract entity
    contract = new TokenContract(address);
    contract.asAccount = address;
    contract.name = name;
    contract.symbol = symbol;
    contract.decimals = decimals;
    contract.mintType = tokenType;
    contract.isExternal = true;
    contract.paused = false; // External tokens don't have pause functionality in our context

    if (tokenType == "USDC") {
      contract.tokenType = "USDC";
    } else if (tokenType == "USDT") {
      contract.tokenType = "USDT"; 
    } else {
      contract.tokenType = "EXTERNAL";
    }

    // Set default values for fields specific to your custom tokens
    contract.cap = constants.BIGDECIMAL_ZERO;
    contract.capExact = constants.BIGINT_ZERO;
    contract.totalSupply = decimalTool.toDecimals(totalSupply, decimals);
    contract.totalSupplyExact = totalSupply;

    // Set fee percentages to zero for external tokens
    contract.mintFeePercentage = constants.BIGDECIMAL_ZERO;
    contract.mintFeePercentageExact = constants.BIGINT_ZERO;
    contract.burnFeePercentage = constants.BIGDECIMAL_ZERO;
    contract.burnFeePercentageExact = constants.BIGINT_ZERO;
    contract.transferFeePercentage = constants.BIGDECIMAL_ZERO;
    contract.transferFeePercentageExact = constants.BIGINT_ZERO;

    // Set default accounts (these won't be relevant for external tokens)
    let zeroAccount = fetchAccount(Address.zero());
    contract.burnTarget = zeroAccount.id;
    contract.mintSource = zeroAccount.id;
    contract.rescueRecipient = zeroAccount.id;
    contract.feeRecipient = zeroAccount.id;
    contract.complianceStatus = false;

    contract.save();

    // Create account entity for the token contract
    let account = fetchAccount(address);
    account.asToken = address;
    account.save();
  }

  return contract as TokenContract;
}

function fetchExternalTokenBalance(
  contract: TokenContract,
  account: Address | null
): TokenBalance {
  let id = contract.id
    .toHex()
    .concat("/")
    .concat(account ? account.toHex() : "totalSupply");
  let balance = TokenBalance.load(id);

  if (balance == null) {
    balance = new TokenBalance(id);
    balance.contract = contract.id;
    balance.account = account;
    balance.value = constants.BIGDECIMAL_ZERO;
    balance.valueExact = constants.BIGINT_ZERO;
    balance.frozenValue = constants.BIGDECIMAL_ZERO;
    balance.frozenValueExact = constants.BIGINT_ZERO;
    balance.save();
  }

  return balance as TokenBalance;
}

function fetchExternalTokenApproval(
  contract: TokenContract,
  owner: Address,
  spender: Address
): TokenApproval {
  let id = contract.id
    .toHex()
    .concat("/")
    .concat(owner.toHex())
    .concat("/")
    .concat(spender.toHex());
  let approval = TokenApproval.load(id);

  if (approval == null) {
    approval = new TokenApproval(id);
    approval.contract = contract.id;
    approval.owner = owner;
    approval.spender = spender;
    approval.value = constants.BIGDECIMAL_ZERO;
    approval.valueExact = constants.BIGINT_ZERO;
    approval.save();
  }

  return approval as TokenApproval;
}

export function handleTransfer(event: TransferEvent): void {
  let contract = fetchExternalToken(event.address);
  let from = fetchAccount(event.params.from);
  let to = fetchAccount(event.params.to);

  // Update balances
  let fromBalance: TokenBalance | null = null;
  let toBalance: TokenBalance | null = null;

  // Handle mint (from zero address)
  if (event.params.from != Address.zero()) {
    fromBalance = fetchExternalTokenBalance(contract, event.params.from);
    fromBalance.value = fromBalance.value.minus(decimalTool.toDecimals(event.params.value, contract.decimals));
    fromBalance.valueExact = fromBalance.valueExact.minus(event.params.value);
    fromBalance.save();
  } else {
    // Mint: increase total supply
    contract.totalSupply = contract.totalSupply.plus(decimalTool.toDecimals(event.params.value, contract.decimals));
    contract.totalSupplyExact = contract.totalSupplyExact.plus(event.params.value);
  }

  // Handle burn (to zero address)
  if (event.params.to != Address.zero()) {
    toBalance = fetchExternalTokenBalance(contract, event.params.to);
    toBalance.value = toBalance.value.plus(decimalTool.toDecimals(event.params.value, contract.decimals));
    toBalance.valueExact = toBalance.valueExact.plus(event.params.value);
    toBalance.save();
  } else {
    // Burn: decrease total supply
    contract.totalSupply = contract.totalSupply.minus(decimalTool.toDecimals(event.params.value, contract.decimals));
    contract.totalSupplyExact = contract.totalSupplyExact.minus(event.params.value);
  }

  contract.save();

  // Create transfer event
  let transfer = new TokenTransfer(events.id(event));
  transfer.emitter = contract.asAccount;
  transfer.transaction = transactions.log(event).id;
  transfer.timestamp = event.block.timestamp;
  transfer.contract = contract.id;
  transfer.from = event.params.from == Address.zero() ? null : from.id;
  transfer.fromBalance = fromBalance ? fromBalance.id : null;
  transfer.to = event.params.to == Address.zero() ? null : to.id;
  transfer.toBalance = toBalance ? toBalance.id : null;
  transfer.value = decimalTool.toDecimals(event.params.value, contract.decimals);
  transfer.valueExact = event.params.value;
  transfer.save();
}

export function handleApproval(event: ApprovalEvent): void {
  let contract = fetchExternalToken(event.address);
  let approval = fetchExternalTokenApproval(contract, event.params.owner, event.params.spender);
  
  approval.value = decimalTool.toDecimals(event.params.value, contract.decimals);
  approval.valueExact = event.params.value;
  approval.save();
}