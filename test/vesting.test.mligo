import "Vesting" as Vesting

const admin = "tz1...";
const beneficiaries = [("tz1...", 1000), ("tz2...", 2000), ("tz3...", 3000)];
const vesting_duration = 10;
const probation_period = 5;
const token_address = "KT1...";
const token_id = 0;

let storage = Vesting.init_storage(admin, beneficiaries, vesting_duration, probation_period, token_address, token_id);

let (ops, storage') = Vesting.start(unit, storage);

assert(
  ops = [
    TRANSFER_TOKENS {
      from_ = admin;
      txs = [
        {
          to_ = token_address;
          amount = 0tez;
          parameters = [UNIT];
          entrypoint = "transfer";
        }
      ]
    }
  ]
);

let current_time = Current_time.get();
let elapsed_time = current_time - storage'.start_time;
assert(elapsed_time >= probation_period);

let beneficiary = "tz1...";
let (ops', storage'') = Vesting.claim(beneficiary, storage');

assert(
  ops' = [
    TRANSFER_TOKENS {
      from_ = token_address;
      txs = [
        {
          to_ = beneficiary;
          amount = 0tez;
          parameters = [PAIR { addr = beneficiary; int = 500 } UNIT];
          entrypoint = "transfer";
        }
      ]
    }
  ]
);

assert(storage''.beneficiaries = [("tz2...", 2000), ("tz3...", 3000)]);
assert(storage''.vesting_start_time = storage'.start_time + probation_period);
assert(storage''.vesting_end_time = storage'.start_time + vesting_duration);

let (ops'', storage''') = Vesting.kill(unit, storage'');

assert(
  ops'' = [
    TRANSFER_TOKENS {
      from_ = token_address;
      txs = [
        {
          to_ = admin;
          amount = 0tez;
          parameters = [PAIR { addr = admin; int = 2500 } UNIT];
          entrypoint = "transfer";
        }
      ]
    }
  ]
);

assert(storage''' = Vesting.init_storage(admin, [], 0, 0, token_address, token_id));
