import { RequestSettings, createReguest } from './lib/create-request';
import { packValidatorParams } from './lib/pack-validator-params';
import { generateRequestData } from './lib/schema-and-field-hash';
import { sendTransaction } from './lib/send-transaction';

// Run with: BTP_RPC_URL=https://sony-bank-development-amoy-deployme-d827.aks-japan.settlemint.com/sm_pat_7d126896602bc42c npx hardhat run generate-request.ts --network btp

// Latest result:
// {"body":{"reason":"Sony Bank KYC","scope":[{"circuitId":"credentialAtomicQuerySigV2OnChain","id":1723452139885,"query":{"allowedIssuers":["*"],"context":"ipfs://Qmaj1iZhYXmLPXrMqazQrUHwbVCqz7SgKurGywLPbrb6n5","credentialSubject":{"customFields.boolean1":{"$eq":true}},"type":"BasicIdentity"}}],"transaction_data":{"chain_id":80002,"contract_address":"0x70696036CA1868B42155b06235F95549667Eb0BE","method_id":"0xb68967e2","network":"polygon-amoy"}},"id":"feef3cf4-0b3c-45d2-a26b-2b0b241bb7d1","thid":"feef3cf4-0b3c-45d2-a26b-2b0b241bb7d1","typ":"application/iden3comm-plain-json","type":"https://iden3-communication.io/proofs/1.0/contract-invoke-request"}

const settings: RequestSettings = {
  schemaJsonLDUrl: `ipfs://Qmaj1iZhYXmLPXrMqazQrUHwbVCqz7SgKurGywLPbrb6n5`,
  type: "BasicIdentity",
  fieldName: "customFields.boolean1",
  value: true,
  requestId: Date.now(),
  allowedIssuers: ["*"],
  validatorAddress: "0x8c99F13dc5083b1E4c16f269735EaD4cFbc4970d",
  universalVerifierAddress: "0x70696036CA1868B42155b06235F95549667Eb0BE"
}

async function main() {
  const requestData = await generateRequestData({
    schemaJsonLDUrl: settings.schemaJsonLDUrl,
    type: settings.type,
    fieldName: settings.fieldName,
    value: settings.value,
  });


  const { invokeRequestMetadata, query } = await createReguest({ requestData, settings });

  await sendTransaction({
    invokeRequestMetadata,
    data: packValidatorParams(query),
    settings
  })

  console.log(JSON.stringify(invokeRequestMetadata));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });