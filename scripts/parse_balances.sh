#!/usr/bin/env ruby

require 'date'

class BalanceRange

  def initialize(range)
    @range = range
    @total_addresses = 0
    @coins = 0
  end

  def process_balance(balance)
    # puts "process balance #{balance}"
    if @range.member?(balance)
      @total_addresses += 1
      @coins += balance
    end
  end

  def set_total_coins(total)
    @total_coins = total
  end

  def share
    "#{@range}, #{@total_addresses}, #{@coins}, #{@coins/@total_coins}"
  end

end


##create ranges, addresses, total_coins

balanceRanges = []
balanceRanges << BalanceRange.new(0..0.001)
balanceRanges << BalanceRange.new(0.001..0.01)
balanceRanges << BalanceRange.new(0.01..0.1)
balanceRanges << BalanceRange.new(0.1..1)
balanceRanges << BalanceRange.new(1..10)
balanceRanges << BalanceRange.new(10..100)
balanceRanges << BalanceRange.new(100..1000)
balanceRanges << BalanceRange.new(1000..10000)
balanceRanges << BalanceRange.new(10000..100000)
balanceRanges << BalanceRange.new(100000..1000000)



if ARGV.size != 1
  puts "Usage ./parse_balances.sh [INPUT_PATH]"
  exit 1
end


INPUT_PATH = ARGV[0]
lines = File.readlines(INPUT_PATH)
total_coins = 0
lines.each_with_index do |line, index|

  if index == 1
    dateStr = line.match(/minted : (.*)\)/)[1]
    block_date = DateTime.parse(dateStr)
    block_date_formatted = block_date.strftime("%F")
  end
  if index >= 6 # on the balance lines
    if line.length > 1
      balance = "#{line.match(/\W*(\d*.\d*)\W*.*/)[1]}"
      total_coins += balance.to_f
      if balance != "0.00000000"
        balanceRanges.each{|br| br.process_balance(balance.to_f)}
      end
    end
  end
end
puts total_coins
balanceRanges.each{|br| br.set_total_coins(total_coins)}
balanceRanges.each{|br| puts br.share}
