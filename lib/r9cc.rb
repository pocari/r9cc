# frozen_string_literal: true

require "r9cc/version"
require 'stringio'
require 'strscan'

module R9cc
  class Main
    TK_NUM = "tk_num"
    TK_EOF = "tk_eof"

    Token = Struct.new(:ty, :val, :input) do
      def inspect
        to_s
      end
      def to_s
        "(#{ty}, #{val}, #{input})"
      end
    end

    attr_reader :out
    def initialize
      @out = StringIO.new
      @tokens = []
    end

    def error(msg)
      raise msg
    end

    def fail_token(index)
      error("unexpected token: #{@token[index].input}")
    end

    def tokenize(code)
      ss = StringScanner.new(code)
      until ss.eos?
        input = ss.string[ss.pos..-1]
        case
        when ss.scan(/\s/)
          # ignore white space
        when ss.scan(/\d+/)
          @tokens << Token.new(TK_NUM, ss.matched, input)
        when ss.scan(/[+-]/)
          @tokens << Token.new(ss.matched, nil, input)
        else
          error("cannot tokenize: #{input}")
        end
      end

      @tokens << Token.new(TK_EOF, nil, nil)
    end

    def run(argv)
      if argv.size != 1
        error("Usage: r9cc <coce>")
      end

      tokenize(argv[0])

      @out.puts('.intel_syntax noprefix')
      @out.puts('.global _main')
      @out.puts('_main:')

      if @tokens[0].ty != TK_NUM
        fail_token(0)
      end

      @out.puts("  mov rax, #{@tokens[0].val}")

      i = 1
      while @tokens[i].ty != TK_EOF
        case @tokens[i].ty
        when '+'
          i += 1
          fail_token(i) unless @tokens[i].ty == TK_NUM
          @out.puts("  add rax, #{@tokens[i].val}")
        when '-'
          i += 1
          fail_token(i) unless @tokens[i].ty == TK_NUM
          @out.puts("  sub rax, #{@tokens[i].val}")
        else
          fail_token(i)
        end
        i += 1
      end
      @out.puts('  ret')
    end
  end
end
