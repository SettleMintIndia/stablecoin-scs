import hre from 'hardhat';
import { RequestMetadata, RequestSettings } from './create-request';

export async function sendTransaction(args: {
  invokeRequestMetadata: RequestMetadata, data: `0x${string}`, settings: RequestSettings
}) {
  try {

    const universalVerifier = await hre.viem.getContractAt('IUniversalVerifier', args.settings.universalVerifierAddress);

    // You can call this method on behalf of any signer which is supposed to be request controller
    await universalVerifier.write.setZKPRequest([BigInt(args.settings.requestId), {
      metadata: JSON.stringify(args.invokeRequestMetadata),
      validator: args.settings.validatorAddress,
      data: args.data,
    }], {
      maxFeePerGas: BigInt(3200000000),
    });

    console.log("Request set: ", JSON.stringify(args.invokeRequestMetadata));
  } catch (e) {
    console.log("error: ", e);
  }
}
