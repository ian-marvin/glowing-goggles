#!/usr/bin/env ruby

require 'rest-client'
require 'json'
require 'pry'

if ARGV.size != 4
  puts "Usage ruby get_transaction_graph.rb [start_block_height] [end_block_height] [insight_api_endpoint] [output_path]"
  exit 1
end

START_BLOCK_HEIGHT = ARGV[0]
END_BLOCK_HEIGHT = ARGV[1]
API_ENDPOINT = ARGV[2]
OUTPUT_PATH = ARGV[3]

def get_block_hash(index)
  response = RestClient.get("#{API_ENDPOINT}/insight-api/block-index/#{index}", headers={})
  parsed = JSON.parse(response)

  parsed["blockHash"]
end

def get_txs(block_hash)
  response = RestClient.get("#{API_ENDPOINT}/insight-api/block/#{block_hash}")
  parsed = JSON.parse(response)
  parsed["tx"]
end

def get_edgelist(txid)
  tries ||= 3
  begin
  response = RestClient.get("#{API_ENDPOINT}/insight-api/tx/#{txid}")
  parsed = JSON.parse(response)
  inputs = parsed["vin"].map{|hash| hash["addr"]}
  outputs = parsed["vout"].map{|hash| hash["scriptPubKey"]["addresses"]}.flatten
  return inputs.product(outputs).uniq
  rescue Exception => e
    if (tries -= 1) > 0
      retry
    else
      puts "ERROR: failing after 3x retries"
    end
  end
end

def write_edgelist(edge_list,block_number)
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

(START_BLOCK_HEIGHT.to_i..END_BLOCK_HEIGHT.to_i).each do |i|
  edge_list = []
  puts "Block height = #{i}"
  block_hash = get_block_hash(i)
  puts "Hash = #{block_hash}"
  txs = get_txs(block_hash)
  puts "writing n txs, n= #{txs.length}"
  txs.each do |txid|
    print "."
    edge_list += get_edgelist(txid)
  end
  write_edgelist(edge_list,i)
end





