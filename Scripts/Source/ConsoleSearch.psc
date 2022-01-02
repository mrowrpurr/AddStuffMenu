scriptName ConsoleSearch
{Get `help` results from the console}

; Returns the raw returned text from running `help "[query]"` in the console
string function Help(string query, bool useConsoleUtil = true) global
    Debug.Trace("[ADDSTUFF] Performing help search for " + query)

    bool consoleOpen = UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown")

    bool consoleUtilInstalled
    if useConsoleUtil
        consoleUtilInstalled = ConsoleUtil.GetVersion() ; This WILL explode on VR (set useConsoleUtil = false on VR)
    endIf
    
    float consoleInitialized = UI.GetFloat("Console", "_global.Console.InstanceLoaded") ; When custom console.swf is available

    ; Initialize by opening the console at least once (then you can immediately close it)
    if ! consoleInitialized

        ; Debug.Trace("[ADDSTUFF] Opening console!")
        if ! consoleOpen
            Input.TapKey(41) ; Open ~
            while ! UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown") ; Wait for it to open
                Utility.WaitMenuMode(0.1)
            endWhile
            consoleOpen = true
        endIf

        UI.InvokeInt("Console", "_global.Console.SetHistoryCharBufferSize", 100000) ; Critical! Or else not all items will be returned! And search might break entirely!

        if consoleOpen && consoleUtilInstalled
            Input.TapKey(41) ; Close (but keep it open if console util not installed)
            ; while UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown") ; Wait for it to close
            ;     Utility.WaitMenuMode(0.1)
            ; endWhile
            Utility.WaitMenuMode(1)
            consoleOpen = false
        endIf
    endIf

    ; Clear the console, saving the history to restore after the search completes
    string history = UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text")
    UI.SetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text", "")

    ; Console command
    string command = "help \"" + query + "\""

    ; Run the command
    if consoleUtilInstalled ; Use ConsoleUtil if installed
        ConsoleUtil.ExecuteCommand(command)

        ; Wait on the output to not be blank (or have more than just the command we write)
        ; while UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == "" || UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == command
        ;     Utility.WaitMenuMode(0.1)
        ; endWhile
        Utility.WaitMenuMode(1)
    else
        ; Open
        if ! consoleOpen
            Input.TapKey(41)
            while ! UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown") ; Wait for it to open
                Utility.WaitMenuMode(0.1)
            endWhile
            consoleOpen = true
        endIf

        ;  The command to run
        UI.SetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text", command)
        ; while UI.GetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text") != command ; Wait for the command entry text to be populated
        ;     Utility.WaitMenuMode(0.1)
        ; endWhile
        Utility.WaitMenuMode(1)

        ; Debug.Trace("[ADDSTUFF] PRESSING ENTER")
        ; Enter (Twice, just cuz)
        Input.TapKey(28)
        Utility.WaitMenuMode(0.1) ; <--- CTD prevention, the game doesn't enjoy Input.TapKey without some wait between them
        Input.TapKey(28)

        if consoleOpen
            ; Debug.Trace("[ADDSTUFF] Closing console!")
            Input.TapKey(41)
            ; while UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown") ; Wait for it to close
            ;     Utility.WaitMenuMode(0.1)
            ; endWhile
            Utility.WaitMenuMode(1)
            consoleOpen = false
        endIf

        ; Wait on the output to not be blank (or have more than just the command we write)
        ; while UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == "" || UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == command
        ;     Utility.WaitMenuMode(0.1)
        ; endWhile
        Utility.WaitMenuMode(1)
    endIf

    ; Remove this from the most recently run command list
    int commandHistoryLength = UI.GetInt("Console", "_global.Console.ConsoleInstance.Commands.length")

    UI.InvokeInt("Console", "_global.Console.ConsoleInstance.Commands.splice", commandHistoryLength - 1)

    string helpText = UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text")

    Debug.Trace("[ADDSTUFF] HELP TEXT: " + helpText)

    ; Restore the terminal's previous history
    UI.SetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text", history)
    UI.SetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text", "")

    Debug.Trace("[ADDSTUFF] RETURNING HELP TEXT FROM SEARCH")

    return helpText
endFunction

; Search Skyrim
;
; Uses the Skyrim ~ console. The ~ console will actually pop open while the Search runs.
;
; You can optionally pass along a `recordType` name. The recordType names correspond to those you'll find
; when using the `help` command in the Skyrim console, e.g. to filter for just NPCs, use `NPC_`
;
; If you want to filter down your results further, provide an additional `filter`.
; Only results which include the provided text in their Name, EditorID, or FormID will be returned.
;
; This function returns an identifier representing the discovered test results.
;
; To read the individual test results, see `GetResultRecordTypes()` `GetResultRecordTypeCount()` `GetNthResultOfRecordType()`
;
; ```
; int results = ConsoleConsoleSearch.Search("Hod")
;
; string[] foundRecordTypes = ConsoleConsoleSearch.GetResultRecordTypes(results)
;
; int recordTypeIndex = 0
; while recordTypeIndex < foundRecordTypes.Length
;   string recordType = foundRecordTypes[recordTypeIndex]
;
;   int countInRecordType = ConsoleConsoleSearch.GetResultRecordTypeCount(results, recordType)
;   int i = 0
;   while i < countInRecordType
;       int result = ConsoleConsoleSearch.GetNthResultOfRecordType(results, recordType, i)
;       
;       Debug.Trace("[ADDSTUFF] Result name: " + ConsoleConsoleSearch.GetRecordName(result))
;       Debug.Trace("[ADDSTUFF] Result form ID: " + ConsoleConsoleSearch.GetRecordFormID(result))
;       Debug.Trace("[ADDSTUFF] Result editor ID: " + ConsoleConsoleSearch.GetRecordEditorID(result))
;
;       i += 1
;   endWhile
;
;   recordTypeIndex += 1
; endWhile
;
; ```
int function ExecuteSearch(string query, string recordType = "", string filter = "", bool useConsoleUtil = true) global ; TODO support array of record types
    Debug.Trace("[ADDSTUFF] Execute Search " + query)
    int results = JMap.object()
    string newline = StringUtil.AsChar(13) ; 10 is Line Feed, 13 is Carriage Return
    string text = Help(query, useConsoleUtil)
    Debug.Trace("[ADDSTUFF] OK ExecuteSearch here I got the help text: " + text)
    string[] lines = StringUtil.Split(text, newline)
    bool parsingForms
    bool parsingGlobals
    int i = 0
    Debug.Trace("[ADDSTUFF] PARSING")
    Debug.Trace(query)
    while i < lines.Length
        string line = lines[i]
        Debug.Trace(i + ": " + line)
        if ! parsingGlobals && ! parsingForms && StringUtil.Find(line, "-GLOBAL VARIABLES-") > -1
            parsingGlobals = true
        elseIf ! parsingForms && StringUtil.Find(line, "-OTHER FORMS-") > -1
            parsingForms = true
            parsingGlobals = false
            Debug.Trace("[ADDSTUFF] PARSING FORMS...")
        elseIf parsingForms
            int colon = StringUtil.Find(line, ":")
            if colon > -1
                int openParens = StringUtil.Find(line, "(")
                int closeParens = StringUtil.Find(line, ")")
                int openSingleQuote = StringUtil.Find(line, "'")
                Debug.Trace("Probably a form! " + openParens + " " + closeParens + " " + openSingleQuote)
                if openParens && closeParens && openSingleQuote
                    string type = StringUtil.Substring(line, 0, colon)
                    if type != "usage" && type != "filters" && (! recordType || type == recordType)
                        string editorId = ""
                        if (openParens - colon - 3) > 0
                            editorId = StringUtil.Substring(line, colon + 2, openParens - colon - 3)
                        endIf
                        string formId = StringUtil.Substring(line, openParens + 1, closeParens - openParens - 1)
                        string name = StringUtil.Substring(line, openSingleQuote + 1, StringUtil.GetLength(line) - openSingleQuote - 2)
                        if (! filter) || StringUtil.Find(name, filter) > -1 || StringUtil.Find(formId, filter) > -1 || StringUtil.Find(editorId, filter) > -1
                            int result = JMap.object()
                            if JMap.hasKey(results, type)
                                JArray.addObj(JMap.getObj(results, type), result)
                            else
                                int typeArray = JArray.object()
                                JMap.setObj(results, type, typeArray)
                                JArray.addObj(typeArray, result)
                            endIf
                            if name == "'"
                                name = ""
                            endIf
                            JMap.setStr(result, "name", name)
                            JMap.setStr(result, "editorID", editorId)
                            JMap.setStr(result, "formID", formId)
                            Debug.Trace("[ADDSTUFF] Found form " + formId + " " + editorId + " " + name)
                        endIf
                    endIf
                endIf
            endIf
        elseIf parsingGlobals && StringUtil.Find(line, "-") == 0
            parsingGlobals = false
        elseIf parsingGlobals
            string[] globalVariableLineParts = StringUtil.Split(line, " ")
            string globalName = globalVariableLineParts[0]
            float globalValue = globalVariableLineParts[2] as float
            int result = JMap.object()
            JMap.setStr(result, "name", globalName)
            JMap.setFlt(result, "globalValue", globalValue)
            if JMap.hasKey(results, "GLOB")
                JArray.addObj(JMap.getObj(results, "GLOB"), result)
            else
                int typeArray = JArray.object()
                JMap.setObj(results, "GLOB", typeArray)
                JArray.addObj(typeArray, result)
            endIf   
        endIf
        i += 1
    endWhile
    return results
endFunction

; Gets a full list of all of recordTypes of discovered results.
; Provide the "`allResultsReference`" which is returned by the `Search()` function.
string[] function GetResultRecordTypes(int allResultsReference) global
    return JMap.allKeysPArray(allResultsReference)
endFunction

; Gets the count of all results discovered in the specified recordType.
; Provide the "`allResultsReference`" which is returned by the `Search()` function.
int function GetResultRecordTypeCount(int allResultsReference, string recordType) global
    int recordTypeArray = JMap.getObj(allResultsReference, recordType)
    if recordTypeArray
        return JArray.count(recordTypeArray)
    else
        return 0
    endIf
endFunction

; Gets a reference to an individual search result in a specified recordType.
; Use `GetResultRecordTypeCount()` to get the full count of individual search results in the recordType,
; and then use `GetNthResultOfRecordType()` to get a result in that recordType using an array index.
; Provide the "`allResultsReference`" which is returned by the `Search()` function.
int function GetNthResultOfRecordType(int allResultsReference, string recordType, int index) global
    int recordTypeArray = JMap.getObj(allResultsReference, recordType)
    if recordTypeArray
        return JArray.getObj(recordTypeArray, index)
    else
        return 0
    endIf
endFunction

; Get the Name of this result.
; To get a result, see `GetNthResultOfRecordType`.
string function GetRecordName(int individualResultReference) global
    return JMap.getStr(individualResultReference, "name")
endFunction

; Get the EditorID of this result.
; To get a result, see `GetNthResultOfRecordType`.
string function GetRecordEditorID(int individualResultReference) global
    return JMap.getStr(individualResultReference, "editorID")
endFunction

; Get the FormID of this result.
; To get a result, see `GetNthResultOfRecordType`.
string function GetRecordFormID(int individualResultReference) global
    return JMap.getStr(individualResultReference, "formID")
endFunction

; Stores the given result(s) in your upcoming save game file.
; Otherwise, the reference may stop working after a few seconds.
; Reference IDs are intended to be used only for a brief amount of time.
; Can be an individual result or full result set (like that returned by `Search`).
function SaveResult(int result) global
    JValue.retain(result)
endFunction

; Deleted the given result(s) from your upcoming save game file.
; Otherwise, the reference may stop working after a few seconds.
; Reference IDs are intended to be used only for a brief amount of time.
; Can be an individual result or full result set (like that returned by `Search`).
function DeleteResult(int result) global
    JValue.release(result)
endFunction

; Saves the given result(s) to file.
; Can be an individual result or full result set (like that returned by `Search`).
; The specified file path is relative to your Skyrim Special Edition folder.
function SaveResultToFile(int result, string filepath) global
    JValue.writeToFile(result, filepath)
endFunction
