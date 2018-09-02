require 'tempfile'
require 'open3'

require 'pry-byebug'

RSpec.describe R9cc do
  it "has a version number" do
    expect(R9cc::VERSION).not_to be nil
  end

  it "指定した数値がステータスコードになること" do
    expect(execute_status('5')).to eq(5)
    expect(execute_status('42')).to eq(42)
  end

  def execute_status(code)
    compile_and_exec_with_gcc(code)
  end

  def compile_and_exec_with_gcc(code)
    output = compile_result(code)
    f = Tempfile.open(['', '.s']) do |fp|
      fp.puts(output)
      fp
    end
    _, err, status = exec("gcc -o tmp_exe #{f.path}")
    raise "compile error: #{err}" unless status.exitstatus == 0
    `./tmp_exe`
    $CHILD_STATUS.exitstatus
  end

  def compile_result(code)
    main = R9cc::Main.new
    main.run([code])
    main.out.string
  end

  def exec(command)
    Open3.capture3(command)
  end
end
