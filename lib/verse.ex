defmodule BibleEx.Verse do
  @moduledoc """
  A Bible verse struct.
  """
  # matt24 = Verse.new(book: "Matt", chapter_number: 2, verse_number: 4)
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

  @doc """
  Make a new `%Verse{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *chapter_number*: an integer that is the chapter number
    - *verse_number*: an integer that is the verse number

  ## Examples
      iex> alias BibleEx.Verse
      iex> first = Verse(book: "Genesis", chapter_number: 1, verse_number: 1)

      %BibleEx.Verse{
        book: "Genesis",
        book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
        book_number: 1,
        reference_type: :verse,
        reference: "Genesis 1:1",
        chapter_number: 1,
        verse_number: 1,
        is_valid: true
      }

      iex> alias BibleEx.Verse
      iex> matt24 = Verse.new(book: "Matt", chapter_number: 2, verse_number: 4)

      %BibleEx.Verse{
        book: "Matt",
        book_names: %{abbr: "MAT", name: "Matthew", osis: "Matt", short: "Mt"},
        book_number: 40,
        reference_type: :verse,
        reference: "Matt 2:4",
        chapter_number: 2,
        verse_number: 4,
        is_valid: true
      }
  """

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
