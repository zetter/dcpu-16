describe Executor do
  include DcpuTestHelper
  subject { Executor.new(Storage.new) }
  describe 'SET' do
    it 'sets A register' do
      subject.execute(build_instruction(literal(4), A, SET))
      subject.storage[A].should == 4
    end
  
    it 'sets B register' do
      subject.execute(build_instruction(literal(4), A + 1, SET))
      subject.storage[A + 1].should == 4
    end
  end
  describe 'ADD' do
    it 'adds small numbers' do
      subject.storage[A] = 2
      subject.execute(build_instruction(literal(4), A, ADD))
      subject.storage[A].should == 6
    end
  end
  describe 'MUL' do
    it 'multiplies small numbers' do
      subject.storage[A] = 2
      subject.execute(build_instruction(literal(4), A, MUL))
      subject.storage[A].should == 8
    end
  end
  describe 'DIV' do
    it 'divides small numbers' do
      subject.storage[A] = 6
      subject.execute(build_instruction(literal(3), A, DIV))
      subject.storage[A].should == 2
    end
  end
  describe 'SHL' do
    it 'shift left small numbers' do
      subject.storage[A] = 2
      subject.execute(build_instruction(literal(3), A, SHL))
      subject.storage[A].should == 16
    end
  end
  describe 'SHR' do
    it 'shift right small numbers' do
      subject.storage[A] = 16
      subject.execute(build_instruction(literal(3), A, SHR))
      subject.storage[A].should == 2
    end
  end
  describe 'AND' do
    it 'bitwise AND small numbers' do
      subject.storage[A] = 0b0110
      subject.execute(build_instruction(literal(0b0101), A, AND))
      subject.storage[A].should == 0b0100
    end
  end
  describe 'BOR' do
    it 'bitwise OR small numbers' do
      subject.storage[A] = 0b0100
      subject.execute(build_instruction(literal(0b0001), A, BOR))
      subject.storage[A].should == 0b0101
    end
  end
  describe 'XOR' do
    it 'bitwise XOR small numbers' do
      subject.storage[A] = 0b0110
      subject.execute(build_instruction(literal(0b0101), A, XOR))
      subject.storage[A].should == 0b0011
    end
  end
  
  describe 'IFE' do
    it 'should skip next instruction when a == b' do
      subject.should_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(4), literal(4), IFE))
    end

    it 'should not skip next instruction when not a == b' do
      subject.should_not_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(4), literal(5), IFE))
    end
  end

  describe 'IFN' do
    it 'should skip next instruction when a != b' do
      subject.should_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(3), literal(4), IFN))
    end

    it 'should not skip next instruction when not a != b' do
      subject.should_not_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(4), literal(4), IFN))
    end
  end

  describe 'IFG' do
    it 'should skip next instruction when a > b' do
      subject.should_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(4), literal(5), IFG))
    end

    it 'should not skip next instruction when not a > b' do
      subject.should_not_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(4), literal(4), IFG))
      subject.execute(build_instruction(literal(5), literal(4), IFG))
    end
  end

  describe 'IFB' do
    it 'should skip next instruction when (a & b) != 0' do
      subject.should_receive :skip_next_instruction! 
      subject.execute(build_instruction(literal(5), literal(5), IFB))
    end

    it 'should not skip next instruction when (a & b) == 0' do
      subject.should_not_receive :skip_next_instruction!
      subject.execute(build_instruction(literal(1), literal(4), IFB))
    end
  end

  describe '#skip_next_instruction!' do
    it 'skips the next one-word instruction' do
      subject.storage[PC] = 5
      subject.storage.memory[5] = build_instruction(literal(1), literal(4), ADD).to_i
      subject.instance_eval {skip_next_instruction!}
      subject.storage[PC].should == 6
    end
    it 'skips the next two-word instruction' do
      subject.storage[PC]= 5
      subject.storage.memory[5] = build_instruction(NEXT_WORD, literal(4), ADD).to_i
      subject.instance_eval {skip_next_instruction!}
      subject.storage[PC].should == 7
    end
    it 'skips the next three-word instruction' do
      subject.storage[PC] = 5
      subject.storage.memory[5] = build_instruction(NEXT_WORD, NEXT_WORD, ADD).to_i
      subject.instance_eval {skip_next_instruction!}
      subject.storage[PC].should == 8
    end
  end
end