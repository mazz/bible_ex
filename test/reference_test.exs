defmodule BibleEx.ReferenceTest do
  use ExUnit.Case
  doctest BibleEx

  alias BibleEx.Chapter
  alias BibleEx.Reference

  test "retrieves_subdivided_references" do
    chapter = Chapter.new(book: "Genesis", chapter_number: 2)
    verses = chapter.verses

    assert length(verses) == 25

    verses = chapter.verses

    # Ensures verses are cached
    assert length(verses) == 25

    book = Reference.new(book: "Genesis")
    chapters = book.chapters

    assert length(chapters) == 50
    chapters = book.chapters

    # Ensures chapters are cached
    assert length(chapters) == 50

    verses = book.verses
    assert length(verses) == 1533

    range =
      Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 3,
        end_chapter: 4,
        end_verse: 5
      )

    verses = range.verses
    assert length(verses) == 52

    verse =
      Reference.new(
        book: "Genesis",
        start_chapter: 2,
        start_verse: 2
      )

    verses = verse.verses
    assert length(verses) == 1
  end

  @tag runnable: true
  test "creates_non_bible_reference" do
    mcd = Reference.new(book: "McDonald", start_chapter: 2, start_verse: 4, end_chapter: 10)
    dbg(mcd)
  end
end
