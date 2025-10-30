import { decimals } from '@amxx/graphprotocol-utils';
import {
	Address,
	ethereum,
} from '@graphprotocol/graph-ts';
import {
	Account
} from '../../generated/schema';

export function fetchAccount(address: Address): Account {
	let account = new Account(address)
	let balance = ethereum.getBalance(address) // returns balance in BigInt
	account.nativeValue = decimals.toDecimals(balance, 18);
	account.nativeValueExact = balance;
	account.save()
	return account
}
