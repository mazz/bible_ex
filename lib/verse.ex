defmodule BibleEx.Verse do
  @enforce_keys [:book, :chapter_number, :verse_number]

  defstruct book: "",
            book_names: %{},
            book_number: nil,
            reference_type: nil,
            # The full book name of the reference in Book chapter:verse format
            reference: nil,
            # The chapter number this verse is within.
            chapter_number: nil,
            # The verse number this verse refers to within a chapter.
            verse_number: -1,
            # Whether this verse is found within the bible.
            is_valid: false

  def new(book: book, chapter_number: chapter_number, verse_number: verse_number) do
    %__MODULE__{
      book: book,
      book_names: BibleEx.Librarian.get_book_names(book: book),
      book_number: BibleEx.Librarian.find_book_number(book: book),
      reference_type: :verse,
      reference:
        BibleEx.Librarian.create_reference_string(
          book: book,
          start_chapter: chapter_number,
          start_verse: verse_number
        ),
      chapter_number: chapter_number,
      verse_number: verse_number,
      is_valid:
        BibleEx.Librarian.verify_reference(
          book: book,
          start_chapter: chapter_number,
          start_verse: verse_number
        )
    }
  end
end
