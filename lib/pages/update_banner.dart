import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/models/banner_model.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:admin/widgets/banner_preview.dart';
import 'package:admin/widgets/cover_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateBanner extends StatefulWidget {
  final Banners bannerData;
  UpdateBanner({Key key, @required this.bannerData}) : super(key: key);

  @override
  _UpdateBannerState createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var sourceCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();


  //bool notifyUsers = true;
  bool uploadStarted = false;




  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'Eres un Tester', 'Solo los admin pueden cargar, modificar o borrar contenido');
      } else {
        setState(()=> uploadStarted = true);
        await updateDatabase();
        setState(()=> uploadStarted = false);
        openDialog(context, 'Actualizado exitosamente', '');
      }
    }

  }







  Future updateDatabase() async {
    final DocumentReference ref = firestore.collection('banner').doc(widget.bannerData.timestamp);
    var _bannerData = {
      'title' : titleCtrl.text,
      'description' : descriptionCtrl.text,
      'image url' : imageUrlCtrl.text,
      'source' : sourceCtrl.text,

    };
    await ref.update(_bannerData);
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
      await showBannerPreview(context, titleCtrl.text, descriptionCtrl.text, imageUrlCtrl.text, sourceCtrl.text, widget.bannerData.date);
    }
  }


  initBannersData (){
    Banners d = widget.bannerData;
    titleCtrl.text = d.title;
    descriptionCtrl.text = d.description;
    imageUrlCtrl.text = d.thumbnailImagelUrl;
    sourceCtrl.text = d.sourceUrl;
  }



  @override
  void initState() {
    super.initState();
    initBannersData();
  }




  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(),
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        body: CoverWidget(widget: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: h * 0.10,
                ),
                Text(
                  'Actualizar detalles del Banner',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),

                SizedBox(height: 50,),

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
                      hintText: 'Ingrese descripción (Html o Texto)',
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
                        label: Text('Preview', style: TextStyle(
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
                          'Actualizar Banner',
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
            )),)

    );
  }








}
