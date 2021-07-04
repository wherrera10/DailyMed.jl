# DailyMed.jl

National Library of Medicine's DailyMed service RESTful interface functions for Julia

## Examples

    using DailyMed
    
    a, meta = rxcuis(extra = ["page" => "725"])
    println(a[1])  # => (rxcui = "1365899", rxstring = "{21 (ETHINYL ESTRADIOL 0.035 MG / NORGESTIMATE 0.25 MG ORAL TABLET) / 7 (INERT INGREDIENTS 1 MG ORAL TABLET) } PACK [MONO-LINYAH 28 DAY]", rxtty = "BPCK")

    a, meta = history("9aa7140c-012c-4ea6-866d-4732e915dab6")
    println(first(a).spl_version)  # "3"

    using Downloads, ImageView, Images, RxNav
    load("phenytoin.jpg")
    id = RxNav.rcui("phenytoin")
    setid = first([x.setid for x in spls(extra = ["rxcui" => id])[1] if contains(x.title, "PARKE-DAVIS")])
    url = media(setid)[1][1].url
    Downloads.download(url, "phenytoin.jpg")
    img = load("phenytoin.jpg")
    imshow(img)

<br /><br />

## Functions

Note:  Most of the functions take optional arguments. For details of the values for such arguments 
you should consult the NLM documentation at https://dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm.

If the function takes an optional argument called `extra`, this means that the function's optional 
argument `extra` should be provided as a `Dict` or as a `Vector` of `Pairs`, with the keys to the 
Dict being the label for the optional term and the values for that key as either a string or a vector
of strings to be assigned to that value in the final URL request. For example, 
    `extra = Dict("sources" => ["ACTIVE", "OBSOLETE"], "toReturn" => 25, page => 3)`
would be translated to 
    `"&sources=ACTIVE+OBSOLETE&toReturn=25&page=3"` 
in the REST call request string sent by HTTP.
<br /><br />

All functions return both data and metadata as a tuple (data, metadata), so you should reference the data returned as 
`classes[1]` in the call `classes[1] = drugclasses()`. In addition, the data is generally returned as a vector of `String`s
or `NamedTuple`s, so to reference the first class returned from drugclasses() you would need to write `class = drugclasses()[1][1]`.

<br /><br />

The Julia module uses the same function names used by the DailyMed REST API, as seen at
#### https://dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm.

| RESTful WEB SERVICE RESOURCES	| DESCRIPTION |
| ----------------- | ---------------- |
|/applicationnumbers	R|eturns a list of all NDA numbers.|
|/drugclasses | Returns a list of all drug classes associated with at least one SPL in the Pharmacologic Class Indexing Files.|
|/drugnames | Returns a list of all drug names.|
|/ndcs | Returns a list of all NDC codes.|
|/rxcuis | Returns a list of all product-level RxCUIs.|
|/spls | Returns a list of all SPLs.|
|/spls/{SETID} | Returns an SPL document for specific SET ID.|
|/spls/{SETID}/history | Returns version history for specific SET ID.|
|/spls/{SETID}/media | Returns links to all media for specific SET ID.|
|/spls/{SETID}/ndcs | Returns all ndcs for specific SET ID.|
|/spls/{SETID}/packaging | Returns all product packaging descriptions for specific SET ID.|
|/uniis | Returns a list of all UNIIs.|

<br /><br />

    `dailymed(restfunc, extra)`

Get and partially parse data from the url formed by `BASEURL * restfunc *`` expanded `extra` args

Returns a 2-tuple: (an EzXML parsed root document, and a Dict of meta data)
<br /><br />


    `applicationnumbers(; extra = [])`

Returns a list of all NDA numbers.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "application_number", "marketing_category_code", "setid", "pagesize", "page"

Returns a 2-tuple: (an vector of Strings of returns application numbers, and a Dict of meta data)
<br /><br />

    `drugclasses(; extra = [])`

Returns a list of all drug classes associated with at least one SPL in the
Pharmacologic Class Indexing Files.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "drug_class_code", "drugclass_coding_system", "code_class_type",
"class_name", "unii_code", "pagesize", "page"

Returns a 2-tuple: (a vector of Tuples(name, code), and a Dict of meta data)
<br /><br />

    `drugnames(; extra = [])`

Returns a list of all drug names. A <em>very large</em> string vector is returned, and the metadata

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "name_type", "manufacturer", "pagesize", "page"

Returns a 2-tuple: (a String vector of names, and a Dict of meta data)
<br /><br />

    `function ndcs(; extra = [])`

Returns a list of all NDC codes.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize" or "page"

Returns a 2-tuple: (a String vector of codes, and a Dict of meta data)
<br /><br />

    function rxcuis(; extra = [])

Returns a list of all product-level RxCUIs.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "rxtty", "rxstring", "rxcui", "pagesize", "page"

Returns a 2-tuple: (a vector of Tuples(rxcui, rxstring, rxtty), and a Dict of meta data)
<br /><br />

    function spls(; extra = [])

Returns a list of all SPLs.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "application_number", "boxed_warning", "dea_schedule_code", "doctype",
"drug_class_code", "drugclass_coding_system", "drug_name", "name_type", "labeler",
"manufacturer", "marketing_category_code", "ndc", "published_date",
"published_date_comparison", "rxcui", "setid", "unii_code", "pagesize", "page"

Returns a 2-tuple: (a vector of Tuples(setid, spl_version, published_date), and a Dict of meta data)
<br /><br />

    function function spls_setid(setid)

Returns an 2-tuple of the SPL document for specific SET ID, and a (blank) meta dict.
<br /><br />

    function history(setid; extra)

Returns version history for specific SET ID.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"

Returns a 2-tuple: (a vector of Tuples(spl_version, published_date), and a Dict of meta data)
<br /><br />

    function media(setid; extra = [])

Returns links to all media for specific SET ID.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"

Returns a 2-tuple: (a vector of Tuples(name, mime_type, url), and a Dict of meta data)
<br /><br />

    function ndcs(setid; extra = [])

Returns all ndcs for specific SET ID.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"

Returns a 2-tuple: (a String vector of NDC codes, and a Dict of meta data)
<br /><br />

    function packaging(setid; extra = [])

Return the XML string for the packaging of the item with the given setid.
The packaging XML is highly variable in labeling and may be deeply nested, so an array
or tuple is not computed, but instead the XML itself is returned.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"

Returns a 2-tuple: (a string of the XML returned, and a Dict of meta data)
<br /><br />

    function uniis(; extra = [])

Returns a list of all UNIIs.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "active_moiety", "drug_class_code", "drug_class_coding_system",
"rxcui", "unii_code", "pagesize", "page"

Returns a 2-tuple: (a vector of Tuples(unii_code, active_moiety), and a Dict of meta data)
<br /><br />



## Installation
                                   
You may install the package from Github in the usual way:
<br />

    # press ] to go to Pkg mode
  
    pkg> add DailyMed
      
 <br />
  
 Or, to install the current master copy:
    
    using Pkg
    Pkg.add("http://github.com/wherrera10/DailyMed.jl")                          
  
 <br /> 
 
