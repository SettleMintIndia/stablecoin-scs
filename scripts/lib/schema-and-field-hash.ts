import { byteEncoder, calculateCoreSchemaHash } from '@0xpolygonid/js-sdk';
import { SchemaHash } from '@iden3/js-iden3-core';
import { Merklizer, Path, getDocumentLoader } from '@iden3/js-jsonld-merklization';

export type RequestData = {
  schemaId: SchemaHash;
  path: bigint;
  hashedValue: bigint;
}

export async function generateRequestData(args: {
  schemaJsonLDUrl: string;
  type: string;
  fieldName: string;
  value: any;
  ipfsGatewayURL?: string;
}): Promise<RequestData> {
  const {
    schemaJsonLDUrl,
    type,
    fieldName,
    value,
  } = args;
  const pathToCredentialSubject = 'https://www.w3.org/2018/credentials#credentialSubject';

  const opts = { ipfsGatewayURL: 'https://ipfs.io' }; // can be your IFPS gateway if your work with ipfs schemas or empty object
  const ldCtx = (await getDocumentLoader(opts)(schemaJsonLDUrl)).document;
  const ldJSONStr = JSON.stringify(ldCtx);
  // const ldBytes = byteEncoder.encode(ldJSONStr);
  const typeId = await Path.getTypeIDFromContext(ldJSONStr, type);
  const schemaHash = calculateCoreSchemaHash(byteEncoder.encode(typeId));

  // you can use custom IPFS
  const path = await Path.getContextPathKey(ldJSONStr, type, fieldName, opts);
  path.prepend([pathToCredentialSubject]);
  const pathBigInt = await path.mtEntry();

  // you can hash the value according to the datatype (that's how it is stored in core claim structure)
  const fieldInfo = {
    pathToField: `${type}.${fieldName}`,
    value
  };

  const datatype = await Path.newTypeFromContext(ldJSONStr, fieldInfo.pathToField);
  const hashedValue = await Merklizer.hashValue(datatype, fieldInfo.value);

  return {
    schemaId: schemaHash,
    path: pathBigInt,
    hashedValue
  }
}