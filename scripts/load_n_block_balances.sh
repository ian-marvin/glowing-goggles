#!/usr/bin/env ruby
blockparser_path = ENV['BLOCKPARSER_HOME']

if ARGV.size != 4
  puts "Usage ruby load_n_block_balances.rb [start_block] [end_block] [step] [path]"
  exit 1
end

start_block = ARGV[0]
end_block = ARGV[1]
step = ARGV[2]
store_dir = ARGV[3]


(start_block..end_block).step(step.to_i).each do |i|
  cmd = "#{blockparser_path}parser allBalances --atBlock #{i} > #{store_dir}/#{i}.txt"
  puts "running: #{cmd}"
  `#{cmd}`
end


