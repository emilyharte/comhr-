
import 'package:flutter/material.dart';
import 'package:secure_social_media/newsfeed.dart';
import 'main.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


class Settings extends StatefulWidget {


  @override
  _SettingsState createState() => _SettingsState();

}




//booleans for switching screens
bool addingMembersNewGroup = false;
bool creatingGroup = false;
bool viewingGroup = false;
bool viewingOneGroup = false;
bool addingMembersExistingGroup = false;
bool removingMembers = false;
bool wantsToDeleteGroup = false;

//bits for encryption
final key = encrypt.Key.fromLength(32);
final iv = encrypt.IV.fromLength(16);
final encrypter = encrypt.Encrypter(encrypt.AES(key));


//Map group names to an index Map<Int, String>, key = group index, String= group name
var groupIndex = new Map();
//Starting index
var index = 0;

//2D list of group members, index of nested list = index of group in map
List<List> groupMembersList = new List<List>();

//List of current user's groups
List myGroups;

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: creatingGroup? _createNewGroupAppBar() : viewingGroup? _viewGroupsAppBar() :
      addingMembersNewGroup ? _enterMembersAppBar() : viewingOneGroup ? _groupActionsAppBar() :
      addingMembersExistingGroup ? _addMembersExistingGroupAppBar() : removingMembers ? _removeMembersGroupAppBar() :
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before, color: Colors.black,),
        onPressed: (){
          Navigator.pop(context);
         },
        ),
        title: Text("Settings",
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 30
          ),
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.home,
              color: Colors.deepPurpleAccent,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: creatingGroup? _createNewGroup() : viewingGroup? _viewMyGroups() :
      addingMembersNewGroup ? _enterGroupMembers() : viewingOneGroup ? _groupActions() :
      addingMembersExistingGroup ? _addMembersExistingGroup() : removingMembers ?  _removeMembersGroup() :
      Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 150, left: 100)
          ),
          FloatingActionButton(
            heroTag: 'btn1',
            tooltip: 'Create a new Group',
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: () {
              //create new group
              setState(() {
                creatingGroup = true;
              });
            },
            child: Icon(Icons.add),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(
              'Create a New Group',
              style: TextStyle(
                  fontSize: 20
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 150),
            child: FloatingActionButton(
              heroTag: 'btn2',
              tooltip: 'View my Groups',
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: () {
                setState(() {
                  myGroups = findMyGroups();
                  viewingGroup = true;
                });
              },
              child: Icon(Icons.people),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(
              'View My Groups',
              style: TextStyle(
                  fontSize: 20
              ),
            ),
          )
        ],
      ),
    );
  }

  //var to save the new group name
  var groupName;

  //list of the new group's members
  List groupMembers = new List();

  Widget _createNewGroupAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.black,),
        onPressed: (){
          setState(() {
            creatingGroup = false;
          });
        },
      ),
      title: Text('Create a New Secure Group', style:
      TextStyle(
          color: Colors.deepPurpleAccent
      ),
      ),
    );
  }

  Widget _createNewGroup() {

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Enter Group Name'),
                        validator: (String value){
                          if(value.isEmpty){
                            return 'Group Name is required';
                          }
                          return null;
                        },
                        onSaved:(String value) {
                          groupName = value;
                        }
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            creatingGroup = false;
                            addingMembersNewGroup = true;
                          });
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _enterMembersAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.black,),
        onPressed: (){
          setState(() {
            addingMembersNewGroup = false;
          });
        },
      ),
      title: Text('Create a New Secure Group', style:
      TextStyle(
          color: Colors.deepPurpleAccent
      ),
      ),
    );
  }


  Widget _enterGroupMembers() {

    String newMember;

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    void createGroup(){
      groupIndex[index] = groupName;
      groupMembersList[index] = groupMembers;
      index++;
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Enter Member to Add'),
                        validator: (String value){
                          if(value.isEmpty){
                            return 'Member Email is Required';
                          } else if(!userMap.containsKey(value)) {
                            return 'User does not exit';
                          } else if(groupMembers.isNotEmpty && groupMembers.contains(value)) {
                            return 'This user is already a member of the group';
                          }
                          return null;
                        },
                        onSaved:(String value) {
                          newMember = value;
                        }
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          groupMembers.add(newMember);
                          setState(() {
                            addingMembersNewGroup = true;
                          });
                        }
                      },
                      child: Text('Next'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          groupMembers.add(newMember);
                          groupMembers.add(currentUser);
                          createGroup();
                          setState(() {
                            addingMembersNewGroup = false;
                          });
                          groupCreatedSuccessfully();
                        }
                      },
                      child: Text('Done'),
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }


  Future groupCreatedSuccessfully() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Group Created Successfully'),
          );
        }
    );
  }


  Widget _viewGroupsAppBar() {

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.deepOrangeAccent,
        size: 30),
        onPressed: (){
          setState(() {
            viewingGroup = false;
          });
        },
      ),
      title: Text('My Groups', style:
      TextStyle(
          color: Colors.deepPurpleAccent,
        fontSize: 30
      ),
      ),
    );

  }

  var currentGroup;
  var currentGroupIndex;


  Widget _viewMyGroups() {

    if(myGroups != null){
      return Scaffold(
        body: ListView.separated(
          padding: EdgeInsets.all(8),
          itemCount: myGroups.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                height: 150,
                width: 400,
                margin: EdgeInsets.only(top: 100),
                child: Center(
                    child: RaisedButton(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
                        onPressed: () {
                          currentGroup = myGroups[index];
                          currentGroupIndex = index;
                          setState(() {
                            viewingGroup = false;
                            viewingOneGroup = true;
                          });
                        },
                        child: Text(myGroups[index],
                            style: TextStyle(
                              fontSize: 30
                            ),
                        ),
                    )
                )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      );
    }

    return Scaffold(
        body: Center(
            child: Text(
              'You are not a member of any groups',
              style: TextStyle(
                  fontSize: 20
              ),
            )
        )
    );

  }



  Widget _groupActionsAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.black,),
        onPressed: (){
          setState(() {
            viewingOneGroup = false;
            viewingGroup = true;
          });
        },
      ),
      title: Text(currentGroup,
        style: TextStyle(
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  Widget _groupActions() {



    void deleteGroup () {
      for (int i = currentGroupIndex; i < groupIndex.length; i++) {
        groupIndex[currentGroupIndex] = groupIndex[currentGroupIndex+1];
      }
      groupMembersList.removeAt(currentGroupIndex);
      postsMap.removeWhere((key, value) => value == currentGroupIndex);
      myGroups = findMyGroups();
    }

    Future<void> _sureToDelete() async {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: new Text("Are you sure you want to delete " + groupIndex[currentGroupIndex] + "?"),
              content:  new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text('A deleted group cannot be recovered'),
                  ],
                ),
              ),
              actions: [
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteGroup();
                      groupDeleted();
                      setState(() {
                        viewingOneGroup = false;
                        viewingGroup = true;
                      });
                    },
                    child: Text("Yes")
                ),
                new FlatButton(
                    onPressed: () {
                      setState(() {
                        viewingOneGroup = true;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("No"))
              ],
            );
          }
      );
    }
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 60, bottom: 60),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 60, bottom: 20),
            child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'btn3',
                    tooltip: 'Add Member to Group',
                    backgroundColor: Colors.deepOrangeAccent,
                    onPressed: () {
                      setState(() {
                        viewingOneGroup = false;
                        addingMembersExistingGroup = true;
                      });
                    },
                    child: Icon(Icons.add),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 70),
                    child: Text(
                      'Add Member to Group',
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn4',
                    tooltip: 'Remove Member from Group',
                    backgroundColor: Colors.deepOrangeAccent,
                    onPressed: () {
                      setState(() {
                        viewingOneGroup = false;
                        removingMembers = true;
                      });
                    },
                    child: Icon(Icons.remove),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 70),
                    child: Text(
                      'Remove Member from Group',
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn5',
                    tooltip: 'Delete Group',
                    backgroundColor: Colors.deepOrangeAccent,
                    onPressed: () {
                      _sureToDelete();
                    },
                    child: Icon(Icons.delete_forever),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Text(
                      'Delete Group',
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                  )
                ]
            ),
          ),
        ],
      ),
    );
  }


  Widget _addMembersExistingGroupAppBar(){

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.black,),
        onPressed: (){
          setState(() {
            addingMembersExistingGroup = false;
            viewingOneGroup = true;
          });
        },
      ),
      title: Text("Add members to " + currentGroup,
        style: TextStyle(
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  Widget _addMembersExistingGroup() {

    String newMember;
    var memberList = groupMembersList[currentGroupIndex];

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    void saveNewMembers() {
      groupMembersList[currentGroupIndex] = memberList;
    }


    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Enter Member to Add'),
                        validator: (String value){
                          if(value.isEmpty){
                            return 'Member Email is Required';
                          } else if(!userMap.containsKey(value)) {
                            return 'User does not exit';
                          } else if(groupMembers.isNotEmpty && groupMembers.contains(value)) {
                            return 'This user is already a member of the group';
                          }
                          return null;
                        },
                        onSaved:(String value) {
                          newMember = value;
                        }
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          memberList.add(newMember);
                          setState(() {
                            addingMembersExistingGroup = true;
                          });
                        }
                      },
                      child: Text('Next'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          memberList.add(newMember);
                          saveNewMembers();
                          membersAddedSuccessfully();
                          setState(() {
                            addingMembersExistingGroup = false;
                          });
                        }
                      },
                      child: Text('Done'),
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  Future membersAddedSuccessfully() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('New Members Added Successfully'),
          );
        }
    );
  }

  Widget _removeMembersGroupAppBar(){

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.black,),
        onPressed: (){
          setState(() {
            removingMembers = false;
            viewingOneGroup = true;
          });
        },
      ),
      title: Text("Remove members from " + currentGroup,
        style: TextStyle(
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  Widget _removeMembersGroup() {

    String memberToRemove;
    var memberList = groupMembersList[currentGroupIndex];

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    void saveNewMembers() {
      groupMembersList[currentGroupIndex] = memberList;
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Enter Member to Remove'),
                        validator: (String value){
                          if(value.isEmpty){
                            return 'Member Email is Required';
                          } else if(!userMap.containsKey(value)) {
                            return 'User does not exit';
                          } else if(groupMembers.isNotEmpty && !groupMembers.contains(value)) {
                            return 'This user is not a member of the group';
                          }
                          return null;
                        },
                        onSaved:(String value) {
                          memberToRemove = value;
                        }
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          memberList.remove(memberToRemove);
                          setState(() {
                            removingMembers = true;
                          });
                        }
                      },
                      child: Text('Next'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          memberList.remove(memberToRemove);
                          saveNewMembers();
                          setState(() {
                            removingMembers = false;
                          });
                          membersRemovedSuccessfully();
                        }
                      },
                      child: Text('Done'),
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  Future groupDeleted() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Group Deleted Successfully'),
        );
      }
    );
  }

  Future membersRemovedSuccessfully() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Removed Members Successfully'),
          );
        }
    );
  }
}

//function to find the groups that user is a member of
List findMyGroups(){
  var myGroups = new List();
  for (int i = 0; i < groupMembersList.length; i++) {
    var group = groupMembersList[i];
    bool inGroup = group.contains(currentUser);
    if (inGroup) {
      myGroups.add(groupIndex[i]);
    }
  }
  print(myGroups);
  return myGroups;
}

