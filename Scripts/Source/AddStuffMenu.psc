scriptName AddStuffMenu extends Quest

function Search()
    UITextEntryMenu textEntry = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
    textEntry.OpenMenu()
    string query = textEntry.GetResultString()
    if query
        int searchResult = ConsoleSearch.ExecuteSearch(query)
        JValue.writeToFile(searchResult, "SearchResultTest.json")
        string json = MiscUtil.ReadFromFile("SearchResultTest.json")
        Debug.MessageBox(json)
    endIf
endFunction
