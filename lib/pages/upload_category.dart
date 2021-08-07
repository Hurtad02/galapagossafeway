
import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UploadCategory extends StatefulWidget {
  UploadCategory({Key key}) : super(key: key);

  @override
  _UploadCategoryState createState() => _UploadCategoryState();
}

class _UploadCategoryState extends State<UploadCategory> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();


  bool notifyUsers = true;
  bool uploadStarted = false;
  String _timestamp;
  String _date;
  var _categoryData;




  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'Eres un Tester', 'Solo el admin puede subir, borrar y modificar contenido');
      } else {
        setState(()=> uploadStarted = true);
        await getDate().then((_) async{
          await saveToDatabase()
              .then((value) => context.read<AdminBloc>().increaseCount('categories_count'));
          setState(()=> uploadStarted = false);
          openDialog(context, 'Subido exitosamente', '');
          clearTextFeilds();
        });
      }
    }

  }







  Future getDate() async {
    DateTime now = DateTime.now();
    String _d = DateFormat('dd MMMM yy').format(now);
    String _t = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      _timestamp = _t;
      _date = _d;
    });

  }



  Future saveToDatabase() async {
    final DocumentReference ref = firestore.collection('categories').doc(_timestamp);
    _categoryData = {
      'name' : titleCtrl.text,
      'image' : imageUrlCtrl.text,
      'date': _date,
      'timestamp' : _timestamp

    };
    await ref.set(_categoryData);
  }


  clearTextFeilds() {
    titleCtrl.clear();
    imageUrlCtrl.clear();
    FocusScope.of(context).unfocus();
  }



  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: h * 0.10,
              ),
              Text(
                'Detalles de categoría',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),

              SizedBox(height: 20,),

              TextFormField(
                decoration: inputDecoration('Ingrese el Título', 'Título', titleCtrl),
                controller: titleCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'El valor está vacío';
                  return null;
                },

              ),
              SizedBox(height: 20,),


              TextFormField(
                decoration: inputDecoration('Ingrese Image Url', 'Image', imageUrlCtrl),
                controller: imageUrlCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'El valor está vacío';
                  return null;
                },

              ),


              SizedBox(height: 20,),

              Container(
                  color: Colors.deepPurpleAccent,
                  height: 45,
                  child: uploadStarted == true
                      ? Center(child: Container(height: 30, width: 30,child: CircularProgressIndicator()),)
                      : FlatButton(
                      child: Text(
                        'Subir Categoría',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async{
                        handleSubmit();

                      })

              ),
              SizedBox(
                height: 200,
              ),
            ],
          )),

    );
  }

}
