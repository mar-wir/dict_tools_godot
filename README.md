
-----

[![contributions
welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/Seneketh/dict_tools_godot/issues)

# Easier handling of nested dictionaries in Godot

### What does this code do:

It enables one to:

  - Add new data to a deeply nested dictionary via a path in form of an
    array of strings. If the defined structures do not exist, they are
    created on the fly.
  - Read data from a deeply nested dictionary via a path in form of an
    array of strings.
  - Export deeply nested dictionaries to CSV format for posterior data
    analysis.
  - Return all values stored in a nested dictionary. This is just a
    recursive `.values()`.
  - Return all keys stored in a nested dictionary. This is just a
    recursive `.keys()`.
  - Filter/search deeply nested dictionaries via keywords (coming soon).

It is aimed at:

  - Enabling scientific applications with Godot as nested data becomes
    analizable.
  - Generally handling nested data more easily.

### Installation:

Download the `DictCSV` and/or `DictIO` scripts via
[DownGit](https://minhaskamal.github.io/DownGit/#/home) or clone this
repository to your local machine. Put the script(s) in your Godot
project folder and add them to the `auto-load` list. This procedure is
explained in more detail
[here](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/singletons_autoload.html).

### Uninstall:

Remove the scripts from the `auto-load` list and delete them.

### Examples

#### Writing/creating/updating nested dictionaries:

Running the following:

``` python
var dict = {}
var path = ["Hull", "Layer_1", "Layer_2", "Layer_3", 'Layer_4', "Core", "Temperature"]
var payload = 4500

var updated_dict = DictIO.manipulate_nested_dict(dict, path, 'write', payload, [])

print(updated_dict)
```

Produces this dictionary:

``` javascript
    {
        "Hull":{
            "Layer_1":{
                "Layer_2":{
                    "Layer_3":{
                        "Layer_4":{
                            "Core":{
                                "Temperature":4500
                            }
                        }
                    }
                }
            }
        }
    }
```

Note that the original outputs printed at the console in Godot look like
this `javascript
{Hull:{Layer_1:{Layer_2:{Layer_3:{Layer_4:{Core:{Sublevel_A:Inserted
Info}}}}}}}`. I have formatted the output for easier interpretation
[here](https://jsonformatter.curiousconcept.com/).

If one wishes to add more information to the dictionary, this is done
exactly the same way as above. Adding the following to the above code:

``` python
var path2 = ["Hull", "Layer_1", "Layer_2", "Layer_3", 
            'New_Path_1', "New_Path_2", "Hidden_Core", "Radiation"]
            
var payload2 = 250
var updated_dict2 = DictIO.manipulate_nested_dict(updated_dict, path2, 'write', payload2, [])

print(updated_dict2)
```

Output:

``` javascript
{
   "Hull":{
      "Layer_1":{
         "Layer_2":{
            "Layer_3":{
               "Layer_4":{
                  "Core":{
                     "Temperature":4500
                  }
               },
               "New_Path_1":{
                  "New_Path_2":{
                     "Hidden_Core":{
                        "Radiation":250
                     }
                  }
               }
            }
         }
      }
   }
}
```

Observe how new entries are added only where the paths begin differing.
`New_Path_1` is inserted at the level of `Layer_4`. Updating or changing
the values of a nested dictionary is performed in the same way as above.

#### Reading:

Taking the last dictionary from above, reading is accomplished by
calling `manipulate_nested_dict()` with the “read”
argument:

``` python
path = ["Hull", "Layer_1", "Layer_2", "Layer_3", 'Layer_4', "Core", "Temperature"]

var looked_up = DictIO.manipulate_nested_dict(updated_dict2, path, 'read', [], [])
    
print(looked_up)
```

Returns `4500`.

Note that when writing and reading with the same `path` variable,
between the `DictIO.manipulate_nested_dict` function calls, the `path`
has to be re-written, like above. **You cannot re-use the `path`
variable withou re-writing it between the function calls.** The reasons
are unclear. My best guess is that the memory management injects some
information from one function-call to another. This persists even when
changing funcion names or sourcing from different scripts. Any pointers
would be great.

When the `path` does not point at an “endpoint” (a dictionary which does
contain a value), but another dictionary along the nesting hierarchy,
the function returns its contents. See here for an
example:

``` python
path = ["Hull", "Layer_1", "Layer_2", "Layer_3", 'Layer_4'] # Here, the path ends earlier than in the above example.

var looked_up = DictIO.manipulate_nested_dict(updated_dict2, path, 'read', [], [])
    
print(looked_up)
```

The following warning is printed: *“Warning: latest entry in path could
not be used as key. Returning as is.”* The function returns following:

``` javascript
{
   "Core":{
      "Temperature":4500
   }
}
```

### Exporting to CSV:

For this example, consider the beginning of the following dictionary
`TEST_DICT` (below), where different `data types` are stored in
`instances`, belonging to different `units`. The stored data is
time-stamped and varies between types. This example is not far from
typical structures used in data collection in scientific experiments.
This format, while quite efficient, is not apt for analysis. In order
for it to be analizable, each datum (yes, even the missing values), have
to be individually identified with each key from the hierarchy it
belongs to. This is called [tidy
data](https://www.jstatsoft.org/index.php/jss/article/view/v059i10/v59i10.pdf)
or a [data matrix](https://en.wikipedia.org/wiki/Tidy_data).

``` javascript
{
    "Data_Type_1":{
       "Unit_A":{
          "Instances":{
             "Inst_01":{
                "Type_A":{
                   "1":{
                      "01.01.2019":4.3,
                      "03.03.2003":"NAN"
                   },
                   "2":{
                      "01.02.2019":805
                   }
                },
                "Type_B":{
                   "3":{
                      "27.12.2017":"beta"
                   }
                }
             },
             "Inst_02":{
                "Type_B":{
                   "3":{
                      "23.04.2016":"gamma",
                      "12.11.2011":"NAN"
                   }
                ...
```

Calling:

``` python
DictCSV.export_nested_dict_to_csv(TEST_DICT, '/home/username/somefolder', 'Filename', ",")
```

will create a CSV file with the seperator `,`, the name `Filename` at
the directory `/home/username/somefolder`. The contents look as follows:

``` javascript
Data_Type_1,Unit_A,Instances,Inst_01,Type_A,1,01.01.2019,4.3
Data_Type_1,Unit_A,Instances,Inst_01,Type_A,1,03.03.2003,NAN
Data_Type_1,Unit_A,Instances,Inst_01,Type_A,2,01.02.2019,805
Data_Type_1,Unit_A,Instances,Inst_01,Type_B,3,27.12.2017,beta
Data_Type_1,Unit_A,Instances,Inst_02,Type_B,3,23.04.2016,gamma
Data_Type_1,Unit_A,Instances,Inst_02,Type_B,3,12.11.2011,NAN
Data_Type_1,Unit_A,Instances,Inst_03,Type_D,1,30.02.2010,10
Data_Type_1,Unit_B,Instances,Inst_01,Type_D,1,30.02.2010,10
Data_Type_1,Unit_B,Instances,Inst_02,Type_A,1,01.01.2019,4.3
Data_Type_1,Unit_B,Instances,Inst_02,Type_A,1,03.03.2003,NAN
Data_Type_1,Unit_B,Instances,Inst_02,Type_A,2,01.02.2019,805
Data_Type_1,Unit_B,Instances,Inst_02,Type_B,1,03.01.2019,4.3
Data_Type_1,Unit_B,Instances,Inst_02,Type_B,1,25.03.2003,5
Data_Type_1,Unit_B,Instances,Inst_02,Type_B,2,01.01.2019,700
Data_Type_1,Unit_B,Instances,Inst_02,Type_B,2,03.03.2003,685
Data_Type_1,Unit_B,Instances,Inst_02,Type_B,3,21.11.2019,6f6e65
Data_Type_1,Unit_B,Instances,Inst_03,Type_D,1,31.03.2012,71
Data_Type_1,Unit_B,Instances,Inst_03,Type_D,1,05.05.2004,4
Data_Type_1,Unit_B,Instances,Inst_03,Type_D,2,24.11.2017,564
Data_Type_1,Unit_B,Instances,Inst_03,Type_D,2,23.09.2009,789
Data_Type_1,Unit_B,Instances,Inst_03,Type_D,2,10.05.2007,754
```

The main limitation to this approach is that the length of the paths
where the data is stored (the endpoints) need to be at the same “depth”.
This means that empty dictionaries `{}` are also not an option and
forces the use of ‘NAN’/‘NA’/‘null’ when there are missing values or to
omit an entry alltogether. It is good statistical practice to consider
the occurence of missing data in your data analysis\!

### Getting all **values** from a nested dictionary:

Calling:

``` python
DictCSV.flatten_dictionary(TEST_DICT, 'values')
```

will
return:

``` python
[4.3, NAN, 805, beta, gamma, NAN, 10, 10, 4.3, NAN, 805, 4.3, 5, 700, 685, 6f6e65, 71, 4, 564, 789, 754]
```

### Getting all **keys** from a nested dictionary:

Calling:

``` python
DictCSV.flatten_dictionary(TEST_DICT, 'paths')
```

will return:

``` python
   [[Data_Type_1, Unit_A, Instances, Inst_01, Type_A, 1, 01.01.2019], 
    [Data_Type_1, Unit_A, Instances, Inst_01, Type_A, 1, 03.03.2003], 
    [Data_Type_1, Unit_A, Instances, Inst_01, Type_A, 2, 01.02.2019], 
    [Data_Type_1, Unit_A, Instances, Inst_01, Type_B, 3, 27.12.2017], 
    [Data_Type_1, Unit_A, Instances, Inst_02, Type_B, 3, 23.04.2016], 
    [Data_Type_1, Unit_A, Instances, Inst_02, Type_B, 3, 12.11.2011], 
    [Data_Type_1, Unit_A, Instances, Inst_03, Type_D, 1, 30.02.2010], 
    [Data_Type_1, Unit_B, Instances, Inst_01, Type_D, 1, 30.02.2010], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_A, 1, 01.01.2019], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_A, 1, 03.03.2003], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_A, 2, 01.02.2019], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_B, 1, 03.01.2019], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_B, 1, 25.03.2003], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_B, 2, 01.01.2019], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_B, 2, 03.03.2003], 
    [Data_Type_1, Unit_B, Instances, Inst_02, Type_B, 3, 21.11.2019], 
    [Data_Type_1, Unit_B, Instances, Inst_03, Type_D, 1, 31.03.2012], 
    [Data_Type_1, Unit_B, Instances, Inst_03, Type_D, 1, 05.05.2004], 
    [Data_Type_1, Unit_B, Instances, Inst_03, Type_D, 2, 24.11.2017], 
    [Data_Type_1, Unit_B, Instances, Inst_03, Type_D, 2, 23.09.2009], 
    [Data_Type_1, Unit_B, Instances, Inst_03, Type_D, 2, 10.05.2007]]
```

The function `flatten_dictionary` delivers useful in-between products to
get to the CSV export. From here, one could easily write a filtering
function to make a dictionary filterable (coming soon).

### Help wanted:

I am open for any constructive input\!

&nbsp;
<hr />
<p style="text-align: center;">A work by <a href="https://www.linkedin.com/in/mwirthlin/">Marco Wirthlin</a></p>
<p style="text-align: center;"><span style="color: #808080;"><em>marco.wirthlin@gmail.com</em></span></p>

<!-- Add icon library -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

<!-- Add font awesome icons -->
<p style="text-align: center;">
    <a href="https://twitter.com/MarcoWirthlin" class="fa fa-twitter"></a>
    <a href="https://www.linkedin.com/in/mwirthlin/" class="fa fa-linkedin"></a>
    <a href="https://github.com/Seneketh" class="fa fa-github"></a>
</p>

&nbsp;
