describe Instruction do
  include DcpuTestHelper
  subject {
    build_instruction(@b = 5, @a = 4, @opcode = 3)
  }
  
  describe '#opcode' do
    it 'returns the opcode' do
      subject.opcode.should == @opcode
    end
  end

  describe '#to_s' do
    it 'return hex representation of the word' do
      subject.to_s.should == '1443'
    end
  end

  describe '#a' do
    it 'returns part a' do
      subject.a.should == @a
    end
  end

  describe '#b' do
    it 'returns part b' do
      subject.b.should == @b
    end
  end

  describe '#==' do
    it 'should be equal if word is equal' do
      Instruction.new(10).should == Instruction.new(10)
    end
    it 'should not be equal if the word is different' do
      Instruction.new(10).should_not == Instruction.new(11)
    end
  end

  describe '#word_count' do
    it "returns 1 for values that don't reference next word" do
      build_instruction(literal(3), literal(4), ADD).word_count.should == 1
      build_instruction(A, PUSH, ADD).word_count.should == 1
    end

    it "returns 2 for instructions witha a value that reference next word" do
      build_instruction(NEXT_WORD, literal(4), ADD).word_count.should == 2
      build_instruction(NEXT_WORD_LITERAL, literal(4), ADD).word_count.should == 2
      build_instruction(REGISTERS_MEM_NEXT_WORD.begin, literal(4), ADD).word_count.should == 2
      build_instruction(REGISTERS_MEM_NEXT_WORD.end, literal(4), ADD).word_count.should == 2
      build_instruction(literal(3), NEXT_WORD, ADD).word_count.should == 2
    end

    it "returns 3 for instructions where both values reference next word" do
      build_instruction(NEXT_WORD, NEXT_WORD_LITERAL, ADD).word_count.should == 3
      build_instruction(REGISTERS_MEM_NEXT_WORD.begin, NEXT_WORD_LITERAL, ADD).word_count.should == 3
    end
  end
end