#!/usr/bin/env ruby
require 'pry'
require 'ruby-graphviz'

cmd ="bash -c 'source bin/debuntu_fun.sh; declare -F | grep debuntu_ | cut -d \" \" -f 3'"
functions= `#{cmd}`.split("\n")

@script_name_regex = /[\s+]debuntu_[\w\.\d-]+/

def break_lines s
  ilb=0
  s.scan(/./).each_with_index.map do |c,i| 
    if c == ' ' and i - ilb > 10
      ilb = i
      "\n"
    else
      c
    end
  end.join
end

def process_scriptname s
  break_lines /debuntu_(.*)/.match(s)[1].gsub(/_/,' ')
end

arcs= functions.map do |fun|
  src = `bash -c 'source bin/debuntu_fun.sh; declare -f #{fun}'`
  src.scan(@script_name_regex).map{|x| [process_scriptname(fun),process_scriptname(x)]}
  .reject{|x| x[0] == x[1]}
end.flatten(1).uniq


g = GraphViz.new( "Debuntu call graph", :type => :digraph )
# functions.each{|f| g.add_node f}
arcs.each{|e| g.add_edge e[0],e[1]}

g.output svg: "#{File.dirname(__FILE__)}/call_graph.svg"
