
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
  sequence_length = 50

  for i in range(sequence_length):
    minimum_outcome = sum(progression_sequence) + minimum_profit
    potential_outcome = current_stake * reward_multiplier

    while potential_outcome < minimum_outcome:
        current_stake += minimum_stake
    progression_sequence.append(current_stake)
  return progression_sequence 

def build_lot_sequence(account_balance):
  '''
  Builds an array of lot size progression relative the users account balance
  '''
  pass
 #Ensure lot sizes(progression sequence) are accurate and relative to account balance 
