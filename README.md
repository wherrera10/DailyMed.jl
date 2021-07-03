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

<br /><br />


The API uses the function names of the DailyMed REST API, as seen at
<link />

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
 
