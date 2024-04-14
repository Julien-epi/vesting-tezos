module C = struct

  type operation = {
    contract : address;
    amount : nat;
  }

  type beneficiary = {
    amount_promised : nat;
    amount_claimed : nat;
  }

  type storage = {
    admin : address;
    beneficiaries : (address, beneficiary) big_map;
    vesting_duration : nat;
    probation_duration : int;
    token_contract : address;
    token_id : nat;
    start_time : timestamp option;
    vesting_start_time : timestamp option
  }

  type start_param = unit
  type claim_param = address
  type kill_param = unit

  type parameter =
    | Start of start_param
    | Claim of claim_param
    | Kill of kill_param

  type fa2_transfer_item = {
    to_ : address;
    token_id : nat;
    amount : nat;
  }

  type fa2_transfer = {
    from_ : address;
    txs : fa2_transfer_item list
  }

  let fa2_transfer_op (contract : address) (transfer : fa2_transfer) : operation = {
    contract = contract;
    amount = 0n;
  }

  [@entry]
  let start (storage : storage) : (operation list * storage) =
    let sender = Tezos.get_sender() in
    if sender = storage.admin then
      let current_time = Tezos.get_now () in
      // List.fold_left (fun (acc, b) ->  acc +  b) 0 storage.beneficiaries in
      let total_tokens_to_transfer = 3n in
      let vesting_start_time : timestamp = (current_time + storage.probation_duration) in
      
      let updated_storage = {
        storage with
        start_time = Some(current_time);
        vesting_start_time = Some(vesting_start_time);
      } in
      let transfer = {from_ = sender; txs = [{to_ = Tezos.get_self_address(); token_id = storage.token_id; amount = total_tokens_to_transfer}]} in
      let op = fa2_transfer_op storage.token_contract transfer in
      ([op], updated_storage)
    else failwith("Unauthorized")

  [@entry]
  let claim (beneficiary_address, storage : claim_param * storage) : (operation list * storage) =
    match Big_map.find_opt  (beneficiary_address) storage.beneficiaries with
    | Some(beneficiary) ->
        let current_time = Tezos.get_now() in
        let elapsed_time = match storage.vesting_start_time with
        | Some(start_time) -> current_time - start_time
        | None -> failwith("Vesting not started yet") in
        let total_time = storage.vesting_duration in
        let vested_ratio = if total_time > 0n then (elapsed_time * 100 / total_time) else 0 in
        let max_claimable = (beneficiary.amount_promised * vested_ratio) / 100 in
        let amount_to_claim = abs(max_claimable - beneficiary.amount_claimed) in
        let updated_beneficiary = {beneficiary with amount_claimed = beneficiary.amount_claimed + amount_to_claim} in
        let updated_beneficiaries = Big_map.update (updated_beneficiary) (Some(storage.beneficiaries - updated_beneficiary)) storage.beneficiaries in
        let updated_storage = {storage with beneficiaries = updated_beneficiaries} in
        let transfer = {from_ = Tezos.get_self_address(); txs = [{to_ = beneficiary_address; token_id = storage.token_id; amount = amount_to_claim}]} in
        let op = fa2_transfer_op storage.token_contract transfer in
        ([op], updated_storage)
    | None -> failwith("Not a beneficiary")

  [@entry]
  let kill (storage : storage) : (operation list * storage) =
    let sender = Tezos.get_sender() in
    if sender = storage.admin then
      let ops = List.map (fun b ->
        let remaining = b.amount_promised - b.amount_claimed in
        fa2_transfer_op storage.token_contract {from_ = Tezos.self_address(); txs = [{to_ = b.address; token_id = storage.token_id; amount = remaining}]}
      ) storage.beneficiaries in
      (ops, {storage with beneficiaries = []})
    else failwith("Unauthorized")
end