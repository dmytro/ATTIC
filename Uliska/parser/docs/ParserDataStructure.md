# @title Uliska Parser Output Data Structure Standard

Uliska Parser Output Data Structure Standard
--------------------------------------------

Specification below describes hash data structure, main goal of which is to make data produced by Uliska parser easy to use by software that does not know about internal data structure, i.e. data driven and schema-less. Data structures should be built in such a way as to make data self-documenting, easy adaptable and "software-friendly".

### Hashes

* Uliska output data structure is multi-level Hash

* Hash key is one of the following classes: String, Symbol

* Hash keys should be descriptive and programmatically convertible to human readable form:

GOOD: 

````
:filesystem_size.humanize
````

BAD:

````
:fs_s.humanize
````

* Hash values belong to one of the classes: Numeric, String, Hash, Array

* On the lowest level of the Hash only String, Numeric and simple Array are allowed as Hash values. Simple array here is an array containing only scalar values -- String or Numeric.


### Arrays

* Array can consist of Numeric, String, Hash values

* All elements of each Array should be of the same class

* Use of Arrays of Hashes acceptable, although discouraged:

OK:

````ruby
   { :local_users => 
      [ { :name => "nobody",
         :password => "*",
         :uid => -2,
         :gid => -2,
         :gecos => "Unprivileged User",
         :homedir => "/var/empty",
         :shell => "/usr/bin/false"
       },
       { :name => "root",
         :password => "*",
         :uid => 0,
         :gid => 0,
         :gecos => "System Administrator",
         :homedir => "/var/root",
         :shell => "/bin/sh"
       }
     ]
   }
````
    
BETTER:

````ruby
   { :local_users => 
      {
      :nobody => 
        { :name  =>  "nobody",
          :password => "*",
          :uid => -2,
          :gid => -2,
          :gecos => "Unprivileged User",
          :homedir => "/var/empty",
          :shell => "/usr/bin/false"
        },
      :root => 
        { :name => "root",
          :password => "*",
          :uid => 0,
          :gid => 0,
          :gecos => "System Administrator",
          :homedir => "/var/root",
          :shell => "/bin/sh"
        }
      }
   }
````

* When Arrays of Hashes are used additional conditions must be satisfied:

  - each Hash in an Array should have key `name` or

  - if name of the Hash enclosing Array-of-Hashes is English noun in plural form, each Hash should have key which is singular form of the same noun:

  **Example 1** -- Array of Hashes with `"name"` key:

````ruby
 {   :local_users=>
     [{:name=>"root",
       :password=>"x",
       :uid=>0,
       :gid=>0,
       :gecos=>"root",
       :homedir=>"/root",
       :shell=>"/bin/bash"},
      {:name=>"daemon",
       :password=>"x",
       :uid=>1,
       :gid=>1,
       :gecos=>"daemon",
       :homedir=>"/usr/sbin",
       :shell=>"/bin/sh"}
     ]
 }
````

  **Example 2** -- Enclosing collection `"groups"` is an Array of Hashes. Each Hash has key `"group"`:

````ruby
    {:groups=>
     [ {:group=>"root",   :password=>"x", :gid=>0, :members=>[]},
       {:group=>"daemon", :password=>"x", :gid=>1, :members=>[]},
       {:group=>"bin",    :password=>"x", :gid=>2, :members=>[]},
       {:group=>"sys",    :password=>"x", :gid=>3, :members=>[]}
      ]
}
````

Local Variables:
fill-column: 9999
End:
