Access Cards
============

This plugin adds access cards to the schema as well as access cards readers, the cards data are stored on a new **MySQL** table in the NutScript database.  
To use this plugin import cards.sql to your NutScript database.  
  
The plugin manages access using access flags which means you can assign different characters to a keycard reader. If an access card has one character in common with the reader it will grant access.  
In an access card, using the symbol ***** will grant access to every door. Make sure to note which characters are assigned to which doors.  
  
Note: The first time you use your card it will fail (as it is loading data from the database), on the second try the door will open.

Creating Cards
--------------
To create a card you need the **d** flag, if you have this flag you will be able to access the management console and will also be able to use the **createcard** command.  
```/createcard <string name> <string access> [string \"Description\"]```  
- Name of the owner (put it in quotes if there are spaces)
- Access flags
- Card description (put it in quotes if there are spaces)

This command will spawn the card where you are looking.

Adding Readers
--------------
- Look at the door you want to add and type ```/adddoor``` (can be used on multiple doors)
- Run the ```/addreader <string access>``` command where the first argument is a list of accepted flags
- Place the reader to the desired location
- Run the ```/addreader true``` to remove all doors from your selection so that you can add new doors