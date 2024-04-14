import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import { InMemorySigner } from '@taquito/signer';

async function main() {
  const rpcUrl = 'https://rpc.ghostnet.teztnets.com'; 
  const privateKey = 'edskRo97rKWNLBgk21yF11zoj4GspJteb9vhmM542wyZcCGVVssc6TPXb96H7nQwaSha5HVeCFWq48iY7eJkPz2GHMbRGXBwea'; 
  const vestingContractAddress = 'KT1...'; 
  const Tezos = new TezosToolkit(rpcUrl);
  
  await Tezos.setProvider({ signer: new InMemorySigner(privateKey) });
  const vestingContract = await Tezos.contract.at(vestingContractAddress);

  async function testStart() {
    try {
      const operation = await vestingContract.methodsObject.start({
        vesting_start_time: new Date(),
        vesting_duration: 86400, 
        probatory_period: 3600,
        beneficiaries: MichelsonMap.fromLiteral({}), 
        fa2_address: vestingContractAddress,
        token_id: 0,
      }).send();

      await operation.confirmation();
      console.log('Test "start" a réussi, hash de l\'opération:', operation.hash);
    } catch (error) {
      console.error('Test "start" a échoué:', error);
    }
  }

  async function testClaim() {
    try {
      const operation = await vestingContract.methodsObject.claim().send();
      await operation.confirmation();
      console.log('Test "claim" a réussi, hash de l\'opération:', operation.hash);
    } catch (error) {
      console.error('Test "claim" a échoué:', error);
    }
  }

  async function testKill() {
    try {
      const operation = await vestingContract.methodsObject.kill().send();
      await operation.confirmation();
      console.log('Test "kill" a réussi, hash de l\'opération:', operation.hash);
    } catch (error) {
      console.error('Test "kill" a échoué:', error);
    }
  }

  await testStart();
  await testClaim();
  await testKill();
}

main().catch((error) => console.log(error));
