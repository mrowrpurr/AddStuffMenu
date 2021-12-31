scriptName AddStuffMenu extends Quest

function Search()
    ; ; Debug.Trace("Searching...")
    int searchResult = ConsoleSearch.ExecuteSearch("Fork")
    Debug.MessageBox("Writing the search result to a file " + searchResult)
    JValue.writeToFile(searchResult, "SearchResultTest.json")
    Debug.MessageBox("Wrote results to file")
    string json = MiscUtil.ReadFromFile("SearchResultTest.json")
    Debug.MessageBox("Search Results: " + json)
endFunction
