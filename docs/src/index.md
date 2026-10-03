# DailyMed.jl

National Library of Medicine's DailyMed service RESTful interface functions for Julia

<img src="https://github.com/wherrera10/DailyMed.jl/blob/main/docs/src/dm_logo.png">

## Examples

    using DailyMed
    
    a, meta = rxcuis(extra = ["page" => "725"])
    println(a[1])  # => (rxcui = "966232", rxstring = "UNITHROID 88 MCG ORAL TABLET", rxtty = "PSN")

    a, meta = history("9aa7140c-012c-4ea6-866d-4732e915dab6")
    println(first(a).spl_version)  # "3"

    using Downloads, ImageView, Images, RxNav
    id = RxNav.rxcui("phenytoin")
    setid = first([x.setid for x in spls(extra = ["rxcui" => id])[1] if contains(x.title, "PARKE-DAVIS")])
    url = media(setid)[1][1].url
    Downloads.download(url, "phenytoin.jpg")
    img = load("phenytoin.jpg")
    imshow(img) # shows chemical structure diagram for phenytoin

<br /><br /><br />

## Functions

```@index
```

```@autodocs
Modules = [DailyMed]
```
