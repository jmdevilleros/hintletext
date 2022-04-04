// =============================================================================
// HintleTxtUI class v0.1
// =============================================================================

import 'dart:io' show stdout, stdin;
import 'hintlegame.dart';

// -----------------------------------------------------------------------------
class HintleTxtUI {
    HintleGame game;
    bool isVerbose = false;

    // -------------------------------------------------------------------------
    HintleTxtUI(this.game, {this.isVerbose = false}) {
        stdout.writeln("Hintle: ${game.name}");
        if (isVerbose) {
            displayParameters();
        }
        displayState();
    }

    // -------------------------------------------------------------------------
    void displayParameters() {
      stdout.writeln("Lexicon size: ${game.words.length}");
      stdout.writeln(
          "maxtries=${game.maxTries},"
          " hintmark=${game.hintMark}"
      );
      stdout.writeln(
          "randomize=${game.isRandom},"
          " strictlex=${game.isStrictLexicon},"
          " strictlen=${game.isStrictLength},"
          " showhints=${game.isWithHints}"
      );
      stdout.writeln(
          "allowdups=${game.isDupAllowed},"
          " showatend=${game.isRevealedAtEnd},"
          " isvisible=${game.isSecretVisible},"
          " plainspot=${game.isPlainSpot}"
      );
      stdout.writeln(
          "spotsymbol=[${game.spotSymbol}],"
          " nearsymbol=[${game.nearSymbol}],"
          " junksymbol=[${game.junkSymbol}],"

      );
      stdout.writeln("alphabet=[${game.alphabet}]");
    }

    // -------------------------------------------------------------------------
    void displayState() {
        stdout.write("\nTry ${game.currentTry} of ${game.maxTries}. ");
        String hint = game.getNextHint();
        stdout.writeln(hint.isNotEmpty ? hint : "");
        stdout.writeln("spotChars: ${game.spotChars}");
        stdout.writeln("nearChars: ${game.nearChars}");
        stdout.writeln("junkChars: ${game.junkChars}");
        stdout.writeln("mintChars: ${game.mintChars}");

        if (game.allGuesses.isEmpty) {
            stdout.writeln(
                "Secret:    [${game.discovered.split("").join("  ")}]");
        }
        else {
            for (var guess in game.allGuesses) {
                stdout.writeln(
                    "'${guess.word}' => "
                    "[ ${guess.eval.split("").join("  ")} ]"
                );
            }
        }

        if (!game.isRunning) {
            stdout.writeln("\nGame ${game.isSolved ? "" : "not "}solved");
            if (!game.isSolved && game.isRevealedAtEnd) {
                stdout.writeln("Secret was '${game.discovered}'");
            }
            stdout.writeln("Game ended");
        }
    }

    // -------------------------------------------------------------------------
    String getInput() {
        stdout.write("Your guess or [q] to quit: ");
        String response = stdin.readLineSync() ?? "";
        if (response == "q") {
            game.stopPlaying();
        }
        return response;
    }
}