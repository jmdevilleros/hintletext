// =============================================================================
// HintleGame class v0.1
// =============================================================================

import 'dart:math' show Random;
import 'hintlelexicon.dart';

// -----------------------------------------------------------------------------
final HINTLE_DFLT_LEXICON    = HintleLexicon.fromListNoHints(WORDLE_EN_LIST);
const HINTLE_DFLT_GAMENAME   = "DEFAULT GAME";
const HINTLE_DFLT_MAXTRIES   = 6;
const HINTLE_DFLT_FIRSTTRY   = 1;
const HINTLE_DFLT_HINTMARK   = HINTLE_DFLT_MAXTRIES - 2;
const HINTLE_DFLT_ALPHABET   = "abcdefghijklmnopqrstuvwxyz";
const HINTLE_DFLT_NEARSYMBOL = "*";
const HINTLE_DFLT_SPOTSYMBOL = "!";
const HINTLE_DFLT_JUNKSYMBOL = "_";

// -----------------------------------------------------------------------------
class HintleGame {
    late final HintleLexicon _lexicon;
    late final String _secretWord;

    int _currentTry = HINTLE_DFLT_FIRSTTRY;
    bool _isRunning = true;
    bool _isSolved  = false;
    int _usedHints  = 0;

    final int maxTries;
    final int hintMark;

    final bool isRandom;
    final bool isWithHints;
    final bool isDupAllowed;
    final bool isStrictLength;
    final bool isStrictLexicon;
    final bool isSecretVisible;
    final bool isRevealedAtEnd;
    final bool isPlainSpot;

    final String name;
    final String alphabet;
    final String nearSymbol;
    final String spotSymbol;
    final String junkSymbol;

    final List<_HintleGuess> allGuesses = [];

    final Set<String> nearChars = {};
    final Set<String> spotChars = {};
    final Set<String> junkChars = {};

    Set<String> get foundChars  => spotChars.union(nearChars);
    Set<String> get usedChars   => foundChars.union(junkChars);
    Set<String> get mintChars =>
        alphabet.split("").toSet().difference(usedChars);

    bool get isRunning         => _isRunning;
    bool get isSolved          => _isSolved;
    int get currentTry         => _currentTry;
    List<String> get words     => _lexicon.allWords;

    String get discovered {
        if (_isSolved || (!isRunning && isRevealedAtEnd) || isSecretVisible) {
            return _secretWord;
        }
        if (allGuesses.isEmpty) {
            return junkSymbol * _secretWord.length;
        }
        return allGuesses.last.eval;
    }

    // -------------------------------------------------------------------------
    HintleGame({
        HintleLexicon? lexicon,
        this.name            = HINTLE_DFLT_GAMENAME,
        this.alphabet        = HINTLE_DFLT_ALPHABET,
        this.maxTries        = HINTLE_DFLT_MAXTRIES,
        this.nearSymbol      = HINTLE_DFLT_NEARSYMBOL,
        this.spotSymbol      = HINTLE_DFLT_SPOTSYMBOL,
        this.junkSymbol      = HINTLE_DFLT_JUNKSYMBOL,
        this.hintMark        = HINTLE_DFLT_HINTMARK,         // when to hint
        this.isRandom        = true,  // aleatory selection of secret word?
        this.isWithHints     = true,  // use hints while guessing?
        this.isPlainSpot     = false, // show matched letters
        this.isDupAllowed    = false, // repeat guess counts as valid try?
        this.isStrictLength  = true,  // accept only fixed size guesses?
        this.isStrictLexicon = false, // accept only words in lexicon?
        this.isSecretVisible = false, // secret word visible while playing?
        this.isRevealedAtEnd = true,  // reveal secret word when game ends?
    }) {
        _lexicon = lexicon ?? HINTLE_DFLT_LEXICON;
        _isRunning = (!_lexicon.isEmpty);
        _secretWord = _chooseWord(isRandomChoice: isRandom);
    }

    // -------------------------------------------------------------------------
    // Select word from lexicon at random or the next in sequence.
    // Sequence is the same for everyone, changes word every day.
    String _chooseWord({bool isRandomChoice = true}) {
        final milliseconds = DateTime.now().millisecondsSinceEpoch;
        final currentTimeInDays = (milliseconds / 1000 / 60 / 60 / 24).round();

        if (_lexicon.isEmpty) {
            return ("");
        }

        var index = isRandomChoice
            ? Random().nextInt(_lexicon.length)
            : currentTimeInDays % _lexicon.length;

        return _lexicon.allWords[index];
    }

    // -------------------------------------------------------------------------
    void stopPlaying() {
        _isRunning = false;
    }

    // -------------------------------------------------------------------------
    void processGuess(String inputWord) {
        if (!_isRunning || !isValidGuess(inputWord)) {
            return;
        }
        final S = _secretWord.toLowerCase();
        final G = inputWord.toLowerCase();
        allGuesses.add(_HintleGuess(G, _evalGuess(G)));
        _isSolved = G == S;
        if (G == S || _currentTry++ >= maxTries) {
            stopPlaying();
        }
     }

    // -------------------------------------------------------------------------
    bool isValidGuess(String word) {
        if (word.isEmpty) {
            return false;
        }
        final bool isCharsetOK =
            word.split("").fold(true, (p, e) => p && alphabet.contains(e));
        final bool isRepeatOK =
            isDupAllowed || !allGuesses.map((g) => g.word).contains(word);
        final bool isLengthOK =
            !isStrictLength || word.length == _secretWord.length;
        final bool isWordOK =
            !isStrictLexicon || words.contains(word);
        return isCharsetOK && isRepeatOK && isLengthOK && isWordOK;
    }

    // -------------------------------------------------------------------------
    /// todo: split evalguess into evalguess and translateguess
    String _evalGuess(String guess) {
        final S = _secretWord.toLowerCase();
        final G = guess.toLowerCase();
        final R = [];

        for (var i = 0; i < G.length; i++) {
            var symbol = "";
            if (!S.contains(G[i])) {
                junkChars.add(G[i]);
                symbol = junkSymbol;
            }
            else if (i < S.length && S[i] == G[i]) {
                spotChars.add(G[i]);
                nearChars.remove(G[i]);
                symbol = isPlainSpot ? G[i] : spotSymbol;
            }
            else {
                nearChars.add(G[i]);
                symbol = nearSymbol;
            }
            R.add(symbol);        }

        return R.join("");
    }

    // -------------------------------------------------------------------------
    String getNextHint() {
        var hint = "";
        var currentHints = _lexicon.allHints[_secretWord] ?? [];
        if (isWithHints && currentHints.isNotEmpty && _currentTry >= hintMark) {
            hint = currentHints[_usedHints % currentHints.length];
            _usedHints++;
        }
        return hint;
    }
}

// -----------------------------------------------------------------------------
class _HintleGuess {
    String word;
    String eval;
    _HintleGuess(this.word, this.eval);
}