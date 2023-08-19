defmodule BibleEx.Chapter do
  @moduledoc """
  A Bible chapter struct.
  """

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

  @doc """
  Make a new `%Chapter{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *chapter_number*: an integer that is the chapter number

  ## Examples
      iex> alias BibleEx.Chapter
      iex> Chapter.new(book: "Gn", chapter_number: 2)

      %BibleEx.Chapter{
        book: "Gn",
        book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
        reference_type: :chapter,
        reference: "Gn 2",
        chapter_number: 2,
        start_verse_number: 1,
        ...
      }

      iex> alias BibleEx.Chapter
      iex> Chapter.new(book: "Gn", chapter_number: nil)

      %BibleEx.Chapter{
        book: "Gn",
        book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
        reference_type: :chapter,
        reference: nil,
        chapter_number: nil,
        start_verse_number: 1,
        start_verse: %BibleEx.Verse{
          book: "Gn",
          book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
          book_number: 1,
          reference_type: :verse,
          reference: nil,
          chapter_number: nil,
          verse_number: 1,
          is_valid: false
        },
        end_verse: %BibleEx.Verse{
          book: "Genesis",
          book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
          book_number: 1,
          reference_type: :verse,
          reference: "Genesis 50:26",
          chapter_number: 50,
          verse_number: 26,
          is_valid: true
        },
        end_verse_number: 26,
        verses: nil,
        is_valid: true
      }

  """
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
