import { Operators, calculateQueryHashV2 } from '@0xpolygonid/js-sdk';
import { Address } from 'viem';
import { ExtendedQuery } from './pack-validator-params';
import { RequestData } from './schema-and-field-hash';


export type RequestSettings = {
  validatorAddress: Address;
  universalVerifierAddress: Address;
  schemaJsonLDUrl: string;
  type: string;
  fieldName: string;
  value: any;
  ipfsGatewayURL?: string;
  requestId: number;
  allowedIssuers: string[];
}

export type RequestMetadata = {
  body: {
    reason: string;
    scope: {
      circuitId: string;
      id: number;
      query: {
        allowedIssuers: string[];
        context: string;
        credentialSubject: {
          [key: string]: {
            $eq: any;
          };
        };
        type: string;
      };
    }[];
    transaction_data: {
      chain_id: number;
      contract_address: Address;
      method_id: string;
      network: string;
    };
  };
  id: string;
  thid: string;
  typ: string;
  type: string;
}

export async function createReguest(args: { requestData: RequestData, settings: RequestSettings }): Promise<{ invokeRequestMetadata: RequestMetadata, query: ExtendedQuery }> {

  const schemaBigInt = args.requestData.schemaId;
  const schemaClaimPathKey = args.requestData.path;

  const query: ExtendedQuery = {
    requestId: args.settings.requestId,
    schema: schemaBigInt,
    claimPathKey: schemaClaimPathKey,
    operator: Operators.EQ,
    slotIndex: 0,
    value: [args.requestData.hashedValue, ...new Array(63).fill(0)], // for operators 1-3 only first value matters
    circuitIds: ["credentialAtomicQuerySigV2OnChain"],
    skipClaimRevocationCheck: false,
    claimPathNotExists: 0,
    allowedIssuers: args.settings.allowedIssuers
  };

  query.queryHash = calculateQueryHashV2(
    query.value,
    query.schema,
    query.slotIndex,
    query.operator,
    query.claimPathKey.toString(),
    query.claimPathNotExists
  ).toString();


  const invokeRequestMetadata: {
    body: {
      reason: string;
      scope: {
        circuitId: string;
        id: number;
        query: {
          allowedIssuers: string[];
          context: string;
          credentialSubject: {
            [key: string]: {
              $eq: any;
            };
          };
          type: string;
        };
      }[];
      transaction_data: {
        chain_id: number;
        contract_address: Address;
        method_id: string;
        network: string;
      };
    };
    id: string;
    thid: string;
    typ: string;
    type: string;
  } = {
    body: {
      reason: "Sony Bank KYC",
      scope: [
        {
          circuitId: query.circuitIds[0],
          id: query.requestId,
          query: {
            allowedIssuers: args.settings.allowedIssuers,
            context: args.settings.schemaJsonLDUrl,
            credentialSubject: {
              [args.settings.fieldName]: {
                $eq: args.settings.value,
              },
            },
            type: args.settings.type,
          },
        },
      ],
      transaction_data: {
        chain_id: 80002,
        contract_address: args.settings.universalVerifierAddress,
        method_id: "0xb68967e2",
        network: "polygon-amoy",
      },
    },
    id: "feef3cf4-0b3c-45d2-a26b-2b0b241bb7d1",
    thid: "feef3cf4-0b3c-45d2-a26b-2b0b241bb7d1",
    typ: "application/iden3comm-plain-json",
    type: "https://iden3-communication.io/proofs/1.0/contract-invoke-request",
  };

  return { invokeRequestMetadata, query };
}