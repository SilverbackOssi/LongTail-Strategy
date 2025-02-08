
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

  # turn the account balance to a multiple of 1000. (divide by 1000)
  pass
 #Ensure lot sizes(progression sequence) are accurate and relative to account balance 

progression_sequence = build_sequence(3)
print(progression_sequence)
print(f'\n total= {sum(progression_sequence)}')
