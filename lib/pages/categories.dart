import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/models/blog.dart';
import 'package:admin/models/category.dart';
import 'package:admin/pages/comments.dart';
import 'package:admin/pages/update_blog.dart';
import 'package:admin/utils/cached_image.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/next_screen.dart';
import 'package:admin/utils/toast.dart';
import 'package:admin/widgets/blog_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController controller;
  DocumentSnapshot _lastVisible;
  bool _isLoading;
  List<DocumentSnapshot> _snap = new List<DocumentSnapshot>();
  List<Category> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String collectionName = 'categories';

  @override
  void initState() {
    controller = new ScrollController()
      ..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection(collectionName)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection(collectionName)
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible['timestamp']])
          .limit(10)
          .get();

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Category.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      openToast(context, 'No more content available');
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }


  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  reloadData() {
    setState(() {
      _snap.clear();
      _data.clear();
      _lastVisible = null;
    });
    _getData();
  }

  Future handleDelete(timestamp) async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text('Borrar?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              SizedBox(
                height: 10,
              ),
              Text('Quieres borrar este archivo de la base de datos?',
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: Colors.redAccent,
                        child: Text(
                          'Sí',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          if (ab.userType == 'tester') {
                            Navigator.pop(context);
                            openDialog(context, 'Eres un Tester',
                                'Solo los admin pueden borrar contenido');
                          } else {
                            await ab.deleteContent(timestamp, 'categories')
                                .then((value) =>
                                ab.decreaseCount('categories_count'))
                                .then((value) =>
                                openToast1(
                                    context, 'Archivo borrado exitosamente!'));
                            reloadData();
                            Navigator.pop(context);
                          }
                        },
                      ),
                      SizedBox(width: 10),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: Colors.deepPurpleAccent,
                        child: Text(
                          'No',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Categorias',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 10),
          height: 3,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.circular(15)),
        ),

        Expanded(
          child: RefreshIndicator(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _data.length + 1,
              itemBuilder: (_, int index) {
                if (index < _data.length) {
                  return dataList(_data[index]);
                }
                return Center(
                  child: new Opacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    child: new SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: new CircularProgressIndicator()),
                  ),
                );
              },
            ),
            onRefresh: () async {
              reloadData();
            },
          ),
        ),
      ],
    );
  }

  Widget dataList(Category d) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(top: 5, bottom: 5),
      height: 150,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: <Widget>[
        Container(
        height: 130,
        width: 130,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: CustomCacheImage(imageUrl: d.imageUrl, radius: 10,),
      ),
      Flexible(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 15,
            left: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                d.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.access_time, size: 15, color: Colors.grey),
                  SizedBox(width: 3),

                  Text(
                    d.date,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(width: 10),
              InkWell(
                child: Container(
                    height: 35,
                    width: 45,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.delete,
                        size: 16, color: Colors.grey[800])),
                onTap: () {
                  handleDelete(d.timestamp);
                },
              ),
            ],
          ),
        ),
      ),
      ],
    )
    ,
    );
  }
}
