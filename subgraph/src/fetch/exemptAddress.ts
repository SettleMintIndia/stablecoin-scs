import { Address, store } from '@graphprotocol/graph-ts';
import { ExemptAddress, TokenContract } from '../../generated/schema';

export function fetchExemptAddress(contract: TokenContract, address: Address): ExemptAddress {
	let id = contract.id
		.toHex()
		.concat("/")
		.concat(address.toHex())

	let exemptAddress = ExemptAddress.load(id);

	if (exemptAddress == null) {
		exemptAddress = new ExemptAddress(id);
		exemptAddress.contract = contract.id;
		exemptAddress.account = address;
	}

	exemptAddress.save()
	return exemptAddress
}

export function deleteExemptAddress(contract: TokenContract, address: Address): void {
	let id = contract.id
		.toHex()
		.concat("/")
		.concat(address.toHex())

	store.remove('ExemptAddress', id)
}
