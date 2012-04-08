describe Word do
  include DcpuTestHelper
  subject {
    build_word(@b = 5, @a = 4, @opcode = 3)
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

  describe '#instruction_word_count' do
    it "returns 1 for values that don't reference next word" do
      build_word(literal(3), literal(4), ADD).instruction_word_count.should == 1
      build_word(A, PUSH, ADD).instruction_word_count.should == 1
    end

    it "returns 2 for instructions witha a value that reference next word" do
      build_word(NEXT_WORD, literal(4), ADD).instruction_word_count.should == 2
      build_word(NEXT_WORD_LITERAL, literal(4), ADD).instruction_word_count.should == 2
      build_word(REGISTERS_MEM_NEXT_WORD.begin, literal(4), ADD).instruction_word_count.should == 2
      build_word(REGISTERS_MEM_NEXT_WORD.end, literal(4), ADD).instruction_word_count.should == 2
      build_word(literal(3), NEXT_WORD, ADD).instruction_word_count.should == 2
    end

    it "returns 3 for instructions where both values reference next word" do
      build_word(NEXT_WORD, NEXT_WORD_LITERAL, ADD).instruction_word_count.should == 3
      build_word(REGISTERS_MEM_NEXT_WORD.begin, NEXT_WORD_LITERAL, ADD).instruction_word_count.should == 3
    end
  end
end