import { SchemaHash } from '@iden3/js-iden3-core';
import { encodeAbiParameters } from 'viem';

export interface ExtendedQuery {
  requestId: number;
  schema: SchemaHash;
  claimPathKey: bigint;
  operator: number;
  slotIndex: number;
  value: bigint[];
  circuitIds: string[];
  skipClaimRevocationCheck: boolean;
  claimPathNotExists: number;
  queryHash?: string
  allowedIssuers: string[]
};

export function packValidatorParams(query: ExtendedQuery) {
  const data = encodeAbiParameters(
    [
      {
        name: "CredentialAtomicQuery",
        type: "tuple",
        components: [
          { name: "schema", type: "uint256" },
          { name: "claimPathKey", type: "uint256" },
          { name: "operator", type: "uint256" },
          { name: "slotIndex", type: "uint256" },
          { name: "value", type: "uint256[]" },
          { name: "queryHash", type: "uint256" },
          { name: "allowedIssuers", type: "uint256[]" },
          { name: "circuitIds", type: "string[]" },
          { name: "skipClaimRevocationCheck", type: "bool" },
          { name: "claimPathNotExists", type: "uint256" },
        ],
      },
    ],
    [
      {
        schema: query.schema.bigInt(),
        claimPathKey: query.claimPathKey,
        operator: BigInt(query.operator),
        slotIndex: BigInt(query.slotIndex),
        value: query.value.map((v) => BigInt(v)),
        queryHash: BigInt(query.queryHash!),
        // allowedIssuers: query.allowedIssuers.map((v) => BigInt(v)),
        allowedIssuers: [],
        circuitIds: query.circuitIds,
        skipClaimRevocationCheck: query.skipClaimRevocationCheck,
        claimPathNotExists: BigInt(query.claimPathNotExists),
      },
    ],
  );

  return data
}