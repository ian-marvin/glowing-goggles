#!/usr/bin/env ruby

R = ""
# require 'rubygems'
require 'rinruby'
require 'date'

r = RinRuby.new({:interactive=>false,:echo=>false})
r.eval("library(ineq)")

if ARGV.size != 2
  puts "Usage ruby gini_calculator.rb [INPUT_PATH] [OUTPUT_PATH]"
  exit 1
end

INPUT_PATH = ARGV[0]
OUTPUT_PATH = ARGV[1]
TEMP_FILE = 'balances.r.tmp'


puts "calculating gini coefficient for balances in #{INPUT_PATH}"

dates_ginis = "date, gini\n"
puts dates_ginis
Dir.glob("#{INPUT_PATH}/*.txt") do |filename|
  File.delete(TEMP_FILE) if File.exist?(TEMP_FILE)
  puts filename.inspect
  lines = File.readlines(filename)
  # puts "read file, #{lines.size} lines"
  balanceStr = ""
  block_date_formatted = nil
  open(TEMP_FILE, 'a') do |out_f|
    lines.each_with_index  do |line, index|
      if index == 1
        dateStr = line.match(/minted : (.*)\)/)[1]
        block_date = DateTime.parse(dateStr)
        block_date_formatted = block_date.strftime("%F")
      end
      if index >= 6 # on the balance lines
        if line.length > 1
          balance = "#{line.match(/\W*(\d*.\d*)\W*.*/)[1]}"
#          if balance != "0.00000000"
            out_f <<  "#{balance}\n"
#          end
        end
      end
    end
  end
  # puts "scanning vector"
  r.eval("data <- scan('#{TEMP_FILE}')")
  # puts "calc gini"
  r.eval("gini <- ineq(data,type='Gini')")
  date_gini = "#{block_date_formatted}, #{r.pull('gini')}\n"
  puts date_gini
  dates_ginis += date_gini
end
IO.write(OUTPUT_PATH, dates_ginis)




