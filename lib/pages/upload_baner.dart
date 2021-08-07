
import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/blog_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UploadBanner extends StatefulWidget {
  UploadBanner({Key key}) : super(key: key);

  @override
  _UploadBannerState createState() => _UploadBannerState();
}

class _UploadBannerState extends State<UploadBanner> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var sourceCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();


  bool notifyUsers = true;
  bool uploadStarted = false;
  String _timestamp;
  String _date;
  var _bannerData;




  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'Eres un Tester', 'Solo los admin pueden subir, borrar y modificar contenido');
      } else {
        setState(()=> uploadStarted = true);
        await getDate().then((_) async{
          await saveToDatabase()
              .then((value) => context.read<AdminBloc>().increaseCount('banner_count'));
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
    final DocumentReference ref = firestore.collection('banner').doc(_timestamp);
    _bannerData = {
      'title' : titleCtrl.text,
      'description' : descriptionCtrl.text,
      'image url' : imageUrlCtrl.text,
      'loves' : 0,
      'source' : sourceCtrl.text,
      'date': _date,
      'timestamp' : _timestamp

    };
    await ref.set(_bannerData);
  }


  clearTextFeilds() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
    sourceCtrl.clear();
    FocusScope.of(context).unfocus();
  }




  handlePreview() async{
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      await getDate().then((_) async{
        await showBlogPreview(context, titleCtrl.text, descriptionCtrl.text, imageUrlCtrl.text, 0, sourceCtrl.text, 'Now');

      });
    }
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
                'Detalles del Banner',
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


              TextFormField(
                decoration: inputDecoration('Ingrese Source Url', 'Source Url', sourceCtrl),
                controller: sourceCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'El valor está vacío';
                  return null;
                },
              ),


              SizedBox(height: 20,),


              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Ingrese la descripción (Html o Texto)',
                    border: OutlineInputBorder(),
                    labelText: 'Descripción',
                    contentPadding: EdgeInsets.only(
                        right: 0, left: 10, top: 15, bottom: 5),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                            icon: Icon(Icons.close, size: 15),
                            onPressed: () {
                              descriptionCtrl.clear();
                            }),
                      ),
                    )),
                textAlignVertical: TextAlignVertical.top,
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: descriptionCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'El valor está vacío';
                  return null;
                },

              ),

              SizedBox(height: 100,),


              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  FlatButton.icon(

                      icon: Icon(Icons.remove_red_eye, size: 25, color: Colors.blueAccent,),
                      label: Text('Vista previa', style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black
                      ),),
                      onPressed: (){
                        handlePreview();
                      }
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  color: Colors.deepPurpleAccent,
                  height: 45,
                  child: uploadStarted == true
                      ? Center(child: Container(height: 30, width: 30,child: CircularProgressIndicator()),)
                      : FlatButton(
                      child: Text(
                        'Subir Banner',
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
