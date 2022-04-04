// =============================================================================
// Hintle Text 0.1
// =============================================================================

import 'dart:io';

import 'package:args/args.dart';

import 'hintlegame.dart';
import 'hintlelexicon.dart';
import 'hintletextui.dart';

bool isVerbose = false;

// -----------------------------------------------------------------------------
void main(List<String> args) {
    var userGame = createFromArgs(args);
    var gameList = [userGame];
    for (var game in gameList) {
        var board = HintleTxtUI(game, isVerbose: isVerbose);
        while (game.isRunning) {
            game.processGuess(board.getInput());
            board.displayState();
        }
    }
}

// -----------------------------------------------------------------------------
HintleGame createFromArgs(List<String> args) {
    var parser = ArgParser();
    defineParams(parser);
    var results = parseParams(args, parser);

    if (results.wasParsed("help") || results.rest.isNotEmpty) {
        printUsage(parser);
        exit(0);
    }

    if (results.wasParsed("verbose")) {
        isVerbose = true;
    }

    if (results.wasParsed("default")) {
        return HintleGame();
    }

    return HintleGame(
        name:     results["name"],
        lexicon:  HintleLexicon.fromFile(results["lexicon"]),
        maxTries: int.tryParse(results["maxtries"]) ?? HINTLE_DFLT_MAXTRIES,
        hintMark: int.tryParse(results["hintmark"]) ?? HINTLE_DFLT_HINTMARK,
        isRandom:        results["randomize"],
        isStrictLexicon: results["strictlex"],
        isStrictLength:  results["strictlen"],
        isWithHints:     results["showhints"],
        isDupAllowed:    results["allowdups"],
        isRevealedAtEnd: results["showatend"],
        isSecretVisible: results["isvisible"],
        isPlainSpot:     results["plainspot"],
        spotSymbol:      results["spotsymbol"],
        nearSymbol:      results["nearsymbol"],
        junkSymbol:      results["junksymbol"],
        alphabet:        results["alphabet"],
    );
}

// -----------------------------------------------------------------------------
void defineParams(ArgParser p) {
    p.addFlag("help",
        abbr: "h",
        defaultsTo: false,
        negatable: false,
        help: "Display this message",
    );
    p.addFlag("verbose",
        abbr: "v",
        defaultsTo: false,
        negatable: false,
        help: "Display full game parameters",
    );
    p.addFlag("default",
        abbr: "d",
        defaultsTo: false,
        negatable: false,
        help: "Start a game with internal lexicon and default settings",
    );
    p.addOption("lexicon",
        abbr: "l",
        aliases: ["dictionary", "dict", "lex", "source"],
        help: "Source lexicon(dictionary) file name",
        valueHelp: "file path",
    );
    p.addOption("name",
        abbr: "n",
        defaultsTo: HINTLE_DFLT_GAMENAME,
        help: "A name for this game",
        valueHelp: "string",
    );
    p.addOption("maxtries",
        defaultsTo: HINTLE_DFLT_MAXTRIES.toString(),
        help: "Maximum number of attempts to find the secret word",
        valueHelp: "integer",
    );
    p.addOption("hintmark",
        defaultsTo: HINTLE_DFLT_HINTMARK.toString(),
        help: "Start hinting after this many tries",
        valueHelp: "integer",
    );
    p.addFlag("randomize",
        aliases: ["random"],
        defaultsTo: true,
        help: "Random choice of word"
    );
    p.addFlag("strictlex",
        defaultsTo: false,
        help: "Only words from the lexicon/dictionary"
    );
    p.addFlag("strictlen",
        defaultsTo: true,
        help: "Guesses must have same length as secret word"
    );
    p.addFlag("showhints",
        defaultsTo: true,
        help: "Use hints (when defined in lexicon)"
    );
    p.addFlag("allowdups",
        defaultsTo: false,
        help: "Admit duplicate guesses"
    );
    p.addFlag("showatend",
        defaultsTo: true,
        help: "Reveal secret word at end of game"
    );
    p.addFlag("isvisible",
        defaultsTo: false,
        help: "Secret word always visible?"
    );
    p.addFlag("plainspot",
        defaultsTo: false,
        help: "Show matched letters in guesses"
    );
    p.addOption("spotsymbol",
        defaultsTo: HINTLE_DFLT_SPOTSYMBOL,
        help: "Representation of guess character in exact position",
        valueHelp: "symbol",
    );
    p.addOption("nearsymbol",
        defaultsTo: HINTLE_DFLT_NEARSYMBOL,
        help: "Representation of guess character in different position",
        valueHelp: "symbol",
    );
    p.addOption("junksymbol",
        defaultsTo: HINTLE_DFLT_JUNKSYMBOL,
        help: "Representation of guess character not in any position",
        valueHelp: "symbol",
    );
    p.addOption("alphabet",
        defaultsTo: HINTLE_DFLT_ALPHABET,
        help: "Valid characters in guesses",
        valueHelp: "characters",
    );

}

// -----------------------------------------------------------------------------
ArgResults parseParams(List <String> args, ArgParser p) {
    if (args.isEmpty) {
        printUsage(p);
        exit(0);
    }
    try {
        return p.parse(args);
    }
    on ArgParserException catch (exception) {
        stdout.writeln(exception);
        printUsage(p);
        exit(1);
    }
}

// -----------------------------------------------------------------------------
void printUsage(ArgParser p) {
    stdout.writeln("hintletxt: A text-based Hintle game\n");
    stdout.writeln("Usage: hintletxt [OPTIONS]");
    stdout.writeln("OPTIONS:");
    stdout.writeln(p.usage);
}
