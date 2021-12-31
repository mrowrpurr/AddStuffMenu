scriptName ConsoleSearch
{Get `help` results from the console}

; Returns the raw returned text from running `help "[query]"` in the console
string function Help(string query) global
    ; Check if console is currently open
    Debug.Trace("Going to call UI.GetBool now...")
    ; Debug.Trace("Going to call UI.GetBool now...")
    Utility.WaitMenuMode(3)

    bool isShown = false

    bool consoleOpen = false ; UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown")

    Debug.Trace("Console Open? " + consoleOpen)
    ; Debug.Trace("Console Open? " + consoleOpen)

    utility.waitmenumode(3)

    ; Is ConsoleUtil installed?
    ; bool consoleUtilInstalled = ConsoleUtil.GetVersion()
    bool consoleUtilInstalled = false
    Debug.Trace("Console Util installed? " + consoleInitialized)
    ; Debug.Trace("Console Util installed? " + consoleInitialized)

    utility.waitmenumode(3)

    ; Is it initialized? Check.
    float consoleInitialized = 0 ; UI.GetFloat("Console", "_global.Console.ConsoleInstance._SearchInitialized")
    Debug.Trace("Console initialized? " + consoleInitialized)
    ; Debug.Trace("Console initialized? " + consoleInitialized)

    utility.waitmenumode(3)

    ; Initialize by opening the console at least once (then you can immediately close it)
    if ! consoleInitialized
        Debug.Trace("Console not initialized")
        if ! consoleOpen
            Debug.Trace("Console not open")

            ; Debug.Trace("TAPPING KEY")
            Debug.Trace("TAPPING KEY")
            Utility.WaitMenuMode(1)

            ; OPEN IT!
            Debug.MessageBox("Opening...")
            Input.TapKey(41) ; Open ~
            Debug.MessageBox("Should be open now")
            ; Input.TapKey(Input.GetMappedKey("Console")) ; Open
            
            Utility.WaitMenuMode(1)
            
            Debug.Trace("Tapped!")
            ; Debug.Trace("Did it open?")

            Utility.WaitMenuMode(5)
            ; Debug.Trace("How about now?")
            Debug.Trace("How about now?")
            ; Wait for it to be Shown
            while ! UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown")
                Debug.Trace("Waiting for console to open....")
                Utility.WaitMenuMode(0.01)
            endWhile
            Debug.MessageBox("It is OPEN!")
            isShown = true
            consoleOpen = true
        endIf

        UI.InvokeInt("Console", "_global.Console.SetHistoryCharBufferSize", 100000)

        UI.SetFloat("Console", "_global.Console.ConsoleInstance._SearchInitialized", 69) ; Set as initialized

        ; if consoleOpen && consoleUtilInstalled
        ;     ; Input.TapKey(Input.GetMappedKey("Console")) ; Close (but keep it open if console util not installed)
        ;     Input.TapKey(41) ; Close (but keep it open if console util not installed)
        ; endIf
    endIf

    Debug.Trace("Clearing the console")
    ; Debug.Trace("Clearing the console")

    ; Clear the console
    UI.SetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text", "")

    ; Console command
    string command = "help \"" + query + "\""

    ; Run the command
    if consoleUtilInstalled ; Use ConsoleUtil if installed
        ; Run the command (in the background)
        ; Debug.Trace("OH NOES CONSOLE UTIL")
        ; ConsoleUtil.ExecuteCommand(command)

        ; Wait on the output to not be blank (or have more than just the command we write)
        while UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == "" || UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == command
            Utility.WaitMenuMode(0.01)
        endWhile
    else
        Debug.Trace("A")

        ; Open
        if ! consoleOpen
            Input.TapKey(41)
            consoleOpen = true
        endIf
        Debug.Trace("B")

        ; Wait for it to be Shown
        while ! isShown && ! UI.GetBool("Console", "_global.Console.ConsoleInstance.Shown")
            Utility.WaitMenuMode(0.01)
        endWhile
        isShown = true
        Debug.Trace("C")

        ;  The command to run
        UI.SetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text", command)
        Debug.Trace("D")

        while UI.GetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text") != command
            Utility.WaitMenuMode(0.01)
        endWhile
        Debug.Trace("E")

        ; Enter (Twice, just cuz)
        Debug.MessageBox("PRESSING ENTER...")
        Input.TapKey(28)
        Utility.WaitMenuMode(1)
        Input.TapKey(28)

        Debug.Trace("F")
        ; Just cuz.
        Utility.WaitMenuMode(0.01) 

        Debug.Trace("G")
        Debug.MessageBox("Closing console! Is it open? "+ consoleOpen)
        ; Close
        ; if consoleOpen
            ; Input.TapKey(Input.GetMappedKey("Console"))
            Input.TapKey(41)
        ; endIf
        Debug.Trace("H")
        Debug.MessageBox("Closed?")

        ; Wait on the output to not be blank (or have more than just the command we write)
        while UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == "" || UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text") == command
            Utility.WaitMenuMode(0.01)
        endWhile
        Debug.Trace("I")
    endIf
        Debug.Trace("X")

    ; Remove this from the most recently run command list
    int commandHistoryLength = UI.GetInt("Console", "_global.Console.ConsoleInstance.Commands.length")

    Debug.Trace("Y")

    UI.InvokeInt("Console", "_global.Console.ConsoleInstance.Commands.splice", commandHistoryLength - 1)

    Debug.Trace("Z")

    return UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text")
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
;       Debug.Trace("Result name: " + ConsoleConsoleSearch.GetRecordName(result))
;       Debug.Trace("Result form ID: " + ConsoleConsoleSearch.GetRecordFormID(result))
;       Debug.Trace("Result editor ID: " + ConsoleConsoleSearch.GetRecordEditorID(result))
;
;       i += 1
;   endWhile
;
;   recordTypeIndex += 1
; endWhile
;
; ```
int function ExecuteSearch(string query, string recordType = "", string filter = "") global
    ; Debug.Trace("Execute Search...")
    Utility.WaitMenuMode(2)

    int results = JMap.object()
    string newline = StringUtil.AsChar(13) ; 10 is Line Feed, 13 is Carriage Return

    ; Debug.Trace("Getting help command output for " + query)
    Utility.WaitMenuMode(2)

    Debug.Trace("Getting Help Text...")

    string text = Help(query)

    Debug.Trace("HELP TEXT: " + text)

    string[] lines = StringUtil.Split(text, newline)
    bool parsingForms
    bool parsingGlobals

    Debug.Trace("PARSE STARTING...")

    Debug.MessageBox("PARSE STARTING")

    int i = 0
    while i < lines.Length
        string line = lines[i]
        Debug.Trace(i + ": " + line)
        if ! parsingGlobals && ! parsingForms && StringUtil.Find(line, "-GLOBAL VARIABLES-") > -1
            parsingGlobals = true
        elseIf ! parsingForms && StringUtil.Find(line, "-OTHER FORMS-") > -1
            parsingForms = true
            parsingGlobals = false
        elseIf parsingForms
            int colon = StringUtil.Find(line, ":")
            if colon > -1
                int openParens = StringUtil.Find(line, "(")
                int closeParens = StringUtil.Find(line, ")")
                int openSingleQuote = StringUtil.Find(line, "'")
                if openParens && closeParens && openSingleQuote
                    string type = StringUtil.Substring(line, 0, colon)
                    if type != "usage" && type != "filters" && (! recordType || type == recordType)
                        string editorId = ""
                        if (openParens - colon - 3) > 0
                            editorId = StringUtil.Substring(line, colon + 2, openParens - colon - 3)
                        endIf
                        string formId = StringUtil.Substring(line, openParens + 1, closeParens - openParens - 1)
                        string name = StringUtil.Substring(line, openSingleQuote + 1, StringUtil.GetLength(line) - openSingleQuote - 2)
                        if ! filter || StringUtil.Find(name, filter) > -1 || StringUtil.Find(formId, filter) > -1 || StringUtil.Find(editorId, filter) > -1
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

    Debug.Trace("RETURNING!")

    Debug.MessageBox("PARSE COMPLETE")

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
