scriptName AddStuffMenu extends Quest

function PrintWhetherConsoleSupportsCustomCommands()
    Debug.MessageBox("Custom Commands Supported? " + UI.GetBool("Console", "_global.Console.SupportsCustomCommands"))
endFunction

function Search()
    RegisterForKey(28)
    RegisterForKey(156)
    UI.SetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text", "Enter Query:\n")
    UI.SetBool("Console", "_global.Console.HandleEnterKey", false)
    Input.TapKey(41) ; ~
endFunction

; Provide option to keep open, e.g. that's what we want!
event OnKeyDown(int keyCode)
    UnregisterForKey(28)
    UnregisterForKey(156)
    string query = UI.GetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text")
    UI.SetBool("Console", "_global.Console.HandleEnterKey", true)
    Input.TapKey(41) ; ~
    Debug.MessageBox("Searching for '" + query + "'")
    UI.SetString("Console", "_global.Console.ConsoleInstance.CommandEntry.text", "")
    if query
        int searchResult = ConsoleSearch.ExecuteSearch(query)
        JValue.writeToFile(searchResult, "SearchResultTest.json")
        string json = MiscUtil.ReadFromFile("SearchResultTest.json")
        Debug.MessageBox(json)
    endIf
endEvent

event OnMenuClose(string menuName)
    if menuName == "Console"
        PrintWhetherConsoleSupportsCustomCommands()
    endIf
endEvent
