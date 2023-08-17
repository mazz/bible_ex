defmodule BibleEx.ParserTest do
  use ExUnit.Case
  doctest BibleEx

  alias BibleEx.RefParser

  test "parser_parses_john_3_16" do
    ref = RefParser.parse_references("John 3:16")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "John 3:16"
    assert Enum.at(ref, 0).book == "John"
    assert Enum.at(ref, 0).start_chapter_number == 3
    assert Enum.at(ref, 0).start_verse_number == 16
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_1_john_3_16" do
    ref = RefParser.parse_references("1john 3:16")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "1 John 3:16"
    assert Enum.at(ref, 0).book == "1 John"
    assert Enum.at(ref, 0).start_chapter_number == 3
    assert Enum.at(ref, 0).start_verse_number == 16
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_jn_2_4" do
    ref = RefParser.parse_references("Jn 2:4")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "John 2:4"
    assert Enum.at(ref, 0).book == "John"
    assert Enum.at(ref, 0).start_chapter_number == 2
    assert Enum.at(ref, 0).start_verse_number == 4
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_empty_string" do
    ref = RefParser.parse_references("")
    assert length(ref) == 0
  end

  test "parser_parses_John_4_5_10" do
    ref = RefParser.parse_references("I love John 4:5-10")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "John 4:5-10"
    assert Enum.at(ref, 0).book == "John"
    assert Enum.at(ref, 0).start_chapter_number == 4
    assert Enum.at(ref, 0).start_verse_number == 5
    assert Enum.at(ref, 0).end_verse_number == 10
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_not_parse_matthew" do
    ref = RefParser.parse_references("This is not going to parse Matthew")
    assert length(ref) == 2
    assert Enum.at(ref, 0).book == "Isaiah"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_only_jam" do
    ref = RefParser.parse_references("Only jam should be parsed")
    assert length(ref) == 1
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_joel_2_5_10" do
    ref = RefParser.parse_references("Joe 2:5-10")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "Joel 2:5-10"
    assert Enum.at(ref, 0).book == "Joel"
    assert Enum.at(ref, 0).start_chapter_number == 2
    assert Enum.at(ref, 0).start_verse_number == 5
    assert Enum.at(ref, 0).end_verse_number == 10
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_joseph_5_10_11" do
    ref = RefParser.parse_references("Joseph 5:10-11")
    assert length(ref) == 0
  end

  test "parser_parses_james_1_2" do
    ref = RefParser.parse_references("So what about James 1 - 2")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "James 1-2"
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_james_1_dot_2" do
    ref = RefParser.parse_references("James 1.2")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "James 1:2"
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_james_1_dot_2_2" do
    ref = RefParser.parse_references("James 1.2 -  2")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "James 1:2"
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_james_1_em_2" do
    ref = RefParser.parse_references("James 1—2")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "James 1-2"
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_james_1_2_2_4" do
    ref = RefParser.parse_references("James 1.2 -  2:4")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "James 1:2 - 2:4"
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_james_1_dot_2_2_dot_4" do
    ref = RefParser.parse_references("James 1 . 2 -  2 . 4")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "James 1:2 - 2:4"
    assert Enum.at(ref, 0).book == "James"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_matthew_2_3_5_to_5_7" do
    ref = RefParser.parse_references("Matthew 2:3-5 - 5:7")
    assert length(ref) == 1
    assert Enum.at(ref, 0).reference == "Matthew 2:3-5"
    assert Enum.at(ref, 0).book == "Matthew"
    assert Enum.at(ref, 0).is_valid == true
  end

  test "parser_parses_all_references" do
    ref = RefParser.parse_references("I hope Matt 2:4 and James 5:1-5 get parsed")
    assert length(ref) == 2

    mat = Enum.at(ref, 0)
    jam = Enum.at(ref, 1)

    assert mat.book == "Matthew"
    assert mat.start_chapter_number == 2
    assert mat.start_verse_number == 4

    assert jam.book == "James"
    assert jam.start_chapter_number == 5
    assert jam.start_verse_number == 1
    assert jam.end_verse_number == 5

    is_ref = RefParser.parse_references("is is still parsed")
    assert length(is_ref) == 2

    no_ref = RefParser.parse_references("This contains nothing")
    assert length(no_ref) == 0
  end

  # describe "parser_verifies_paratexts/1" do
  #   test "parser_verifies_paratexts" do
  #     refs = RefParser.parse_references("Mat Jam PSA joh")

  #     Enum.each(refs, fn x ->
  #       assert length(x.book) > 3
  #     end)
  #   end
  # end
end
