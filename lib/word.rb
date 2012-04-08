class Word
  include StorageConstants

  def initialize(word)
    @word = word
  end

  def to_i
    @word
  end

  def to_s
    @word.to_s(16)
  end

  def opcode
    @word % 0b10000
  end

  def a
    (@word >> 4) % 0b1000000
  end

  def b
    (@word >> 10) % 0b1000000
  end

  def instruction_word_count
    1 + [a, b].count do |value|
      VALUES_REFERENCING_NEXT_WORD.any?{|range| range === value}
    end
  end
end