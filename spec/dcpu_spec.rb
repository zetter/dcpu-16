describe Dcpu do
  include DcpuTestHelper

  subject { Dcpu.new }
  
  describe '#run' do
    it 'runs a simple program and retuns the contents of the A register' do
      subject.load([build_instruction(literal(20), A, SET).to_i, nil])
      subject.run.should == 20
    end
  
    it 'it can do maths' do
      subject.load([
        build_instruction(literal(2), A + 2, SET).to_i,
        build_instruction(literal(4), A + 1, SET).to_i,
        build_instruction(A + 2, A + 1, ADD).to_i,
        build_instruction(literal(2), A + 1, MUL).to_i,
        build_instruction(A + 1, A, SET).to_i,        
        nil
      ])
      subject.run.should == 12
    end
  end
end