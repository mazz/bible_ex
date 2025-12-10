defmodule BibleEx.RefParser do
  @moduledoc """
  Parses general strings for Bible references.

  This module scans arbitrary text for Bible references in a variety of
  formats (full book names, abbreviations, ranges, etc.) and returns
  `%BibleEx.Reference{}` structs.
  """

  alias BibleEx.BibleData
  alias BibleEx.Reference

  @doc ~S"""
  Parses a binary for all Bible references and returns a list of `%BibleEx.Reference{}`.

  The parser supports:

    * Full book names with chapter and verse.
    * Common abbreviations and variants (e.g. `Matt`, `Jn`, `1 Tim`).
    * Same-chapter verse ranges (e.g. `John 3:16-18`).
    * Cross-chapter ranges (e.g. `John 3:16-4:3`).
    * Dot separators with optional spaces (e.g. `James 1 . 2 -  2 . 4`).
    * Bare book names (e.g. `Isaiah`, `1 Timothy`) which are normalized by `BibleEx.Reference`.

  ## Examples

      iex> alias BibleEx.RefParser
      iex> [ref] = RefParser.parse_references("John 3:16")
      iex> ref.book
      "John"
      iex> ref.start_chapter
      3
      iex> ref.start_verse
      16

      iex> refs = RefParser.parse_references("Matt 2:4 and James 5:1-5")
      iex> Enum.map(refs, & &1.book)
      ["Matthew", "James"]
      iex> Enum.map(refs, & &1.reference_type) |> Enum.sort()
      [:verse, :verse_range]

      iex> [ref] = RefParser.parse_references("James 1 . 2 -  2 . 4")
      iex> ref.book
      "James"
      iex> {ref.start_chapter, ref.start_verse, ref.end_chapter, ref.end_verse}
      {1, 2, 2, 4}

      iex> [ref] = RefParser.parse_references("is. 1 Timothy 6, 1.")
      iex> ref.book
      "1 Timothy"
      iex> {ref.start_chapter, ref.start_verse}
      {6, 1}

  """

  def parse_references(string) when is_binary(string) do
    # Run the full regex over the input string, collecting all raw matches.
    # Each element is a list: [full_match, book, maybe_chapter, maybe_verse, ...].
    books_matched =
      Regex.scan(full_regex(), string)
      # Drop anything whose first captured token is not a known book key.
      |> Enum.reject(fn [full, book | _] ->
        norm = String.downcase(String.trim(book))

        not (
          Map.has_key?(BibleEx.BibleData.books(), norm) or
          Map.has_key?(BibleEx.BibleData.osis_books(), norm) or
          Map.has_key?(BibleEx.BibleData.shortened_books(), norm) or
          Map.has_key?(BibleEx.BibleData.variants(), norm)
        )
      end)

    # Turn each raw regex match into a %BibleEx.Reference{}.
    Enum.map(books_matched, fn x ->
      cond do
        # Case 1: book-only reference, e.g. ["is", "is"] or ["Matthew", "Matthew"].
        # Delegate to Reference.new/1 so it can normalize book names and defaults.
        length(x) == 2 and String.trim(Enum.at(x, 0)) == Enum.at(x, 1) ->
          book_name = String.trim(Enum.at(x, 0))
          Reference.new(book: book_name)

        # Case 2: book + chapter, no verse, e.g. ["Judges 19", "Judges", "19"].
        length(x) == 3 ->
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: nil,
            end_chapter: nil,
            end_verse: nil
          )

        # Case 3: book + chapter:verse, e.g. ["Jn 3:16", "Jn", "3", "16"].
        length(x) == 4 ->
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: String.to_integer(Enum.at(x, 3)),
            end_chapter: nil,
            end_verse: nil
          )

        # Case 4: five captures – could be a verse range, dotted form, or chapter range.
        length(x) == 5 ->
          # Full matched text, used to distinguish ":" vs "." vs "-" semantics.
          ref = String.trim(Enum.at(x, 0))

          cond do
            # Example: "John 4:5-10" → same-chapter verse range.
            String.contains?(ref, ":") ->
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )

            # Example: "James 1.2 -  2" → dotted start verse only.
            String.contains?(ref, ".") ->
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: nil
              )

            # Example: "James 1 - 2" or "James 1 — 2" → chapter range with no verses.
            String.contains?(ref, "-") or String.contains?(ref, "—") ->
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: nil,
                end_chapter: String.to_integer(Enum.at(x, 4)),
                end_verse: nil
              )

            # Fallback: treat as start + end verse within the same chapter.
            true ->
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )
          end

        # Case 5: six captures – cross-chapter range, e.g. ["John 3:16-4:3", "John", "3", "16", "4", "3"].
        length(x) == 6 ->
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: String.to_integer(Enum.at(x, 3)),
            end_chapter: String.to_integer(Enum.at(x, 4)),
            end_verse: String.to_integer(Enum.at(x, 5))
          )

        # Anything that does not match the expected shapes is ignored.
        true ->
          nil
      end
    end)
  end

  defp full_regex() do
    # Collect all canonical book keys from the different BibleData maps.
    # These are the tokens that will be recognized as book names in the regex.
    canonical_book_keys = Map.keys(BibleEx.BibleData.books())
    osis_keys           = Map.keys(BibleEx.BibleData.osis_books())
    shortened_keys      = Map.keys(BibleEx.BibleData.shortened_books())
    variant_keys        = Map.keys(BibleEx.BibleData.variants())

    # Merge all keys into a single list of searchable tokens:
    #   * downcased so matching is case-insensitive at the pattern level,
    #   * deduplicated,
    #   * sorted longest-first so multi-word / longer tokens win before prefixes.
    all_searchable =
      (canonical_book_keys ++ osis_keys ++ shortened_keys ++ variant_keys)
      |> Enum.map(&String.downcase/1)
      |> Enum.uniq()
      |> Enum.sort_by(&String.length/1, :desc)

    # Turn the list of book tokens into a single alternation group:
    #   "genesis|gen|gn|..." – with each token regex-escaped for safety.
    book_alternation =
      all_searchable
      |> Enum.map(&Regex.escape/1)
      |> Enum.join("|")

    # Main reference-matching pattern:
    #   1. Match a book token with safe left/right boundaries.
    #   2. Optionally match chapter and verse.
    #   3. Optionally match a range (same chapter or cross-chapter).
    pattern = """
    (?<![A-Za-z0-9])          # left boundary: do not allow letters/digits before the book
    (#{book_alternation})     # 1: book token (any of the known keys)
    (?![A-Za-z])              # right boundary: next char cannot be a letter (avoid 'Jos' in 'Joseph')
    \\s*                      # optional whitespace after book

    (?:
      (\\d+)                  # 2: optional chapter number (e.g. '3' in 'John 3:16')
      (?:\\s*[.:]\\s*(\\d+))? # 3: optional verse number with ':' or '.' (e.g. '16' in '3:16' or '3 . 16')

      (?:
        \\s*[—-]\\s*          # optional range separator: dash or em dash, with optional surrounding spaces

        (?:
          (\\d+)              # 4: end chapter (for cross-chapter ranges, e.g. '4' in '3:16-4:3')
          (?:\\s*[.:]\\s*(\\d+))? # 5: optional end verse after end chapter (e.g. '3' in '4:3')
          |                   # OR

          (\\d+)              # 6: end verse within the same chapter (e.g. '18' in '3:16-18')
        )
      )?
    )?                        # entire chapter/verse/range part is optional (supports book-only matches)
    """

    # Compile the pattern with:
    #   x – extended mode (whitespace/comments allowed),
    #   i – case-insensitive,
    #   u – Unicode mode.
    {:ok, regex} = Regex.compile(pattern, "xiu")
    regex
  end
end
