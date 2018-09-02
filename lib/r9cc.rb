# frozen_string_literal: true

require "r9cc/version"
require 'stringio'
require 'strscan'

module R9cc
  class Main
    attr_reader :out
    def initialize
      @out = StringIO.new
    end

    def error_exit(msg)
      warn(msg)
      exit(1)
    end

    def run(argv)
      if argv.size != 1
        error_exit("Usage: r9cc <coce>")
      end

      ss = StringScanner.new(argv[0])
      @out.puts('.intel_syntax noprefix')
      @out.puts('.global _main')
      @out.puts('_main:')
      raise 'not a number' unless ss.scan(/\d+/)
      @out.puts("  mov rax, #{ss.matched}")

      until ss.eos?
        ss.scan(/./)
        op = ss.matched

        case op
        when '+'
          raise 'expected number but not number.' unless ss.scan(/\d+/)
          @out.puts("  add rax, #{ss.matched}")
        when '-'
          raise 'expected number but not number.' unless ss.scan(/\d+/)
          @out.puts("  sub rax, #{ss.matched}")
        else
          error_exit("unexpected character: #{op}")
        end
      end

      @out.puts('  ret')
    end
  end
end
