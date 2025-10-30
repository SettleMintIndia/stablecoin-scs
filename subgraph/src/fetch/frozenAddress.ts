import { Address, store } from '@graphprotocol/graph-ts';
import { FrozenAddress, TokenContract } from '../../generated/schema';

export function fetchFrozenAddress(contract: TokenContract, address: Address): FrozenAddress {
	let id = contract.id
		.toHex()
		.concat("/")
		.concat(address.toHex())

	let frozenAddress = FrozenAddress.load(id);

	if (frozenAddress == null) {
		frozenAddress = new FrozenAddress(id);
		frozenAddress.contract = contract.id;
		frozenAddress.account = address;
	}

	frozenAddress.save()
	return frozenAddress
}



export function deleteFrozenAddress(contract: TokenContract, address: Address): void {
	let id = contract.id
		.toHex()
		.concat("/")
		.concat(address.toHex())

	store.remove('FrozenAddress', id)
}
