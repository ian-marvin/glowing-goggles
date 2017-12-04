#!/usr/bin/env ruby

require 'rest-client'
require 'json'
require 'pry'

if ARGV.size != 3
  puts "Usage ./get_transactions_for_date.sh [insight_api_endpoint] [YYYY-mm-dd] [output_path]"
  exit 1
end

API_ENDPOINT = ARGV[0]
DATE_STRING = ARGV[1]
OUTPUT_PATH = ARGV[2]

def get_edgelist(txid)
  tries ||= 1000
  begin
  puts "."
  response = RestClient.get("#{API_ENDPOINT}/insight-api/tx/#{txid}")
  parsed = JSON.parse(response)
  inputs = parsed["vin"].map{|hash| hash["addr"]}
  outputs = parsed["vout"].map{|hash| hash["scriptPubKey"]["addresses"]}.flatten
  ret = inputs.product(outputs).uniq
  puts ret.inspect
  ret
  rescue Exception => e
    if (tries -= 1) > 0
      sleep(30)
      puts "retrying.. "
      retry
    else
      puts "ERROR: failing after retries"
    end
  end
end

def write_edgelist(edge_list,block_number)
  puts edge_list.inspect
  sb = StringIO.new
  edge_list.each do |edge|
    input = edge[0]
    output = edge[1]
    if input != nil && output != nil
      sb << "#{input} #{output}\n"
    end
  end
  IO.write("#{OUTPUT_PATH}/#{block_number}.txt", sb.string)
end

def get_txs(block_id)
  puts "get for blockid #{block_id}"
  tries ||= 1000
  begin
    response = RestClient.get("#{API_ENDPOINT}/insight-api/block/#{block_id}")
    parsed = JSON.parse(response)
    parsed["tx"]
  rescue Exception => e
    if (tries -= 1) > 0
      puts "error #{e} retrying.. "
      sleep(30)
      retry
    else
      puts "ERROR: failing after retries"
    end
  end
end


def get_block_ids_date(dateStr)
tries ||= 1000
begin
  response = RestClient.get("#{API_ENDPOINT}/insight-api/blocks?blockDate=#{dateStr}")
  parsed = JSON.parse(response)
  parsed["blocks"].map{|block| block["hash"] }
rescue Exception => e
  if (tries -= 1) > 0
    puts "error #{e} retrying.. "
    sleep(30)
    retry
  else
    puts "ERROR: failing after retries"
  end
end
end

###retrieve transaction list for dates
block_heights = get_block_ids_date(DATE_STRING)
edge_list = []

block_heights.each do |block_height|
  puts "Block height = #{block_height}"
  txs = get_txs(block_height)
  puts "writing n txs, n= #{txs.length}"
  txs.each do |txid|
    print "."
    edge_list += get_edgelist(txid)
  end
end

# txlist = block_heights.map{|bh| get_txs(bh)}.flatten
# puts "total tx: #{txlist.size}"
# edge_list = txlist.map{|txid| get_edgelist(txid)}
#
###write to file
write_edgelist(edge_list, DATE_STRING)



