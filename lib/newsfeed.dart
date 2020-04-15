import 'package:flutter/material.dart';
import 'package:secure_social_media/main.dart';
import 'settings.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Newsfeed extends StatefulWidget {
  Newsfeed({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewsfeedState createState() => _NewsfeedState();
}

//map of all posts in the map where Key<String> = post  and Value<Int> is the index of group
var postsMap = new Map();

//list of posts converted from map
var postList = [];

//list of indices of posts converted from map
var indexList = [];

//Current users list of groups
List myGroupsNews;


bool pickingGroup = false;
bool posting = false;

class _NewsfeedState extends State<Newsfeed> {

  Settings settings = new Settings();

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: pickingGroup? _whichGroupToPostAppBar() : posting ? _createPostAppBar(currentGroup) :
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: new IconButton(
            icon: new Icon(
              Icons.settings,
              color: Colors.deepPurpleAccent,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => settings));
            }
        ),
        title: Text('Comhrá',
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 30
          ),
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.add,
              color: Colors.deepPurpleAccent,
              size: 30.0,
            ),
            onPressed: () {
              myGroupsNews = findMyGroups();
              setState(() {
                pickingGroup = true;
              });

            },
          ),
        ],
      ),
      body: pickingGroup ? _whichGroupToPost() : posting? _createPost() :
      ListView.separated(
        padding: EdgeInsets.all(8),
        itemCount: postList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(top: 50),
            child: AspectRatio(
              aspectRatio: 6/3,
              child: Card(
                elevation: 2,
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: <Widget> [
                      _post(postList[index]),
                      Divider(color: Colors.grey),
                      _postedInGroup(groupIndex[indexList[index]]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  Widget _post(String postText) {

    return Expanded(
      flex: 3,
      child: Row(
        children: <Widget> [
          _postContent(postText)
        ]
      )
    );
}

  Widget _postContent(String postText) {

    return Expanded(
      flex: 4,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text(postText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20
                  ),
                )
              ]
          ),
        ),
    );
  }

  Widget _postedInGroup(String group) {

    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("From " + group,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ],
        )
      ),
    );
  }

  Widget _whichGroupToPostAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.deepOrangeAccent,
        size: 40),
        onPressed: () {
          setState(() {
            pickingGroup = false;
          });
        },
      ),
      title: Text("Select a Group to Post in",
        style: TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 22
        ),
      ),
    );
  }

  var currentGroup;
  var currentGroupIndex;

  Widget _whichGroupToPost() {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 20, left: 20),
        child: ListView.separated(
          padding: EdgeInsets.all(8),
          itemCount: myGroupsNews.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                height: 150,
                width: 400,
                margin: EdgeInsets.only(top: 100),
                child: Center(
                    child: RaisedButton(
                      padding: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
                      onPressed: () {
                        currentGroup = myGroupsNews[index];
                        currentGroupIndex = index;
                        setState(() {
                          pickingGroup = false;
                          posting = true;
                        });
                      },
                      child: Text(myGroupsNews[index],
                        style: TextStyle(
                            fontSize: 30
                        ),
                      ),
                    )
                )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        )
      )
    );
  }

  Widget _createPostAppBar(String currentGroup) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.navigate_before, color: Colors.deepOrangeAccent,),
        onPressed: () {
          setState(() {
            pickingGroup = true;
            posting = false;
          });
        },
      ),
      title: Text("New Post in " + currentGroup,
        style: TextStyle(
          color: Colors.deepPurpleAccent
        ),
      ),
    );
  }

  var post;

  Widget _createPost() {

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "What do you have to say?"
                    ),
                    maxLines: null,
                    validator: (String value) {
                      if(value.isEmpty) {
                        return "You have to post something!";
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      post = value;
                    },
                  ),
                  RaisedButton(
                    onPressed: () {
                      if(_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        indexList.insert(0, currentGroupIndex);
                        postList.insert(0, post);
                        postsMap[post] = currentGroupIndex;
                        setState(() {
                          posting = false;
                        });
                        postedSuccessfully();
                      }

                    },
                    child: Text("Post")
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future postedSuccessfully() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Success!'),
          );
        }
    );
  }

}





//convert map of posts to a list containing the post strings
//and a list containing the group indices
void mapToList() {
  postsMap.forEach((k, v) => postList.add(k));
  postsMap.forEach((k, v) => indexList.add(v));


  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  //iterate through the post lists to check if the currently logged in user
  //is a member of the group the post was posted in
  //if they are not the post string is encrypted for the user


  for (int i  = 0; i < postList.length; i++) {
    index = indexList[i];
    if (!groupMembersList[index].contains(currentUser)) {
        var encryptedString = encrypter.encrypt(postList[i], iv: iv);
        postList[i] = encryptedString.base64;
    }
  }
}

