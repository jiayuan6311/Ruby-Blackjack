#!/usr/bin/env ruby
puts "Hi! Welcome to Blackjack."
puts "How many players are at the table?(Max 10 players)" #Because using only 52 cards
def main
  @balance = Hash.new(1000)  
  @playernum = gets.to_i 
  
  if @playernum < 0 or @playernum > 10
    puts "Wrong player number. Please try again."
    main
  end
  runGame()
  puts "Thanks for playing!"
end #end main
def runGame
  @deck =  (1..52).to_a.shuffle  #deck creates a fresh random deck
  @dealerHand = [@deck.pop,@deck.pop]  #dealers initial hand
  @players = Hash.new
  @players_split = Hash.new
  @bets = Hash.new
  @bets_split = Hash.new
  index = 0  #initial to 0
  
  puts "\nGame begin!"
  puts "\nDealer shows: #{identCard(@dealerHand[0])}"
    
  @playernum.times{  #betting step
  puts "\nPlayer #{index}, what's your bet? Your balance: #{@balance[index]}"
  doBet(index)
  puts "Your bet: #{@bets[index]}."
  index += 1
  }  
  
  index = 0  
  @playernum.times{  #playing step
  @players[index] = [@deck.pop,@deck.pop]
  @players_split[index] = [0,0]
  
  puts "\nPlayer #{index}: "+ identCard(@players[index][0]) + ", " +identCard(@players[index][1])
  puts "Current balance: #{@balance[index]} \nBet: #{@bets[index]}"
  puts "Total score: " + scoreHand(@players[index]).to_s
  doLoop(@players, @bets, index)  #do split, hit, double, stand and quit
  if @players_split[index][0] != 0   #deal with the second deck
    puts "\nSecond deck: " + identCard(@players_split[index][0]) + ", " + identCard(@players_split[index][1])
    puts "Current balance: #{@balance[index]} \nBet: #{@bets_split[index]}"
    puts "Total score: " + scoreHand(@players_split[index]).to_s()
    doLoop(@players_split, @bets_split, index)
  end
  index += 1
  }
  
  showResult() 
  
  puts "Would you like to play again? (y/n)"
  replay = gets().downcase.strip
  runGame if replay == "y"
end #end runGame
def doLoop(playersHash,betsHash,index)
  loop do
    puts "\nWould you like to (sp)lit, (d)ouble, (h)it, (s)tand or (q)uit?"
    puts "Can not split.(No resplit)" if @players_split[index][0] != 0
    answer = gets().downcase.strip
    case 
      when answer == "sp"
        if getValue(playersHash[index][0]) != getValue(playersHash[index][1])
          puts "You can split only when two cards have same value. Please try again."
        elsif betsHash[index] > @balance[index]
          puts "Don't have enough money to do split."
        else
          doSplit(index)
        end
      when answer == "q"
        betsHash[index] = -1  #mark player's status of quit
        break
      when answer == "h"
        doHit(playersHash,index)
        break if scoreHand(playersHash[index]) > 21 #busted
      when answer == "s"
        puts "You stand with score: " + scoreHand(@players[index]).to_s
        break
      when answer == "d"
        doHit(playersHash,index)
        @balance[index] -= betsHash[index]
        betsHash[index] *= 2
        break
    end #end case
  end #end loop
end #end doLoop
def doBet(index)
  temp = gets.to_i
  if temp<=@balance[index] and temp>0
  @bets[index]=temp
  @balance[index]-=temp
  else
    puts "Bet should be positive and no larger your balance #{@balance[index]}. Please bet again."
    doBet(index)
  end
end #end doBet
def doSplit(index)
  @players_split[index][0] = @players[index][1]
  @players[index][1] = @deck.pop
  @players_split[index][1] = @deck.pop
  @bets_split[index] = @bets[index]
  @balance[index] -= @bets_split[index]
    
  puts "First deck: " + identCard(@players[index][0]) + ", " + identCard(@players[index][1])
  puts "Current balance: #{@balance[index]} \nBet: #{@bets[index]}"
  puts "Total score: " + scoreHand(@players[index]).to_s()
end #end doSplit
def getValue(card)# given card number to calculate the its value
  case card%13
    when 0,11,12 then 10
    when 1 then 11 
    else card%13
    end 
end #end getValue 
def identCard(card) #given card number to identifies its face and suit
  suit = (case (card-1)/13
          when 0 then "Heart "
          when 1 then "Club "
          when 2 then "Diamond "
          when 3 then "Spade "
          else raise StandardError
          end)  #end case
  case card%13
    when 1 then suit+"Ace"
    when 11 then suit+"Jack"
    when 12 then suit+"Queen"
    when 0 then suit+"King"
    else suit+(card%13).to_s
  end #end case
end #end identCard
def scoreHand(hand) #determines the score of the hand
  total=0
  aceCount=0
  hand.each  do |i|
    aceCount+=1 if i%13==1
    total+=getValue(i)
    while total>21 do
      if aceCount>0 then
       total = total-10
       aceCount-=1
      end #end if
      break if aceCount == 0
    end #end while     
  end #end do
  total 
end #end scorehand
def doHit(playersHash,index)
  playersHash[index] << @deck.pop
  puts "You drew: " + identCard(playersHash[index][playersHash[index].length - 1])
  puts "Your score: " + scoreHand(playersHash[index]).to_s
  puts "Bust! You lose." if scoreHand(playersHash[index])> 21
end #end doHit
def showResult
  puts "*******************************************************" #add a cut line
  puts "Dealer: " + identCard(@dealerHand[0]) + ", " + identCard(@dealerHand[1])
  puts "Dealer's score: " + scoreHand(@dealerHand).to_s
  puts "Dealer stands" if scoreHand(@dealerHand)>16
  while scoreHand(@dealerHand)<17
    @dealerHand<<@deck.pop
    puts "Dealer drew: #{identCard(@dealerHand[@dealerHand.length - 1])}" 
    puts "Dealer's score: #{scoreHand(@dealerHand).to_s}"  
    puts "Dealer busts!" if scoreHand(@dealerHand)>21
  end #end while
 puts "*******************************************************" #add a cut line
  @players.each do |index,cards|
  if @bets[index] == -1
    puts "Player #{index}, you quit."
  elsif (scoreHand(@dealerHand) > scoreHand(cards) && scoreHand(@dealerHand)<22)||scoreHand(cards)>21
    puts "Player #{index}, you lose."
  elsif scoreHand(@dealerHand) < scoreHand(cards) || scoreHand(@dealerHand)>21
    @balance[index] += @bets[index]*2
    puts "Player #{index}, you win!"
  else
    @balance[index] += @bets[index]
    puts "Player #{index}, draw."
  end #end if
  
  if @players_split[index][0] != 0  #compute the splited deck
    if @bets_split[index] == -1
      puts "And quit for the second deck."
    elsif (scoreHand(@dealerHand) > scoreHand(@players_split[index]) && scoreHand(@dealerHand)<22)||scoreHand(@players_split[index])>21
      puts "And lose for the second deck."
    elsif scoreHand(@dealerHand) < scoreHand(@players_split[index]) || scoreHand(@dealerHand)>21 
      @balance[index] += @bets_split[index]*2
      puts "And win for the second deck!"
    else
      @balance[index] += @bets_split[index]
      puts "And draw for the second deck."
    end
  end
  puts "Current balance: #{@balance[index]}."
  @bets[index] = 0  #set bets to initial
  @bets_split[index] = 0 #set bets_split to initial
  puts ""  #add a blank line
  end #end each
end #end showResult
main  #executues main program