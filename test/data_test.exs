defmodule BibleEx.DataTest do
  use ExUnit.Case
  doctest BibleEx

  alias BibleEx.Librarian

  test "returns the correct OSIS abbreviation for the book of Genesis" do
    assert Librarian.get_book_names(book: "genesis").osis == "Gen"
  end

  test "returns the correct ABBR abbreviation for the book of Genesis" do
    assert Librarian.get_book_names(book: "genesis").abbr == "GEN"
  end

  test "returns the correct Name abbreviation for the book of Genesis" do
    assert Librarian.get_book_names(book: "genesis").name == "Genesis"
  end

  test "returns the correct short abbreviation for the book of Genesis" do
    assert Librarian.get_book_names(book: "genesis").short == "Gn"
  end

  test "returns the correct OSIS abbreviation for the book of 1 Corinthians" do
    assert Librarian.get_book_names(book: "1 Corinthians").osis == "1Cor"
  end

  test "returns the correct ABBR abbreviation for the book of 1 Corinthians" do
    assert Librarian.get_book_names(book: "1 Corinthians").abbr == "1CO"
  end

  test "returns the correct Name abbreviation for the book of 1 Corinthians" do
    assert Librarian.get_book_names(book: "1 Corinthians").name == "1 Corinthians"
  end

  test "returns the correct short abbreviation for the book of 1 Corinthians" do
    assert Librarian.get_book_names(book: "1 Corinthians").short == "1 Cor"
  end

  test "returns the empty map for the incorrect book name <empty string>" do
    assert Librarian.get_book_names(book: "") == %{}
  end

  test "returns the empty map for the incorrect book name nil" do
    assert Librarian.get_book_names(book: nil) == %{}
  end

  test "librarian_returns_1_for_genesis" do
    assert Librarian.find_book_number(book: "genesis") == 1
  end

  test "librarian_returns_46_for_1cor" do
    assert Librarian.find_book_number(book: "1cor") == 46
  end

  test "librarian_returns_19_for_psalm" do
    assert Librarian.find_book_number(book: "psalm") == 19
  end

  test "librarian_returns_nil_for_a_nonexistent_book" do
    assert Librarian.find_book_number(book: "joseph") == nil
  end

  test "librarian_identifies_joseph_as_nonexistent" do
    assert Librarian.check_book(book: "joseph") == false
  end

  test "librarian_identifies_1cor_as_existent" do
    assert Librarian.check_book(book: "1cor") == true
  end

  test "librarian_identifies_genesis_as_existent" do
    assert Librarian.check_book(book: "Genesis") == true
  end

  test "librarian_identifies_jn_as_existent" do
    assert Librarian.check_book(book: "jn") == true
  end

  test "librarian_returns_the_correct_last_verse_number_for_the_book_of_John" do
    assert Librarian.get_last_verse_number(book: "John") == 25
  end

  test "librarian_returns_the_correct_last_chapter_number_for_the_book_of_John" do
    assert Librarian.get_last_chapter_number(book: "John") == 21
  end

  test "librarian_correctly_verifies_books" do
    assert Librarian.verify_reference(book: 1) == true
    assert Librarian.verify_reference(book: 33) == true
    assert Librarian.verify_reference(book: 66) == true
    assert Librarian.verify_reference(book: 67) == false
    assert Librarian.verify_reference(book: -1) == false
  end

  test "librarian_correctly_generates_reference_type" do
    Librarian.identify_reference_type(
      book: "John",
      start_chapter: nil,
      start_verse: 4,
      end_chapter: nil,
      end_verse: 6
    ) == :verse_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 2,
      start_verse: 4,
      end_chapter: nil,
      end_verse: 6
    ) == :verse_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 2,
      start_verse: 4,
      end_chapter: nil,
      end_verse: nil
    ) == :verse

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 2,
      start_verse: 4,
      end_chapter: 5,
      end_verse: nil
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: 1,
      end_chapter: nil,
      end_verse: nil
    ) == :verse

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: nil,
      end_chapter: 2,
      end_verse: nil
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "Joeseph",
      start_chapter: 1,
      start_verse: 1,
      end_chapter: 2,
      end_verse: nil
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: nil,
      start_verse: 4,
      end_chapter: nil,
      end_verse: 6
    ) == :verse_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: nil,
      start_verse: 4,
      end_chapter: nil,
      end_verse: nil
    ) == :verse

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: nil,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    ) == :book

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    ) == :chapter

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: nil,
      end_chapter: 2,
      end_verse: nil
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: 1,
      end_chapter: 2,
      end_verse: nil
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: nil,
      end_chapter: 2,
      end_verse: nil
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: nil,
      end_chapter: 2,
      end_verse: 1
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: 1,
      end_chapter: 2,
      end_verse: 1
    ) == :chapter_range

    Librarian.identify_reference_type(
      book: "John",
      start_chapter: 1,
      start_verse: 1,
      end_chapter: nil,
      end_verse: nil
    ) == :verse
  end

  test "librarian_correctly_generates_general_reference_type" do
    genesis_book =
      BibleEx.Reference.new(
        book: "Genesis",
        start_chapter: nil,
        start_verse: nil,
        end_chapter: nil,
        end_verse: nil
      )

    # let genesisBookRef = Reference(book: "Genesis", startChapter: nil, startVerse: nil, endChapter: nil, endVerse: nil)
    # XCTAssert(genesisBookRef.book == "Genesis")
    # XCTAssert(genesisBookRef.startChapterNumber == 1)
    # XCTAssert(genesisBookRef.startVerseNumber == 1)
    # XCTAssert(genesisBookRef.endVerseNumber == 26)
    # XCTAssert(genesisBookRef.endChapterNumber == 50)
    # XCTAssert(genesisBookRef.reference == "Genesis 1")
    # XCTAssert(genesisBookRef.isValid == true)

    # dbg(genesis_ref)
    assert genesis_book.book == "Genesis"
    assert genesis_book.start_chapter_number == 1
    assert genesis_book.start_verse_number == 1
    assert genesis_book.end_chapter_number == 1
    assert genesis_book.end_verse_number == 31
    assert genesis_book.reference == "Genesis"
    assert genesis_book.reference_type == :chapter
    assert genesis_book.is_valid == true

    genesis_ref_not_valid =
      BibleEx.Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 3,
        end_chapter: 1,
        end_verse: 2
      )

    genesis_chapter_range =
      BibleEx.Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 3,
        end_chapter: 4,
        end_verse: 5
      )

    # dbg(genesis_ref)
    assert genesis_chapter_range.book == "Genesis"
    assert genesis_chapter_range.start_chapter_number == 2
    assert genesis_chapter_range.start_verse_number == 3
    assert genesis_chapter_range.end_chapter_number == 4
    assert genesis_chapter_range.end_verse_number == 5
    assert genesis_chapter_range.reference == "Genesis 2:3 - 4:5"
    assert genesis_chapter_range.reference_type == :chapter_range
    assert genesis_chapter_range.is_valid == true

    genesis_ref_not_valid =
      BibleEx.Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 3,
        end_chapter: 1,
        end_verse: 2
      )

    genesis_chapter_range =
      BibleEx.Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 3,
        end_chapter: 4,
        end_verse: 5
      )

    # dbg(genesis_ref)
    assert genesis_chapter_range.book == "Genesis"
    assert genesis_chapter_range.start_chapter_number == 2
    assert genesis_chapter_range.start_verse_number == 3
    assert genesis_chapter_range.end_chapter_number == 4
    assert genesis_chapter_range.end_verse_number == 5
    assert genesis_chapter_range.reference == "Genesis 2:3 - 4:5"
    assert genesis_chapter_range.reference_type == :chapter_range
    assert genesis_chapter_range.is_valid == true

    genesis_ref_not_valid =
      BibleEx.Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 3,
        end_chapter: 1,
        end_verse: 2
      )

    dbg(genesis_ref_not_valid)

    assert genesis_ref_not_valid.start_chapter_number == 2
    assert genesis_ref_not_valid.start_verse_number == 3
    assert genesis_ref_not_valid.end_chapter_number == 1
    assert genesis_ref_not_valid.end_verse_number == 2
    assert genesis_ref_not_valid.reference == "Genesis 2:3 - 1:2"
    assert genesis_ref_not_valid.reference_type == :chapter_range
    assert genesis_ref_not_valid.is_valid == false
  end

  test "librarian_correctly_generates_general_reference_verse_range" do
    genesis_2_verses_3_to_4 =
      BibleEx.Reference.verse_range(
        book: "Genesis",
        chapter: 2,
        start_verse: 3,
        end_verse: 4
      )

    assert genesis_2_verses_3_to_4.book == "Genesis"
    assert genesis_2_verses_3_to_4.start_chapter_number == 2
    assert genesis_2_verses_3_to_4.start_verse_number == 3
    assert genesis_2_verses_3_to_4.end_chapter_number == 2
    assert genesis_2_verses_3_to_4.end_verse_number == 4
    assert genesis_2_verses_3_to_4.reference == "Genesis 2:3-4"
    assert genesis_2_verses_3_to_4.reference_type == :verse_range
    assert genesis_2_verses_3_to_4.is_valid == true
  end

  test "librarian_correctly_generates_general_reference_chapter_range" do
    genesis_2_to_3 =
      BibleEx.Reference.chapter_range(
        book: "Genesis",
        start_chapter: 2,
        end_chapter: 3
      )

    assert genesis_2_to_3.book == "Genesis"
    assert genesis_2_to_3.start_chapter_number == 2
    assert genesis_2_to_3.start_verse_number == 1
    assert genesis_2_to_3.end_chapter_number == 3
    assert genesis_2_to_3.end_verse_number == 24
    assert genesis_2_to_3.reference == "Genesis 2-3"
    assert genesis_2_to_3.reference_type == :chapter_range
    assert genesis_2_to_3.is_valid == true
  end

  test "librarian_correctly_generates_general_reference_chapter" do
    genesis_2 =
      BibleEx.Reference.chapter(
        book: "Genesis",
        chapter: 2
      )

    assert genesis_2.book == "Genesis"
    assert genesis_2.start_chapter_number == 2
    assert genesis_2.start_verse_number == 1
    assert genesis_2.end_chapter_number == 2
    assert genesis_2.end_verse_number == 25
    assert genesis_2.reference == "Genesis 2"
    assert genesis_2.reference_type == :chapter
    assert genesis_2.is_valid == true
  end

  test "librarian_correctly_generates_general_reference_verse" do
    genesis_2_1 =
      BibleEx.Reference.verse(
        book: "Genesis",
        chapter: 2,
        verse: 1
      )

    assert genesis_2_1.book == "Genesis"
    assert genesis_2_1.start_chapter_number == 2
    assert genesis_2_1.start_verse_number == 1
    assert genesis_2_1.end_chapter_number == 2
    assert genesis_2_1.end_verse_number == 1
    assert genesis_2_1.reference == "Genesis 2:1"
    assert genesis_2_1.reference_type == :verse
    assert genesis_2_1.is_valid == true
  end

  test "librarian_correctly_creates_last_verse_objects" do
    verse_john = BibleEx.Librarian.get_last_verse(book: "John", chapter: nil)

    assert verse_john.book == "John"
    assert verse_john.chapter_number == 21
    assert verse_john.verse_number == 25
    assert verse_john.reference_type == :verse

    verse_ps = BibleEx.Librarian.get_last_verse(book: "Ps")

    assert verse_ps.book == "Psalms"
    assert verse_ps.chapter_number == 150
    assert verse_ps.verse_number == 6
    assert verse_ps.reference_type == :verse

    verse_gen1 = BibleEx.Librarian.get_last_verse(book: "Gen", chapter: nil)

    assert verse_gen1.book == "Genesis"
    assert verse_gen1.chapter_number == 50
    assert verse_gen1.verse_number == 26
    assert verse_gen1.reference_type == :verse

    verse_gen_chapter_2 = BibleEx.Librarian.get_last_verse(book: "Genesis", chapter: 2)

    assert verse_gen_chapter_2.book == "Genesis"
    assert verse_gen_chapter_2.chapter_number == 2
    assert verse_gen_chapter_2.verse_number == 25
    assert verse_gen_chapter_2.reference_type == :verse
  end

  test "librarian_correctly_creates_last_chapter_objects" do
    chapter = BibleEx.Librarian.get_last_chapter(book: "Gen")
    assert chapter.book == "Genesis"
    assert chapter.chapter_number == 50
    assert chapter.reference_type == :chapter
  end

  test "librarian_creates_correct_reference_strings_book_start_chapter" do
    assert BibleEx.Librarian.create_reference_string(
             book: "John",
             start_chapter: 2
           ) == "John 2"

    assert BibleEx.Librarian.create_reference_string(
             book: "John",
             start_chapter: 2,
             start_verse: 3
           ) == "John 2:3"

    assert BibleEx.Librarian.create_reference_string(
             book: "John",
             start_chapter: 2,
             start_verse: 3,
             end_chapter: 4
           ) == "John 2:3 - 4:54"

    assert BibleEx.Librarian.create_reference_string(
             book: "John",
             start_chapter: 2,
             start_verse: 3,
             end_chapter: 4,
             end_verse: 5
           ) == "John 2:3 - 4:5"

    assert BibleEx.Librarian.create_reference_string(
             book: "John",
             start_chapter: 2,
             start_verse: nil,
             end_chapter: 4,
             end_verse: 5
           ) == "John 2:1 - 4:5"

    assert BibleEx.Librarian.create_reference_string(
             book: "John",
             start_chapter: 2,
             start_verse: nil,
             end_chapter: 4
           ) == "John 2-4"

    assert BibleEx.Librarian.create_reference_string(
             book: "Genesis",
             start_chapter: 2,
             start_verse: 3
           ) == "Genesis 2:3"

    assert BibleEx.Librarian.create_reference_string(
             book: "Genesis",
             start_chapter: 2,
             start_verse: 3,
             end_chapter: nil,
             end_verse: 4
           ) == "Genesis 2:3-4"
  end

  test "librarian_correctly_verifies_books_with_start_chapters" do
    assert Librarian.verify_reference(book: 33, start_chapter: 1) == true
    assert Librarian.verify_reference(book: 33, start_chapter: 8) == false
    assert Librarian.verify_reference(book: 33, start_chapter: nil) == true
  end

  test "librarian_correctly_verifies_books_with_start_chapters_and_start_verses" do
    assert Librarian.verify_reference(book: 1, start_chapter: 1, start_verse: 1) == true
    assert Librarian.verify_reference(book: 1, start_chapter: 1, start_verse: nil) == true
    assert Librarian.verify_reference(book: 1, start_chapter: nil, start_verse: nil) == true
  end

  test "librarian_correctly_verifies_books_with_start_chapters_and_end_verses" do
    assert Librarian.verify_reference(book: 33, start_chapter: 1, end_verse: 16) == true
    assert Librarian.verify_reference(book: 33, start_chapter: 1, end_verse: 17) == false
    assert Librarian.verify_reference(book: 33, start_chapter: 1, end_verse: nil) == true
    assert Librarian.verify_reference(book: 33, start_chapter: nil, end_verse: nil) == true
  end

  test "librarian_correctly_verifies_string_books_with_start_chapters_and_end_verses" do
    assert Librarian.verify_reference(book: "John", start_chapter: 1, end_verse: 1) == true
    assert Librarian.verify_reference(book: "John", start_chapter: 1, end_verse: nil) == true
    assert Librarian.verify_reference(book: "John", start_chapter: nil, end_verse: nil) == true
  end

  test "librarian_correctly_verifies_books_with_start_chapters_and_start_verses_and_end_chapters_and_end_verses" do
    assert Librarian.verify_reference(
             book: 33,
             start_chapter: 1,
             start_verse: 17,
             end_chapter: nil,
             end_verse: 18
           ) == false

    assert Librarian.verify_reference(
             book: "John",
             start_chapter: 1,
             start_verse: 1,
             end_chapter: 1,
             end_verse: 2
           ) == true

    assert Librarian.verify_reference(
             book: "John",
             start_chapter: 1,
             start_verse: 1,
             end_chapter: 1,
             end_verse: nil
           ) == true

    assert Librarian.verify_reference(
             book: "John",
             start_chapter: 1,
             start_verse: 1,
             end_chapter: nil,
             end_verse: nil
           ) == true

    assert Librarian.verify_reference(
             book: "John",
             start_chapter: 1,
             start_verse: nil,
             end_chapter: nil,
             end_verse: nil
           ) == true

    assert Librarian.verify_reference(
             book: "John",
             start_chapter: nil,
             start_verse: nil,
             end_chapter: nil,
             end_verse: nil
           ) == true

    # a reference can't have an end verse without an end chapter
    assert Librarian.verify_reference(
             book: "John",
             start_chapter: 1,
             start_verse: 1,
             end_chapter: nil,
             end_verse: 1
           ) == false

    # a reference can't have an end chapter without a start chapter
    assert Librarian.verify_reference(
             book: "John",
             start_chapter: nil,
             start_verse: nil,
             end_chapter: 1,
             end_verse: nil
           ) == false

    # a reference can't be without a start chapter nor an end chapter
    assert Librarian.verify_reference(
             book: "John",
             start_chapter: nil,
             start_verse: nil,
             end_chapter: nil,
             end_verse: 1
           ) == false
  end
end
