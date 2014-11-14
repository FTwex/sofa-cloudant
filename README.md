sofa
=======



<pre>
  _ _ _ _ _ _ _ _ _ _ _ 
 /|                   |\
/ |_ _ _ _ _ _ _ _ _ _| \
\ /                    \/
 \ ___________________ /
</pre>

#### *An easy interface to CouchDB from R*

Note: Check out [*R4couchdb*](https://github.com/wactbprot/R4CouchDB), another R package to interact with CouchDB. 

## Quickstart

### Install CouchDB

Instructions [here](http://wiki.apache.org/couchdb/Installation)

### Connect to CouchDB

In your terminal 

```sh
couchdb
```

You can interact with your CouchDB databases as well in your browser. Navigate to [http://localhost:5984/_utils](http://localhost:5984/_utils)

### Install sofa

From GitHub


```r
install.packages("devtools")
devtools::install_github("sckott/sofa")
```


```r
library('sofa')
```

### Cushions

Cushions? What? Since it's couch we gotta use `cushions` somehow. `cushions` are basically just a simple named list holding details of connections for different couches you work with. See `?cushions` or `?authentication` for help. 

As an example, here's how I set up details for connecting to my Cloudant couch:


```r
cushion(name = 'cloudant', user = '<user name>', pwd = '<password>', type = "cloudant")
```

Break down of parameters: 

* `name`: Name of the cushion. This is how you'll refer to each connection. `cushion` is the first parameter of each function. 
* `user`: User name for the service.
* `pwd`: Password for the service, if any.
* `type`: Type of cushion. This is important. Only `localhost`, `cloudant`, and `iriscouch` are supported right now. Internally in `sofa` functions this variable determines how urls are constructed for http requests. 
* `port`: The port to connect to

Of course by default there is a built in `cushion` for localhost so you don't have to do that, unless you want to change those details, e.g., the port number.

Right now cushions aren't preserved across R sessions, but working on that.

### Ping the server


```r
ping()
#> $couchdb
#> [1] "Welcome"
#> 
#> $uuid
#> [1] "2c10f0c6d9bd17205b692ae93cd4cf1d"
#> 
#> $version
#> [1] "1.5.0"
#> 
#> $vendor
#> $vendor$version
#> [1] "1.5.0-1"
#> 
#> $vendor$name
#> [1] "Homebrew"
```

Nice, it's working.

### Create a new database, and list available databases


```
#> $ok
#> [1] TRUE
```


```r
createdb(dbname='sofadb')
#> $ok
#> [1] TRUE
```

see if its there now


```r
listdbs()
#> [[1]]
#> [1] "_replicator"
#> 
#> [[2]]
#> [1] "_users"
#> 
#> [[3]]
#> [1] "cachecall"
#> 
#> [[4]]
#> [1] "hello_earth"
#> 
#> [[5]]
#> [1] "leothelion"
#> 
#> [[6]]
#> [1] "mran"
#> 
#> [[7]]
#> [1] "mydb"
#> 
#> [[8]]
#> [1] "newdbs"
#> 
#> [[9]]
#> [1] "sofadb"
```

### Create documents

#### Write a document WITH a name (uses PUT)


```r
doc1 <- '{"name":"sofa","beer":"IPA"}'
writedoc(dbname="sofadb", doc=doc1, docid="a_beer")
#> $ok
#> [1] TRUE
#> 
#> $id
#> [1] "a_beer"
#> 
#> $rev
#> [1] "1-a48c98c945bcc05d482bc6f938c89882"
```

#### Write a json document WITHOUT a name (uses POST)


```r
doc2 <- '{"name":"sofa","icecream":"rocky road"}'
writedoc(dbname="sofadb", doc=doc2)
#> $ok
#> [1] TRUE
#> 
#> $id
#> [1] "822dd9c93ba0a7f149d75edf06006434"
#> 
#> $rev
#> [1] "1-fd0da7fcb8d3afbfc5757d065c92362c"
```

#### XML? 

Write an xml document WITH a name (uses PUT). The xml is written as xml in couchdb, just wrapped in json, when you get it out it will be as xml.

write the xml


```r
doc3 <- "<top><a/><b/><c><d/><e>bob</e></c></top>"
writedoc(dbname="sofadb", doc=doc3, docid="somexml")
#> $ok
#> [1] TRUE
#> 
#> $id
#> [1] "somexml"
#> 
#> $rev
#> [1] "1-5f06e82103a0d5baa9d5f75226c8dcb8"
```

get the doc back out


```r
getdoc(dbname="sofadb", docid="somexml")
#> $`_id`
#> [1] "somexml"
#> 
#> $`_rev`
#> [1] "1-5f06e82103a0d5baa9d5f75226c8dcb8"
#> 
#> $xml
#> [1] "<top><a/><b/><c><d/><e>bob</e></c></top>"
```

get just the xml out


```r
getdoc(dbname="sofadb", docid="somexml")[["xml"]]
#> [1] "<top><a/><b/><c><d/><e>bob</e></c></top>"
```

### Views

First, create a database


```r
createdb(dbname='alm_couchdb')
#> $ok
#> [1] TRUE
```

Write a view - here letting key be the default of null


```r
view_put(dbname='alm_couchdb', design_name='almview2', value="doc.baseurl")
#> $ok
#> [1] TRUE
#> 
#> $id
#> [1] "_design/almview2"
#> 
#> $rev
#> [1] "1-e7c17cff1b96e4595c3781da53e16ad8"
```

get info on your new view


```r
view_get(dbname='alm_couchdb', design_name='almview2')
#> $`_id`
#> [1] "_design/almview2"
#> 
#> $`_rev`
#> [1] "1-e7c17cff1b96e4595c3781da53e16ad8"
#> 
#> $views
#> $views$foo
#> $views$foo$map
#> [1] "function(doc){emit(null,doc.baseurl)}"
```

get data using a view


```r
view_search(dbname='alm_couchdb', design_name='almview2')
#> $total_rows
#> [1] 0
#> 
#> $offset
#> [1] 0
#> 
#> $rows
#> list()
```

delete the view


```r
view_del(dbname='alm_couchdb', design_name='almview2')
#> $ok
#> [1] TRUE
#> 
#> $id
#> [1] "_design/almview2"
#> 
#> $rev
#> [1] "2-9a57913471486e8e761651c85fd26d4b"
```


### Full text search? por sepuesto

I'm working on an R client for Elaticsearch called `elastic` - find it at [https://github.com/ropensci/elastic](https://github.com/ropensci/elastic)

Thinking about where to include functions to allow `elastic` and `sofa` to work together...if you have any thoughts hit up the issues. 
