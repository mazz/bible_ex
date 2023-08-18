defmodule BibleEx.Chapter do
  @enforce_keys [:book, :chapter_number]

  defstruct book: "",
            book_names: %{},
            reference_type: nil,
            reference: nil,
            chapter_number: -1,
            start_verse_number: -1,
            # The first verse in this chapter represented by a [Verse] object.
            start_verse: nil,
            # The last verse in this chapter represented by a [Verse] object.
            end_verse: nil,
            # The last verse within this chapter.
            end_verse_number: nil,
            verses: nil,
            is_valid: false

  def new(book: book, chapter_number: chapter_number) do
    %__MODULE__{
      book: book,
      book_names: BibleEx.Librarian.get_book_names(book: book),
      chapter_number: chapter_number,
      reference_type: :chapter,
      reference:
        BibleEx.Librarian.create_reference_string(
          book: book,
          start_chapter: chapter_number
        ),
      start_verse_number: 1,
      start_verse: BibleEx.Verse.new(book: book, chapter_number: chapter_number, verse_number: 1),
      end_verse: BibleEx.Librarian.get_last_verse(book: book, chapter: chapter_number),
      end_verse_number:
        BibleEx.Librarian.get_last_verse_number(book: book, chapter: chapter_number),
      verses: BibleEx.Librarian.get_verses(book: book, chapter: chapter_number),
      is_valid:
        BibleEx.Librarian.verify_reference(
          book: book,
          start_chapter: chapter_number
        )
    }
  end
end
