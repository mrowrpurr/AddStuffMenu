scriptName AddStuffMenu extends Quest

ObjectReference property ItemsContainer auto
Message property SearchingMessage auto

string[] _itemTypeCategoryNames

string _searchInProgress

function OnInit()
    _itemTypeCategoryNames = new string[12]
    _itemTypeCategoryNames[0] = "ALCH"
    _itemTypeCategoryNames[1] = "AMMO"
    _itemTypeCategoryNames[2] = "ARMO"
    _itemTypeCategoryNames[3] = "BOOK"
    _itemTypeCategoryNames[4] = "FLOR"
    _itemTypeCategoryNames[5] = "INGR"
    _itemTypeCategoryNames[6] = "KEYM"
    _itemTypeCategoryNames[7] = "MISC"
    _itemTypeCategoryNames[8] = "NOTE"
    _itemTypeCategoryNames[9] = "SCRL"
    _itemTypeCategoryNames[10] = "SLGM"
    _itemTypeCategoryNames[11] = "WEAP"
endFunction

event OnUpdate()
    if _searchInProgress
        ShowSearchingMesage()
        RegisterForSingleUpdate(1)
    endIf
endEvent

function ShowSearchingMesage()
    string helpMessageId = "ConsoleSearchInProgressMessage" + Utility.RandomFloat(0, 1000000) ; Else it'll flash forever and ever...
    SearchingMessage.ShowAsHelpMessage(helpMessageId, 1.0, 1.0, 1)
endFunction

function Search()
    if _searchInProgress
        Debug.Trace("[ADDSTUFF] Search in progress for " + _searchInProgress)
        return
    endIf

    string query = ConsoleTextEntry.GetText("Please enter something:")

    if query
        Debug.Trace("[ADDSTUFF] PREPARING THE RESULTS!")
        _searchInProgress = query
        ItemsContainer.RemoveAllItems()
        ShowSearchingMesage()
        RegisterForSingleUpdate(1)
        ; bool useConsoleUtilIfAvailable = (Game.GetModByName("SkyrimVR.esm") == 255) ; ConsoleUtil for VR currently causes CTD
        bool useConsoleUtilIfAvailable = false
        int searchResult = ConsoleSearch.ExecuteSearch(query, useConsoleUtil = useConsoleUtilIfAvailable)
        Debug.Trace("[ADDSTUFF] SEARCH EXECUTE done")
        string[] resultCategories = ConsoleSearch.GetResultRecordTypes(searchResult)
        Debug.Trace(resultCategories)
        int i = 0
        while i < resultCategories.Length
            string category = resultCategories[i]
            if _itemTypeCategoryNames.Find(category) > -1
                int categoryCount = ConsoleSearch.GetResultRecordTypeCount(searchResult, category)
                int j = 0
                while j < categoryCount
                    int result = ConsoleSearch.GetNthResultOfRecordType(searchResult, category, j)
                    string resultFormHex = ConsoleSearch.GetRecordFormID(result)
                    Form resultForm = FormHelper.HexToForm(resultFormHex)
                    if resultForm
                        ItemsContainer.AddItem(resultForm)
                    endIf
                    j += 1
                endWhile
            endIf
            i += 1
        endWhile

        _searchInProgress = ""

        Debug.Trace("[ADDSTUFF] Container: " + ItemsContainer)
        if ItemsContainer.GetNumItems() > 0
            ItemsContainer.Activate(Game.GetPlayer())
        else
            Debug.MessageBox("No search results found for " + query)
        endIf
    endIf
endFunction
