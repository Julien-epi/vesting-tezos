## Exercice 6

Vesting contract (locked tokens)

### Setup
You will need the "FA2" token implementation from Ligolang registry.

### What is asked

Create a smart contract that distributes funds to beneficiaries on a period of time. Funds are frozen during a probatory period then available on time basis (proportionnaly to the period duration). Funds are implemented as a FA2 token. 

The administrator of the contract must own the required amount of tokens to be able to `start` the contract. 

The `start` entrypoint transfers vested tokens to the contract, and set the starting time and the vesting starting time.

The beneficiaries are specified at the creation of the contract, with their corresponding promised amounts of token.

The vesting duration, and probatory period duration are specified at the creation of the contract.

The FA2 token (address and token_id) that is used to represent funds must be specified at the creation of the contract. 


Available funds can be claimed by a beneficiary. The `claim` entrypoint transfers available amount of tokens to the beneficiary.

A `kill` entrypoint callable only by the administrator must be implemented to be able to retrieve funds, and pay beneficiaries (on time elpased basis).  


Obviously, 
- a non-beneficiary cannot claim and receive funds
- a beneficiary cannot claim and receive more funds than promised

The tests must check success and failure of entrypoints 


### Hints

The `claim` entrypoint transfers available funds to the beneficiary (caller) by invoking the `Transfer` entrypoint of the FA2 token.



### Solution
- lib/exo_6_solution.mligo
- test/exo_6_solution.test.mligo

j'aimerai faire le contrat ensuite tester le tout en local avant de le compiler et deployer sur le ghostnet ou la encore on le retestera avec l'outil Taquito, de plus voici les deux fichiers sur lesquels on peut s'appuyer pour commencer :  

fichier pour les tests : 
import "exo_6_solution" as Solution

// Test du point d'entrée 'start'
let test_start =
  // Initialiser le stockage
  let storage = [%init ...] in
  // Appeler le point d'entrée 'start'
  let (ops, storage') = Solution.start () storage in
  // Vérifier les résultats
  ...

// Test du point d'entrée 'claim'
let test_claim =
  // Initialiser le stockage
  let storage = [%init ...] in
  // Appeler le point d'entrée 'claim'
  let (ops, storage') = Solution.claim beneficiary storage in
  // Vérifier les résultats
  ...

// Test du point d'entrée 'kill'
let test_kill =
  // Initialiser le stockage
  let storage = [%init ...] in
  // Appeler le point d'entrée 'kill'
  let (ops, storage') = Solution.kill () storage in
  // Vérifier les résultats
  ...

// Exécuter tous les tests
let tests = [test_start; test_claim; test_kill]


fichier contrat : type beneficiary is [%def fa2_address, nat]

type storage is [
  %admin : fa2_address,
  %beneficiaries : list(beneficiary),
  %vesting_duration : duration,
  %probation_duration : duration,
  %token_contract : address,
  %token_id : nat,
  %start_time : timestamp,
  %vesting_start_time : timestamp
]

type parameter is [
  | Start of unit
  | Claim of fa2_address
  | Kill of unit
]

let main (param : parameter) (storage : storage) : operation list * storage =
  match param with
  | Start _ ->
    (* Vérifier que l'administrateur a suffisamment de jetons *)
    (* Transférer les jetons au contrat *)
    (* Mettre à jour start_time et vesting_start_time *)
    ([], storage)
  | Claim beneficiary ->
    (* Calculer les jetons disponibles pour le bénéficiaire *)
    (* Transférer les jetons au bénéficiaire *)
    ([], storage)
  | Kill _ ->
    (* Vérifier que l'appelant est l'administrateur *)
    (* Récupérer les jetons restants *)
    (* Distribuer les jetons aux bénéficiaires en fonction du temps écoulé *)
    ([], storage)

@entry start
let start () : operation list * storage is
  (* Appel à main avec le paramètre Start *)

@entry claim
let claim (beneficiary : fa2_address) : operation list * storage is
  (* Appel à main avec le paramètre Claim et l'adresse du bénéficiaire *)

@entry kill
let kill () : operation list * storage is
  (* Appel à main avec le paramètre Kill *)

