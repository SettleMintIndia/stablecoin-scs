import { VerfifiedZKPRequest } from '../generated/schema';
import {
  ZKPResponseSubmitted as ZKPResponseSubmittedEvent
} from "../generated/universal-verifier/UniversalVerifier";
import { fetchAccount } from './fetch/account';


export function handleZKPResponseSubmitted(
  event: ZKPResponseSubmittedEvent
): void {
  let id = event.transaction.from.toHexString().concat(event.params.requestId.toString())
  let contract = VerfifiedZKPRequest.load(id);

  if (contract == null) {
    contract = new VerfifiedZKPRequest(id);
    contract.requestId = event.params.requestId;
    const account = fetchAccount(event.transaction.from);
    contract.account = account.id;
    contract.save();
  }
}
