
def build_sequence(reward_multiplier: int):
  '''
  Computes the progression sequence used in determining the lot sizes
  Args:
  returns: an array of 50 integers
  '''

  minimum_stake: int = 1
  bankroll = minimum_stake * 1000
  minimum_profit = minimum_stake * 2
  current_stake = minimum_stake
  progression_sequence = []
  sequence_length = 20

  for i in range(sequence_length):
    minimum_outcome = sum(progression_sequence) + minimum_profit

    while current_stake * reward_multiplier < minimum_outcome:
        current_stake += minimum_stake
        
    progression_sequence.append(current_stake)
  return progression_sequence 

def build_lot_sequence(account_balance, progression_sequence):
  '''
  Builds an array of lot size progression relative the users account balance
  '''
  # the minimum stake depends on the pip value of the pair, and the account balance
  # for now we'll build with XAU/USD in mind

  # Build the base lot sequence
  # idealy, the first term of the lot sequence should be the lot 
  # that produces the first term of the progression sequence at grid size pips
  # but we would use assumptions for speed sake
  # for speed we develop with symbol minimal volume 0.01 (1/100) - XAU/USD our grid is 200 points(2usd)
  # for volatility 75-1s minimum lot is 0.05 and our grid is 2000 points(1usd)
  minimum_lot = 0.01
  sequence_relationship = progression_sequence[0]/minimum_lot
  base_lot_sequence = [term/sequence_relationship for term in progression_sequence if term > 0]
  print(base_lot_sequence)

  # Build the balance relative lot sequence 
  # turn the account balance to a multiple of 1000. (divide by 1000) since base sequence is based on 1000usd

  pass
 #Ensure lot sizes(progression sequence) are accurate and relative to account balance 

progression_sequence = build_sequence(3)
print(progression_sequence)
print(f'\n total= {sum(progression_sequence)}')
build_lot_sequence(10000,progression_sequence=progression_sequence)
