#!/usr/bin/env ruby

require 'json'
require 'colorize'
require 'mustache'

class JsonSchemaParser

  def initialize
    @indent = 0
  end

  def load_schema(filename)
    @path = File.dirname(filename)
    @file = filename
    @schema = JSON.parse(IO.read(filename))
  end

  def build_schema(schema = @schema)
    schema.each do |k, v|
      if v.is_a?(Hash)
        build_schema(v)
      elsif v.is_a?(Array)
        v.each do |a|
          if a.is_a?(Hash)
            build_schema(a)
          end
        end
      else
        if k == "$ref"
          tok = v.split('#')
          v = tok[0]
          if v.empty?
            puts "local ref not supported".red
          else
            op = @path
            r = load_schema(@path + "/" + v)
            v = r
            build_schema(v)
            @path = op
          end
        end
      end
    end
  end

  def print_schema(schema = @schema)
    schema.each do |k, v|
      if v.is_a?(Hash)
        @indent += 1
        print_schema(v)
        @indent -= 1
      elsif v.is_a?(Array)
        v.each do |a|
          if a.is_a?(Hash)
            @indent += 1
            print_schema(a)
            @indent -= 1
          else
            @indent.times { print "  " }
            puts "#{k} => #{a}".green
          end
        end
      else
        @indent.times { print "  " }
        puts "#{k} => #{v}".green
      end
    end
  end
end

file = ARGV[0]

puts "Reading #{file}...".yellow

parser = JsonSchemaParser.new

parser.load_schema(file)
schema = parser.build_schema

parser.print_schema

puts schema

