# frozen_string_literal: true

require "r9cc/version"
require 'stringio'

module R9cc
  class Main
    attr_reader :out
    def initialize
      @out = StringIO.new
    end

    def run(argv)
      if argv.size != 1
        warn("Usage: r9cc <code>")
        exit(1)
      end
      @out.puts('.intel_syntax noprefix')
      @out.puts('.global _main')
      @out.puts('_main:')
      @out.puts("  mov rax, #{argv[0].to_i}")
      @out.puts('  ret')
    end
  end
end
